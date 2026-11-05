import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../device_manager/urls.dart';
import '../../../utils/Store/HiveStore.dart';

/// Singleton WebSocket manager for Chat. Handles connecting, 30s ping
/// heartbeats, sending messages over socket, receiving realtime messages, and
/// auto-reconnecting on drop. Never throws.
class ChatWebSocketService {
  ChatWebSocketService._();

  static final ChatWebSocketService instance = ChatWebSocketService._();

  WebSocket? _socket;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  bool _isConnecting = false;
  bool _isConnected = false;

  /// Guards against overlapping reconnects (see [reconnect]).
  bool _isReconnecting = false;

  bool get isConnected => _isConnected;

  /// When the current socket opened. Null while disconnected. Used to decide
  /// whether a conversation created after this moment needs a re-sync.
  DateTime? _connectedAt;

  DateTime? get connectedAt => _connectedAt;

  /// Conversations the current socket session is known to be aware of. The
  /// server re-syncs its conversation set on (re)connect, so this set is
  /// cleared on every (re)connect and rebuilt as callers confirm ids.
  final Set<String> _knownConversationIds = <String>{};

  bool isConversationKnown(String id) => _knownConversationIds.contains(id);

  void markConversationKnown(String id) {
    if (id.isNotEmpty) _knownConversationIds.add(id);
  }

  final StreamController<Map<String, dynamic>> _incomingMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Broadcast stream of incoming realtime message events (`type: new_message`).
  Stream<Map<String, dynamic>> get onNewMessage =>
      _incomingMessageController.stream;

  /// Connects to the chat WebSocket server using the stored access token.
  /// Safe to call multiple times (no-op if already connected/connecting).
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    final String token = _getToken();
    if (token.isEmpty) {
      debugPrint('ChatWebSocketService: No access token available to connect.');
      return;
    }

    _isConnecting = true;
    final String wsUrl = Urls.wsChatUrl(token);

    try {
      debugPrint('ChatWebSocketService: Connecting to chat socket');
      _socket = await WebSocket.connect(wsUrl);
      _isConnected = true;
      _isConnecting = false;
      _connectedAt = DateTime.now();
      // The server re-syncs its conversation set on (re)connect, so any
      // client-side knowledge from the previous session is stale.
      _knownConversationIds.clear();
      debugPrint('ChatWebSocketService: Connected successfully.');

      _startPingTimer();
      _listenToSocket();
    } catch (e) {
      debugPrint('ChatWebSocketService: Connection failed: $e');
      _isConnected = false;
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Cleanly drops the current socket and opens a fresh one so the server
  /// re-syncs its conversation set (the fix for conversations created after
  /// the socket connected, which the live session does not know about —
  /// there is no join/subscribe frame). No-op reentry is guarded by
  /// [_isReconnecting]; overlapping connects are guarded by [_isConnecting].
  /// Awaits until connected (or a short timeout) so callers can proceed.
  Future<void> reconnect() async {
    if (_isReconnecting) return;
    _isReconnecting = true;
    try {
      // Tear down the current socket WITHOUT scheduling the 5s auto-reconnect,
      // then reconnect immediately below.
      _reconnectTimer?.cancel();
      _pingTimer?.cancel();
      await _subscription?.cancel();
      _subscription = null;
      try {
        await _socket?.close();
      } catch (_) {}
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      _connectedAt = null;

      await connect();
      // connect() returns after the socket resolves; _isConnected reflects it.
    } finally {
      _isReconnecting = false;
    }
  }

  /// Resyncs the socket's conversation set by reconnecting. Alias for
  /// [reconnect] kept for call-site readability.
  Future<void> resyncConversations() => reconnect();

  /// Ensures the socket is connected, returning true once [_isConnected] or
  /// false if [timeout] elapses first. Does not force a reconnect of an
  /// already-open socket (use [reconnect] for that).
  Future<bool> ensureConnected({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (_isConnected) return true;
    if (!_isConnecting) {
      // Fire a connect; poll below until it resolves.
      // ignore: unawaited_futures
      connect();
    }
    final Duration slice = const Duration(milliseconds: 100);
    Duration waited = Duration.zero;
    while (!_isConnected && waited < timeout) {
      await Future<void>.delayed(slice);
      waited += slice;
    }
    return _isConnected;
  }

  /// Sends a message over the active WebSocket connection. Returns true if the
  /// payload was sent over the socket.
  bool sendMessage({
    required String conversationId,
    required String content,
  }) {
    if (!_isConnected || _socket == null) {
      debugPrint('ChatWebSocketService: Cannot send message, socket not connected.');
      return false;
    }

    try {
      final payload = jsonEncode(<String, dynamic>{
        'type': 'send_message',
        'conversation_id': conversationId,
        'content': content,
      });
      _socket?.add(payload);
      debugPrint('ChatWebSocketService: Message sent over socket -> $payload');
      return true;
    } catch (e) {
      debugPrint('ChatWebSocketService: Send message error: $e');
      return false;
    }
  }

  /// Acknowledges that an incoming message reached this device. Sends
  /// `{"type":"ack_delivery","message_id":id}` over the active socket. No-op
  /// (with a debug log) when the socket is not connected or [messageId] is
  /// empty. Never throws and never logs the token.
  void ackDelivery(String messageId) =>
      _sendAck('ack_delivery', messageId);

  /// Acknowledges that the recipient is looking at the conversation. Sends
  /// `{"type":"ack_read","message_id":id}` over the active socket. Same
  /// no-op/guard behavior as [ackDelivery].
  void ackRead(String messageId) => _sendAck('ack_read', messageId);

  /// Shared writer for the `ack_delivery` / `ack_read` frames.
  void _sendAck(String type, String messageId) {
    if (messageId.isEmpty) return;
    if (!_isConnected || _socket == null) {
      debugPrint('ChatWebSocketService: Not connected, skipping $type.');
      return;
    }
    try {
      final payload = jsonEncode(<String, dynamic>{
        'type': type,
        'message_id': messageId,
      });
      _socket?.add(payload);
      debugPrint('ChatWebSocketService: Sent $type over socket -> $payload');
    } catch (e) {
      debugPrint('ChatWebSocketService: $type error: $e');
    }
  }

  void _listenToSocket() {
    _subscription?.cancel();
    _subscription = _socket?.listen(
      (event) {
        if (event is String) {
          _handleIncomingData(event);
        }
      },
      onError: (error) {
        debugPrint('ChatWebSocketService: Socket error: $error');
        _handleDisconnect();
      },
      onDone: () {
        debugPrint('ChatWebSocketService: Socket closed by server.');
        _handleDisconnect();
      },
      cancelOnError: true,
    );
  }

  void _handleIncomingData(String rawJson) {
    debugPrint('ChatWebSocketService: RAW INCOMING FRAME -> $rawJson');
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type']?.toString();
        debugPrint('ChatWebSocketService: Received event type -> $type');

        if (type == 'pong') {
          debugPrint('ChatWebSocketService: Received pong from server.');
        } else {
          // Broadcast message and chat events to subscribers
          _incomingMessageController.add(decoded);
        }
      }
    } catch (e) {
      debugPrint('ChatWebSocketService: Error parsing incoming socket frame: $e');
    }
  }

  /// 30-second ping timer to keep the WebSocket connection alive.
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _socket != null) {
        try {
          _socket?.add(jsonEncode(<String, dynamic>{'type': 'ping'}));
          debugPrint('ChatWebSocketService: Sent ping to keep connection alive.');
        } catch (e) {
          debugPrint('ChatWebSocketService: Ping failed: $e');
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectedAt = null;
    _pingTimer?.cancel();
    _subscription?.cancel();
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isConnecting) {
        debugPrint('ChatWebSocketService: Attempting auto-reconnect...');
        connect();
      }
    });
  }

  /// Closes the WebSocket connection and resets timers.
  void disconnect() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _subscription?.cancel();
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _isConnected = false;
    _isConnecting = false;
    _connectedAt = null;
    _knownConversationIds.clear();
    debugPrint('ChatWebSocketService: Disconnected and cleaned up.');
  }

  String _getToken() {
    try {
      final dynamic token = HiveStore.defBox.get(Keys.ACCESSTOKEN);
      return token is String ? token.trim() : '';
    } catch (_) {
      return '';
    }
  }
}

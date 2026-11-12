import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/Store/HiveStore.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../routes/routes.dart';
import '../../home/controller/blocked_controller.dart';
import '../../home/controller/conversations_controller.dart';
import '../../home/controller/friends_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/friend.dart';
import '../../home/model/member.dart';
import '../../home/services/block_services.dart';
import '../model/chat_message.dart';
import '../model/conversation_model.dart';
import '../services/chat_websocket_service.dart';
import '../services/conversation_services.dart';
import '../views/widgets/report_user_sheet.dart';

/// Drives the 1:1 chat screen. The peer ([FriendUser]) is passed via
/// [Get.arguments]. Uses DEMO data until the chat APIs/socket are provided —
/// every spot that needs a real call is marked `// TODO(api)`.
class ChatController extends GetxController {
  /// Server conversation id; null on the demo (plain FriendUser) path.
  /// TODO(api): GET/POST conversations/{conversationId}/messages
  String? conversationId;

  /// The friend I'm chatting with; null when the route argument is missing.
  final Rxn<FriendUser> peer = Rxn<FriendUser>();

  /// Messages stored oldest → newest (the list view renders reversed). The
  /// API returns newest first, so pages are reversed before insertion.
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  final RxBool isLoading = false.obs;

  /// True when the FIRST history page failed (drives the inline retry row
  /// instead of the "Say hi" empty state).
  final RxBool loadFailed = false.obs;

  /// Older page in flight (small spinner at the top of the list).
  final RxBool isLoadingMore = false.obs;

  /// An older page failed; shows a retry row at the top (no auto-retry loop).
  final RxBool loadMoreFailed = false.obs;

  static const int _pageSize = 50;

  /// Raw server rows consumed so far (offset of the next older page).
  int _offset = 0;
  bool _hasMore = false;

  /// Peer "typing…" indicator. TODO(api): drive from the realtime socket.
  final RxBool peerTyping = false.obs;

  /// Mirrors the composer text so the send button can react via Obx.
  final RxString draft = ''.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode inputFocus = FocusNode();

  /// Two messages from the same sender within this window are grouped.
  static const Duration _groupWindow = Duration(minutes: 5);

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  StreamSubscription? _socketSubscription;

  /// True while THIS chat screen is open (the controller is route-scoped via
  /// ChatBinding, so controller-alive == screen-open). Drives whether an
  /// incoming `new_message` also gets `ack_read`. We deliberately do NOT add a
  /// WidgetsBindingObserver app-background handler (the task marks it
  /// OPTIONAL): it adds lifecycle complexity for a marginal gain. Tradeoff: if
  /// the user backgrounds the app while this chat is on top, an incoming
  /// message is still read-acked. Acceptable for v1.
  bool isScreenActive = false;

  /// Message ids already read-acked this session, so we never re-ack the same
  /// id (history load + live arrival both route through [_sendReadAck]).
  final Set<String> _ackedRead = <String>{};

  @override
  void onInit() {
    super.onInit();

    // Step 2: Connect to WebSocket after login / opening chat
    ChatWebSocketService.instance.connect();
    _socketSubscription = ChatWebSocketService.instance.onNewMessage.listen(_onIncomingSocketData);
    isScreenActive = true;

    final arg = Get.arguments;
    if (arg is ChatArgs) {
      // Real conversation from POST conversations: header uses `other_user`.
      conversationId = arg.conversation.id;
      peer.value = arg.conversation.otherUser;
      // If this conversation is newer than the current socket session, the
      // live session does not know it (no join frame) and realtime receive /
      // any residual socket send would miss it. Reconnect ONCE to let the
      // server re-sync. Fire-and-forget so screen build / history load are not
      // delayed. Anti-thrash: guarded by _knownConversationIds + createdAt.
      unawaited(_ensureSocketKnowsConversation(arg.conversation));
      // Real conversations never show fabricated demo messages. History is
      // fetched only when the conversation already has messages; a brand-new
      // one (hasNoMessages) starts empty without a request.
      scrollController.addListener(_onScroll);
      if (!arg.conversation.hasNoMessages) loadMessages();
    } else if (arg is FriendUser) {
      // Demo / unknown-conversation path (no conversationId).
      peer.value = arg;
      loadHistory();
    }
  }

  /// Step 4: Handles incoming realtime messages from WebSocket (`type: new_message`).
  void _onIncomingSocketData(Map<String, dynamic> eventData) {
    if (isClosed) return;
    try {
      debugPrint('ChatController: Realtime socket event received -> $eventData');

      final String type = eventData['type']?.toString() ?? '';

      // Error frame, e.g. {"type":"error","code":"not_found",...}. Never parse
      // it as a message. Match the active conversation by conversation_id when
      // present; `not_found` carries none, so treat a bare error as a failure
      // of the most recent in-flight optimistic message. (FIX-2 is HTTP-primary
      // so in normal operation nothing is in flight here; this is the safety
      // net that keeps a bubble from showing `sent` after a server rejection.)
      if (type == 'error') {
        final String errConvId = eventData['conversation_id']?.toString() ?? '';
        final String activeId = conversationId ?? '';
        if (errConvId.isNotEmpty &&
            activeId.isNotEmpty &&
            errConvId != activeId) {
          return; // error for a different conversation
        }
        debugPrint(
            'ChatController: socket error frame -> ${eventData['code']}: ${eventData['message']}');
        _failLatestPending();
        return;
      }

      // Status-receipt frames for MY messages. They carry a `message_id` (and
      // optionally `conversation_id`); match purely by id and never fall
      // through to new_message parsing. Each branch returns early.
      if (type == 'message_delivered' ||
          type == 'message_read' ||
          type == 'message_sent') {
        final String statusId = (eventData['message_id'] ??
                    eventData['id'] ??
                    (eventData['message'] is Map
                        ? (eventData['message'] as Map)['id']
                        : null))
                ?.toString() ??
            '';
        final String statusConvId =
            eventData['conversation_id']?.toString() ?? '';
        final MessageStatus target = type == 'message_read'
            ? MessageStatus.read
            : (type == 'message_delivered'
                ? MessageStatus.delivered
                : MessageStatus.sent);
        _applyStatusUpgrade(statusId, target, convId: statusConvId);
        return;
      }

      // Realtime new_message frames carry the message in a nested `message`
      // sub-object: {"type":"new_message","message":{...}}. Parse ONLY that.
      final Map<String, dynamic> msgJson = eventData['message'] is Map
          ? Map<String, dynamic>.from(eventData['message'] as Map)
          : (eventData['data'] is Map
              ? Map<String, dynamic>.from(eventData['data'] as Map)
              : Map<String, dynamic>.from(eventData));

      final String eventConvId =
          (msgJson['conversation_id'] ?? eventData['conversation_id'])?.toString() ?? '';
      final String activeConvId = conversationId ?? '';

      if (activeConvId.isNotEmpty &&
          eventConvId.isNotEmpty &&
          eventConvId != activeConvId) {
        debugPrint(
            'ChatController: Ignoring event for different conv $eventConvId vs $activeConvId');
        return;
      }

      final me = currentUserId();
      final peerId = peer.value?.id ?? '';
      final ChatMessage? incoming = ChatMessage.fromApiJson(
        msgJson,
        isMine: (json) {
          final String sId =
              (json['sender_id'] ?? json['user_id'] ?? json['sender']?['id'])
                      ?.toString() ??
                  '';
          return resolveIsMine(
            senderId: sId,
            currentUserId: me,
            peerId: peerId,
          );
        },
      );

      if (incoming != null && incoming.text.isNotEmpty) {
        final existingIndex = messages.indexWhere((m) => m.id == incoming.id);
        if (existingIndex != -1) {
          messages[existingIndex] = incoming;
        } else if (incoming.isMine) {
          // If it's my own message echoing back from the server, replace the pending
          // local optimistic message (id starts with 'local-') with the server message.
          final localIndex = messages.indexWhere(
            (m) => isLocalId(m.id) && m.text.trim() == incoming.text.trim(),
          );
          if (localIndex != -1) {
            messages[localIndex] = incoming;
          } else {
            messages.add(incoming);
          }
        } else {
          messages.add(incoming);
        }
        _scrollToBottom();

        // Recipient's responsibility: ack a message from the OTHER user the
        // moment it arrives. Always ack delivery; also ack read when this
        // chat is the active, matching conversation. Skipped on the demo
        // (no-conversationId) path by _canAck.
        if (!incoming.isMine && _canAck(eventConvId)) {
          ChatWebSocketService.instance.ackDelivery(incoming.id);
          if (isScreenActive) _sendReadAck(incoming.id);
        }
      }
    } catch (e) {
      debugPrint('ChatController: Socket message parsing error: $e');
    }
  }

  /// Whether acks may be emitted for an event: there must be a real
  /// conversation (demo FriendUser path has none), and when the frame carries
  /// a conversation_id it must match the active conversation.
  bool _canAck(String eventConvId) {
    final String activeConvId = conversationId ?? '';
    if (activeConvId.isEmpty) return false;
    if (eventConvId.isNotEmpty && eventConvId != activeConvId) return false;
    return true;
  }

  /// Sends `ack_read` for [messageId] once per session (de-duped via
  /// [_ackedRead]). No-op on a repeat id.
  void _sendReadAck(String messageId) {
    if (messageId.isEmpty || !_ackedRead.add(messageId)) return;
    ChatWebSocketService.instance.ackRead(messageId);
  }

  /// Upgrades MY message [messageId] to [target] status (never downgrades,
  /// `failed` is terminal until retry). Ignores the frame when its [convId]
  /// is present and does not match the active conversation, or when the id is
  /// not in the current list. Mutates reactively.
  void _applyStatusUpgrade(
    String messageId,
    MessageStatus target, {
    String? convId,
  }) {
    if (messageId.isEmpty) return;
    final String activeConvId = conversationId ?? '';
    if (convId != null &&
        convId.isNotEmpty &&
        activeConvId.isNotEmpty &&
        convId != activeConvId) {
      return; // status frame for a different conversation
    }
    final int i = messages.indexWhere((m) => m.id == messageId);
    if (i == -1) return;
    final MessageStatus current = messages[i].status;
    // failed is terminal until the user retries; do not auto-advance it.
    if (current == MessageStatus.failed) return;
    if (target.index <= current.index) return; // never move backwards
    messages[i] = messages[i].copyWith(status: target);
  }

  /// Read-on-open: for every loaded message from the OTHER user that is not
  /// already read, send `ack_read` (de-duped). Only runs when the screen is
  /// active and there is a real conversation; local (un-posted) ids are
  /// skipped. Old history pages are already-read context for the recipient
  /// but the sender still needs them turned read, so this acks them too.
  void _ackReadForLoadedHistory() {
    if (!isScreenActive) return;
    final String id = conversationId ?? '';
    if (id.isEmpty) return;
    for (final m in messages) {
      if (!m.isMine &&
          m.status != MessageStatus.read &&
          !isLocalId(m.id)) {
        _sendReadAck(m.id);
      }
    }
  }

  /// If the socket session does not yet know [conversation] and the
  /// conversation was created after the socket connected, reconnect once so
  /// the server re-syncs. Reconnects at most once per conversation open
  /// (guarded by the service's known-conversation set).
  Future<void> _ensureSocketKnowsConversation(Conversation conversation) async {
    final String id = conversation.id;
    if (id.isEmpty) return;
    final ws = ChatWebSocketService.instance;
    if (ws.isConversationKnown(id)) return;

    final bool connected = await ws.ensureConnected();
    if (!connected || isClosed) return;

    final DateTime? createdAt = conversation.createdAt;
    final DateTime? connectedAt = ws.connectedAt;
    final bool newerThanSession = createdAt != null &&
        connectedAt != null &&
        createdAt.isAfter(connectedAt);

    if (newerThanSession) {
      await ws.reconnect().timeout(
            const Duration(seconds: 2),
            onTimeout: () {},
          );
    }
    // Mark known either way so we don't reconnect again for this id.
    ws.markConversationKnown(id);
  }

  /// Loads the conversation history.
  /// TODO(api): fetch chat history for peer.id (paginate older messages when
  /// the user scrolls to the top).
  Future<void> loadHistory() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // DEMO latency
      if (isClosed) return;
      messages.assignAll(_demoMessages());
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// The logged-in user's id: the saved Keys.USERID (login, or GET /users/me)
  /// or '' when unknown.
  static String currentUserId() {
    try {
      final dynamic v = HiveStore.defBox.get(Keys.USERID);
      return v is String ? v.trim() : '';
    } catch (_) {
      return '';
    }
  }

  /// LEFT/RIGHT rule. A known [currentUserId] always wins: mine iff
  /// sender == me. Last resort when it is unknown: anything not sent by the
  /// peer is mine.
  static bool resolveIsMine({
    required String senderId,
    required String currentUserId,
    required String peerId,
  }) {
    if (currentUserId.isNotEmpty) return senderId == currentUserId;
    if (peerId.isNotEmpty && senderId.isNotEmpty) return senderId != peerId;
    return false;
  }

  /// Loads the first (newest) history page; also used by the retry row.
  Future<void> loadMessages() async {
    final id = conversationId;
    if (id == null || id.isEmpty || isLoading.value) return;
    isLoading.value = true;
    loadFailed.value = false;
    try {
      final res = await _fetchPage(id, 0);
      if (isClosed) return;
      if (!res.success) {
        loadFailed.value = true;
        _toast("Couldn't load messages", res.message);
        return;
      }
      _offset = res.rawCount;
      _hasMore = res.rawCount > 0 && _offset < res.total;
      // Server order is newest first; the list wants oldest first.
      final history = res.items.reversed.toList();
      final ids = history.map((m) => m.id).toSet();
      // Keep anything sent locally before the page arrived (never in history).
      final locals = messages.where((m) => !ids.contains(m.id)).toList();
      messages.assignAll([...history, ...locals]);
      _ackReadForLoadedHistory();
    } finally {
      if (!isClosed) {
        isLoading.value = false;
        _fillIfShort();
      }
    }
  }

  /// Loads the next OLDER page and prepends it (de-duped by id).
  Future<void> loadOlder() async {
    final id = conversationId;
    if (id == null ||
        id.isEmpty ||
        !_hasMore ||
        isLoading.value ||
        isLoadingMore.value) {
      return;
    }
    isLoadingMore.value = true;
    loadMoreFailed.value = false;
    try {
      final res = await _fetchPage(id, _offset);
      if (isClosed) return;
      if (!res.success) {
        loadMoreFailed.value = true;
        _toast("Couldn't load older messages", res.message);
        return;
      }
      _offset += res.rawCount;
      _hasMore = res.rawCount > 0 && _offset < res.total;
      final existing = messages.map((m) => m.id).toSet();
      final older = res.items.reversed.where((m) => !existing.contains(m.id));
      // The list is reversed, so prepending extends the TOP; the pixel offset
      // is measured from the bottom, hence the scroll position stays put.
      messages.insertAll(0, older.toList());
      _ackReadForLoadedHistory();
    } finally {
      if (!isClosed) {
        isLoadingMore.value = false;
        _fillIfShort();
      }
    }
  }

  Future<MessageListResponse> _fetchPage(String id, int offset) {
    final me = currentUserId();
    final peerId = peer.value?.id ?? '';
    return ConversationService.instance.fetchMessages(
      id,
      limit: _pageSize,
      offset: offset,
      isMine: (json) => resolveIsMine(
        senderId: json['sender_id']?.toString() ?? '',
        currentUserId: me,
        peerId: peerId,
      ),
    );
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final p = scrollController.position;
    // Reversed list: maxScrollExtent is the TOP (oldest messages).
    if (p.pixels >= p.maxScrollExtent - 200) loadOlder();
  }

  /// If the loaded messages don't fill the viewport nothing can scroll, so
  /// keep pulling older pages.
  void _fillIfShort() {
    if (!_hasMore || loadMoreFailed.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !scrollController.hasClients) return;
      if (scrollController.position.maxScrollExtent <= 0) loadOlder();
    });
  }

  void _toast(String title, String message) => Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
      );

  void onDraftChanged(String value) => draft.value = value;

  /// Local (not yet confirmed by the server) message ids start with this.
  static const String _localPrefix = 'local-';

  static bool isLocalId(String id) => id.startsWith(_localPrefix);

  /// Local ids waiting for (or in) their POST, oldest first. Serialising the
  /// POSTs keeps the server order equal to the UI order.
  final List<String> _sendQueue = <String>[];
  bool _draining = false;

  /// Sends my message. Real conversations: optimistic append (`sending`),
  /// queued POST, then a page-1 reload that is MERGED in. Demo path keeps
  /// its local sending → sent → delivered simulation.
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: '$_localPrefix${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      isMine: true,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    messages.add(message);
    textController.clear();
    draft.value = '';
    _scrollToBottom();

    if (conversationId != null && conversationId!.isNotEmpty) {
      // HTTP-primary send (FIX-2 option b). The WebSocket `send_message` is
      // rejected with {"type":"error","code":"not_found"} for a conversation
      // created after the socket connected (there is no join frame; the live
      // session only knows conversations that existed at connect). The HTTP
      // POST hits the same id in the DB and is the proven delivery path, so we
      // always POST and let the socket be the realtime RECEIVE channel. The
      // existing merge/replace de-dup means a socket echo of my own message
      // never duplicates the bubble.
      _sendQueue.add(message.id);
      await _drainQueue();
      return;
    }

    // DEMO: fake server ack + delivery receipt.
    await Future.delayed(const Duration(milliseconds: 600));
    if (isClosed) return;
    _updateStatus(message.id, MessageStatus.sent);

    await Future.delayed(const Duration(seconds: 1));
    if (isClosed) return;
    _updateStatus(message.id, MessageStatus.delivered);

    // The demo reply only runs on the demo (plain FriendUser) path.
    if (conversationId == null && peer.value?.isOnline == true) _demoReply();
  }

  /// Tap on a failed bubble: POST the same message again.
  Future<void> retryMessage(String localId) async {
    final i = messages.indexWhere((m) => m.id == localId);
    if (i == -1 || messages[i].status != MessageStatus.failed) return;
    messages[i] = messages[i].copyWith(status: MessageStatus.sending);
    _sendQueue.add(localId);
    await _drainQueue();
  }

  /// Long-press / x on a failed bubble: drop it locally.
  void deleteFailedMessage(String localId) {
    final i = messages.indexWhere((m) => m.id == localId);
    if (i == -1 || messages[i].status != MessageStatus.failed) return;
    messages.removeAt(i);
  }

  /// Shows confirmation dialog to delete [message].
  void confirmDeleteMessage(BuildContext context, ChatMessage message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomColor.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Delete Message",
          style: TextStyles.registerSectionTitle.copyWith(
            fontSize: 16,
            color: CustomColor.color0F172A,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this message?",
          style: TextStyles.policiesConsentSubtitle.copyWith(
            fontSize: 14,
            color: CustomColor.color475569,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyles.browseToggleLabel.copyWith(
                color: CustomColor.color64748B,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteMessageApi(message);
            },
            child: Text(
              "Delete",
              style: TextStyles.browseToggleLabel.copyWith(
                color: CustomColor.colorE11D48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calls DELETE /messages/{message_id} API. Checks status code (200/204) for
  /// API success, and removes the message from the local [messages] list on success.
  Future<void> deleteMessageApi(ChatMessage message) async {
    // If it's a local un-posted message, remove immediately
    if (isLocalId(message.id)) {
      messages.removeWhere((m) => m.id == message.id);
      return;
    }

    final res = await ConversationService.instance.deleteMessage(message.id);
    if (isClosed) return;

    if (res.success) {
      messages.removeWhere((m) => m.id == message.id);
      Get.snackbar(
        'Message deleted',
        res.message.isNotEmpty ? res.message : 'The message was deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Could not delete message',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _drainQueue() async {
    if (_draining) return;
    _draining = true;
    var anySuccess = false;
    try {
      while (_sendQueue.isNotEmpty && !isClosed) {
        final localId = _sendQueue.removeAt(0);
        if (await _postOne(localId)) anySuccess = true;
      }
    } finally {
      _draining = false;
    }
    if (anySuccess && !isClosed) await _afterSend();
  }

  /// POSTs one queued message. Returns true on success.
  Future<bool> _postOne(String localId) async {
    final id = conversationId;
    final i = messages.indexWhere((m) => m.id == localId);
    if (id == null || i == -1) return false; // deleted meanwhile
    final res = await ConversationService.instance.sendMessage(
      id,
      messages[i].text,
      // A message returned by my own POST is always mine.
      isMine: (_) => true,
    );
    if (isClosed) return false;
    final sent = res.sent;
    if (res.success && sent != null) {
      messages.assignAll(replaceMessage(messages, localId, sent));
      return true;
    }
    final j = messages.indexWhere((m) => m.id == localId);
    if (j != -1) {
      messages[j] = messages[j].copyWith(status: MessageStatus.failed);
    }
    _toast("Message not sent", res.message);
    return false;
  }

  /// After a successful send: reload page 1 and MERGE it (never replace), then
  /// quietly refresh the Chats tab. `_offset`/`_hasMore` are left untouched.
  Future<void> _afterSend() async {
    final id = conversationId;
    if (id != null) {
      final res = await _fetchPage(id, 0);
      if (isClosed) return;
      if (res.success) {
        messages.assignAll(mergeNewest(messages, res.items));
      } else {
        // Quiet: the POST-response message is already in the list.
        debugPrint('ChatController: post-send reload failed: ${res.message}');
      }
    }
    // Chats tab: a quiet page-1 refresh updates the last-message snippet and
    // time right away (it also refreshes on return, but this keeps the tab
    // correct if it is visible underneath). Errors are silent when quiet.
    // Skip while only "prepared": creating it here would bind it to the Chat
    // route; a fresh one loads when the tab opens.
    if (Get.isRegistered<ConversationsController>() &&
        !Get.isPrepared<ConversationsController>()) {
      Get.find<ConversationsController>().loadFirstPage(quiet: true);
    }
  }

  /// Pure: swaps the local message [localId] IN PLACE with [server]. If the
  /// server id is already in [list] (a concurrent reload added it) the local
  /// one is simply dropped, so no duplicate appears.
  static List<ChatMessage> replaceMessage(
    List<ChatMessage> list,
    String localId,
    ChatMessage server,
  ) {
    final i = list.indexWhere((m) => m.id == localId);
    if (i == -1) return List<ChatMessage>.of(list);
    final result = List<ChatMessage>.of(list);
    final dup = result.indexWhere((m) => m.id == server.id);
    if (dup != -1 && dup != i) {
      result.removeAt(i);
    } else {
      result[i] = server;
    }
    return result;
  }

  /// Pure: merges a page-1 response ([pageNewestFirst], server order) into
  /// [existing] (oldest → newest). Only ids not already present are added,
  /// sorted by time and placed after the existing server messages; local
  /// `sending`/`failed` messages stay at the very end.
  static List<ChatMessage> mergeNewest(
    List<ChatMessage> existing,
    List<ChatMessage> pageNewestFirst,
  ) {
    final seen = existing.map((m) => m.id).toSet();
    final fresh = <ChatMessage>[];
    for (final m in pageNewestFirst) {
      if (seen.add(m.id)) fresh.add(m);
    }
    if (fresh.isEmpty) return List<ChatMessage>.of(existing);
    fresh.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final server = existing.where((m) => !isLocalId(m.id));
    final local = existing.where((m) => isLocalId(m.id));
    return [...server, ...fresh, ...local];
  }

  /// Marks the newest still-pending optimistic message as failed (reuses the
  /// existing failed/retry bubble UI). No-op when nothing is in flight.
  void _failLatestPending() {
    final updated = markLatestPendingFailed(messages);
    if (updated != null) {
      messages.assignAll(updated);
      _toast('Message not sent', 'The server rejected it. Tap to retry.');
    }
  }

  /// Pure: finds the newest message with a local id and `sending` status and
  /// returns a new list with it marked `failed`. Returns null when there is no
  /// such message (so callers can skip any UI side effect).
  static List<ChatMessage>? markLatestPendingFailed(List<ChatMessage> list) {
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (isLocalId(m.id) && m.status == MessageStatus.sending) {
        final result = List<ChatMessage>.of(list);
        result[i] = m.copyWith(status: MessageStatus.failed);
        return result;
      }
    }
    return null;
  }

  void _updateStatus(String id, MessageStatus status) {
    final i = messages.indexWhere((m) => m.id == id);
    // Never downgrade (e.g. a late "delivered" after "read").
    if (i == -1 || messages[i].status.index >= status.index) return;
    messages[i] = messages[i].copyWith(status: status);
  }

  /// DEMO only: peer "types" then answers, and my messages become read.
  /// TODO(api): replace with realtime typing / message / read-receipt events.
  Future<void> _demoReply() async {
    if (peerTyping.value) return;
    peerTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));
    if (isClosed) return;
    peerTyping.value = false;
    // Only messages that actually reached the server can be read; in-flight
    // ("sending") ones keep progressing through sent → delivered.
    for (var i = 0; i < messages.length; i++) {
      final s = messages[i].status;
      if (messages[i].isMine &&
          s.index >= MessageStatus.sent.index &&
          s != MessageStatus.read) {
        messages[i] = messages[i].copyWith(status: MessageStatus.read);
      }
    }
    messages.add(ChatMessage(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      text: 'Haha, love that 😄',
      isMine: false,
      sentAt: DateTime.now(),
    ));
    _scrollToBottom();
  }

  /// The list is reversed, so "bottom" is offset 0.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // --- Header / menu actions ------------------------------------------------
  /// True while POST users/{id}/block is in flight (ignores repeat taps).
  final RxBool isBlocking = false.obs;

  /// Opens the peer's Member Details screen. The list-style [Member] built
  /// from the peer renders instantly; the screen then fetches the full
  /// profile (GET users/{id}) and availability itself.
  void viewProfile() {
    final FriendUser? p = peer.value;
    if (p == null || p.id.isEmpty) {
      comingSoon('Profile');
      return;
    }
    Get.toNamed(
      Routes.MEMBER_DETAIL,
      arguments: Member(
        id: p.id,
        displayName: p.displayName,
        age: p.age,
        role: '',
        avatarUrl: p.avatarUrl,
        profile: MemberProfile.empty,
      ),
    );
  }

  /// Confirm, then POST users/{id}/block. On success: snackbar, sync the
  /// other tabs, and leave the chat. On failure: error snackbar, stay here.
  void blockUser() {
    final FriendUser? p = peer.value;
    if (p == null || p.id.isEmpty) return;
    if (isBlocking.value) return;
    final String name = p.displayName.isNotEmpty ? p.displayName : 'this user';
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomColor.colorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Block $name?',
          style: TextStyles.registerSectionTitle.copyWith(
            color: CustomColor.color0F172A,
          ),
        ),
        content: Text(
          'They won\'t be able to message you, and this chat will close.',
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color64748B,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.color64748B,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _doBlock(p);
            },
            child: Text(
              'Block',
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.colorBE123C,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doBlock(FriendUser p) async {
    if (isBlocking.value) return;
    isBlocking.value = true;
    try {
      final res = await BlockService.instance.blockUser(p.id);
      if (!res.success) {
        Get.snackbar('Could not block', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Get.snackbar(
        'Blocked',
        res.message.isNotEmpty ? res.message : '${p.displayName} blocked',
        snackPosition: SnackPosition.BOTTOM,
      );
      _syncAfterBlock(p.id);
      if (isClosed) return;
      // Leave the chat (pop the CHAT route itself; Get.back() would only
      // close the snackbar shown above in get 4.7.3).
      Get.until((route) => route.settings.name != Routes.CHAT);
    } finally {
      if (!isClosed) isBlocking.value = false;
    }
  }

  /// Keeps Browse / Blocked / Friends / Chats current after a block. Each is
  /// optional (skip when not registered or only "prepared"); not awaited.
  void _syncAfterBlock(String userId) {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.blockStates[userId] = true;
      home.onRefresh();
    }
    if (Get.isRegistered<BlockedController>() &&
        !Get.isPrepared<BlockedController>()) {
      Get.find<BlockedController>().refreshBlocked(showError: false);
    }
    if (Get.isRegistered<FriendsController>() &&
        !Get.isPrepared<FriendsController>()) {
      // loadAll() now refreshes Saved profiles (no friend-request APIs).
      Get.find<FriendsController>().loadAll();
    }
    if (Get.isRegistered<ConversationsController>() &&
        !Get.isPrepared<ConversationsController>()) {
      Get.find<ConversationsController>().loadFirstPage(quiet: true);
    }
  }

  /// Opens the Report User modal bottom sheet.
  void reportUser(BuildContext context) {
    final String peerId = peer.value?.id ?? '';
    final String name = peer.value?.displayName ?? 'this user';
    if (peerId.isEmpty) return;
    showReportUserBottomSheet(
      context: context,
      reportedUserId: peerId,
      displayName: name,
    );
  }

  /// True while DELETE conversations/{id} is in flight (ignores repeat taps).
  final RxBool isClearing = false.obs;

  /// Confirm, then DELETE conversations/{id} ("Clear this conversation for
  /// me"). On success (status 200/202/204): empties this chat locally, resets
  /// paging, and refreshes the Chats tab. On failure: error snackbar, the
  /// messages stay.
  void clearChat() {
    final String? id = conversationId;
    if (id == null || id.isEmpty) {
      comingSoon('Clear chat');
      return;
    }
    if (isClearing.value) return;
    final String name = peer.value?.displayName ?? 'this user';
    Get.dialog(
      AlertDialog(
        backgroundColor: CustomColor.colorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear chat?',
          style: TextStyles.registerSectionTitle.copyWith(
            color: CustomColor.color0F172A,
          ),
        ),
        content: Text(
          'All messages with $name will be removed from this chat for you.',
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color64748B,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.color64748B,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _doClearChat(id);
            },
            child: Text(
              'Clear',
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.colorE11D48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doClearChat(String id) async {
    if (isClearing.value) return;
    isClearing.value = true;
    try {
      final res = await ConversationService.instance.clearConversation(id);
      if (isClosed) return;
      if (!res.success) {
        Get.snackbar('Could not clear chat', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      // Drop everything shown, including unsent/failed local bubbles, and
      // reset paging so older pages aren't fetched back in.
      _sendQueue.clear();
      messages.clear();
      _offset = 0;
      _hasMore = false;
      loadFailed.value = false;
      Get.snackbar(
        'Chat cleared',
        res.message.isNotEmpty ? res.message : 'All messages were cleared.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Chats tab: last-message snippet / unread count change.
      if (Get.isRegistered<ConversationsController>() &&
          !Get.isPrepared<ConversationsController>()) {
        Get.find<ConversationsController>().loadFirstPage(quiet: true);
      }
    } finally {
      if (!isClosed) isClearing.value = false;
    }
  }

  void comingSoon(String feature) {
    Get.snackbar('Coming soon', '$feature is coming soon.',
        snackPosition: SnackPosition.BOTTOM);
  }

  // --- Formatting / grouping helpers (used by the screen) ------------------
  String timeLabel(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// "Today", "Yesterday", else "12 Mar 2025".
  String dayLabel(DateTime d) {
    final now = DateTime.now();
    if (isSameDay(d, now)) return 'Today';
    if (isSameDay(d, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  /// Header status line.
  /// TODO(api): use a real lastSeenAt from the presence API.
  String statusLine(FriendUser u) =>
      u.isOnline ? 'Online' : 'Last seen recently';

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether messages[i] and messages[j] belong to the same visual group.
  bool _grouped(int i, int j) {
    if (i < 0 || j < 0 || i >= messages.length || j >= messages.length) {
      return false;
    }
    final a = messages[i];
    final b = messages[j];
    return a.isMine == b.isMine &&
        isSameDay(a.sentAt, b.sentAt) &&
        b.sentAt.difference(a.sentAt).abs() < _groupWindow;
  }

  /// [chronoIndex] is the oldest-first index into [messages].
  bool isGroupedWithPrevious(int chronoIndex) =>
      _grouped(chronoIndex - 1, chronoIndex);

  bool isGroupedWithNext(int chronoIndex) =>
      _grouped(chronoIndex, chronoIndex + 1);

  @override
  void onClose() {
    isScreenActive = false;
    _socketSubscription?.cancel();
    textController.dispose();
    scrollController.dispose();
    inputFocus.dispose();
    super.onClose();
  }

  // --- DEMO data (remove when the APIs are wired) ---------------------------
  List<ChatMessage> _demoMessages() {
    final now = DateTime.now();
    final y = now.subtract(const Duration(days: 1));
    DateTime yAt(int h, int m) => DateTime(y.year, y.month, y.day, h, m);
    DateTime ago(Duration d) => now.subtract(d);

    return [
      ChatMessage(
        id: 'm1',
        text: 'Hey! Thanks for accepting my request 😊',
        isMine: false,
        sentAt: yAt(21, 10),
      ),
      ChatMessage(
        id: 'm2',
        text: 'Hi! Of course, your profile looked fun.',
        isMine: true,
        sentAt: yAt(21, 14),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        text: 'Are you into hiking?',
        isMine: true,
        sentAt: yAt(21, 15),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm4',
        text: 'Love it. Did a sunrise trail last weekend 🌄',
        isMine: false,
        sentAt: yAt(21, 30),
      ),
      ChatMessage(
        id: 'm5',
        text: 'Good morning ☀️',
        isMine: false,
        sentAt: ago(const Duration(hours: 3, minutes: 20)),
      ),
      ChatMessage(
        id: 'm6',
        text: 'How was your day so far?',
        isMine: false,
        sentAt: ago(const Duration(hours: 3, minutes: 18)),
      ),
      ChatMessage(
        id: 'm7',
        text: 'Morning! Busy, but better now.',
        isMine: true,
        sentAt: ago(const Duration(hours: 2, minutes: 5)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm8',
        text: 'Coffee this weekend?',
        isMine: false,
        sentAt: ago(const Duration(minutes: 40)),
      ),
      ChatMessage(
        id: 'm9',
        text: 'Sounds great!',
        isMine: true,
        sentAt: ago(const Duration(minutes: 12)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm10',
        text: 'Saturday 11am works for me ☕',
        isMine: true,
        sentAt: ago(const Duration(minutes: 11)),
        status: MessageStatus.delivered,
      ),
    ];
  }
}

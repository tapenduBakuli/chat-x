import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/Store/HiveStore.dart';
import '../../home/controller/conversations_controller.dart';
import '../../home/model/friend.dart';
import '../model/chat_message.dart';
import '../model/conversation_model.dart';
import '../services/conversation_services.dart';

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

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ChatArgs) {
      // Real conversation from POST conversations: header uses `other_user`.
      conversationId = arg.conversation.id;
      peer.value = arg.conversation.otherUser;
      // Real conversations never show fabricated demo messages. History is
      // fetched only when the conversation already has messages; a brand-new
      // one (hasNoMessages) starts empty without a request.
      scrollController.addListener(_onScroll);
      if (!arg.conversation.hasNoMessages) loadMessages();
      // TODO(api): subscribe to the realtime socket for this conversation.
    } else if (arg is FriendUser) {
      // Demo / unknown-conversation path (no conversationId).
      peer.value = arg;
      loadHistory();
      // TODO(api): subscribe to the realtime socket for this conversation
      // (incoming messages, typing, read receipts); unsubscribe in onClose.
    }
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
    if (Get.isRegistered<ConversationsController>()) {
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

  // --- Header / menu actions (DEMO) ----------------------------------------
  /// TODO(api): open the peer's profile once a FriendUser → Member lookup
  /// exists.
  void viewProfile() => comingSoon('Profile');

  /// TODO(api): call the block-user endpoint, then leave the chat.
  void blockUser() {
    final name = peer.value?.displayName ?? 'This user';
    Get.snackbar('Blocked', '$name has been blocked (demo).',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// TODO(api): call the report-user endpoint.
  void reportUser() {
    final name = peer.value?.displayName ?? 'this user';
    Get.snackbar('Reported', 'Thanks, we\'ll review $name (demo).',
        snackPosition: SnackPosition.BOTTOM);
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
    // TODO(api): unsubscribe from the realtime socket.
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

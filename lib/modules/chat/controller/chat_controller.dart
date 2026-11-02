import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/model/friend.dart';
import '../model/chat_message.dart';

/// Drives the 1:1 chat screen. The peer ([FriendUser]) is passed via
/// [Get.arguments]. Uses DEMO data until the chat APIs/socket are provided —
/// every spot that needs a real call is marked `// TODO(api)`.
class ChatController extends GetxController {
  /// The friend I'm chatting with; null when the route argument is missing.
  final Rxn<FriendUser> peer = Rxn<FriendUser>();

  /// Messages stored oldest → newest (the list view renders reversed).
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  final RxBool isLoading = false.obs;

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
    if (arg is FriendUser) {
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

  void onDraftChanged(String value) => draft.value = value;

  /// Appends my message locally (sending → sent → delivered in DEMO).
  /// TODO(api): POST the message / emit via socket; on ack set `sent`, on
  /// failure mark it failed and offer a retry.
  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      isMine: true,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    messages.add(message);
    textController.clear();
    draft.value = '';
    _scrollToBottom();

    // DEMO: fake server ack + delivery receipt.
    await Future.delayed(const Duration(milliseconds: 600));
    if (isClosed) return;
    _updateStatus(message.id, MessageStatus.sent);

    await Future.delayed(const Duration(seconds: 1));
    if (isClosed) return;
    _updateStatus(message.id, MessageStatus.delivered);

    if (peer.value?.isOnline == true) _demoReply();
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

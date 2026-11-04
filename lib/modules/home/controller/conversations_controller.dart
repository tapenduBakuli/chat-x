import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../chat/model/conversation_model.dart';
import '../../chat/services/conversation_services.dart';

/// Chat tab (bottom nav index 1): paginated GET conversations list.
/// Paging is by raw server offset; `hasMore = offset < total`.
class ConversationsController extends GetxController {
  static const int pageSize = 20;
  static const Duration _throttle = Duration(seconds: 10);
  static const Duration _errorToastGap = Duration(seconds: 30);

  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxInt total = 0.obs;

  /// Page-1 load in flight (first load, pull-to-refresh or quiet refresh).
  final RxBool isLoading = false.obs;

  /// First page-1 attempt finished (success or failure).
  final RxBool hasLoaded = false.obs;
  final RxBool isLoadingMore = false.obs;

  /// Raw server rows consumed so far.
  final RxInt _offset = 0.obs;

  int _gen = 0;
  DateTime? _lastFetch;
  DateTime? _lastErrorToast;
  bool _isOpening = false;

  bool get hasMore => _offset.value < total.value;

  /// Called when the Chat tab is selected. First call always loads; later
  /// calls refresh quietly, at most once per [_throttle].
  void onTabOpened() {
    if (!hasLoaded.value && !isLoading.value) {
      loadFirstPage();
      return;
    }
    if (isLoading.value) return;
    if (_lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _throttle) {
      return;
    }
    loadFirstPage(quiet: true);
  }

  /// Lets the next tab open refetch immediately.
  void invalidate() => _lastFetch = null;

  Future<void> onRefresh() => loadFirstPage();

  Future<void> loadFirstPage({bool quiet = false}) async {
    final int gen = ++_gen;
    isLoadingMore.value = false;
    _lastFetch = DateTime.now();
    isLoading.value = true;
    try {
      final res = await ConversationService.instance
          .fetchConversations(limit: pageSize, offset: 0);
      if (gen != _gen) return;
      if (!res.success) {
        _lastFetch = null; // retry on the next tab open
        if (!quiet) _toast('Could not load conversations', res.message);
        return;
      }
      conversations.assignAll(_dedupe(res.items));
      total.value = res.total;
      _offset.value = res.rawCount;
    } finally {
      if (gen == _gen) {
        isLoading.value = false;
        hasLoaded.value = true;
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore) return;
    final int gen = _gen;
    isLoadingMore.value = true;
    try {
      final res = await ConversationService.instance
          .fetchConversations(limit: pageSize, offset: _offset.value);
      if (gen != _gen) return;
      if (!res.success) {
        _toast('Could not load more', res.message);
        return;
      }
      final known = conversations.map((c) => c.id).toSet();
      conversations.addAll(res.items.where((c) => known.add(c.id)));
      total.value = res.total;
      _offset.value += res.rawCount;
      // Stop paging on an empty page.
      if (res.rawCount == 0) _offset.value = total.value;
    } finally {
      if (gen == _gen) isLoadingMore.value = false;
    }
  }

  List<Conversation> _dedupe(List<Conversation> items) {
    final seen = <String>{};
    return items.where((c) => seen.add(c.id)).toList();
  }

  /// Opens the chat for a list row (no POST: the id is already known), then
  /// quietly refreshes so snippet/time/unread are current on return.
  Future<void> openConversation(Conversation c) async {
    if (_isOpening || c.id.isEmpty) return;
    _isOpening = true;
    try {
      await Get.toNamed(Routes.CHAT, arguments: ChatArgs(c));
    } finally {
      _isOpening = false;
    }
    if (!isClosed) loadFirstPage(quiet: true);
  }

  void _toast(String title, String message) {
    final now = DateTime.now();
    if (_lastErrorToast != null &&
        now.difference(_lastErrorToast!) < _errorToastGap) {
      return;
    }
    _lastErrorToast = now;
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}

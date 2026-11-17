import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/chat/services/chat_websocket_service.dart';
import '../modules/home/controller/home_controller.dart';
import '../routes/routes.dart';
import 'Store/HiveStore.dart';
import 'activity_tracker.dart';
import 'text_utils/app_strings.dart';

enum LogoutReason { idleTimeout, expired, manual, accountDeleted, paymentCancel }

/// Single place that ends a login session.
class SessionManager {
  SessionManager._();

  static bool _inProgress = false;
  static DateTime? _lastForcedLogout;

  /// True for ~2 s after a forced logout (lets Splash skip a second route).
  static bool get loggedOutRecently =>
      _lastForcedLogout != null &&
      DateTime.now().difference(_lastForcedLogout!) <
          const Duration(seconds: 2);

  /// Clears the session (remember-me is kept, except for
  /// [LogoutReason.accountDeleted]), closes the chat socket without
  /// auto-reconnect, stops the notification poll, routes to Login and shows
  /// the toast for [reason]. Single-flight.
  static void forceLogout({required LogoutReason reason}) {
    if (_inProgress) return;
    _inProgress = true;
    try {
      debugPrint('SessionManager.forceLogout reason=$reason');
      if (reason != LogoutReason.manual &&
          reason != LogoutReason.accountDeleted &&
          reason != LogoutReason.paymentCancel) {
        _lastForcedLogout = DateTime.now();
      }
      final HiveStore store = HiveStore();
      store.clearSession();
      if (reason == LogoutReason.accountDeleted) {
        store.remove(Keys.REMEMBERME);
        store.remove(Keys.SAVEDEMAIL);
        store.remove(Keys.SAVEDPASSWORD);
      }
      ChatWebSocketService.instance.disconnectForLogout();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().stopBadgePolling();
      }
      ActivityTracker.instance.markActive();
      if (Get.currentRoute != Routes.LOGIN) Get.offAllNamed(Routes.LOGIN);
      switch (reason) {
        case LogoutReason.idleTimeout:
          Get.snackbar(
            AppStrings.sessionIdleTimeoutTitle,
            AppStrings.sessionIdleTimeoutMessage,
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        case LogoutReason.expired:
          Get.snackbar(
            AppStrings.sessionExpiredTitle,
            AppStrings.sessionExpiredMessage,
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
        case LogoutReason.manual:
        case LogoutReason.accountDeleted:
        case LogoutReason.paymentCancel:
          break;
      }
    } finally {
      // All work above is synchronous, so the guard only needs to cover
      // re-entrant/concurrent callers within this turn.
      Future<void>.microtask(() => _inProgress = false);
    }
  }
}

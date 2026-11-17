import 'package:flutter/foundation.dart';

/// App-wide record of the last user touch. The backend logs a user out after
/// 5 idle minutes, and any authenticated call (even a background poll) resets
/// that clock, so timer-driven calls must skip while [isIdle].
class ActivityTracker {
  ActivityTracker({DateTime Function()? clock})
      : _now = clock ?? DateTime.now {
    _last = _now();
  }

  static final ActivityTracker instance = ActivityTracker();

  static const Duration idleAfter = Duration(minutes: 5);

  final DateTime Function() _now;
  late DateTime _last;

  DateTime get lastInteraction => _last;

  void markActive() => _last = _now();

  @visibleForTesting
  void reset() => markActive();

  bool get isIdle => _now().difference(_last) >= idleAfter;
}

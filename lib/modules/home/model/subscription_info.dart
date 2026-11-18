/// GET subscriptions/me `data` payload.
class SubscriptionInfo {
  final String status;
  final int daysRemaining;
  final bool isTrial;
  final DateTime? currentPeriodEnd;
  final int? planMonths;
  final bool autoRenew;

  const SubscriptionInfo({
    required this.status,
    required this.daysRemaining,
    required this.isTrial,
    this.currentPeriodEnd,
    this.planMonths,
    required this.autoRenew,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');
    final String status = (json['status'] ?? '').toString().toLowerCase();
    final dynamic end = json['current_period_end'];
    return SubscriptionInfo(
      status: status,
      daysRemaining: asInt(json['days_remaining']) ?? 0,
      isTrial: json['is_trial'] == true,
      currentPeriodEnd: end == null ? null : DateTime.tryParse(end.toString()),
      planMonths: asInt(json['plan_months']),
      autoRenew: json['auto_renew'] == true,
    );
  }

  bool get isActiveLike => status == 'active' || status == 'trial';

  int get _days => daysRemaining < 0 ? 0 : daysRemaining;

  String get planName {
    if (isTrial) return '15-Day Free Trial';
    final int? m = planMonths;
    if (m == null || m == 0) return autoRenew ? 'Monthly Continuous' : 'Subscription';
    switch (m) {
      case 1:
        return '1-Month Single Pass';
      case 3:
        return '3 Months Pass';
      case 6:
        return '6 Months VIP Pass';
      default:
        return '$m Months Pass';
    }
  }

  /// Capitalised status, e.g. "Expired".
  String get statusLabel => status.isEmpty
      ? 'Inactive'
      : status[0].toUpperCase() + status.substring(1);

  /// Local date of [currentPeriodEnd], e.g. "2 Dec 2026" ("—" when unknown).
  String get endsOnText => currentPeriodEnd == null
      ? '—'
      : formatDayMonthYear(currentPeriodEnd!.toLocal());

  String get trialPillText =>
      '$_days ${_days == 1 ? 'Day' : 'Days'} Free Trial Left';

  String get daysRemainingText =>
      '$_days ${_days == 1 ? 'day' : 'days'} remaining';
}

const List<String> _months = <String>[
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "d MMM yyyy" without `intl`.
String formatDayMonthYear(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

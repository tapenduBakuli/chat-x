/// Represents a single report reason item returned by GET /reports/reasons.
class ReportReason {
  final String code;
  final String label;

  const ReportReason({
    required this.code,
    required this.label,
  });

  factory ReportReason.fromJson(Map<String, dynamic> json) {
    return ReportReason(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

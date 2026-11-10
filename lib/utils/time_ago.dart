/// Short relative time, e.g. "just now", "5m ago", "3h ago", "Yesterday",
/// "4d ago", or a date ("4 Nov 2026") for anything a week or older.
/// [now] is injectable for tests.
String timeAgoShort(DateTime since, {DateTime? now}) {
  final DateTime current = now ?? DateTime.now();
  final Duration diff = current.difference(since);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  final DateTime today = DateTime(current.year, current.month, current.day);
  final DateTime day = DateTime(since.year, since.month, since.day);
  final int dayGap = today.difference(day).inDays;
  if (dayGap <= 0 && diff.inHours < 24) return '${diff.inHours}h ago';
  if (dayGap == 1) return 'Yesterday';
  if (dayGap < 7) return '${dayGap}d ago';
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${since.day} ${months[since.month - 1]} ${since.year}';
}

import '../../../utils/time_ago.dart';
import 'member.dart';

enum PresenceKind { online, lastSeen, offline }

/// What the member-detail availability pill shows.
class PresenceLabel {
  final PresenceKind kind;
  final String text;
  const PresenceLabel(this.kind, this.text);
}

/// Pure pill-text logic. Returns null (pill hidden) while availability is
/// unknown (loading or failed). [now] is injectable for tests.
PresenceLabel? presenceLabel(UserAvailability? a, {DateTime? now}) {
  if (a == null) return null;
  if (a.isOnline) return const PresenceLabel(PresenceKind.online, 'Active now');
  final DateTime? seen = a.lastSeenAt;
  if (seen == null) return const PresenceLabel(PresenceKind.offline, 'Offline');
  final String ago = timeAgoShort(seen, now: now);
  return PresenceLabel(PresenceKind.lastSeen, 'Last seen $ago');
}

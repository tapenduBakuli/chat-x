/// A user shown in the Friends tab — either a pending friend request or an
/// accepted friend. Shape is provisional until the friends APIs exist; add a
/// `fromJson` here when they land.
class FriendUser {
  final String id;
  final String displayName;
  final int age;
  final String avatarUrl;

  /// Short line under the name (e.g. orientation / "Online now").
  final String subtitle;

  /// For requests: when it was sent. For friends: when they became friends.
  final DateTime? since;

  final bool isOnline;

  const FriendUser({
    required this.id,
    required this.displayName,
    this.age = 0,
    this.avatarUrl = '',
    this.subtitle = '',
    this.since,
    this.isOnline = false,
  });
}

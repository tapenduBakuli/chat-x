import 'dart:io';

import '../../../device_manager/urls.dart';

/// One server-backed gallery photo from GET/POST/PUT `users/me/photos`.
///
/// `{ "id": "...", "url": "https://.../uploads/avatars/x.png", "position": 1 }`
///
/// Position 0 is the backend's own copy of the main avatar and is never part
/// of the gallery; gallery positions start at 1 (= first gallery tile).
class GalleryPhoto {
  final String id;
  final String url;
  final int position;

  const GalleryPhoto({
    required this.id,
    required this.url,
    required this.position,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    final rawPos = json['position'];
    final int position = rawPos is num
        ? rawPos.toInt()
        : int.tryParse((rawPos ?? '').toString()) ?? 0;
    return GalleryPhoto(
      id: (json['id'] ?? '').toString(),
      url: _absoluteUrl((json['url'] ?? '').toString()),
      position: position,
    );
  }

  GalleryPhoto copyWith({int? position}) => GalleryPhoto(
        id: id,
        url: url,
        position: position ?? this.position,
      );

  /// Parses a `data` list: drops position-0 (avatar) items and items with no
  /// id/url, then sorts ascending by position. Non-list input → empty list.
  static List<GalleryPhoto> listFromData(dynamic data) {
    if (data is! List) return <GalleryPhoto>[];
    final photos = data
        .whereType<Map>()
        .map((e) => GalleryPhoto.fromJson(Map<String, dynamic>.from(e)))
        .where((p) => p.position >= 1 && p.id.isNotEmpty && p.url.isNotEmpty)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    return photos;
  }

  /// Parses a full `{ success, message, data: [...] }` response body.
  static List<GalleryPhoto> listFromResponse(dynamic body) =>
      body is Map ? listFromData(body['data']) : <GalleryPhoto>[];

  /// PUT `users/me/photos/reorder` body: ids in the new order (list index 0 =
  /// new position 1). Position-0 (avatar) items are never sent.
  static Map<String, dynamic> reorderPayload(List<GalleryPhoto> ordered) =>
      <String, dynamic>{
        'photo_ids':
            ordered.where((p) => p.position != 0).map((p) => p.id).toList(),
      };

  /// Prefixes [Urls.baseUrl] for server-relative paths ("/uploads/...").
  static String _absoluteUrl(String url) =>
      url.startsWith('/') ? '${Urls.baseUrl}$url' : url;
}

/// A gallery photo picked locally whose upload is still in flight (rendered
/// as a spinner tile over the local preview).
class PendingGalleryUpload {
  final String localId;
  final File file;

  PendingGalleryUpload(this.file)
      : localId = DateTime.now().microsecondsSinceEpoch.toString();
}

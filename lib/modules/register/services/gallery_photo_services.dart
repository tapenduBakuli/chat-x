import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../device_manager/urls.dart';
import '../../../utils/base_client.dart';
import '../../../utils/exception_handler.dart';
import '../../../utils/text_utils/app_strings.dart';
import '../model/gallery_photo_model.dart';

/// Network layer for the profile gallery (`users/me/photos`). Mirrors
/// FriendService: wraps [BaseClient] and never throws — failures come back
/// with `success: false` and a user-facing message.
///
/// The gallery never touches the main avatar (that stays on
/// POST /users/me/avatar).
class GalleryPhotoService {
  GalleryPhotoService._();

  static final GalleryPhotoService instance = GalleryPhotoService._();

  /// GET /users/me/photos — gallery photos (position >= 1, ascending;
  /// position 0 is dropped by [GalleryPhoto.listFromResponse]).
  Future<({bool success, String message, List<GalleryPhoto> photos})>
      fetchPhotos() async {
    try {
      final http.Response response =
          await BaseClient.instance.get(Urls.myPhotos);
      final code = response.statusCode;
      final body = _decode(response);
      if (code == 200 && body is Map) {
        return (
          success: true,
          message: '',
          photos: GalleryPhoto.listFromResponse(body),
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not load photos ($code).'),
        photos: <GalleryPhoto>[],
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: _offlineMessage(e),
        photos: <GalleryPhoto>[],
      );
    } catch (e) {
      debugPrint('GalleryPhotoService.fetchPhotos error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        photos: <GalleryPhoto>[],
      );
    }
  }

  /// POST /users/me/photos — multipart/form-data, field `file`, with an
  /// image content-type derived from the file extension.
  Future<({bool success, String message, GalleryPhoto? photo})> uploadPhoto(
      File file) async {
    try {
      final http.Response response = await BaseClient.instance.postMultipart(
        Urls.myPhotos,
        file,
        fieldName: 'file',
        contentType: _mediaTypeFor(file.path),
      );
      final code = response.statusCode;
      final body = _decode(response);
      if ((code == 200 || code == 201) && body is Map) {
        final data = body['data'];
        return (
          success: true,
          message: _serverMessage(body, 'Photo uploaded'),
          photo: data is Map
              ? GalleryPhoto.fromJson(Map<String, dynamic>.from(data))
              : null,
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not upload photo ($code).'),
        photo: null,
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e), photo: null);
    } catch (e) {
      debugPrint('GalleryPhotoService.uploadPhoto error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        photo: null,
      );
    }
  }

  /// DELETE /users/me/photos/{photoId}. Success is decided by status code
  /// only (200/204) — the 204 body is empty.
  Future<({bool success, String message})> deletePhoto(String photoId) async {
    try {
      final http.Response response = await BaseClient.instance.delete(
        Urls.myPhotoById(photoId),
        <String, dynamic>{},
      );
      final code = response.statusCode;
      if (code == 200 || code == 204) {
        return (
          success: true,
          message: _serverMessage(_decode(response), 'Photo removed'),
        );
      }
      return (
        success: false,
        message: _extractMessage(
          _decode(response),
          'Could not remove photo ($code).',
        ),
      );
    } on AppException catch (e) {
      return (success: false, message: _offlineMessage(e));
    } catch (e) {
      debugPrint('GalleryPhotoService.deletePhoto error: $e');
      return (success: false, message: 'Something went wrong. Please try again.');
    }
  }

  /// PUT /users/me/photos/reorder — body {"photo_ids": [...]} where list
  /// order is the new position order (position 0 is never sent).
  Future<({bool success, String message, List<GalleryPhoto> photos})>
      reorderPhotos(List<GalleryPhoto> ordered) async {
    try {
      final http.Response response = await BaseClient.instance.put(
        Urls.reorderMyPhotos,
        GalleryPhoto.reorderPayload(ordered),
      );
      final code = response.statusCode;
      final body = _decode(response);
      if ((code == 200 || code == 201) && body is Map) {
        return (
          success: true,
          message: _serverMessage(body, 'Photos reordered'),
          photos: GalleryPhoto.listFromResponse(body),
        );
      }
      return (
        success: false,
        message: _extractMessage(body, 'Could not reorder photos ($code).'),
        photos: <GalleryPhoto>[],
      );
    } on AppException catch (e) {
      return (
        success: false,
        message: _offlineMessage(e),
        photos: <GalleryPhoto>[],
      );
    } catch (e) {
      debugPrint('GalleryPhotoService.reorderPhotos error: $e');
      return (
        success: false,
        message: 'Something went wrong. Please try again.',
        photos: <GalleryPhoto>[],
      );
    }
  }

  /// Image media type from the file extension (defaults to image/jpeg).
  MediaType _mediaTypeFor(String path) {
    final dot = path.lastIndexOf('.');
    final ext = dot == -1 ? '' : path.substring(dot + 1).toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  dynamic _decode(http.Response r) {
    if (r.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Non-empty top-level `message`, else [fallback].
  String _serverMessage(dynamic body, String fallback) =>
      body is Map &&
              body['message'] != null &&
              body['message'].toString().trim().isNotEmpty
          ? body['message'].toString()
          : fallback;

  String _offlineMessage(AppException e) =>
      e.message == AppStrings.noInternetConnection
          ? 'No internet connection. Please check your network and try again.'
          : 'Could not reach the server. Please try again.';

  /// Top-level `message`, nested `error.message`, or string `error`.
  String _extractMessage(dynamic body, String fallback) {
    if (body is Map) {
      final top = body['message'];
      if (top != null && top.toString().trim().isNotEmpty) {
        return top.toString();
      }
      final err = body['error'];
      if (err is Map &&
          err['message'] != null &&
          err['message'].toString().trim().isNotEmpty) {
        return err['message'].toString();
      }
      if (err is String && err.trim().isNotEmpty) return err;
    }
    return fallback;
  }
}

// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../device_manager/urls.dart';
import '../modules/chat/services/chat_websocket_service.dart';
import '../modules/login/model/login_response_model.dart';
import '../routes/routes.dart';
import 'Store/HiveStore.dart';
import 'exception_handler.dart';
import 'text_utils/app_strings.dart';

/// Result of one POST /auth/refresh attempt.
enum _RefreshOutcome {
  /// New tokens were saved.
  refreshed,

  /// The server refused (non-2xx / no token in the body) or there is no
  /// stored refresh token → the session is over.
  rejected,

  /// The refresh call itself could not complete (offline, timeout, …). The
  /// session is kept; the caller gets [ApiNotResponding].
  networkError,
}

class BaseClient {
  BaseClient._();

  static final instance = BaseClient._();

  static const int timeOutDuration = 20;

  /// The in-flight refresh, shared by every request that hits a 401 while it
  /// runs (single-flight). Reset when it completes.
  Future<_RefreshOutcome>? _refreshInFlight;

  /// Reads a Hive string without printing it (tokens). null when missing.
  String? _quiet(String key) {
    final dynamic v = HiveStore.defBox.get(key);
    return v is String ? v : null;
  }

  /// Resolves the bearer token at call time (not once at construction) so a
  /// token saved after app start is picked up. Falls back ACCESSTOKEN ->
  /// REGISTRATIONTOKEN -> AUTHTOKEN, so onboarding calls right after register
  /// authenticate via the registration token.
  String? get _authToken =>
      _quiet(Keys.ACCESSTOKEN) ??
      _quiet(Keys.REGISTRATIONTOKEN) ??
      _quiet(Keys.AUTHTOKEN);

  /// The login-session access token ('' when there is no login session).
  String get _sessionAccessToken => HiveStore().getStringQuiet(Keys.ACCESSTOKEN);

  /// Lightweight reachability check (no extra package). Resolves a well-known
  /// host; if DNS fails or times out we treat the device as offline.
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  /// Throws [FetchDataException] (same type/message as a SocketException) when
  /// there is no connectivity, so callers that already handle that case work
  /// unchanged. Called at the start of every request method.
  Future<void> _ensureConnected(String path) async {
    if (!await hasInternet()) {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    }
  }

  // --- Token refresh ---------------------------------------------------------

  /// POST /auth/refresh with the stored REFRESHTOKEN. Uses `http.post`
  /// directly (never [post]) so it can't re-enter the 401 handling and its
  /// body/response (tokens) are never logged. On success saves the new access
  /// token (ACCESSTOKEN + AUTHTOKEN, mirroring login) and the rotated refresh
  /// token.
  Future<_RefreshOutcome> _doRefresh() async {
    final String refreshToken = HiveStore().getStringQuiet(Keys.REFRESHTOKEN);
    if (refreshToken.isEmpty) return _RefreshOutcome.rejected;
    try {
      final http.Response r = await http
          .post(
            Uri.parse(Urls.authRefresh),
            headers: <String, String>{'Content-Type': AppStrings.contentType},
            body: jsonEncode(<String, String>{'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: timeOutDuration));
      debugPrint('Token refresh -> ${r.statusCode}');
      if (r.statusCode < 200 || r.statusCode >= 300) {
        return _RefreshOutcome.rejected;
      }
      final dynamic body = r.body.isNotEmpty
          ? jsonDecode(utf8.decode(r.bodyBytes))
          : <String, dynamic>{};
      if (body is! Map) return _RefreshOutcome.rejected;
      final RefreshTokenResponse res =
          RefreshTokenResponse.fromJson(Map<String, dynamic>.from(body));
      if (!res.isValid) return _RefreshOutcome.rejected;

      final AuthTokens tokens = res.tokens!;
      final HiveStore store = HiveStore();
      await store.setStringQuiet(Keys.ACCESSTOKEN, tokens.accessToken);
      await store.setStringQuiet(Keys.AUTHTOKEN, tokens.accessToken);
      if (tokens.refreshToken.isNotEmpty) {
        // The refresh token rotates: the old one is no longer valid.
        await store.setStringQuiet(Keys.REFRESHTOKEN, tokens.refreshToken);
      }
      // The chat socket captured the OLD access token in its connect URL and
      // is not notified of rotations. Reconnect so it picks up the freshly
      // saved ACCESSTOKEN. Fire-and-forget; the service's _isReconnecting /
      // _isConnecting guards (and single-flight refresh) prevent loops.
      // ignore: unawaited_futures
      ChatWebSocketService.instance.reconnect();
      return _RefreshOutcome.refreshed;
    } catch (_) {
      debugPrint('Token refresh -> network error');
      return _RefreshOutcome.networkError;
    }
  }

  /// Concurrent callers await the same in-flight refresh.
  Future<_RefreshOutcome> _refreshSingleFlight() =>
      _refreshInFlight ??= _doRefresh().whenComplete(() {
        _refreshInFlight = null;
      });

  /// Refreshes the tokens (single-flight) without navigating. Returns true
  /// only when new tokens were saved. Used by logout, which must resend the
  /// latest rotated refresh token itself.
  Future<bool> refreshTokens() async =>
      await _refreshSingleFlight() == _RefreshOutcome.refreshed;

  /// Ends the login session after a rejected refresh: clears it (remember-me
  /// is preserved), routes to Login and tells the user. Callers only invoke
  /// this while ACCESSTOKEN is still present, so when several requests fail
  /// together only the first one gets here (clearSession runs synchronously).
  void _expireSession() {
    HiveStore().clearSession();
    if (Get.currentRoute != Routes.LOGIN) Get.offAllNamed(Routes.LOGIN);
    Get.snackbar(
      AppStrings.sessionExpiredTitle,
      AppStrings.sessionExpiredMessage,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Sends a request built by [send] (given the bearer token to use) and, on
  /// a 401, refreshes the login session once and retries once.
  ///
  /// Refresh happens only when ALL hold:
  /// - the request is authenticated (not an `isAuth` call such as login,
  ///   register, send-otp; the refresh call itself never goes through here);
  /// - the status is 401. 403 is "forbidden", not "expired" — nothing in the
  ///   app/backend contract uses 403 for expired tokens — so it keeps the
  ///   previous behavior;
  /// - it was sent with the login ACCESSTOKEN. Registration-token calls
  ///   (register path: no ACCESSTOKEN, no REFRESHTOKEN stored) keep the
  ///   previous behavior, as no refresh is possible there;
  /// - [refreshOnUnauthorized] is true.
  ///
  /// Never loops: the retry's response is returned as-is, even if it is
  /// another 401. If the refresh is rejected the session is expired
  /// ([_expireSession]) and [UnAuthorizedException] is thrown so callers stop
  /// their spinners; a refresh network error throws [ApiNotResponding].
  Future<http.Response> _sendWithRefresh(
    String path,
    Future<http.Response> Function(String? token) send, {
    required bool authenticated,
    bool refreshOnUnauthorized = true,
  }) async {
    final String? used = authenticated ? _authToken : null;
    final bool sentWithSession =
        authenticated && _sessionAccessToken.isNotEmpty;

    final http.Response first = await send(used);
    if (!authenticated ||
        !refreshOnUnauthorized ||
        first.statusCode != 401 ||
        !sentWithSession) {
      return first;
    }

    // Another request already expired the session meanwhile.
    if (_sessionAccessToken.isEmpty) {
      throw UnAuthorizedException(utf8.decode(first.bodyBytes), path);
    }

    // Another request already refreshed since this one was sent: retry once
    // with the current token, no new refresh.
    if (_sessionAccessToken != used) return send(_authToken);

    final _RefreshOutcome outcome = await _refreshSingleFlight();
    switch (outcome) {
      case _RefreshOutcome.refreshed:
        return send(_authToken);
      case _RefreshOutcome.networkError:
        throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', path);
      case _RefreshOutcome.rejected:
        if (_sessionAccessToken.isNotEmpty) _expireSession();
        throw UnAuthorizedException(utf8.decode(first.bodyBytes), path);
    }
  }

  //GET
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
   if (query != null) {
      path = "$path?";
      query.forEach((key, value) {
        path += "$key=$value&";
      });
    }

    try {
      await _ensureConnected(path);
      final String url = path;
      var response = await _sendWithRefresh(
        url,
        (token) => http.get(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': AppStrings.contentType,
            'Authorization': "Bearer ${token ?? ''}"
          },
        ),
        authenticated: true,
      );

      debugPrint(DateTime.now().toString());

      log(response.body);
       if (query != null) debugPrint(query.toString());
      debugPrint(response.statusCode.toString());
      print("okk");
      return response;
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }

//POST
  /// [refreshOnUnauthorized] = false disables the automatic 401 refresh/retry
  /// (used by logout, whose body carries the refresh token itself).
  Future<dynamic> post( path, dynamic payloadObj,
      {bool isAuth = false, bool refreshOnUnauthorized = true}) async {

    var payload = jsonEncode(payloadObj);
    print(payload);

    try {
      await _ensureConnected(path);
      var response = await _sendWithRefresh(
        '$path',
        (token) => http.post(
          Uri.parse(path),
          body: payload,
          headers: <String, String>{
            'Content-Type': AppStrings.contentType,
            if (!isAuth) 'Authorization': "Bearer ${token ?? ''}"
          },
        ),
        authenticated: !isAuth,
        refreshOnUnauthorized: refreshOnUnauthorized,
      );
      debugPrint(DateTime.now().toString());
      debugPrint(payload);
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      log(response.body.toString());

      return response;
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }

  // MULTIPART POST (file upload)
  /// Uploads [file] as a multipart/form-data field named [fieldName] to [path].
  /// Attaches the bearer token (resolved at call time) unless [isAuth] is true.
  /// Returns the raw [http.Response] like [post]. [contentType] sets the
  /// part's media type (null keeps http's default, as the avatar upload uses).
  ///
  /// A MultipartRequest / file stream can't be sent twice, so every attempt
  /// (including the post-refresh retry) rebuilds the request and reopens the
  /// file from the same path, field name and content type.
  Future<http.Response> postMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    bool isAuth = false,
    MediaType? contentType,
  }) async {
    try {
      await _ensureConnected(path);
      final response = await _sendWithRefresh(
        path,
        (token) async {
          final request = http.MultipartRequest('POST', Uri.parse(path));
          if (!isAuth) {
            request.headers['Authorization'] = "Bearer ${token ?? ''}";
          }
          request.files.add(await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            contentType: contentType,
          ));
          final streamed = await request.send();
          return http.Response.fromStream(streamed);
        },
        authenticated: !isAuth,
      );

      debugPrint(DateTime.now().toString());
      debugPrint(response.statusCode.toString());
      log(response.body.toString());
      return response;
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }

  Future<dynamic> delete( path, dynamic payloadObj) async {
    // var token = GetStorage().read(UserData.token);
    try {
      await _ensureConnected(path);
      final String body = jsonEncode(payloadObj);
      final response = await _sendWithRefresh(
        '$path',
        (token) => http.delete(
          Uri.parse(path),
          body: body,
          headers: <String, String>{
            'Content-Type': AppStrings.contentType,
            'Authorization': "Bearer ${token ?? ''}"
          },
        ),
        authenticated: true,
      );
      debugPrint(DateTime.now().toString());
      //debugPrint('$_basepath/$path');
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return response;
      //return _processResponse(response);
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }

  //PATCH
  Future<dynamic> patch( path, dynamic payloadObj,
      {bool isAuth = false}) async {
    // var token = GetStorage().read(UserData.token);
    var payload = json.encode(payloadObj);
    debugPrint(payload);
    try {
      await _ensureConnected(path);
      var response = await _sendWithRefresh(
        '$path',
        (token) => http.patch(
          Uri.parse(path),
          body: payload,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            if (!isAuth) 'Authorization': "Bearer ${token ?? ''}"
          },
        ),
        authenticated: !isAuth,
      );
      debugPrint(DateTime.now().toString());
      // debugPrint('$_basepath/$path');
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return response;
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }
  //Put
  Future<dynamic> put( path, dynamic payloadObj,
      {bool isAuth = false}) async {
    // var token = GetStorage().read(UserData.token);
    //var payload = json.encode(payloadObj);
     var payload = jsonEncode(payloadObj);
    debugPrint(payload);
    try {
      await _ensureConnected(path);
      var response = await _sendWithRefresh(
        '$path',
        (token) => http.put(
          Uri.parse(path),
          body: payload,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            if (!isAuth) 'Authorization': "Bearer ${token ?? ''}"
          },
        ),
        authenticated: !isAuth,
      );
      debugPrint(DateTime.now().toString());
      // debugPrint('$_basepath/$path');
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return response;
    //  return _processResponse(response);
    } on SocketException {
      throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
    } on TimeoutException {
      throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
    }
  }
  // ignore: unused_element
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        // var responseJson = json.decode(response.body);
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        return responseJson;
      case 201:
        var responseJson =
            json.decode(response.body); //utf8.decode(response.body);
        return responseJson;
      case 202:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 404:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 401:
      case 403:
        throw UnAuthorizedException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 502:
        throw UnAuthorizedException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 422:
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        throw FetchDataException(
            '${AppStrings.errorOccuredWithCode} : ${response.statusCode}',
            response.request!.url.toString());
    }
  }
}

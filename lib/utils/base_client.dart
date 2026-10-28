// ignore_for_file: unnecessary_string_interpolations

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'Store/HiveStore.dart';

import 'Store/HiveStore.dart';
import 'exception_handler.dart';
import 'text_utils/app_strings.dart';

class BaseClient {
  BaseClient._();

  static final instance = BaseClient._();

  static const int timeOutDuration = 20;

  /// Resolves the bearer token at call time (not once at construction) so a
  /// token saved after app start is picked up. Falls back ACCESSTOKEN ->
  /// REGISTRATIONTOKEN -> AUTHTOKEN, so onboarding calls right after register
  /// authenticate via the registration token.
  String? get _authToken =>
      HiveStore().getString(Keys.ACCESSTOKEN) ??
      HiveStore().getString(Keys.REGISTRATIONTOKEN) ??
      HiveStore().getString(Keys.AUTHTOKEN);

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
      var response = await http.get(

        Uri.parse(path),
        headers: <String, String>{
          'Content-Type': AppStrings.contentType,
          'Authorization': "Bearer ${_authToken ?? ''}"
        },
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
  Future<dynamic> post( path, dynamic payloadObj,
      {bool isAuth = false}) async {

    var payload = jsonEncode(payloadObj);
    print(payload);

    try {
      await _ensureConnected(path);
      var response = await http.post(
       Uri.parse(path),
        body: payload,
        headers: <String, String>{
          'Content-Type': AppStrings.contentType,
          if (!isAuth) 'Authorization': "Bearer ${_authToken ?? ''}"
        },
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
  /// Returns the raw [http.Response] like [post].
  Future<http.Response> postMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    bool isAuth = false,
  }) async {
    try {
      await _ensureConnected(path);
      final request = http.MultipartRequest('POST', Uri.parse(path));
      if (!isAuth) {
        request.headers['Authorization'] = "Bearer ${_authToken ?? ''}";
      }
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

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
      final response = await http.delete(
        Uri.parse(path),
        body: jsonEncode(payloadObj),
        headers: <String, String>{
          'Content-Type': AppStrings.contentType,
          'Authorization': "Bearer ${_authToken ?? ''}"
        },
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
      var response = await http.patch(
        Uri.parse(path),
        body: payload,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (!isAuth) 'Authorization': "Bearer ${_authToken ?? ''}"
        },
      );
      debugPrint(DateTime.now().toString());
      // debugPrint('$_basepath/$path');
      debugPrint(response.statusCode.toString());
      debugPrint(response.body);
      return _processResponse(response);
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
      var response = await http.put(
        Uri.parse(path),
        body: payload,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (!isAuth) 'Authorization': "Bearer ${_authToken ?? ''}"
        },
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

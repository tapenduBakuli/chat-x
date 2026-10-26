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

// class BaseClient {
//   BaseClient._();
//
//   static final instance = BaseClient._();
//
//   static const int timeOutDuration = 20;
//   var token = HiveStore().getString(Keys.AUTHTOKEN);
//
//   //GET
//   Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
//    if (query != null) {
//       path = "$path?";
//       query.forEach((key, value) {
//         path += "$key=$value&";
//       });
//     }
//
//     try {
//       var response = await http.get(
//
//         Uri.parse(path),
//         headers: <String, String>{
//           'Content-Type': AppStrings.contentType,
//           'Authorization': "Bearer $token"
//         },
//       );
//
//       debugPrint(DateTime.now().toString());
//
//       log(response.body);
//        if (query != null) debugPrint(query.toString());
//       debugPrint(response.statusCode.toString());
//       print("okk");
//       return response;
//     } on SocketException {
//       throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
//     } on TimeoutException {
//       throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
//     }
//   }
//
// //POST
//   Future<dynamic> post( path, dynamic payloadObj,
//       {bool isAuth = false}) async {
//
//     var payload = jsonEncode(payloadObj);
//     print(payload);
//
//     try {
//       var response = await http.post(
//        Uri.parse(path),
//         body: payload,
//         headers: <String, String>{
//           'Content-Type': AppStrings.contentType,
//           if (!isAuth) 'Authorization': "Bearer $token"
//         },
//       );
//       debugPrint(DateTime.now().toString());
//       debugPrint(payload);
//       debugPrint(response.statusCode.toString());
//       debugPrint(response.body.toString());
//       log(response.body.toString());
//
//       return response;
//     } on SocketException {
//       throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
//     } on TimeoutException {
//       throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
//     }
//   }
//
//   // Future<dynamic> put(String path, dynamic data) async {
//   //   var token = GetStorage().read(UserData.token);
//   //   try {
//   //     final response = await http.put(
//   //       Uri.parse('$_basepath/$path'),
//   //       headers: <String, String>{
//   //         'Content-Type': 'application/json; charset=UTF-8',
//   //         'Authorization': "Bearer $token"
//   //       },
//   //       body: jsonEncode(data),
//   //     );
//   //     debugPrint(DateTime.now().toString());
//   //     debugPrint('$_basepath/$path');
//   //     debugPrint(response.statusCode.toString());
//   //     debugPrint(response.body);
//   //     return _processResponse(response);
//   //   } on SocketException {
//   //     throw FetchDataException('${ConfigStringConstants.noInternetConnection}', '$_basepath/$path');
//   //   } on TimeoutException {
//   //     throw ApiNotResponding('${ConfigStringConstants.apiNotRespondingAtTime}', '$_basepath/$path');
//   //   }
//   // }
//
//   Future<dynamic> delete( path, dynamic payloadObj) async {
//     // var token = GetStorage().read(UserData.token);
//     try {
//       final response = await http.delete(
//         Uri.parse(path),
//         body: jsonEncode(payloadObj),
//         headers: <String, String>{
//           'Content-Type': AppStrings.contentType,
//           'Authorization': "Bearer $token"
//         },
//       );
//       debugPrint(DateTime.now().toString());
//       //debugPrint('$_basepath/$path');
//       debugPrint(response.statusCode.toString());
//       debugPrint(response.body);
//       return response;
//       //return _processResponse(response);
//     } on SocketException {
//       throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
//     } on TimeoutException {
//       throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
//     }
//   }
//
//   //PATCH
//   Future<dynamic> patch( path, dynamic payloadObj,
//       {bool isAuth = false}) async {
//     // var token = GetStorage().read(UserData.token);
//     var payload = json.encode(payloadObj);
//     debugPrint(payload);
//     try {
//       var response = await http.patch(
//         Uri.parse(path),
//         body: payload,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           if (!isAuth) 'Authorization': "Bearer $token"
//         },
//       );
//       debugPrint(DateTime.now().toString());
//       // debugPrint('$_basepath/$path');
//       debugPrint(response.statusCode.toString());
//       debugPrint(response.body);
//       return _processResponse(response);
//     } on SocketException {
//       throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
//     } on TimeoutException {
//       throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
//     }
//   }
//   //Put
//   Future<dynamic> put( path, dynamic payloadObj,
//       {bool isAuth = false}) async {
//     // var token = GetStorage().read(UserData.token);
//     //var payload = json.encode(payloadObj);
//      var payload = jsonEncode(payloadObj);
//     debugPrint(payload);
//     try {
//       var response = await http.put(
//         Uri.parse(path),
//         body: payload,
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           if (!isAuth) 'Authorization': "Bearer $token"
//         },
//       );
//       debugPrint(DateTime.now().toString());
//       // debugPrint('$_basepath/$path');
//       debugPrint(response.statusCode.toString());
//       debugPrint(response.body);
//       return response;
//     //  return _processResponse(response);
//     } on SocketException {
//       throw FetchDataException('${AppStrings.noInternetConnection}', '$path');
//     } on TimeoutException {
//       throw ApiNotResponding('${AppStrings.apiNotRespondingAtTime}', '$path');
//     }
//   }
//   dynamic _processResponse(http.Response response) {
//     switch (response.statusCode) {
//       case 200:
//         // var responseJson = json.decode(response.body);
//         var responseJson = json.decode(utf8.decode(response.bodyBytes));
//         return responseJson;
//       case 201:
//         var responseJson =
//             json.decode(response.body); //utf8.decode(response.body);
//         return responseJson;
//       case 202:
//         var responseJson = json.decode(response.body);
//         return responseJson;
//       case 400:
//         var responseJson = json.decode(response.body);
//         return responseJson;
//       case 404:
//         var responseJson = json.decode(response.body);
//         return responseJson;
//       case 401:
//       case 403:
//         throw UnAuthorizedException(
//             utf8.decode(response.bodyBytes), response.request!.url.toString());
//       case 502:
//         throw UnAuthorizedException(
//             utf8.decode(response.bodyBytes), response.request!.url.toString());
//       case 422:
//         throw BadRequestException(
//             utf8.decode(response.bodyBytes), response.request!.url.toString());
//       case 500:
//       default:
//         throw FetchDataException(
//             '${AppStrings.errorOccuredWithCode} : ${response.statusCode}',
//             response.request!.url.toString());
//     }
//   }
// }

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:voiceroomkit_ui/base/device_manager.dart';
import 'package:voiceroomkit_ui/config/app_config.dart';
import 'package:voiceroomkit_ui/service/profile/app_profile.dart';
import 'package:voiceroomkit_ui/service/servers.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';

class AppHttpClient {
  static AppHttpClient? _instance;

  factory AppHttpClient() {
    return _instance ??= AppHttpClient._internal();
  }

  late final Dio dio;

  AppHttpClient._internal() {
    var options = BaseOptions(
        baseUrl: AppConfig().baseUrl,
        connectTimeout: Duration(milliseconds: servers.connectTimeout),
        receiveTimeout: Duration(milliseconds: servers.receiveTimeout));

    dio = Dio(options);
  }

  /// common header
  Map<String, dynamic> get headers => {
        'accountToken': AppProfile.accountToken,
        'accountId': AppProfile.accountId,
        'appKey': AppConfig().appKey,
        'clientType': DeviceManager().clientType,
        'appVersionName': AppConfig().versionName,
        'appVersionCode': AppConfig().versionCode,
        'deviceId': DeviceManager().deviceId,
        'lang': AppConfig().language,
      };

  /// post request data data -- json
  Future<Response?> post(String path, data, {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      VoiceRoomKitLog.d('HTTP',
          'req url=${AppConfig().baseUrl}$path, header=${kReleaseMode ? '' : options.headers.toString()} params=${data?.toString()}');
      response = await dio.post(path, data: data, options: options);
    } on DioError catch (e) {
      VoiceRoomKitLog.e('HTTP', '$path error=$e');
    }
    return response;
  }

  /// post request data data -- json
  Future<Response?> postUri(Uri uri, data, {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      VoiceRoomKitLog.d('HTTP',
          'req path=$uri header=${kReleaseMode ? '' : options.headers.toString()} params=${data?.toString()}');
      response = await dio.postUri(uri, data: data, options: options);
    } on DioError catch (e) {
      VoiceRoomKitLog.e('HTTP', '$uri error=$e');
    }
    return response;
  }

  Future<Response?> downloadFile(String url, ProgressCallback onReceiveProgress,
      {Options? options}) async {
    Response? response;
    try {
      options ??= Options();
      options.headers = mergeHeaders(options.headers, headers);
      options.responseType = ResponseType.bytes;
      options.receiveTimeout = Duration(milliseconds: 0);
      VoiceRoomKitLog.d('HTTP', 'down load file $url');
      response = await dio.get(url,
          onReceiveProgress: onReceiveProgress, options: options);
    } on DioError catch (e) {
      VoiceRoomKitLog.e('HTTP', '$url error=$e');
    }
    return response;
  }

  static Map<String, dynamic>? mergeHeaders(
      Map<String, dynamic>? lhs, Map<String, dynamic>? rhs) {
    if (lhs != null || rhs != null) {
      return {
        if (lhs != null) ...(lhs..removeWhere((key, value) => value == null)),
        if (rhs != null) ...(rhs..removeWhere((key, value) => value == null)),
      };
    }
    return null;
  }
}

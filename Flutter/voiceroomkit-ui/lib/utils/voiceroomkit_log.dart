// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:voiceroomkit_ui/constants/consts.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRoomKitLog {
  static Future<bool> init() async {
    var logRootPath = await _defaultLogRootPath;
    var rootPath = logRootPath.endsWith('/') ? logRootPath : '$logRootPath/';
    String roomSDKPath = '${rootPath}voiceroomkit/';
    if (!(await _createDirectory(rootPath))) return false;
    final success = Alog.init(ALogLevel.verbose, roomSDKPath, "voiceroomkit");
    return success;
  }

  static void i(String tag, String content) {
    Alog.i(tag: tag, moduleName: moduleName, content: content);
  }

  static void d(String tag, String content) {
    Alog.d(tag: tag, moduleName: moduleName, content: content);
  }

  static void e(String tag, String content) {
    Alog.e(tag: tag, moduleName: moduleName, content: content);
  }

  static Future<bool> _createDirectory(String path) async {
    var isCreate = false;
    var filePath = Directory(path);
    try {
      if (!await filePath.exists()) {
        await filePath.create();
        isCreate = true;
      } else {
        isCreate = true;
      }
    } catch (e) {
      isCreate = false;
      print('error $e');
    }
    return isCreate;
  }

  static Future<String> get _defaultLogRootPath async {
    var directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }
    return '${directory.path}/log/';
  }
}

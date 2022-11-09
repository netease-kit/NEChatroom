// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:path_provider/path_provider.dart';

class AudioHelper {
  AudioHelper._internal();

  static final AudioHelper _singleton = AudioHelper._internal();

  factory AudioHelper() => _singleton;

  late String musicPath1;
  late String musicPath2;
  late String musicPath3;
  late String effectPath1;
  late String effectPath2;

  void init() async {
    copyFile(AssetName.music1, 'music1').then((value) => musicPath1 = value);
    copyFile(AssetName.music2, 'music2').then((value) => musicPath2 = value);
    copyFile(AssetName.music3, 'music3').then((value) => musicPath3 = value);
    copyFile(AssetName.effect1, 'effect1').then((value) => effectPath1 = value);
    copyFile(AssetName.effect2, 'effect2').then((value) => effectPath2 = value);
  }

  Future<String> copyFile(String assetName, String filename) async {
    var bytes = await rootBundle.load(assetName);
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    return '$dir/$filename';
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}

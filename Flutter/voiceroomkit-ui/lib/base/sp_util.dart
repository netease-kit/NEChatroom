// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

abstract class Preferences {
  static SharedPreferences? instance;

  Future prepare() async {
    instance ??= await SharedPreferences.getInstance();
  }

  /// save
  Future<void> setSp(String key, String value) async {
    await prepare();
    instance!.setString(key, value);
  }

  Future<void> setBoolSp(String key, bool value) async {
    await prepare();
    instance!.setBool(key, value);
  }

  Future<void> setIntSp(String key, int value) async {
    await prepare();
    instance!.setInt(key, value);
  }

  /// get
  Future<String?> getSp(String key) async {
    await prepare();
    return instance!.get(key) as String?;
  }

  Future<bool?> getBoolSp(String key) async {
    await prepare();
    return instance!.getBool(key);
  }

  Future<int?> getIntSp(String key) async {
    await prepare();
    return instance!.getInt(key);
  }
}

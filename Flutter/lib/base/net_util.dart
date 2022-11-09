// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:connectivity_plus/connectivity_plus.dart';

class NetUtil {
  static final NetUtil _singleton = NetUtil._internal();

  factory NetUtil() {
    return _singleton;
  }

  NetUtil._internal();

  static ConnectivityResult globalNetWork = ConnectivityResult.none;

  void addListener() {
    isConnectedType();

    ///netWork
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      globalNetWork = result;
    });
  }

  void isConnectedType() async {
    //获取网络连接类型
    var connectivityResult = await (Connectivity().checkConnectivity());
    globalNetWork = connectivityResult;
  }
}

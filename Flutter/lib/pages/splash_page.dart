// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/pages/welcome_page.dart';
import 'package:voiceroomkit_ui/utils/userinfo_manager.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../base/base_state.dart';
import 'home_page.dart';
import '../app_config.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends BaseState<SplashPage> {
  bool hasLogin = false;
  @override
  void initState() {
    super.initState();
    var config = AppConfig();
    Alog.i(
        tag: 'appInit',
        content: 'vName=${config.versionName} vCode=${config.versionCode}');
    _doInit();
  }

  @override
  Widget build(BuildContext context) {
    if(hasLogin){
      return const HomePageRoute();
    }else{
      return const Scaffold(
        body: Center(
          child: Text("will go to homePage after login...",style: TextStyle(fontSize: 16),),
        ),
      );
    }
  }

  void _doInit() {
    var extras = <String, String>{};
    if (AppConfig().isOverSea) {
      extras["serverUrl"] = "oversea";
    }
    extras["baseUrl"] = AppConfig.baseurl;
    // var options =
    // NEVoiceRoomKitOptions(appKey: AppConfig().appKey, extras: extras);
    var options =
        NEVoiceRoomKitOptions(appKey: AppConfig().appKey, extras: extras);
    NEVoiceRoomKit.instance.initialize(options).then((value) {
      if (value.isSuccess()) {
        Alog.d(content: "voice room init success");
      } else {
        Alog.d(
            content:
                "voice room init failed code: ${value.code} message: ${value.msg}");
      }
      NEVoiceRoomKit.instance
          .login(AppConfig.account, AppConfig.token)
          .then((value) async {
        bool isLoggedIn = await NEVoiceRoomKit.instance.isLoggedIn;
        UserInfoManager.setUserInfo(AppConfig.account, AppConfig.token,
            AppConfig.nickname, AppConfig.avatar);
        setState(() {
          hasLogin = isLoggedIn;
        });
      });
    }).catchError((e) {
      Alog.d(content: 'voice room init failed with error ${e.toString()}');
    });
  }
}

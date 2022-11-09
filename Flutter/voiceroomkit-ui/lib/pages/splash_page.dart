// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_auth/auth.dart';
import 'package:netease_auth/provider/login_provider.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/pages/welcome_page.dart';
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
    return Consumer<LoginModel>(
      builder: (context, loginModel, child) {
        if (loginModel.loginState == LoginState.logined) {
          return const HomePageRoute();
        } else if (loginModel.loginState == LoginState.logout) {
          return UnifyLogin.goLoginPage(context);
        } else {
          if (loginModel.loginState == LoginState.logining) {
            NEVoiceRoomKit.instance
                .login(loginModel.userInfo!.accountId!,
                    loginModel.userInfo!.accessToken!)
                .then((value) async {
              var isLoggedIn = await NEVoiceRoomKit.instance.isLoggedIn;
              UnifyLogin.setLoginResult(value.isSuccess() || isLoggedIn);
            });
          }
          return const WelcomePage();
        }
      },
    );
  }

  void _doInit() {
    var extras = <String, String>{};
    if (AppConfig().isOverSea) {
      extras["serverUrl"] = "oversea";
    }
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

      UnifyLogin.initLoginConfig(AppConfig().appKey, AppConfig().parentScope,
          AppConfig().scope, false);

      /// 自动登录
      var state = Provider.of<LoginModel>(context, listen: false).loginState;
      if (state == LoginState.init) {
        UnifyLogin.loginWithToken();
      }
    }).catchError((e) {
      Alog.d(content: 'voice room init failed with error ${e.toString()}');
    });
  }
}

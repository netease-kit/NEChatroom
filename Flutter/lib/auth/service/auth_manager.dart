// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/app_config.dart';
import 'package:voiceroomkit_ui/auth/service/result.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:yunxin_alog/yunxin_alog.dart';
import 'dart:convert';
import '../../base/global_preferences.dart';
import 'auth_state.dart';
import 'login_info.dart';

class AuthManager {
  static const String _tag = 'AuthManager';

  factory AuthManager() => _instance ??= AuthManager._internal();

  static AuthManager? _instance;
  LoginInfo? _loginInfo;
  final bool _autoRegistered = false;

  final StreamController<LoginInfo?> _authInfoChanged =
      StreamController.broadcast();

  AuthManager._internal();

  Future<void> init() async {
    var loginInfo = await GlobalPreferences().loginInfo;
    if (TextUtils.isEmpty(loginInfo)) return;
    try {
      final cachedLoginInfo =
          LoginInfo.fromJson(jsonDecode(loginInfo as String) as Map);
      _authInfoChanged.add(cachedLoginInfo);
      _loginInfo = cachedLoginInfo;

      bool isLogged = await NEVoiceRoomKit.instance.isLoggedIn;
      AuthState()
          .updateState(state: isLogged ? AuthState.authed : AuthState.init);
    } catch (e) {
      VoiceRoomKitLog.d(
          _tag,
          'LoginInfo.fromJson(jsonDecode(loginInfo) exception = ' +
              e.toString());
    }
  }

  String? get accountId => _loginInfo?.accountId;

  String? get nickName => _loginInfo?.nickname;

  String? get mobilePhone => _loginInfo?.account;

  String? get accountToken => _loginInfo?.accountToken;

  String? get avatar => _loginInfo?.avatar;

  bool? get autoRegistered => _autoRegistered;

  Future<bool> autoLogin() async {
    if (_loginInfo == null || TextUtils.isEmpty(_loginInfo?.accountId)) {
      return Future.value(false);
    }

    if (isLogined()) {
      Alog.i(
          tag: _tag,
          content:
              'autoLogin but isLogined, nelive need refresh account and token');
      if (_loginInfo != null) {
        NEVoiceRoomKit.instance
            .login(_loginInfo!.accountId, _loginInfo!.accountToken);
      }
      return Future.value(true);
    }

    AuthState().updateState(state: AuthState.init);
    var result = await loginWithToken(_loginInfo!);
    return Future.value(result.code == 0);
  }

  Future<Result<void>> loginWithToken(LoginInfo loginInfo) async {
    var completer = Completer<Result<void>>();
    NEVoiceRoomKit.instance
        .login(loginInfo.accountId, loginInfo.accountToken)
        .then((value) {
      if (value.code == 0) {
        AuthState().updateState(state: AuthState.authed);
        _syncAuthInfo(loginInfo);
      }
      return completer.complete(Result(code: value.code, msg: value.msg));
    });
    return completer.future;
  }

  void _syncAuthInfo(LoginInfo loginInfo) {
    _loginInfo = loginInfo;
    GlobalPreferences().setLoginInfo(jsonEncode(loginInfo));
    _authInfoChanged.add(loginInfo);
  }

  void logout() {
    NEVoiceRoomKit.instance.logout();
    _loginInfo = null;
    GlobalPreferences().setLoginInfo('{}');
    _authInfoChanged.add(_loginInfo);
  }

  Stream<LoginInfo?> authInfoStream() {
    return _authInfoChanged.stream;
  }

  void tokenIllegal(String errorTip) {
    logout();
    AuthState().updateState(state: AuthState.tokenIllegal, errorTip: errorTip);
  }

  bool isLogined() {
    return AuthState().state == AuthState.authed;
  }
}

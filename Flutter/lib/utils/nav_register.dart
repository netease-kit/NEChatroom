// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:voiceroomkit_ui/auth/login_page.dart';
import 'package:voiceroomkit_ui/pages/live_list_page.dart';
import 'package:voiceroomkit_ui/pages/home_page.dart';
import 'package:voiceroomkit_ui/pages/room_page.dart';

import '../pages/start_live_page.dart';
import '../pages/home_page.dart';
import '../pages/about_logout_view.dart';
import '../pages/about_view.dart';
import '../constants/router_name.dart';

class RoutesRegister {
  static Map<String, WidgetBuilder> routes(RouteSettings settings) {
    return {
      RouterName.homePage: (context) => HomePageRoute(),
      RouterName.loginPage: (context) => const LoginRoute(),
      RouterName.aboutView: (context) => AboutViewRoute(),
      RouterName.aboutLogoutView: (context) => const AboutLogoutViewRoute(),
      RouterName.liveListPage: (context) => const LiveListPage(),
      RouterName.startLivePage: (context) => const StartLivePageRoute(),
      RouterName.roomPage: (context) =>
          RoomPageRoute(arguments: settings.arguments as Map<String, dynamic>),
    };
  }
}

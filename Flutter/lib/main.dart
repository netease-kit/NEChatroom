// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/constants/style/app_style_util.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/pages/splash_page.dart';
import 'package:voiceroomkit_ui/app_config.dart';
import 'package:voiceroomkit_ui/utils/audio_helper.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import 'utils/application.dart';
import 'base/net_util.dart';
import 'utils/nav_register.dart';

void main() {
  AppStyle.setStatusBarTextBlackColor();
  VoiceRoomKitLog.init()
      .then((value) => VoiceRoomKitLog.i("main", "log init result = $value"));
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      AppConfig().init().then((value) {
        // _initializeFlutterFire();
        runApp(NEVoiceRoomApp());
        if (Platform.isAndroid) {
          var systemUiOverlayStyle = const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black,
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.light);
          SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        }
        NetUtil().addListener();
      });
    });
  }, (Object error, StackTrace stack) {
    Alog.e(
        tag: 'flutter-crash',
        content:
            'crash exception: timeMillis:${DateTime.now().millisecondsSinceEpoch},$error \ncrash stack: $stack');
    // FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class NEVoiceRoomApp extends StatelessWidget {
  NEVoiceRoomApp({Key? key}) : super(key: key) {
    AudioHelper().init();
  }

  @override
  Widget build(BuildContext context) {
    Application.context = context;
    return MaterialApp(
        builder: BotToastInit(),
        color: Colors.black,
        theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light)),
        themeMode: ThemeMode.light,
        // navigatorKey: NavUtils.navigatorKey,
        home: const SplashPage(),
        navigatorObservers: [BotToastNavigatorObserver(), routeObserver],
        // routes: RoutesRegister.routes,
        onGenerateRoute: (settings) {
          WidgetBuilder builder =
          RoutesRegister.routes(settings)[settings.name]
          as WidgetBuilder;
          return MaterialPageRoute(
              builder: (ctx) => builder(ctx),
              settings: RouteSettings(name: settings.name));
        },
        localizationsDelegates: const [
          S.delegate,
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          print('deviceLocale languageCode: ${deviceLocale?.languageCode}');
          if (languageCodeZh == deviceLocale?.languageCode) {
            AppConfig().language = languageCodeZh;
          } else {
            AppConfig().language = languageCodeEn;
          }
        },
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ]);
  }
}

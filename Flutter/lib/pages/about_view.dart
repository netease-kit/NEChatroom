// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/utils/nav_utils.dart';
import 'package:voiceroomkit_ui/app_config.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/constants/colors.dart';
import 'package:voiceroomkit_ui/constants/dimem.dart';
import 'package:package_info/package_info.dart';
import 'package:netease_roomkit/netease_roomkit.dart';

import '../constants/servers.dart';
import '../utils/web_view_utils.dart';

///关于页面
class AboutViewRoute extends StatefulWidget {
  const AboutViewRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AboutViewRouteRouteState();
  }
}

class _AboutViewRouteRouteState extends State<AboutViewRoute> {
  NESDKVersions? _nesdkVersions;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );
  String? _imVersion;
  String? _videoVersion;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initSDKVersionInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: _buildContentView(),
          onTap: () {}
          // _touchAreaClickCallback(),
          ),
    );
  }

  Widget _buildContentView() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: viewportConstraints.maxHeight,
        ),
        child: Container(
          color: AppColors.color_1a1a24,
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).padding.top,
              ),
              Container(
                height: 80,
                color: AppColors.color_191923,
                alignment: Alignment.center,
                child: buildTitle(S.of(context).about),
              ),
              itemLine(),
              Container(
                height: 218,
                child: Image.asset(AppConfig().isZh
                    ? AssetName.iconAboutLogoZH
                    : AssetName.iconAboutLogoEN),
              ),
              buildSystemSettingItem(
                  S.of(context).appVersion, _packageInfo.version),
              buildSystemSettingItem(S.of(context).imVersion,
                  _nesdkVersions?.imVersion ?? S.of(context).unKnowVersion),
              buildSystemSettingItem(S.of(context).audioAndVideoSdkVersion,
                  _nesdkVersions?.rtcVersion ?? S.of(context).unKnowVersion),
              buildSettingItemPadding(),
              buildSettingItem(
                  S.of(context).privacyPolicy,
                  () =>
                      {WebViewUtils.launchInWebViewOrVC(Servers().urlPrivacy)}),
              buildSettingItem(
                  S.of(context).termsOfService,
                  () => {
                        WebViewUtils.launchInWebViewOrVC(
                            Servers().urlUserPolice)
                      }),
              buildSettingItem(
                  S.of(context).disclaimer,
                  () => {
                        WebViewUtils.launchInWebViewOrVC(
                            Servers().urlDisclaimer)
                      },
                  needBottomLine: false),
            ],
          ),
        ),
      ));
    });
  }

  Widget buildTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            NavUtils.pop(context);
          },
          child: Container(
            child: Image.asset(AssetName.iconBack),
            width: 24,
            margin: const EdgeInsets.only(left: 20),
          ),
        ),
        Container(
          height: Dimen.titleHeight,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
                color: AppColors.white,
                fontSize: TextSize.titleSize,
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 20),
        ),
      ],
    );
  }

  Widget buildSystemSettingItem(String title, String subtitle) {
    return GestureDetector(
      child: Container(
          height: Dimen.primaryItemHeight,
          color: AppColors.white_10_ffffff,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.white)),
                      const Spacer(),
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.white)),
                        ),
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
                ),
              ),
            ],
          )),
    );
  }

  Widget buildSettingItem(String title, VoidCallback voidCallback,
      {bool needBottomLine = true}) {
    return GestureDetector(
      child: Container(
          height: Dimen.primaryItemHeight,
          color: AppColors.white_10_ffffff,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.white)),
                      const Spacer(),

                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerRight,
                          // padding: EdgeInsets.only(right: 22),
                          child: Image.asset(AssetName.iconHomeMenuArrow),
                        ),
                      ),

                      // Icon(IconFont.iconyx_allowx, size: 14, color: AppColors.grey_cccccc)
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
                ),
              ),
              (needBottomLine
                  ? Container(
                      padding: EdgeInsets.only(left: Dimen.globalPadding),
                      child: itemLine(),
                    )
                  : Container(
                      padding: EdgeInsets.only(left: Dimen.globalPadding),
                    )),
            ],
          )),
      onTap: voidCallback,
    );
  }

  Container buildSettingItemPadding() {
    return Container(height: Dimen.globalPadding);
  }

  Widget itemLine() {
    return Container(
        margin: const EdgeInsets.only(left: 0, right: 0),
        color: AppColors.white_50_ffffff,
        height: 1);
  }

  Future<void> _initPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _initSDKVersionInfo() async {
    NESDKVersions nesdkVersions = await NERoomKit.instance.sdkVersions;
    setState(() {
      _nesdkVersions = nesdkVersions;
    });
  }
}

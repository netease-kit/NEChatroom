// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_auth/auth.dart';
import 'package:netease_auth/provider/login_provider.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/utils/nav_utils.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/constants/colors.dart';
import 'package:voiceroomkit_ui/constants/dimem.dart';

class AboutLogoutViewRoute extends StatefulWidget {
  const AboutLogoutViewRoute({
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _AboutLogoutViewRouteRouteState();
  }
}

class _AboutLogoutViewRouteRouteState extends State<AboutLogoutViewRoute> {
  String? iconUrl = LoginModel.instance.userInfo?.avatar;
  String nickname = LoginModel.instance.userInfo?.nickname ?? 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: _buildContentView(),
          onTap: () {}),
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
                child: buildTitle(S.of(context).settingTitle),
              ),
              itemLine(),
              buildSettingItemPadding(),
              buildPersonMessageItem(iconUrl, S.of(context).avatar),
              buildSystemSettingItem(S.of(context).nickName, nickname),
              buildSettingItemPadding(),
              GestureDetector(
                onTap: () {
                  ///click logout
                  UnifyLogin.logout();
                  NEVoiceRoomKit.instance.logout();
                  Navigator.pop(context);
                },
                child: Container(
                  height: Dimen.primaryItemHeight,
                  color: AppColors.white_10_ffffff,
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).logoutEn,
                    style:
                        const TextStyle(color: AppColors.white, fontSize: 17),
                  ),
                ),
              ),
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
            style: const TextStyle(
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

  Widget buildPersonMessageItem(String? iconUrl, String? name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      height: 88,
      color: AppColors.white_10_ffffff,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              (name ?? 'Null'),
              style: const TextStyle(color: AppColors.white, fontSize: 20),
            ),
          ),
          Container(
            height: 32,
            width: 32,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: (iconUrl == null || iconUrl.isEmpty)
                ? Image.asset(AssetName.iconAvatar)
                : Image.network(iconUrl),
          ),
        ],
      ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.globalPadding),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimen.globalPadding),
                ),
              ),
              (needBottomLine
                  ? Container(
                      padding: const EdgeInsets.only(left: Dimen.globalPadding),
                      child: itemLine(),
                    )
                  : Container(
                      padding: const EdgeInsets.only(left: Dimen.globalPadding),
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
}

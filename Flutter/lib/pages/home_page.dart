// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceroomkit_ui/base/data_center.dart';
import 'package:voiceroomkit_ui/base/global_preferences.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/config/app_config.dart';
import 'package:voiceroomkit_ui/constants/servers.dart';
import 'package:voiceroomkit_ui/service/auth/auth_manager.dart';
import 'package:voiceroomkit_ui/utils/dialog_utils.dart';
import 'package:voiceroomkit_ui/utils/web_view_utils.dart';
import 'package:voiceroomkit_ui/constants/ValueKeys.dart';
import '../../base/lifecycle_base_state.dart';
import '../utils/nav_utils.dart';
import '../constants/router_name.dart';
import '../constants/asset_name.dart';
import '../constants/colors.dart';
import '../constants/dimem.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageRouteState();
  }
}

class _HomePageRouteState extends LifecycleBaseState<HomePageRoute> {
  static const _tag = "_HomePageRouteState";

  late PageController _pageController;
  final List<int> _list = [];
  int _currentIndex = 0;
  DataCenter _dataCenter = DataCenter.mainland;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 1; i++) {
      _list.add(i);
    }
    GlobalPreferences().dataCenter.then((value) => setState(() {
          if (value == DataCenter.oversea.index) {
            _dataCenter = DataCenter.oversea;
          }
        }));
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChange,
          allowImplicitScrolling: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[buildHomePage(), buildSettingPage()],
        ),
        bottomNavigationBar: buildBottomAppBar());
  }

  BottomAppBar buildBottomAppBar() {
    return BottomAppBar(
        color: AppColors.white_15_ffffff,
        child: SizedBox(
            height: 54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildTabItem(
                        0,
                        _currentIndex == 0,
                        AssetName.iconHomeBottomMainSelect,
                        AssetName.iconHomeBottomMain),
                    buildTabItem(
                        1,
                        _currentIndex == 1,
                        AssetName.iconHomeBottomMineSelect,
                        AssetName.iconHomeBottomMine),
                  ],
                ),
              ],
            )));
  }

  Widget buildTabItem(
      int index, bool select, String selectAsset, String normalAsset) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _onTap(index);
      },
      child: Image.asset(select ? selectAsset : normalAsset,
          width: 130, height: 32),
    );
  }

  Widget buildHomePage() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetName.iconHomeBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(height: MediaQuery.of(context).padding.top),
          Container(
            height: 80,
            alignment: Alignment.center,
            child: Image(
              width: 250,
              height: 35,
              image: AssetImage(AppConfig().isZh
                  ? AssetName.iconHomePageLogoZH
                  : AssetName.iconHomePageLogoEN),
              fit: BoxFit.fill,
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              color: AppColors.white_10_ffffff,
              height: 1),
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            height: 300,
            // color: Colors.red,
            child: buildListView(),
          ),
          // Expanded(
          // )
        ],
      ),
    );
  }

  Widget buildListView() {
    return Scrollbar(
      child: ListView.builder(
        // scrollDirection: Axis.horizontal,//设置为水平布局
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return buildListViewItem(index);
          } else {
            return const Icon(Icons.add);
          }
        },
        itemCount: _list.length,
      ),
    );
  }

  Widget buildListViewItem(int index) {
    return GestureDetector(
        child: buildListViewDetail(),
        key: index == 0
            ? ValueKeys.buildListViewDetail0
            : ValueKeys.buildListViewDetail,
        onTap: () {
          // todo NELiveKit.instance.nickname = AuthManager().nickName;
          NavUtils.pushNamed(context, RouterName.liveListPage);
        });
  }

  Widget buildListViewDetail() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: AppColors.black_80,
        // border: new Border.all(color: ColorUtil.hexColor(0x38CFCF),width: 0.5),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 48,
            height: 48,
            child: Image(
              image: AssetImage(AssetName.iconHomeVoiceRoom),
              fit: BoxFit.fill,
            ),
          ),
          Container(
            width: 12,
          ),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).homeListViewDetailText1,
                  style: TextStyle(color: AppColors.white, fontSize: 18),
                ),
                Container(
                  height: 8,
                ),
                Text(
                  S.of(context).homeListViewDetailText2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.white),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(AssetName.iconHomeMenuArrow),
          ),
        ],
      ),
    );
  }

  Widget buildTopView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(AssetName.tabSetting),
        const Text('',
            style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
        const Text(
          ' | Real-time audio and video',
          style: TextStyle(color: AppColors.white, fontSize: 18),
        ),
        Container(
          width: 18,
        )
      ],
    );
  }

  Expanded buildItem(String assetStr, String text, VoidCallback voidCallback) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: voidCallback,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image(
            //     image: AssetImage(assetStr, package: Packages.uiKit),
            //     width: Dimen.homeIconSize,
            //     height: Dimen.homeIconSize),
            Text(text,
                style: const TextStyle(
                    color: AppColors.black_222222,
                    fontSize: 14,
                    fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  }

  Widget buildSettingPage() {
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
              Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  color: AppColors.white_10_ffffff,
                  height: 1),
              buildSettingItemPadding(),
              buildPersonMessageItem(
                  AuthManager().avatar, AuthManager().nickName),
              buildSettingItemPadding(),
              buildSettingItem(S.of(context).freeForTest, () {
                WebViewUtils.launchInWebViewOrVC(Servers().urlFreeTrail);
              }),
              buildSettingItem(S.of(context).about, () {
                NavUtils.pushNamed(context, RouterName.aboutView);
              }, needBottomLine: false),
              buildSettingItemPadding(),
            ],
          ),
        ),
      ));
    });
  }

  Container buildTitle(String title) {
    return Container(
      height: Dimen.titleHeight,
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
            color: AppColors.white,
            fontSize: TextSize.titleSize,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Container buildSettingItemPadding() {
    return Container(height: Dimen.globalPadding);
  }

  Widget buildPersonMessageItem(String? iconUrl, String? name) {
    return GestureDetector(
      onTap: () {
        NavUtils.pushNamed(context, RouterName.aboutLogoutView);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        height: 88,
        color: AppColors.white_10_ffffff,
        child: Row(
          children: <Widget>[
            //图片
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: iconUrl != null
                  ? Image.network(iconUrl)
                  : Image.asset(AssetName.iconAvatar),
            ),

            Container(
              width: 12,
            ),

            Text(
              name ?? 'name',
              style: const TextStyle(color: AppColors.white, fontSize: 20),
            ),

            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: Image.asset(AssetName.iconHomeMenuArrow),
              ),
            ),
          ],
        ),
      ),
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

  Widget buildDataCenterItem() {
    return Theme(
        data: ThemeData(unselectedWidgetColor: AppColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(S.of(context).dataCenterTitle,
                style: const TextStyle(fontSize: 16, color: AppColors.white)),
            Radio<DataCenter>(
                activeColor: AppColors.white,
                value: DataCenter.mainland,
                groupValue: _dataCenter,
                onChanged: (value) {
                  _switchDataCenter(value);
                }),
            Text(S.of(context).dataCenterCN,
                style: const TextStyle(fontSize: 16, color: AppColors.white)),
            Radio<DataCenter>(
                hoverColor: AppColors.white,
                value: DataCenter.oversea,
                groupValue: _dataCenter,
                onChanged: (value) {
                  _switchDataCenter(value);
                }),
            Text(S.of(context).dataCenterOverSea,
                style: const TextStyle(fontSize: 16, color: AppColors.white)),
          ],
        ));
  }

  _switchDataCenter(DataCenter? value) async {
    if (value != null && _dataCenter != value) {
      if (await _switchDataCenterDialog()) {
        setState(() {
          _dataCenter = value;
        });
        await GlobalPreferences().setDataCenter(value.index);
        AuthManager().logout();
        await NEVoiceRoomKit.instance.logout();
        if (Platform.isAndroid) {
          Restart.restartApp();
        } else {
          exit(0);
        }
      }
    }
  }

  Future<bool> _switchDataCenterDialog() async {
    var ret = false;
    await DialogUtils.showCommonDialog(context, S.of(context).tip,
        S.of(context).dataCenterSwitchConfirmMessage, () {}, () {
      ret = true;
    }, cancelText: S.of(context).no, acceptText: S.of(context).yes);
    return ret;
  }

  Widget buildPersonItem(String title, VoidCallback voidCallback,
      {String titleTip = '', String arrowTip = ''}) {
    return GestureDetector(
      child: Container(
        height: Dimen.primaryItemHeight,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
        child: Row(
          children: <Widget>[
            Text(title,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.black_222222)),
            titleTip == ''
                ? Container()
                : Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.only(
                        left: 8, top: 3, right: 8, bottom: 3),
                    color: AppColors.color_1a337eff,
                    child: Text(titleTip,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.color_337eff)),
                  ),
            const Spacer(),
            arrowTip == ''
                ? Container()
                : Text(
                    arrowTip,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.color_999999),
                  ),
            Container(
              width: 20,
            ),
          ],
        ),
      ),
      onTap: voidCallback,
    );
  }

  void onPageChange(int value) {
    if (_currentIndex != value) {
      setState(() {
        _currentIndex = value;
      });
    }
  }

  void _onTap(int value) {
    _pageController.jumpToPage(value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget line() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimen.globalPadding),
      color: AppColors.color_e8e9eb,
      height: 0.5,
    );
  }

  Widget itemLine() {
    return Container(
        margin: const EdgeInsets.only(left: 0, right: 0),
        color: AppColors.white_50_ffffff,
        height: 1);
  }
}

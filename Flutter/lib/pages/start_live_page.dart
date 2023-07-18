// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/app_config.dart';
import 'package:voiceroomkit_ui/utils/userinfo_manager.dart';
import 'package:voiceroomkit_ui/widgets/live_info_view.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../base/lifecycle_base_state.dart';
import '../utils/nav_utils.dart';
import '../constants/router_name.dart';
import '../utils/loading.dart';
import '../utils/toast_utils.dart';
import '../constants/ValueKeys.dart';
import '../constants/asset_name.dart';
import '../constants/colors.dart';
import '../model/start_live_arguments.dart';

class StartLivePageRoute extends StatefulWidget {
  const StartLivePageRoute({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _StartLivePageRouteState();
  }
}

class _StartLivePageRouteState extends LifecycleBaseState<StartLivePageRoute> {
  static const _tag = '_StartLivePageRouteState';

  @override
  void initState() {
    super.initState();
    bool isAllGranted = true;
    _requestPermissions().then((value) {
      value.forEach((key, value) {
        if (value.isDenied || value.isPermanentlyDenied) {
          Alog.e(tag: _tag, content: '${key.toString()} is denied');
          isAllGranted = false;
        }
      });
      if (!isAllGranted) {
        NavUtils.pop(context,
            arguments: StartLiveArguments(StartLiveResult.noPermission));
      }
    });
  }

  Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
    ].request();
    return statuses;
  }

  String? _cover;
  String? _topic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => {Navigator.of(context).pop(true)}),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0, //消除阴影
        ),
        body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetName.homePageBgIcon),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 20,
                    child: buildBottomView(),
                  ),
                  Positioned(
                      left: 10,
                      top: 100,
                      right: 10,
                      child: StartLiveInfoView(
                        onInfoChanged: (String? cover, String? topic) {
                          _cover = cover;
                          _topic = topic;
                        },
                      )),
                ],
              ),
            )));
  }

  Widget buildBottomView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: buildStartLiveButton(),
        ),
      ],
    );
  }

  void _startLive() async {
    LoadingUtil.showLoading();
    if (TextUtils.isNotEmpty(_topic) && TextUtils.isNotEmpty(_cover)) {
      // todo 改为上麦申请需要主播同意（默认）+ 邀请上麦需要观众同意（测试新增的麦位接口）
      var createVoiceRoomParams = NECreateVoiceRoomParams(
          title: _topic!,
          cover: _cover!,
          seatCount: 9,
          nick: UserInfoManager.getNickname(),
          configId: AppConfig().configId);

      NEVoiceRoomKit.instance
          .createRoom(createVoiceRoomParams, NECreateVoiceRoomOptions())
          .then((value) {
        LoadingUtil.cancelLoading();
        if (value.isSuccess()) {
          NavUtils.pushNamed(context, RouterName.roomPage, arguments: {
            'roomInfo': value.data as NEVoiceRoomInfo,
            'isAnchor': true
          });
        } else {
          ToastUtils.showToast(
              context, '${S.of(context).startLiveFailed}, ${value.msg}');
        }
      });
    } else {
      LoadingUtil.cancelLoading();
      ToastUtils.showToast(context, S.of(context).topAndCoverEmptyHint);
    }
  }

  @override
  void dispose() {
    LoadingUtil.cancelLoading();
    super.dispose();
  }

  buildStartLiveButton() {
    return GestureDetector(
      onTap: () {
        _startLive();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.only(left: 16, right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [
            AppColors.color_ff30F2F2,
            AppColors.color_ff6699ff,
          ]),
        ),
        alignment: Alignment.center,
        child: Text(
          S.of(context).startLive,
          key: ValueKeys.startLive,
          style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

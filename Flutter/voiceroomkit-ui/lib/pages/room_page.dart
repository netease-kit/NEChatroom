// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/utils/application.dart';
import 'package:voiceroomkit_ui/base/lifecycle_base_state.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat_event.dart';
import 'package:voiceroomkit_ui/utils/seat_util.dart';
import 'package:voiceroomkit_ui/utils/toast_utils.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:voiceroomkit_ui/constants/ValueKeys.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/viewmodel/seat_viewmodel.dart';
import 'package:voiceroomkit_ui/widgets/custom_dialog.dart';
import 'package:voiceroomkit_ui/widgets/seat_option_list_widget.dart';
import 'package:voiceroomkit_ui/widgets/seat_widget.dart';
import 'package:voiceroomkit_ui/viewmodel/roominfo_viewmodel.dart';
import 'package:voiceroomkit_ui/widgets/voice_room_buttom_tool_view.dart';
import 'package:wakelock/wakelock.dart';

import '../utils/nav_utils.dart';
import '../constants/router_name.dart';
import '../utils/dialog_utils.dart';
import '../constants/colors.dart';
import '../widgets/chatroom_list_view.dart';
import '../widgets/seat_apply_list_widget.dart';
import '../viewmodel/background_music_viewmodel.dart';

///房间页
class RoomPageRoute extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const RoomPageRoute({Key? key, required this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RoomPageRouteState();
  }
}

class _RoomPageRouteState extends LifecycleBaseState<RoomPageRoute> {
  //聊天消息列表.
  final ChatroomMessagesController _controller = ChatroomMessagesController();
  late NEVoiceRoomEventCallback _callback;
  late RoomInfoViewModel viewModel;
  bool _showCancelApplyUI = false;
  AudioMaxing audioMaxing = AudioMaxing();

  late SeatViewModel seatViewModel;
  //在线人数
  int? _memberNum;

  @override
  void initState() {
    super.initState();
    VoiceRoomKitLog.i(tag, "room page initState");
    Wakelock.enable();
    seatViewModel = SeatViewModel();
    viewModel = RoomInfoViewModel();
    viewModel.initData(widget.arguments);
    seatViewModel.initRoomInfo(viewModel.roomInfo);
    viewModel.joinRoom((value) {
      if (value == NEVoiceRoomErrorCode.success) {
        VoiceRoomKitLog.i(tag, "joinRoomSuccess");
        seatViewModel.initSeatInfo();
      } else {
        VoiceRoomKitLog.i(tag, "joinRoomFail");
        ToastUtils.showToast(context, "joinRoomFail");
        NavUtils.popUntil(context, RouterName.liveListPage);
      }
    });
    seatViewModel.eventBus.on<ChatroomTextMessage>().listen((event) {
      VoiceRoomKitLog.i(tag, "eventBus,ChatroomTextMessage event:$event");
      _controller.addMessage(event);
    });
    seatViewModel.eventBus.on<AudioBannedEvent>().listen((event) {
      VoiceRoomKitLog.i(tag, "eventBus,bool event:$event");
      if (event.audioBanned) {
        SeatUtil.showSeatMutedByAnchorTips(context);
      } else {
        SeatUtil.showSeatUnMutedByAnchorTips(context);
      }
    });
    seatViewModel.eventBus.on<int>().listen((event) {
      VoiceRoomKitLog.i(tag, "eventBus,int event:$event");
      if (event != SeatViewModel.CURRENT_SEAT_STATE_APPLYING) {
        _showCancelApplyUI = false;
      }
      _handleMyAudioState(event == SeatViewModel.CURRENT_SEAT_STATE_ON_SEAT);
    });

    seatViewModel.eventBus.on<VoiceRoomSeatEvent>().listen((event) {
      VoiceRoomKitLog.i(tag, "eventBus,VoiceRoomSeatEvent event:$event");
      if (event.reason == Reason.ANCHOR_INVITE ||
          event.reason == Reason.ANCHOR_APPROVE_APPLY) {
        _onEnterSeat(event, false);
      } else if (event.reason == Reason.ANCHOR_DENY_APPLY) {
        _onSeatApplyDenied(event);
      } else if (event.reason == Reason.LEAVE) {
        _onLeaveSeat(event, true);
      } else if (event.reason == Reason.ANCHOR_KICK) {
        _onLeaveSeat(event, false);
      }
    });

    seatViewModel.eventBus.on<ApplySeatEvent>().listen((event) {
      VoiceRoomKitLog.i(tag, "eventBus,VoiceRoomSeatEvent event:$event");
      _showCancelApplyUI = event.showCancelApplySeat;
    });

    _callback = NEVoiceRoomEventCallback(
      memberJoinRoomCallback: (List<NEVoiceRoomMember> members) {
        VoiceRoomKitLog.i(tag, "memberJoinRoomCallback :$members");
        _reloadWithDatas();
        for (var m in members) {
          if (!m.role.contains('host')) {
            _controller.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberJoin,
                  userUuid: m.account,
                  nickname: m.name),
            );
          }
        }
      },
      memberLeaveRoomCallback: (List<NEVoiceRoomMember> members) {
        VoiceRoomKitLog.i(tag, "memberLeaveRoomCallback :$members");
        _reloadWithDatas();
        for (var m in members) {
          if (!m.role.contains('host')) {
            _controller.addMessage(
              ChatroomNotifyMessage(
                  notifyType: ChatroomNotifyType.kMemberLeave,
                  userUuid: m.account,
                  nickname: m.name),
            );
          }
        }
      },
      receiveTextMessageCallback: (NEVoiceRoomChatTextMessage message) {
        VoiceRoomKitLog.i(tag, "receiveTextMessageCallback :$message");
        _controller.addMessage(
          ChatroomTextMessage(
              userUuid: message.fromUserUuid,
              nickname: message.fromNick,
              text: message.text,
              isAnchor:
                  message.fromUserUuid == viewModel.roomInfo.anchor?.account),
        );
      },
      roomEndedCallback: (NEVoiceRoomEndReason reason) {
        VoiceRoomKitLog.i(tag, "roomEndedCallback :$reason");
        if (!mounted) {
          return;
        }
        if (!viewModel.isAnchor && reason != NEVoiceRoomEndReason.leaveBySelf) {
          ToastUtils.showToast(Application.context, S.current.closeRoomTips);
          _leaveRoom();
        }
      },
    );
    NEVoiceRoomKit.instance.addVoiceRoomListener(_callback);
  }

  @override
  Widget build(BuildContext context) {
    VoiceRoomKitLog.i(tag, "room page build");
    _reloadWithDatas();
    return ChangeNotifierProvider(
      create: (context) {
        return seatViewModel;
      },
      builder: (context, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: WillPopScope(
            onWillPop: () {
              if (viewModel.isAnchor) {
                DialogUtils.showEndLiveDialog(context, '', () {}, () {
                  NEVoiceRoomKit.instance.endRoom().then((value) {
                    if (!mounted) {
                      return;
                    }
                    if (value.isSuccess()) {
                      ToastUtils.showToast(
                          context, S.of(context).endRoomSuccess);
                    } else {
                      ToastUtils.showToast(context, S.of(context).operateFail);
                    }
                    NavUtils.popUntil(context, RouterName.liveListPage);
                  });
                });
              } else {
                _leaveRoom();
              }
              return Future.value(false);
            },
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: _buildPageUI(context),
                onTap: () {
                  // todo _touchAreaClickCallback();
                }
                // _touchAreaClickCallback(),
                ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    NEVoiceRoomKit.instance.removeVoiceRoomListener(_callback);
    Wakelock.disable();
  }

  Widget _buildPageUI(BuildContext context) {
    SeatViewModel seatViewModel = context.watch<SeatViewModel>();
    return Stack(
      children: [
        _buildCommonUI(seatViewModel),
      ],
    );
  }

  Widget _buildCommonUI(SeatViewModel seatViewModel) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 背景
        _buildBgUI(),
        _buildChatListUI(),
        // 顶部UI，标题、公告、x 在线人数
        _buildTopUI(),
        _buildApplySeatUI(seatViewModel),
        _buildCancelApplySeatUI(seatViewModel),
        // 麦位UI
        const Positioned(
          top: 120,
          child: SeatWidget(),
        ),
        // 底部UI，包括聊天室评论框，右下角静音按钮、更多按钮
        _buildBottomUI(seatViewModel),
        _buildApplySeatListUI(seatViewModel),
      ],
    );
  }

  Widget _buildTopUI() {
    return ChangeNotifierProvider(
      create: (context) {
        return viewModel;
      },
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(

                ///房间名
                top: 8 + MediaQuery.of(context).padding.top,
                left: 8,
                width: MediaQuery.of(context).size.width - 30,
                height: 24,
                child: Text(
                  context
                          .watch<RoomInfoViewModel>()
                          .roomInfo
                          .liveModel
                          ?.liveTopic ??
                      S.of(context).roomName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                )),
            Positioned(

                ///退出房间按钮
                top: 8 + MediaQuery.of(context).padding.top,
                right: 8,
                width: 24,
                height: 24,
                child: GestureDetector(
                  onTap: _clickCancelButton,
                  child: const Image(
                    image: AssetImage(AssetName.iconTopCancel),
                  ),
                )),
            Positioned(
              ///公告栏
              left: 8,
              top: 45 + MediaQuery.of(context).padding.top,
              child: GestureDetector(
                onTap: _showAnnouncement,
                child: Container(
                  width: 60,
                  height: 20,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.color_ff0C0C0D,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Image(
                        image: AssetImage(AssetName.iconTopSpeaker),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        S.of(context).announcementTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              ///在线人数
              right: 8,
              top: 45 + MediaQuery.of(context).padding.top,
              // width: 54,
              height: 20,
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.color_ff0C0C0D,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  S.of(context).online +
                      (_memberNum ?? 0).toString() +
                      S.of(context).onlineNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatListUI() {
    double screenHeight = MediaQuery.of(context).size.height;
    double chatListHeight =
        screenHeight - 470 - MediaQuery.of(context).padding.top;
    VoiceRoomKitLog.i(tag, "screen height:$screenHeight");
    VoiceRoomKitLog.i(tag, "chatListHeight:$chatListHeight");
    return Positioned(
      ///chatView
      right: 87,
      bottom: 60,
      left: 8,
      height: chatListHeight,
      child: ChatroomListView(
        controller: _controller,
      ),
    );
  }

  Widget _buildApplySeatListUI(SeatViewModel seatViewModel) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: SeatApplyListWidget(
        seatViewModel: seatViewModel,
      ),
    );
  }

  Widget _buildBottomUI(SeatViewModel seatViewModel) {
    return Positioned(
        right: 8,
        bottom: 8,
        left: 8,
        height: 36,
        child: VoiceRoomBottomToolView(
          isAnchor: viewModel.isAnchor,
          isOnSeat: seatViewModel.isCurrentUserOnSeat(),
          isAudioMuted: seatViewModel.selfSeatMuted,
          controller: _controller,
          audioMaxing: audioMaxing,
        ));
  }

  Widget _buildBgUI() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetName.roomBg),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildApplySeatUI(SeatViewModel seatViewModel) {
    return Visibility(
        visible: SeatUtil.isAnchor(),
        child: Positioned(
            top: 80,
            child: InkWell(
              onTap: () {
                seatViewModel.setShowApplySeatListUI(true);
              },
              child: Visibility(
                visible: seatViewModel.applySeatList.isNotEmpty,
                child: Container(
                  height: 38,
                  key: ValueKeys.applySeatButton,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF9966),
                          Color(0xFFFF66b2),
                        ]),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          "${S.of(context).applySeat}(${seatViewModel.applySeatsNumber})",
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        const Image(
                            width: 20,
                            height: 20,
                            image:
                                AssetImage(AssetName.seatApplyArrowDownIcon)),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  void _showAnnouncement() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDialog(S.of(context).announcementTitle,
              S.of(context).announcementContent);
        });
  }

  void _clickCancelButton() {
    //页面退出
    if (viewModel.isAnchor) {
      //关闭直播间
      DialogUtils.showEndLiveDialog(context, '', () {}, () {
        NEVoiceRoomKit.instance.endRoom().then((value) {
          if (!mounted) {
            return;
          }
          if (value.isSuccess()) {
            ToastUtils.showToast(context, S.of(context).endRoomSuccess);
          } else {
            ToastUtils.showToast(context, S.of(context).operateFail);
          }
          NavUtils.popUntil(context, RouterName.liveListPage);
        });
      });
    } else {
      _leaveRoom();
    }
  }

  void _handleMyAudioState(bool isOnSeat) async {
    NEVoiceRoomMember? localMember = NEVoiceRoomKit.instance.localMember;
    if (localMember == null) {
      return;
    }
    VoiceRoomKitLog.i(tag,
        "handleMyAudioState,isAudioOn:${localMember.isAudioOn},isAudioBanned:${localMember.isAudioBanned}");
    if (isOnSeat && !localMember.isAudioOn) {
      var status = await Permission.microphone.status;
      if (status.isGranted) {
        VoiceRoomKitLog.i(tag, "microphone permission isGranted1");
        seatViewModel.unmuteMyAudio();
      } else {
        var permissionStatus = await Permission.microphone.request();
        VoiceRoomKitLog.i(tag, "microphone permission request");
        if (permissionStatus.isGranted) {
          VoiceRoomKitLog.i(tag, "microphone permission isGranted2");
          seatViewModel.unmuteMyAudio();
        } else {
          ToastUtils.showToast(context, "microphone permission denied");
          VoiceRoomKitLog.i(tag, "microphone permission denied");
        }
      }
    } else if (!isOnSeat && localMember.isAudioOn) {
      seatViewModel.muteMyAudio();
    }
  }

  void _onEnterSeat(VoiceRoomSeatEvent event, bool last) {
    // 更新右下角UI
    if (!last) {
      _hintSeatState(event, true);
    }
  }

  void _onSeatApplyDenied(VoiceRoomSeatEvent currentSeatEvent) {
    SeatUtil.showApplySeatRejectTips(context);

    /// 隐藏取消申请麦位的UI
  }

  void _onLeaveSeat(VoiceRoomSeatEvent event, bool bySelf) {
    if (!bySelf) {
      _hintSeatState(event, false);
    }
  }

  void _hintSeatState(VoiceRoomSeatEvent event, bool on) {
    if (on) {
      if (event.reason == Reason.ANCHOR_INVITE) {
        SeatUtil.showOnSeatByAnchorPickTips(context, event.index);
      } else if (event.reason == Reason.ANCHOR_APPROVE_APPLY) {
        // 展示打钩提示弹窗
      }
    } else {
      if (event.reason == Reason.ANCHOR_KICK) {
        SeatUtil.showKickSeatTips(context);
      }
    }
  }

  void _reloadWithDatas() {
    List<NEVoiceRoomMember>? memberList = NEVoiceRoomKit.instance.allMemberList;
    int? tempIconNum = memberList?.length;
    if (tempIconNum == null || tempIconNum == 0) {
      tempIconNum = 0;
    }
    setState(() {
      if (!mounted) {
        return;
      }
      _memberNum = (tempIconNum! - 1 < 0) ? 0 : (tempIconNum - 1);
    });
  }

  Widget _buildCancelApplySeatUI(SeatViewModel seatViewModel) {
    return Positioned(
        top: 80,
        child: Visibility(
          visible: _showCancelApplyUI,
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(19))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 40, right: 40, top: 10, bottom: 10),
              child: Row(
                children: [
                  Text(
                    S.of(context).seatApplying,
                    style: TextStyle(color: Color(0xFF525252), fontSize: 14),
                  ),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            List<String> list = [];
                            list.add(S.of(context).confirmToCancel);
                            list.add(S.of(context).cancel);
                            return SeatOptionListWidget(
                                list, null, seatViewModel);
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        S.of(context).cancel,
                        style: const TextStyle(
                            color: Color(0xFF0888ff), fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _leaveRoom() {
    NEVoiceRoomKit.instance.leaveRoom().then((value) {
      VoiceRoomKitLog.i(tag,
          "roomEndedCallback,leaveRoom,code:${value.code},msg:${value.msg}");
      if (!mounted) {
        return;
      }
      NavUtils.popUntil(context, RouterName.liveListPage);
    });
  }
}

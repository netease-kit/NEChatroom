// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:netease_auth/provider/login_provider.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat.dart';
import 'package:voiceroomkit_ui/model/voiceroom_seat_event.dart';
import 'package:voiceroomkit_ui/utils/seat_util.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';
import 'package:voiceroomkit_ui/widgets/chatroom_list_view.dart';

/// 麦位数据
class SeatViewModel extends ChangeNotifier {
  final tag = "SeatViewModel";
  static const _anchorSeatIndex = 1;
  static const int CURRENT_SEAT_STATE_IDLE = 0;
  static const int CURRENT_SEAT_STATE_APPLYING = 1;
  static const int CURRENT_SEAT_STATE_ON_SEAT = 2;

  VoiceRoomSeat anchorSeat =
      VoiceRoomSeat(_anchorSeatIndex, Status.ON, Reason.NONE, null);
  List<VoiceRoomSeat> audienceSeats = _initAudienceSeat();
  List<VoiceRoomSeat> applySeatList = [];

  String get applySeatsNumberString => applySeatList.length.toString();
  int get applySeatsNumber => applySeatList.length;

  int currentSeatState = CURRENT_SEAT_STATE_IDLE;

  bool get isAnchor => SeatUtil.isAnchor();
  late NEVoiceRoomEventCallback eventCallback;
  EventBus eventBus = EventBus();
  late StreamSubscription<ConnectivityResult> _networkSubscription;

  bool selfSeatMuted = false;
  bool showApplySeatListUI = false;
  void initSeatInfo() {
    _addSeatListener();
    _getSeatInfo();
    if (isAnchor) {
      _getSeatRequestList();
    }
    _addNetworkListener();
  }

  void initRoomInfo(NEVoiceRoomInfo roomInfo) {
    _updateAnchorInfo(roomInfo);
  }

  void _addSeatListener() {
    eventCallback = NEVoiceRoomEventCallback(
        memberAudioMuteChangedCallback: (member, mute, operateBy) {
      _notifyMemberAudioMuteChanged(member, mute, operateBy);
    }, memberAudioBannedCallback: (member, banned) {
      _notifyMemberAudioBanned(member, banned);
    }, seatRequestSubmittedCallback: (seatIndex, account) {
      _notifySeatRequestSubmitted(seatIndex, account);
    }, seatRequestCancelledCallback: (seatIndex, account) {
      _notifySeatRequestCancelled(seatIndex, account);
    }, seatRequestApprovedCallback:
            (seatIndex, account, operateBy, isAutoAgree) {
      _notifySeatRequestApproved(seatIndex, account, operateBy, isAutoAgree);
    }, seatRequestRejectedCallback: (seatIndex, account, operateBy) {
      _notifySeatRequestRejected(seatIndex, account, operateBy);
    }, seatLeaveCallback: (seatIndex, account) {
      _notifySeatLeave(seatIndex, account);
    }, seatKickedCallback: (seatIndex, account, operateBy) {
      _notifySeatKicked(seatIndex, account, operateBy);
    }, seatInvitationAcceptedCallback: (seatIndex, account, isAutoAgree) {
      _notifySeatInvitationAccepted(seatIndex, account, isAutoAgree);
    }, seatListChangedCallback: (seatItems) {
      _notifySeatListChanged(seatItems);
    });
    NEVoiceRoomKit.instance.addVoiceRoomListener(eventCallback);
  }

  void _notifyMemberAudioMuteChanged(
      NEVoiceRoomMember member, bool mute, NEVoiceRoomMember? operateBy) {
    VoiceRoomKitLog.i(tag,
        "_notifyMemberAudioMuteChanged,role:${member.role},member:$member,mute:$mute,operateBy:$operateBy");
    if (SeatUtil.isSelf(member.account)) {
      selfSeatMuted = mute;
    }
    notifyListeners();
  }

  void _notifyMemberAudioBanned(NEVoiceRoomMember member, bool banned) {
    VoiceRoomKitLog.i(
        tag, "_notifyMemberAudioBanned,member:$member,banned:$banned");
    if (SeatUtil.isSelf(member.account) && isCurrentUserOnSeat()) {
      eventBus.fire(AudioBannedEvent(banned));
    }
    notifyListeners();
  }

  void _notifySeatRequestSubmitted(int seatIndex, String account) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatRequestSubmitted,seatIndex:$seatIndex,account:$account");
    notifyListeners();
  }

  void _notifySeatRequestCancelled(int seatIndex, String account) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatRequestCancelled,seatIndex:$seatIndex,account:$account");
    _buildSeatEventMessage(account, S.current.applyCanceled);
    if (SeatUtil.isSelf(account)) {
      eventBus.fire(ApplySeatEvent(false));
    }
    notifyListeners();
  }

  void _notifySeatRequestApproved(
      int seatIndex, String account, String operateBy, bool isAutoAgree) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatRequestApproved,seatIndex:$seatIndex,account:$account,operateBy:$operateBy,isAutoAgree:$isAutoAgree");
    if (SeatUtil.isSelf(account)) {
      eventBus.fire(
          VoiceRoomSeatEvent(account, seatIndex, Reason.ANCHOR_APPROVE_APPLY));
    }
    _buildSeatEventMessage(account, S.current.alreadySeat);
    notifyListeners();
  }

  void _notifySeatRequestRejected(
      int seatIndex, String account, String operateBy) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatRequestRejected,seatIndex:$seatIndex,account:$account,operateBy:$operateBy");
    if (SeatUtil.isSelf(account)) {
      eventBus.fire(
          VoiceRoomSeatEvent(account, seatIndex, Reason.ANCHOR_DENY_APPLY));
    }
    _buildSeatEventMessage(account, S.current.requestRejected);
    notifyListeners();
  }

  void _notifySeatLeave(int seatIndex, String account) {
    VoiceRoomKitLog.i(
        tag, "_notifySeatLeave,seatIndex:$seatIndex,account:$account");
    if (SeatUtil.isSelf(account)) {
      currentSeatState = CURRENT_SEAT_STATE_IDLE;
      eventBus.fire(currentSeatState);
      eventBus.fire(VoiceRoomSeatEvent(account, seatIndex, Reason.LEAVE));
    }
    _buildSeatEventMessage(account, S.current.downSeat);
    notifyListeners();
  }

  void _notifySeatKicked(int seatIndex, String account, String operateBy) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatKicked,seatIndex:$seatIndex,account:$account,operateBy:$operateBy");
    if (isCurrentUserOnSeat() && SeatUtil.isSelf(account)) {
      currentSeatState = CURRENT_SEAT_STATE_IDLE;
      eventBus.fire(currentSeatState);
      eventBus.fire(VoiceRoomSeatEvent(account, seatIndex, Reason.ANCHOR_KICK));
    }
    _buildSeatEventMessage(account, S.current.kickoutSeatByHost);
    notifyListeners();
  }

  void _notifySeatInvitationAccepted(
      int seatIndex, String account, bool isAutoAgree) {
    VoiceRoomKitLog.i(tag,
        "_notifySeatInvitationAccepted,seatIndex:$seatIndex,account:$account,isAutoAgree:$isAutoAgree");
    if (SeatUtil.isSelf(account)) {
      eventBus
          .fire(VoiceRoomSeatEvent(account, seatIndex, Reason.ANCHOR_INVITE));
    }
    notifyListeners();
  }

  void _notifySeatListChanged(List<NEVoiceRoomSeatItem> seatItems) {
    _handleSeatItemListChanged(seatItems);
    if (isAnchor) {
      _getSeatRequestList();
    }
    notifyListeners();
  }

  void _getSeatInfo() {
    NEVoiceRoomKit.instance.getSeatInfo().then((value) {
      if (value.isSuccess()) {
        List<NEVoiceRoomSeatItem>? seatItems = value.data?.seatItems;
        if (seatItems != null) {
          List<VoiceRoomSeat> allSeats =
              _transNESeatItem2VoiceRoomSeat(seatItems);
          List<VoiceRoomSeat> audienceSeatList = [];
          if (allSeats.isNotEmpty) {
            for (var seat in allSeats) {
              if (seat.index != _anchorSeatIndex) {
                audienceSeatList.add(seat);
              }
            }
          }
          audienceSeats = audienceSeatList;
          notifyListeners();
        }
      }
    });
  }

  void _getSeatRequestList() {
    NEVoiceRoomKit.instance.getSeatRequestList().then((value) {
      List<NEVoiceRoomSeatRequestItem> list = value.data!;
      applySeatList.clear();
      for (var requestItem in list) {
        if (isAnchor) {
          ///获取当前信息判断是否和主播信息一致，如果一致则过滤
          if (requestItem.user == LoginModel.instance.userInfo?.accountId) {
            continue;
          }
        }
        applySeatList.add(VoiceRoomSeat(requestItem.index, Status.APPLY,
            Reason.NONE, _getMember(requestItem.user)));
      }
      // ignore: prefer_is_empty
      if (applySeatList.length <= 0) {
        showApplySeatListUI = false;
      }
      notifyListeners();
    });
  }

  NEVoiceRoomMember? _getMember(String account) {
    if (NEVoiceRoomKit.instance.allMemberList == null) {
      return null;
    }
    List<NEVoiceRoomMember> allMemberList =
        NEVoiceRoomKit.instance.allMemberList!;
    if (allMemberList.isNotEmpty) {
      for (var neVoiceRoomMember in allMemberList) {
        if (neVoiceRoomMember.account == account) {
          return neVoiceRoomMember;
        }
      }
    }
    return null;
  }

  List<VoiceRoomSeat> _transNESeatItem2VoiceRoomSeat(
      List<NEVoiceRoomSeatItem> neSeatItemList) {
    List<VoiceRoomSeat> onSeatList = [];
    for (var item in neSeatItemList) {
      int status;
      switch (item.status) {
        case NEVoiceRoomSeatItemStatus.waiting:
          status = Status.APPLY;
          break;
        case NEVoiceRoomSeatItemStatus.closed:
          status = Status.CLOSED;
          break;
        case NEVoiceRoomSeatItemStatus.taken:
          status = Status.ON;
          break;
        default:
          status = Status.INIT;
          break;
      }
      final int reason;
      if (item.onSeatType == NEVoiceRoomOnSeatType.request) {
        reason = Reason.ANCHOR_APPROVE_APPLY;
      } else if (item.onSeatType == NEVoiceRoomOnSeatType.invitation) {
        reason = Reason.ANCHOR_INVITE;
      } else {
        reason = Reason.NONE;
      }
      onSeatList.add(
          VoiceRoomSeat(item.index, status, reason, _getMember(item.user)));
    }
    return onSeatList;
  }

  void _buildSeatEventMessage(String account, String content) {
    eventBus.fire(ChatroomTextMessage(
        text: content,
        isAnchor: false,
        nickname: _getMember(account)?.name ?? _getMember(account)?.account,
        userUuid: account));
  }

  bool isCurrentUserOnSeat() {
    return currentSeatState == CURRENT_SEAT_STATE_ON_SEAT;
  }

  void _handleSeatItemListChanged(List<NEVoiceRoomSeatItem> seatItems) {
    VoiceRoomKitLog.i(tag, "_handleSeatItemListChanged,seatItems:$seatItems");
    List<VoiceRoomSeat> seats = _transNESeatItem2VoiceRoomSeat(seatItems);
    List<VoiceRoomSeat> newAudiencesSeats = [];
    for (var element in seats) {
      if (element.index != _anchorSeatIndex) {
        newAudiencesSeats.add(element);
      }
    }
    audienceSeats = newAudiencesSeats;
    notifyListeners();
    if (!isAnchor) {
      String currentUuid = NEVoiceRoomKit.instance.localMember?.account ?? '';
      VoiceRoomSeat? myAfterSeat = _findSeatByAccount(seats, currentUuid);
      if (myAfterSeat != null && myAfterSeat.isOn()) {
        currentSeatState = CURRENT_SEAT_STATE_ON_SEAT;
      } else if (myAfterSeat != null &&
          myAfterSeat.getStatus() == Status.APPLY) {
        currentSeatState = CURRENT_SEAT_STATE_APPLYING;
      } else {
        currentSeatState = CURRENT_SEAT_STATE_IDLE;
      }
      eventBus.fire(currentSeatState);
    }
  }

  VoiceRoomSeat? _findSeatByAccount(List<VoiceRoomSeat> seats, String account) {
    if (seats.isEmpty) return null;
    for (var seat in seats) {
      if (seat.getMember() != null && seat.member?.account == account) {
        return seat;
      }
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    VoiceRoomKitLog.i(tag, 'seatViewModel dispose');
    NEVoiceRoomKit.instance.removeVoiceRoomListener(eventCallback);
    _networkSubscription.cancel();
  }

  void showCancelApplySeatUI(bool show) {
    eventBus.fire(ApplySeatEvent(show));
  }

  void setShowApplySeatListUI(bool show) {
    showApplySeatListUI = show;
    notifyListeners();
  }

  bool isUserOnSeat(String account) {
    VoiceRoomSeat? seat = _findSeatByAccount(audienceSeats, account);
    return seat != null && seat.isOn();
  }

  bool isCurrentUserAudioOn() {
    return isCurrentUserOnSeat() &&
        NEVoiceRoomKit.instance.localMember!.isAudioOn;
  }

  void unmuteMyAudio() {
    NEVoiceRoomKit.instance.unmuteMyAudio().then((value) {
      if (value.code == NEVoiceRoomErrorCode.success) {
        selfSeatMuted = false;
      } else {
        selfSeatMuted = true;
      }
      notifyListeners();
    });
  }

  void muteMyAudio() {
    NEVoiceRoomKit.instance.muteMyAudio().then((value) {
      if (value.code == NEVoiceRoomErrorCode.success) {
        selfSeatMuted = true;
      } else {
        selfSeatMuted = false;
      }
      notifyListeners();
    });
  }

  void _addNetworkListener() {
    _networkSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        VoiceRoomKitLog.i(tag, "network is not available");
      } else {
        VoiceRoomKitLog.i(tag, "network is available");
        _getSeatInfo();
        if (isAnchor) {
          _getSeatRequestList();
        }
      }
    });
  }

  void _updateAnchorInfo(NEVoiceRoomInfo roomInfo) {
    String role = NEVoiceRoomRole.host.name.toLowerCase();
    NEVoiceRoomAnchor? anchorInfo = roomInfo.anchor;
    if (anchorInfo == null) {
      return;
    }
    anchorSeat = VoiceRoomSeat(
        _anchorSeatIndex,
        Status.ON,
        Reason.NONE,
        NEVoiceRoomMember(anchorInfo.account!, anchorInfo.nick!, role, true,
            false, anchorInfo.avatar));
    notifyListeners();
  }
}

List<VoiceRoomSeat> _initAudienceSeat() {
  List<VoiceRoomSeat> list = [];
  for (int i = 1; i < VoiceRoomSeat.SEAT_COUNT; i++) {
    list.add(VoiceRoomSeat(i + 1, Status.INIT, Reason.NONE, null));
  }
  return list;
}

class ApplySeatEvent {
  final bool showCancelApplySeat;

  ApplySeatEvent(this.showCancelApplySeat);
}

class AudioBannedEvent {
  final bool audioBanned;

  AudioBannedEvent(this.audioBanned);
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

typedef VoiceRoomAuthEventCallback = void Function(NEVoiceRoomAuthEvent evt);
typedef MemberJoinRoomCallback = void Function(List<NEVoiceRoomMember> members);
typedef MemberLeaveRoomCallback = void Function(
    List<NEVoiceRoomMember> members);
typedef RoomEndedCallback = void Function(NEVoiceRoomEndReason reason);
typedef RtcChannelErrorCallback = void Function(int code);
typedef MemberAudioMuteChangedCallback = void Function(
    NEVoiceRoomMember member, bool mute, NEVoiceRoomMember? operateBy);
typedef MemberAudioBannedCallback = void Function(
    NEVoiceRoomMember member, bool banned);
typedef ReceiveTextMessageCallback = void Function(
    NEVoiceRoomChatTextMessage message);
typedef SeatRequestSubmittedCallback = void Function(
    int seatIndex, String account);
typedef SeatRequestCancelledCallback = void Function(
    int seatIndex, String account);
typedef SeatRequestApprovedCallback = void Function(
    int seatIndex, String account, String operateBy, bool isAutoAgree);
typedef SeatRequestRejectedCallback = void Function(
    int seatIndex, String account, String operateBy);
typedef SeatLeaveCallback = void Function(int seatIndex, String account);
typedef SeatKickedCallback = void Function(
    int seatIndex, String account, String operateBy);
typedef SeatInvitationAcceptedCallback = void Function(
    int seatIndex, String account, bool isAutoAgree);
typedef SeatListChangedCallback = void Function(
    List<NEVoiceRoomSeatItem> seatItems);
typedef AudioMixingStateChangedCallback = void Function(int reason);
typedef AudioOutputDeviceChangedCallback = void Function(
    NEVoiceRoomAudioOutputDevice device);

/// 登录事件回调
class NEVoiceRoomAuthEventCallback {
  /// 登录事件回调
  final VoiceRoomAuthEventCallback? voiceRoomAuthEventCallback;
  NEVoiceRoomAuthEventCallback(this.voiceRoomAuthEventCallback);
}

/// 房间事件回调
class NEVoiceRoomEventCallback {
  /// 成员进入房间回调
  final MemberJoinRoomCallback? memberJoinRoomCallback;

  /// 成员离开房间回调
  final MemberLeaveRoomCallback? memberLeaveRoomCallback;

  /// 房间结束回调
  final RoomEndedCallback? roomEndedCallback;

  /// RTC频道错误回调
  final RtcChannelErrorCallback? rtcChannelErrorCallback;

  /// 成员音频状态回调
  final MemberAudioMuteChangedCallback? memberAudioMuteChangedCallback;

  /// 成员音频禁用事件回调
  final MemberAudioBannedCallback? memberAudioBannedCallback;

  /// 聊天室消息回调
  final ReceiveTextMessageCallback? receiveTextMessageCallback;

  /// 成员提交了麦位申请的回调
  final SeatRequestSubmittedCallback? seatRequestSubmittedCallback;

  /// 成员取消了麦位申请的回调
  final SeatRequestCancelledCallback? seatRequestCancelledCallback;

  /// 管理员通过了成员的麦位申请的回调
  final SeatRequestApprovedCallback? seatRequestApprovedCallback;

  /// 管理员拒绝了成员的麦位申请的回调
  final SeatRequestRejectedCallback? seatRequestRejectedCallback;

  /// 成员下麦的回调
  final SeatLeaveCallback? seatLeaveCallback;

  /// 成员被踢下麦的回调
  final SeatKickedCallback? seatKickedCallback;

  /// 成员接受了上麦邀请的回调
  final SeatInvitationAcceptedCallback? seatInvitationAcceptedCallback;

  /// 麦位变更的回调
  final SeatListChangedCallback? seatListChangedCallback;

  /// 伴音错误状态的回调
  final AudioMixingStateChangedCallback? audioMixingStateChangedCallback;

  /// 本端音频输出设备变更回调，如切换到扬声器、听筒、耳机等
  final AudioOutputDeviceChangedCallback? audioOutputDeviceChangedCallback;

  NEVoiceRoomEventCallback(
      {this.memberJoinRoomCallback,
      this.memberLeaveRoomCallback,
      this.roomEndedCallback,
      this.rtcChannelErrorCallback,
      this.memberAudioMuteChangedCallback,
      this.memberAudioBannedCallback,
      this.receiveTextMessageCallback,
      this.seatRequestSubmittedCallback,
      this.seatRequestCancelledCallback,
      this.seatRequestApprovedCallback,
      this.seatRequestRejectedCallback,
      this.seatLeaveCallback,
      this.seatKickedCallback,
      this.seatInvitationAcceptedCallback,
      this.seatListChangedCallback,
      this.audioMixingStateChangedCallback,
      this.audioOutputDeviceChangedCallback});
}

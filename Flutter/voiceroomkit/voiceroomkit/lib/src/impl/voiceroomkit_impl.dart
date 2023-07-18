// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class _VoiceRoomKitImpl extends NEVoiceRoomKit with _AloggerMixin {
  NERoomContext? _currentRoomContext;
  NEVoiceRoomInfo? _voiceRoomInfo;
  final int _roomMode = 2; // 房间类型（1：互动直播 2：语聊房 3：Karaoke）
  final _authEventCallbacks = <NEVoiceRoomAuthEventCallback>{};
  final _eventCallbacks = <NEVoiceRoomEventCallback>{};
  late NERoomEventCallback _roomEventCallback;
  late NESeatEventCallback _seatEventCallback;
  bool _isEarBackEnable = false;
  int _recordingSignalVolume = 100;
  int _audioMixingVolume = 100;
  int _effectVolume = 100;
  List<NESeatItem>? currentSeatItems;
  // Error Msg
  static const String ERROR_MSG_NOT_IN_ROOM = "not in room";
  static const String ERROR_MSG_ROOM_NOT_EXISTS = "Room not exists";
  static const String ERROR_MSG_MEMBER_NOT_EXISTS = "Member not exists";
  static const String ERROR_MSG_MEMBER_AUDIO_BANNED = "Member audio banned";
  static const String ERROR_MSG_LIVEID_NOT_EXIST = "LiveId not exist";

  static const String SERVER_URL_KEY = "serverUrl";
  static const String BASE_URL_KEY = "baseUrl";
  static const String HTTP_PREFIX = "http";
  static const String TEST_URL_VALUE = "test";
  static const String OVERSEA_URL_VALUE = "oversea";
  static const String OVERSEA_SERVER_URL = "https://roomkit-sg.netease.im/";
  // 自己操作后的mute状态，区别于ban之后的mute
  bool _isSelfMuted = false;

  @override
  void addAuthListener(NEVoiceRoomAuthEventCallback listener) {
    commonLogger.i('addAuthListener,listener:$listener');
    _authEventCallbacks.add(listener);
  }

  @override
  void addVoiceRoomListener(NEVoiceRoomEventCallback listener) {
    commonLogger.i('addVoiceRoomListener,listener:$listener');
    _eventCallbacks.add(listener);
  }

  @override
  Future<VoidResult> adjustRecordingSignalVolume(int volume) {
    commonLogger.i('adjustRecordingSignalVolume,volume:$volume');
    if (_currentRoomContext != null) {
      _recordingSignalVolume = volume;
      return _currentRoomContext!.rtcController
          .adjustRecordingSignalVolume(volume);
    } else {
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  List<NEVoiceRoomMember>? get allMemberList => _handleAllMembers();

  @override
  Future<VoidResult> approveSeatRequest(String account) async {
    commonLogger.i('approveSeatRequest,account:$account');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.approveSeatRequest(account);
      commonLogger.i("approveSeatRequest,ret:$ret");
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> banRemoteAudio(String account) async {
    commonLogger.i('banRemoteAudio,account:$account');
    if (_currentRoomContext != null) {
      if (_currentRoomContext!.getMember(account) == null) {
        return Future.value(const NEResult(
            code: NEVoiceRoomErrorCode.failure,
            msg: ERROR_MSG_MEMBER_NOT_EXISTS));
      }
      var ret = await _currentRoomContext!.updateMemberProperty(
          account,
          MemberPropertyConstants.CAN_OPEN_MIC_KEY,
          MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO);
      commonLogger.i('banRemoteAudio,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> cancelSeatRequest() async {
    commonLogger.i('cancelSeatRequest');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController.cancelSeatRequest();
      commonLogger.i('cancelSeatRequest,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> closeSeats(List<int> seatIndices) async {
    commonLogger.i('closeSeats');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.closeSeats(seatIndices);
      commonLogger.i('closeSeats,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<NEResult<NEVoiceRoomInfo>> createRoom(
      NECreateVoiceRoomParams params, NECreateVoiceRoomOptions options) async {
    commonLogger.i('createRoom params=$params');
    NEStartVoiceRoomParams startParams = NEStartVoiceRoomParams(
        title: params.title,
        nick: params.nick,
        seatCount: params.seatCount,
        configId: params.configId,
        roomName: params.title,
        cover: params.cover,
        liveType: _roomMode);
    var seatInviteMode = NEVoiceRoomSeatInvitationConfirmMode.off.index;
    var seatApplyMode = NEVoiceRoomSeatRequestApprovalMode.on.index;
    var ret = await _NEVoiceRoomHttpRepository.startVoiceRoom(
        startParams.title,
        startParams.cover,
        startParams.liveType,
        startParams.configId,
        startParams.roomName,
        startParams.seatCount,
        seatApplyMode,
        seatInviteMode);
    if (ret.isSuccess()) {
      commonLogger.i('createRoom success info = ${ret.data}');
      _voiceRoomInfo = ret.data;
    } else {
      commonLogger
          .e('createRoom error: code = ${ret.code} message = ${ret.msg}');
    }
    return ret;
  }

  @override
  Future<VoidResult> disableEarback() {
    commonLogger.i('disableEarback');
    if (_currentRoomContext != null) {
      return _currentRoomContext!.rtcController
          .disableEarBack()
          .then((value) => _handleEarback(value, false));
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> enableEarback(int volume) {
    commonLogger.i('enableEarback,volume:$volume');
    if (_currentRoomContext != null) {
      return _currentRoomContext!.rtcController
          .enableEarBack(volume)
          .then((value) => _handleEarback(value, true));
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> endRoom() async {
    commonLogger.i("endRoom");
    if (_currentRoomContext == null) {
      commonLogger.e('endRoom currentRoomContext is null');
      return const NEResult(code: -1, msg: "currentRoomContext is null");
    }
    _currentRoomContext!.endRoom().then((value) {
      if (value.isSuccess()) {
        commonLogger.i("endRoom success");
      } else {
        commonLogger
            .e("endRoom error code = ${value.code} message = ${value.msg}");
      }
      _reset();
    });

    if (_voiceRoomInfo?.liveModel?.liveRecordId != null) {
      var stopRet = await _NEVoiceRoomHttpRepository.stopVoiceRoom(
          _voiceRoomInfo!.liveModel!.liveRecordId!);
      if (stopRet.isSuccess()) {
        commonLogger.i("stopVoiceRoom success");
      } else {
        commonLogger.e(
            "stopVoiceRoom error code = ${stopRet.code} message = ${stopRet.msg}");
      }
      return stopRet;
    } else {
      commonLogger.e("_voiceRoomInfo?.liveModel?.liveRecordId == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_LIVEID_NOT_EXIST));
    }
  }

  @override
  int getAudioMixingVolume() {
    commonLogger.i('getAudioMixingVolume');
    return _audioMixingVolume;
  }

  @override
  Future<NEResult<NEVoiceCreateRoomDefaultInfo>>
      getCreateRoomDefaultInfo() async {
    commonLogger.i('getCreateRoomDefaultInfo');
    var ret = await _NEVoiceRoomHttpRepository.getCreateRoomDefaultInfo();
    commonLogger.i('getCreateRoomDefaultInfo  info = $ret');
    return NEResult(code: ret.code, msg: ret.msg, data: ret.data);
  }

  @override
  int getEffectVolume() {
    commonLogger.i('getEffectVolume');
    return _effectVolume;
  }

  @override
  int getRecordingSignalVolume() {
    commonLogger.i('getRecordingSignalVolume');
    return _recordingSignalVolume;
  }

  @override
  Future<NEResult<NEVoiceRoomSeatInfo>> getSeatInfo() async {
    commonLogger.i('getSeatInfo');
    String creator = "";
    List<String> managers = [];
    List<NEVoiceRoomSeatItem> seatItems = [];
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController.getSeatInfo();
      creator = ret.data?.creator ?? '';
      ret.data?.managers?.forEach((element) {
        managers.add(element);
      });

      ret.data?.seatItems?.forEach((element) {
        seatItems.add(NEVoiceRoomSeatItem(
            element.index!,
            element.status!,
            element.user ?? '',
            element.userName,
            element.icon,
            element.onSeatType!,
            element.updated!));
      });
      commonLogger.i('getSeatInfo,ret:$ret');
      return Future.value(NEResult(
          code: ret.code,
          msg: ret.msg,
          data: NEVoiceRoomSeatInfo(creator, managers, seatItems)));
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(NEResult(
          code: NEVoiceRoomErrorCode.failure,
          msg: ERROR_MSG_NOT_IN_ROOM,
          data: NEVoiceRoomSeatInfo(creator, managers, seatItems)));
    }
  }

  @override
  Future<NEResult<List<NEVoiceRoomSeatRequestItem>>>
      getSeatRequestList() async {
    commonLogger.i('getSeatRequestList');
    List<NEVoiceRoomSeatRequestItem> list = [];
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController.getSeatRequestList();
      ret.data?.forEach((element) {
        list.add(NEVoiceRoomSeatRequestItem(
            element.index!, element.user!, element.userName, element.icon));
      });
      commonLogger.i('getSeatRequestList,ret:$ret');
      return Future.value(NEResult(code: ret.code, msg: ret.msg, data: list));
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(NEResult(
          code: NEVoiceRoomErrorCode.failure,
          msg: ERROR_MSG_NOT_IN_ROOM,
          data: list));
    }
  }

  @override
  Future<NEResult<NEVoiceRoomList>> getRoomList(
      NEVoiceRoomLiveState liveState, int pageNum, int pageSize) async {
    commonLogger.i(
        'fetchLiveList pageNum:$pageNum pageSize:$pageSize liveStatus:$liveState');
    var ret = await _NEVoiceRoomHttpRepository.fetchLiveList(
        pageNum, pageSize, liveState);
    commonLogger.i('fetchLiveList  info = $ret');
    return NEResult(code: ret.code, msg: ret.msg, data: ret.data);
  }

  @override
  Future<VoidResult> initialize(NEVoiceRoomKitOptions options) {
    commonLogger.i('initialize,options:$options');
    NERoomKit.instance.authService.onAuthEvent.listen((event) {
      _handleAuthEvent(event);
    });

    String realRoomServerUrl = "";
    bool isOversea = false;
    var realExtras = Map<String, String>();
    options.extras?.entries.forEach((element) {
      realExtras[element.key] = element.value;
    });
    if (options.extras?[SERVER_URL_KEY] != null) {
      String? serverUrl = options.extras?[SERVER_URL_KEY];
      if (!TextUtils.isEmpty(serverUrl)) {
        if (TEST_URL_VALUE == serverUrl) {
          realRoomServerUrl = serverUrl!;
        } else if (OVERSEA_URL_VALUE == serverUrl) {
          realRoomServerUrl = OVERSEA_SERVER_URL;
          isOversea = true;
        } else if (serverUrl!.startsWith(HTTP_PREFIX)) {
          realRoomServerUrl = serverUrl;
        }
      }
    }
    realExtras[SERVER_URL_KEY] = realRoomServerUrl;
    if (options.extras?[BASE_URL_KEY] != null) {
      var baseUrl = options.extras?[BASE_URL_KEY];
      ServersConfig().serverUrl = baseUrl ?? '';
    }
    _NEVoiceRoomHttpRepository.appKey = options.appKey;
    commonLogger.i(
        "ServersConfig().baseUrl:${ServersConfig().baseUrl},realRoomServerUrl:$realRoomServerUrl,isOversea:$isOversea,realExtras:$realExtras");
    if (isOversea) {
      NEServerConfig serversConfig = NEServerConfig();
      NEIMServerConfig imServerConfig = NEIMServerConfig();
      imServerConfig.link = IMPrivateConstants.LINK;
      imServerConfig.lbs = IMPrivateConstants.LBS;
      imServerConfig.nosLbs = IMPrivateConstants.NOS_LBS;
      imServerConfig.nosUploader = IMPrivateConstants.NOS_UPLOADER;
      imServerConfig.nosDownloader = IMPrivateConstants.NOS_DOWNLOADER;
      imServerConfig.nosUploaderHost = IMPrivateConstants.NOS_UPLOADER_HOST;
      imServerConfig.httpsEnabled = true;
      serversConfig.imServerConfig = imServerConfig;
      NERoomKitServerConfig roomKitServerConfig = NERoomKitServerConfig();
      roomKitServerConfig.roomServer = realRoomServerUrl;
      serversConfig.roomKitServerConfig = roomKitServerConfig;
      return NERoomKit.instance.initialize(NERoomKitOptions(
          appKey: options.appKey,
          extras: realExtras,
          serverConfig: serversConfig));
    } else {
      return NERoomKit.instance.initialize(
          NERoomKitOptions(appKey: options.appKey, extras: realExtras));
    }
  }

  @override
  bool isEarbackEnable() {
    commonLogger.i('isEarbackEnable');
    return _isEarBackEnable;
  }

  @override
  bool get isInitialized => NERoomKit.instance.isInitialized;

  @override
  Future<bool> get isLoggedIn => NERoomKit.instance.authService.isLoggedIn;

  @override
  Future<NEResult<NEVoiceRoomInfo>> joinRoom(
      NEJoinVoiceRoomParams params, NEJoinVoiceRoomOptions options) async {
    commonLogger.i('joinRoom params=$params');
    var joinRet = await NERoomKit.instance.roomService.joinRoom(
        NEJoinRoomParams(
            roomUuid: params.roomUuid,
            userName: params.nick,
            avatar: params.avatar,
            role: params.role.name.toLowerCase(),
            initialMyProperties: params.extraData),
        NEJoinRoomOptions(
            enableMyAudioDeviceOnJoinRtc:
                options.enableMyAudioDeviceOnJoinRtc));

    /// 加入房间失败
    if (!joinRet.isSuccess() || joinRet.data == null) {
      commonLogger
          .e('joinRoom error: code = ${joinRet.code} msg = ${joinRet.msg}');
      return NEResult(code: joinRet.code, msg: joinRet.msg);
    }

    commonLogger.i('joinRoom roomUuid=${params.roomUuid} success');
    _currentRoomContext = joinRet.data;
    _setAudioProfile();
    _roomEventCallback = NERoomEventCallback(
        memberJoinRtcChannel: _notifyMemberJoinRtcChannel,
        roomEnd: _notifyRoomEnd,
        memberJoinRoom: _notifyMembersJoin,
        memberLeaveRoom: _notifyMembersLeave,
        chatroomMessagesReceived: _notifyChatroomMessageReceived,
        rtcChannelError: _notifyRtcChannelError,
        memberAudioMuteChanged: _notifyMemberAudioMuteChanged,
        rtcAudioOutputDeviceChanged: _notifyAudioOutputDeviceChanged,
        rtcAudioMixingStateChanged: _notifyAudioMixingStateChanged,
        memberPropertiesChanged: _notifyMemberPropertiesChanged,
        memberJoinChatroom: _notifyMemberJoinChatroom);
    _seatEventCallback = NESeatEventCallback(
        seatManagerAddedCallback: _notifySeatManagerAddedCallback,
        seatManagerRemovedCallback: _notifySeatManagerRemovedCallback,
        seatRequestSubmittedCallback: _notifySeatRequestSubmittedCallback,
        seatRequestCancelledCallback: _notifySeatRequestCancelledCallback,
        seatRequestApprovedCallback: _notifySeatRequestApprovedCallback,
        seatRequestRejectedCallback: _notifySeatRequestRejectedCallback,
        seatInvitationReceivedCallback: _notifySeatInvitationReceivedCallback,
        seatInvitationCancelledCallback: _notifySeatInvitationCancelledCallback,
        seatInvitationAcceptedCallback: _notifySeatInvitationAcceptedCallback,
        seatInvitationRejectedCallback: _notifySeatInvitationRejectedCallback,
        seatLeaveCallback: _notifySeatLeaveCallback,
        seatKickedCallback: _notifySeatKickedCallback,
        seatListChangedCallback: _notifySeatListChangedCallback);
    _addListener();
    _currentRoomContext?.rtcController
        .setClientRole(NERoomRtcClientRole.AUDIENCE);
    var rtcRet = await _currentRoomContext!.rtcController.joinRtcChannel();
    commonLogger.i('joinRtcChannel rtcRet:$rtcRet');

    /// 加入Rtc失败
    if (!rtcRet.isSuccess()) {
      var rtcLeaveRet =
          await _currentRoomContext!.rtcController.leaveRtcChannel();
      if (rtcLeaveRet.isSuccess()) {
        commonLogger.i('leaveRtcChannel success');
      } else {
        commonLogger.e(
            'leaveRtcChannel error code = ${rtcLeaveRet.code} message = ${rtcLeaveRet.msg}');
      }
      return NEResult(code: rtcRet.code, msg: rtcRet.msg);
    }

    var chatroomRet = await _currentRoomContext!.chatController.joinChatroom();
    if (!chatroomRet.isSuccess()) {
      commonLogger.i(
          'joinChatroom failed,code:${chatroomRet.code},msg:${chatroomRet.msg}');
      return NEResult(code: rtcRet.code, msg: chatroomRet.msg);
    }

    var roomInfo =
        await _NEVoiceRoomHttpRepository.getRoomInfo(params.liveRecordId);
    commonLogger.i("getRoomInfo roomInfo:$roomInfo");
    if (roomInfo.isSuccess()) {
      commonLogger.i("joinRoom  getRoomInfo success");
    } else {
      commonLogger.e(
          "get room info after join room error: code = ${roomInfo.code} message = ${roomInfo.msg}");
    }

    return roomInfo;
  }

  void _setAudioProfile() {
    _currentRoomContext?.rtcController.setAudioProfile(
        NERoomRtcAudioProfile.HIGH_QUALITY_STEREO,
        NERoomRtcAudioScenario.MUSIC);
    _currentRoomContext?.rtcController
        .setChannelProfile(NERoomRtcChannelProfile.liveBroadcasting);
  }

  @override
  Future<VoidResult> kickSeat(String account) async {
    commonLogger.i('kickSeat,account:$account');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController.kickSeat(account);
      commonLogger.i('kickSeat,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> leaveRoom() async {
    commonLogger.i("leaveRoom");
    if (_currentRoomContext == null) {
      commonLogger.e('leaveRoom currentRoomContext is null');
      return const NEResult(code: -1, msg: "currentRoomContext is null");
    }
    var ret = await _currentRoomContext!.leaveRoom();
    if (ret.isSuccess()) {
      commonLogger.i("leaveRoom success");
    } else {
      commonLogger.e("leaveRoom error code = ${ret.code} message = ${ret.msg}");
    }
    _reset();
    return ret;
  }

  @override
  Future<VoidResult> leaveSeat() async {
    commonLogger.i('leaveSeat');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController.leaveSeat();
      commonLogger.i('leaveSeat,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  NEVoiceRoomMember? get localMember => _handleLocalMembers();

  @override
  Future<VoidResult> login(String account, String token) {
    commonLogger.i('login account:$account token:$token');
    ServersConfig().token = token;
    ServersConfig().userUuid = account;
    ServersConfig().deviceId = const Uuid().v1();
    return NERoomKit.instance.authService.login(account, token);
  }

  @override
  Future<VoidResult> logout() {
    commonLogger.i('logout');
    ServersConfig().token = "";
    ServersConfig().userUuid = "";
    ServersConfig().deviceId = "";
    return NERoomKit.instance.authService.logout();
  }

  @override
  Future<VoidResult> muteMyAudio() async {
    commonLogger.i('muteMyAudio');
    return _muteMyAudioInner(true);
  }

  Future<VoidResult> _muteMyAudioInner(bool operateBySelf) async {
    commonLogger.i('_muteMyAudioInner,operateBySelf:$operateBySelf');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.updateMemberProperty(
          _currentRoomContext!.localMember.uuid,
          MemberPropertyConstants.MUTE_VOICE_KEY,
          MemberPropertyConstants.MUTE_VOICE_VALUE_OFF);
      commonLogger.i('muteMyAudio,ret:$ret');
      if (operateBySelf && ret.isSuccess()) {
        _isSelfMuted = true;
      }
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_ROOM_NOT_EXISTS));
    }
  }

  @override
  Future<VoidResult> openSeats(List<int> seatIndices) async {
    commonLogger.i('openSeats,seatIndices:$seatIndices');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.openSeats(seatIndices);
      commonLogger.i('openSeats,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> pauseAudioMixing() async {
    commonLogger.i('pauseAudioMixing');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.rtcController.pauseAudioMixing();
      commonLogger.i('pauseAudioMixing,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> playEffect(
      int effectId, NEVoiceRoomCreateAudioEffectOption option) async {
    commonLogger.i('playEffect,option:$option');
    if (_currentRoomContext != null) {
      NECreateAudioEffectOption createAudioEffectOption =
          NECreateAudioEffectOption(
              path: option.path,
              loopCount: option.loopCount,
              sendEnabled: option.sendEnabled,
              sendVolume: option.sendVolume,
              playbackEnabled: option.playbackEnabled,
              playbackVolume: option.playbackVolume);
      var ret = await _currentRoomContext!.rtcController
          .playEffect(effectId, createAudioEffectOption);
      commonLogger.i('playEffect,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> rejectSeatRequest(String account) async {
    commonLogger.i('rejectSeatRequest,account:$account');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.rejectSeatRequest(account);
      commonLogger.i('rejectSeatRequest,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  void removeAuthListener(NEVoiceRoomAuthEventCallback listener) {
    commonLogger.i('removeAuthListener,listener:$listener');
    _authEventCallbacks.remove(listener);
  }

  @override
  void removeVoiceRoomListener(NEVoiceRoomEventCallback listener) {
    commonLogger.i('removeVoiceRoomListener,listener:$listener');
    _eventCallbacks.remove(listener);
  }

  @override
  Future<VoidResult> resumeAudioMixing() async {
    commonLogger.i('resumeAudioMixing');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.rtcController.resumeAudioMixing();
      commonLogger.i('resumeAudioMixing,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> sendSeatInvitation(int seatIndex, String account) async {
    commonLogger.i('sendSeatInvitation,seatIndex:$seatIndex,account:$account');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController
          .sendSeatInvitation(seatIndex, account);
      commonLogger.i('sendSeatInvitation,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> sendTextMessage(String content) async {
    commonLogger.i('sendTextMessage,content:$content');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.chatController
          .sendBroadcastTextMessage(content);
      commonLogger.i('sendTextMessage,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> setAudioMixingVolume(int volume) {
    commonLogger.i('setAudioMixingVolume,volume:$volume');
    if (_currentRoomContext != null) {
      _currentRoomContext!.rtcController.setAudioMixingSendVolume(volume);
      _audioMixingVolume = volume;
      return _currentRoomContext!.rtcController
          .setAudioMixingPlaybackVolume(volume);
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> setEffectVolume(int effectId, int volume) {
    commonLogger.i('setEffectVolume,effectId:$effectId,volume:$volume');
    if (_currentRoomContext != null) {
      _effectVolume = volume;
      _currentRoomContext!.rtcController.setEffectSendVolume(effectId, volume);
      return _currentRoomContext!.rtcController
          .setEffectPlaybackVolume(effectId, volume);
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> startAudioMixing(
      NEVoiceRoomCreateAudioMixingOption option) async {
    commonLogger.i('startAudioMixing,option:$option');
    if (_currentRoomContext != null) {
      NECreateAudioMixingOption mixingOption = NECreateAudioMixingOption(
          path: option.path,
          loopCount: option.loopCount,
          sendEnabled: option.sendEnabled,
          sendVolume: option.sendVolume,
          playbackEnabled: option.playbackEnabled,
          playbackVolume: option.playbackVolume);
      var ret = await _currentRoomContext!.rtcController
          .startAudioMixing(mixingOption);
      commonLogger.i('startAudioMixing,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> stopAllEffect() async {
    commonLogger.i('stopAllEffect');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.rtcController.stopAudioMixing();
      commonLogger.i('stopAllEffect,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> stopAudioMixing() async {
    commonLogger.i('stopAudioMixing');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.rtcController.stopAudioMixing();
      commonLogger.i('stopAudioMixing,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> stopEffect(int effectId) async {
    commonLogger.i('stopEffect,effectId:$effectId');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.rtcController.stopEffect(effectId);
      commonLogger.i('stopEffect,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> submitSeatRequest(int seatIndex, bool exclusive) async {
    commonLogger
        .i('submitSeatRequest,seatIndex:$seatIndex,exclusive:$exclusive');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController
          .submitSeatRequest(seatIndex, exclusive);
      commonLogger.i('submitSeatRequest,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> unbanRemoteAudio(String account) async {
    commonLogger.i('unbanRemoteAudio,account:$account');
    if (_currentRoomContext != null) {
      var member = _currentRoomContext!.getMember(account);
      if (member == null) {
        commonLogger.e('unbanRemoteAudio,ret:$ERROR_MSG_MEMBER_NOT_EXISTS');
        return Future.value(const NEResult(
            code: NEVoiceRoomErrorCode.failure,
            msg: ERROR_MSG_MEMBER_NOT_EXISTS));
      }
      if (member.properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY] ==
          MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO) {
        var ret = await _currentRoomContext!.updateMemberProperty(
            account,
            MemberPropertyConstants.CAN_OPEN_MIC_KEY,
            MemberPropertyConstants.CAN_OPEN_MIC_VALUE_YES);
        commonLogger.i('unbanRemoteAudio,ret:$ret');
        return ret;
      } else {
        commonLogger.i('unbanRemoteAudio,success');
        return Future.value(
            const NEResult(code: NEVoiceRoomErrorCode.success, msg: ''));
      }
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> unmuteMyAudio() async {
    commonLogger.i('unmuteMyAudio');
    if (_currentRoomContext != null) {
      if (mapMember(_currentRoomContext!.localMember).isAudioBanned) {
        commonLogger
            .e('unmuteMyAudio failed,msg:$ERROR_MSG_MEMBER_AUDIO_BANNED');
        return Future.value(const NEResult(
            code: NEVoiceRoomErrorCode.failure,
            msg: ERROR_MSG_MEMBER_AUDIO_BANNED));
      }
      var neResult = await _currentRoomContext!.rtcController.unmuteMyAudio();
      if (neResult.isSuccess()) {
        var updateMemberPropertyResult = await _currentRoomContext!
            .updateMemberProperty(
                _currentRoomContext!.localMember.uuid,
                MemberPropertyConstants.MUTE_VOICE_KEY,
                MemberPropertyConstants.MUTE_VOICE_VALUE_ON);
        commonLogger.i(
            'unmuteMyAudio,isAudioOn:${_currentRoomContext!.localMember.isAudioOn},updateMemberProperty,code:${updateMemberPropertyResult.code},msg:${updateMemberPropertyResult.msg}');
        if (updateMemberPropertyResult.isSuccess()) {
          _isSelfMuted = false;
        }
        return Future.value(NEResult(
            code: updateMemberPropertyResult.code,
            msg: updateMemberPropertyResult.msg));
      } else {
        commonLogger.e(
            'unmuteMyAudio failed,msg:rtcController unmuteMyAudio failed,code:${neResult.code},msg:${neResult.msg}');
        return Future.value(NEResult(
            code: neResult.code,
            msg:
                "rtcController unmuteMyAudio failed,code:${neResult.code},msg:${neResult.msg}"));
      }
    } else {
      commonLogger.e('unmuteMyAudio failed,msg:$ERROR_MSG_ROOM_NOT_EXISTS');
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_ROOM_NOT_EXISTS));
    }
  }

  NEVoiceRoomMember mapMember(NERoomMember member) {
    return VoiceRoomMemberImpl(member);
  }

  List<NEVoiceRoomMember>? _handleAllMembers() {
    if (_currentRoomContext == null) {
      return null;
    }
    List<NEVoiceRoomMember> list = [];
    list.add(mapMember(_currentRoomContext!.localMember));
    for (var roomMember in _currentRoomContext!.remoteMembers) {
      list.add(mapMember(roomMember));
    }
    return list;
  }

  NEVoiceRoomMember? _handleLocalMembers() {
    if (_currentRoomContext == null) {
      return null;
    }
    return mapMember(_currentRoomContext!.localMember);
  }

  void _handleAuthEvent(NEAuthEvent evt) {
    for (var callback in _authEventCallbacks) {
      if (evt == NEAuthEvent.kAccountTokenError) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.accountTokenError);
      } else if (evt == NEAuthEvent.kForbidden) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.forbidden);
      } else if (evt == NEAuthEvent.kIncorrectToken) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.incorrectToken);
      } else if (evt == NEAuthEvent.kKickOut) {
        callback.voiceRoomAuthEventCallback?.call(NEVoiceRoomAuthEvent.kickOut);
      } else if (evt == NEAuthEvent.kLoggedIn) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.loggedIn);
      } else if (evt == NEAuthEvent.kLoggedOut) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.loggedOut);
      } else if (evt == NEAuthEvent.kTokenExpired) {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.tokenExpired);
      } else {
        callback.voiceRoomAuthEventCallback
            ?.call(NEVoiceRoomAuthEvent.loggedOut);
      }
    }
  }

  Future<VoidResult> _handleEarback(NEResult result, bool enable) {
    if (result.code == NEVoiceRoomErrorCode.success) {
      if (enable) {
        _isEarBackEnable = true;
      } else {
        _isEarBackEnable = false;
      }
    }
    return Future.value(
        const NEResult(code: NEVoiceRoomErrorCode.success, msg: ""));
  }

  void _removeListener() {
    _currentRoomContext?.removeEventCallback(_roomEventCallback);
    _currentRoomContext?.seatController.removeEventCallback(_seatEventCallback);
  }

  void _notifyMembersLeave(List<NERoomMember> members) {
    for (var callback in _eventCallbacks.copy()) {
      List<NEVoiceRoomMember> voiceRoomMembers = [];
      for (var element in members) {
        voiceRoomMembers.add(mapMember(element));
      }
      callback.memberLeaveRoomCallback?.call(voiceRoomMembers);
    }
  }

  void _notifyMembersJoin(List<NERoomMember> members) {
    for (var callback in _eventCallbacks.copy()) {
      List<NEVoiceRoomMember> voiceRoomMembers = [];
      for (var element in members) {
        voiceRoomMembers.add(mapMember(element));
      }
      callback.memberJoinRoomCallback?.call(voiceRoomMembers);
    }
  }

  void _notifyRoomEnd(NERoomEndReason reason) {
    for (var callback in _eventCallbacks.copy()) {
      callback.roomEndedCallback
          ?.call(ModelConvertUtil.handleRoomEndReason(reason));
    }
  }

  void _notifyChatroomMessageReceived(List<NERoomChatMessage> messages) {
    for (var callback in _eventCallbacks.copy()) {
      for (var message in messages) {
        if (message.messageType == NERoomChatMessageType.kText) {
          var textMessage = message as NERoomChatTextMessage;
          NEVoiceRoomChatTextMessage chatTextMessage =
              NEVoiceRoomChatTextMessage(
                  textMessage.fromUserUuid ?? "",
                  textMessage.fromNick,
                  textMessage.toUserUuidList,
                  textMessage.time,
                  textMessage.text);
          callback.receiveTextMessageCallback?.call(chatTextMessage);
        }
      }
    }
  }

  void _notifyRtcChannelError(int code) {
    for (var callback in _eventCallbacks.copy()) {
      callback.rtcChannelErrorCallback?.call(code);
    }
  }

  void _notifyMemberAudioMuteChanged(
      NERoomMember member, bool mute, NERoomMember? operateBy) {
    for (var callback in _eventCallbacks.copy()) {
      if (operateBy == null) {
        callback.memberAudioMuteChangedCallback
            ?.call(mapMember(member), mute, null);
      } else {
        callback.memberAudioMuteChangedCallback
            ?.call(mapMember(member), mute, mapMember(operateBy));
      }
    }
  }

  void _notifyAudioOutputDeviceChanged(NEAudioOutputDevice device) {
    for (var callback in _eventCallbacks.copy()) {
      callback.audioOutputDeviceChangedCallback
          ?.call(ModelConvertUtil.handleAudioOutputDevices(device));
    }
  }

  void _notifyMemberPropertiesChanged(
      NERoomMember member, Map<String, String> properties) {
    String uuid = localMember?.account ?? "";
    if (properties.containsKey(MemberPropertyConstants.MUTE_VOICE_KEY)) {
      String voiceValue =
          properties[MemberPropertyConstants.MUTE_VOICE_KEY] as String;
      if (voiceValue == MemberPropertyConstants.MUTE_VOICE_VALUE_ON ||
          voiceValue == MemberPropertyConstants.MUTE_VOICE_VALUE_OFF) {
        bool mute = voiceValue != MemberPropertyConstants.MUTE_VOICE_VALUE_ON;
        if (member.uuid == uuid) {
          syncLocalAudioState(mute);
        }
        NEVoiceRoomMember voiceRoomMember = mapMember(member);
        commonLogger.i(
            "onMemberAudioMuteChanged voiceRoomMember:$voiceRoomMember,mute:$mute,operateBy:");
        for (var callback in _eventCallbacks.copy()) {
          callback.memberAudioMuteChangedCallback
              ?.call(voiceRoomMember, mute, localMember);
        }
      }
    } else if (properties
        .containsKey(MemberPropertyConstants.CAN_OPEN_MIC_KEY)) {
      bool banned = properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY] ==
          MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO;
      if (member.uuid == uuid) {
        if (banned) {
          // 响应房主关麦操作
          _muteMyAudioInner(false);
        } else {
          // 响应房主开麦操作
          if (!_isSelfMuted) {
            // 自己未主动闭麦的情况下，打开麦克风
            unmuteMyAudio();
          }
        }
      }
      NEVoiceRoomMember voiceRoomMember = mapMember(member);
      commonLogger.i(
          "onMemberAudioBanned voiceRoomMember:$voiceRoomMember,banned:$banned");
      for (var callback in _eventCallbacks.copy()) {
        callback.memberAudioBannedCallback?.call(voiceRoomMember, banned);
      }
    }
  }

  void syncLocalAudioState(bool mute) {
    _currentRoomContext?.rtcController.setRecordDeviceMute(mute);
  }

  void _addListener() {
    _currentRoomContext?.addEventCallback(_roomEventCallback);
    _currentRoomContext?.seatController.addEventCallback(_seatEventCallback);
  }

  void _notifyAudioMixingStateChanged(int reason) {
    for (var callback in _eventCallbacks.copy()) {
      callback.audioMixingStateChangedCallback?.call(reason);
    }
  }

  void _notifySeatManagerAddedCallback(List<String?> managers) {}
  void _notifySeatManagerRemovedCallback(List<String?> managers) {}
  void _notifySeatRequestSubmittedCallback(int seatIndex, String user) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatRequestSubmittedCallback?.call(seatIndex, user);
    }
  }

  void _notifySeatRequestCancelledCallback(int seatIndex, String user) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatRequestCancelledCallback?.call(seatIndex, user);
    }
  }

  void _notifySeatRequestApprovedCallback(
      int seatIndex, String user, String operateBy, bool isAutoAgree) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatRequestApprovedCallback
          ?.call(seatIndex, user, operateBy, isAutoAgree);
    }
  }

  void _notifySeatRequestRejectedCallback(
      int seatIndex, String user, String operateBy) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatRequestRejectedCallback?.call(seatIndex, user, operateBy);
    }
  }

  void _notifySeatInvitationReceivedCallback(
      int seatIndex, String user, String operateBy) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatInvitationReceivedCallback?.call(seatIndex, user, operateBy);
    }
  }

  void _notifySeatInvitationCancelledCallback(
      int seatIndex, String user, String operateBy) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatInvitationCancelledCallback
          ?.call(seatIndex, user, operateBy);
    }
  }

  void _notifySeatInvitationAcceptedCallback(
      int seatIndex, String user, bool isAutoAgree) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatInvitationAcceptedCallback
          ?.call(seatIndex, user, isAutoAgree);
    }
  }

  void _notifySeatInvitationRejectedCallback(int seatIndex, String user) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatInvitationRejectedCallback?.call(seatIndex, user);
    }
  }

  void _notifySeatLeaveCallback(int seatIndex, String user) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatLeaveCallback?.call(seatIndex, user);
    }
  }

  void _notifySeatKickedCallback(int seatIndex, String user, String operateBy) {
    for (var callback in _eventCallbacks.copy()) {
      callback.seatKickedCallback?.call(seatIndex, user, operateBy);
    }
  }

  void _notifySeatListChangedCallback(List<NESeatItem> seatItems) {
    String myUuid = _currentRoomContext!.localMember.uuid;
    NESeatItem? old;
    NESeatItem? now;
    if (currentSeatItems != null) {
      for (NESeatItem item in currentSeatItems!) {
        if (myUuid == item.user) {
          old = item;
          break;
        }
      }
    }
    for (NESeatItem item in seatItems) {
      if (myUuid == item.user) {
        now = item;
        break;
      }
    }
    commonLogger.i("_notifySeatListChangedCallback,old:$old,now:$now");
    if ((old == null || old.status != NESeatItemStatus.TAKEN) &&
        now != null &&
        now.status == NESeatItemStatus.TAKEN) {
      unmuteMyAudio();
      _currentRoomContext!.rtcController
          .setClientRole(NERoomRtcClientRole.BROADCASTER);
    } else if (old != null &&
        old.status == NESeatItemStatus.TAKEN &&
        now == null) {
      _muteMyAudioInner(false);
      _currentRoomContext!.rtcController
          .setClientRole(NERoomRtcClientRole.AUDIENCE);
      // 成员自己重置
      if (_currentRoomContext!.localMember
              .properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY] ==
          MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO) {
        _currentRoomContext!.deleteMemberProperty(
            myUuid, MemberPropertyConstants.CAN_OPEN_MIC_KEY);
      }
    }
    currentSeatItems = seatItems;
    for (var callback in _eventCallbacks.copy()) {
      List<NEVoiceRoomSeatItem> list = [];
      for (var element in seatItems) {
        list.add(NEVoiceRoomSeatItem(
            element.index!,
            element.status!,
            element.user!,
            element.userName,
            element.icon,
            element.onSeatType!,
            element.updated!));
      }
      callback.seatListChangedCallback?.call(list);
    }
  }

  void _notifyMemberJoinRtcChannel(List<NERoomMember> members) {}

  void _reset() {
    commonLogger.i("_reset");
    _voiceRoomInfo = null;
    _currentRoomContext = null;
    currentSeatItems = null;
    _removeListener();
  }

  @override
  Future<VoidResult> cancelSeatInvitation(String account) async {
    commonLogger.i('cancelSeatInvitation,account:$account');
    if (_currentRoomContext != null) {
      var ret = await _currentRoomContext!.seatController
          .cancelSeatInvitation(account);
      commonLogger.i('cancelSeatInvitation,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> acceptSeatInvitation() async {
    commonLogger.i('acceptSeatInvitation');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.acceptSeatInvitation();
      commonLogger.i('acceptSeatInvitation,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  @override
  Future<VoidResult> rejectSeatInvitation() async {
    commonLogger.i('rejectSeatInvitation');
    if (_currentRoomContext != null) {
      var ret =
          await _currentRoomContext!.seatController.rejectSeatInvitation();
      commonLogger.i('rejectSeatInvitation,ret:$ret');
      return ret;
    } else {
      commonLogger.e("_currentRoomContext == null");
      return Future.value(const NEResult(
          code: NEVoiceRoomErrorCode.failure, msg: ERROR_MSG_NOT_IN_ROOM));
    }
  }

  void _notifyMemberJoinChatroom(List<NERoomMember> members) {
    for (int i = 0; i < members.length; i++) {
      if (members[i].uuid == NEVoiceRoomKit.instance.localMember?.account) {
        _currentRoomContext!.seatController.getSeatInfo().then((value) {
          if (value.isSuccess()) {
            _notifySeatListChangedCallback(value.data!.seatItems!);
          }
        });
        break;
      }
    }
  }
}

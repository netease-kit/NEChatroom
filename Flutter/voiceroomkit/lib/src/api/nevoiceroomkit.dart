// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// VoiceRoomKit入口
abstract class NEVoiceRoomKit {
  static final _instance = _VoiceRoomKitImpl();

  /// 获取全局唯一的 NEVoiceRoomKit 实例
  static NEVoiceRoomKit get instance => _instance;

  /// 本端成员信息
  NEVoiceRoomMember? get localMember;

  /// 所有成员（包括本端）加入房间后获取
  List<NEVoiceRoomMember>? get allMemberList;

  /// 初始化状态
  bool get isInitialized;

  /// 是否已经登录
  Future<bool> get isLoggedIn;

  /// current userUuid
  String? get userUuid;

  /// nickname
  String? nickname;

  ///
  /// 初始化
  /// [options] 初始化参数
  ///
  Future<VoidResult> initialize(NEVoiceRoomKitOptions options);

  /// 添加登录状态监听
  /// @param callback 监听器
  void addAuthListener(NEVoiceRoomAuthEventCallback callback);

  /// 移除登录状态监听
  /// @param callback 监听器
  void removeAuthListener(NEVoiceRoomAuthEventCallback callback);

  /// 注册房间监听
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param callback 监听器
  void addVoiceRoomListener(NEVoiceRoomEventCallback callback);

  /// 移除房间监听
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param callback 监听器
  void removeVoiceRoomListener(NEVoiceRoomEventCallback callback);

  /// 登录
  ///
  /// @param account NERoom登录账号
  /// @param token NERoom token
  /// <br>相关回调：登录成功后，会触发[NEVoiceRoomAuthListener.onVoiceRoomAuthEvent]回调
  Future<VoidResult> login(String account, String token);

  /// 登出
  /// <br>相关回调：登出成功后，会触发[NEVoiceRoomAuthListener.onVoiceRoomAuthEvent]回调
  Future<VoidResult> logout();

  /// 获取房间列表
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param liveState 直播状态 (直播状态) [NEVoiceRoomLiveState]
  /// @param pageNum 页码
  /// @param pageSize 页大小,一页包含多少条
  ///
  Future<NEResult<NEVoiceRoomList>> getRoomList(
    NEVoiceRoomLiveState liveState,
    int pageNum,
    int pageSize,
  );

  /// 创建房间
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param params 创建房间参数配置[NECreateVoiceRoomParams]
  /// @param options 进入房间时的必要配置[NECreateVoiceRoomOptions]
  /// <br>注意事项：只有房主能执行该操作
  Future<NEResult<NEVoiceRoomInfo>> createRoom(
    NECreateVoiceRoomParams params,
    NECreateVoiceRoomOptions options,
  );

  /// 获取创建房间的默认信息
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  Future<NEResult<NEVoiceCreateRoomDefaultInfo>> getCreateRoomDefaultInfo();

  /// 加入房间
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param params 加入房间参数配置[NEJoinVoiceRoomParams]
  /// @param options 进入房间时的必要配置[NEJoinVoiceRoomOptions]
  /// <br>相关回调：加入房间成功后，会触发[NEVoiceRoomEventCallback.memberJoinRoomCallback]回调
  Future<NEResult<NEVoiceRoomInfo>> joinRoom(
    NEJoinVoiceRoomParams params,
    NEJoinVoiceRoomOptions options,
  );

  /// 离开房间
  /// <br>使用前提：该方法仅在调用[joinRoom]方法加入房间成功后调用有效
  /// <br>相关回调：离开房间成功后，会触发[NEVoiceRoomEventCallback.memberLeaveRoomCallback]回调
  Future<VoidResult> leaveRoom();

  /// 结束房间 房主权限
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>相关回调：离开房间成功后，会触发[NEVoiceRoomEventCallback.roomEndedCallback]回调
  /// <br>注意事项：只有房主能执行该操作
  Future<VoidResult> endRoom();

  /// 获取麦位信息。
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  Future<NEResult<NEVoiceRoomSeatInfo>> getSeatInfo();

  /// 获取麦位申请列表。按照申请时间正序排序，先申请的成员排在列表前面。
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  ///
  Future<NEResult<List<NEVoiceRoomSeatRequestItem>>> getSeatRequestList();

  /// 房主向成员[account]发送上麦邀请，指定位置为[seatIndex]，非管理员执行该操作会失败。
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param seatIndex 麦位位置。
  /// @param account 麦上的用户ID。
  /// <br>相关回调：邀请上麦后，观众同意后（组件默认自动接收邀请），房间内所有成员会触发[NEVoiceRoomEventCallback.seatInvitationAcceptedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> sendSeatInvitation(int seatIndex, String account);

  ///管理员取消成员[user]的上麦邀请，非管理员执行该操作会失败。
  ///@param user 麦上的用户ID。
  /// @param callback 回调。
  ///<br>相关回调：取消邀请上麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatInvitationCancelledCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> cancelSeatInvitation(String account);

  /// 成员申请指定位置为[seatIndex]的麦位，位置从**1**开始。
  /// 如果当前成员为管理员，则会自动通过申请。
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param seatIndex 麦位位置。
  /// @param exclusive 是否独占的。
  /// <br>相关回调：申请上麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatRequestSubmittedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> submitSeatRequest(int seatIndex, bool exclusive);

  /// 取消申请上麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>相关回调：取消申请上麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatRequestCancelledCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  /// <br>注意事项：只有非房主能执行该操作
  Future<VoidResult> cancelSeatRequest();

  /// 同意上麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param account 被同意上麦的用户account
  /// <br>相关回调：房主同意申请上麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatRequestApprovedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  /// <br>注意事项：只有房主能执行该操作
  Future<VoidResult> approveSeatRequest(String account);

  /// 拒绝上麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param account 被拒绝上麦的用户account

  /// <br>相关回调：房主拒绝申请上麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatRequestRejectedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  /// <br>注意事项：只有房主能执行该操作
  Future<VoidResult> rejectSeatRequest(String account);

  /// 踢麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param account 被踢用户的uid
  /// <br>相关回调：房主踢麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatKickedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  /// <br>注意事项：只有房主能执行该操作
  Future<VoidResult> kickSeat(String account);

  /// 下麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>相关回调：房主踢麦后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatLeaveCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> leaveSeat();

  /// 同意上麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>相关回调：成员同意后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatInvitationAcceptedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> acceptSeatInvitation();

  /// 拒绝上麦
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>相关回调：成员同意后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatInvitationRejectedCallback]回调和[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> rejectSeatInvitation();

  /// 禁用指定成员音频
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param account 成员

  /// <br>注意事项：只有房主能执行该操作
  /// <br>相关回调：禁用指定成员音频后，房间内所有成员会触发[NEVoiceRoomEventCallback.memberAudioBannedCallback]回调
  Future<VoidResult> banRemoteAudio(String account);

  /// 解禁指定成员的音频
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param account 成员
  /// <br>注意事项：只有房主能执行该操作
  /// <br>相关回调：解禁指定成员的音频后，房间内所有成员会触发[NEVoiceRoomEventCallback.memberAudioBannedCallback]回调
  Future<VoidResult> unbanRemoteAudio(String account);

  /// 打开麦位
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param seatIndices 麦位序号
  /// <br>注意事项：只有房主能执行该操作
  /// <br>相关回调：打开麦位后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> openSeats(List<int> seatIndices);

  /// 关闭麦位
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// <br>注意事项：只有房主能执行该操作
  /// <br>相关回调：关闭麦位后，房间内所有成员会触发[NEVoiceRoomEventCallback.seatListChangedCallback]回调
  Future<VoidResult> closeSeats(List<int> seatIndices);

  /// 发送聊天室消息
  /// <br>使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// @param content 消息内容
  /// <br>相关回调：调用改方法后，房间内其他成员都会触发[NEVoiceRoomEventCallback.receiveTextMessageCallback]回调
  Future<VoidResult> sendTextMessage(String content);

  /// 关闭自己的麦克风
  /// <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEVoiceRoomEventCallback.memberAudioMuteChangedCallback]回调
  Future<VoidResult> muteMyAudio();

  /// 打开自己的麦克风
  /// <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// <br>相关回调：调用该方法后，本端和其他上麦用户会触发[NEVoiceRoomEventCallback.memberAudioMuteChangedCallback]回调
  Future<VoidResult> unmuteMyAudio();

  /// 开启耳返功能。
  /// <br>开启耳返功能后，必须连接上耳机或耳麦，才能正常使用耳返功能。
  /// @param volume 设置耳返音量，可设置为 0~100，默认为 100。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> enableEarback(int volume);

  /// 关闭耳返功能。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> disableEarback();

  ///是否开启耳返功能
  /// @return true 开启  false 关闭
  bool isEarbackEnable();

  /// 调节人声音量
  /// <br>使用前提：该方法仅在调用[login]方法登录成功且上麦成功后调用有效
  /// @param volume 音量 范围0-100  默认100
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> adjustRecordingSignalVolume(int volume);

  /// 获取人声音量
  /// @return 人声音量
  int getRecordingSignalVolume();

  /// 开始播放音乐文件。
  /// 该方法指定本地或在线音频文件来和录音设备采集的音频流进行混音。
  /// 支持的音乐文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地文件或在线 URL。
  /// @param option    创建混音任务配置的选项，包括混音任务类型、混音文件全路径或 URL 等，详细信息请参考 audio.NERtcCreateAudioMixingOption。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> startAudioMixing(
      NEVoiceRoomCreateAudioMixingOption option);

  /// 暂停播放音乐文件及混音。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> pauseAudioMixing();

  /// 恢复播放伴奏。
  /// 该方法恢复混音，继续播放伴奏。请在房间内调用该方法。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> resumeAudioMixing();

  /// 停止播放伴奏。
  /// 该方法停止混音，停止播放伴奏。请在房间内调用该方法。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> stopAudioMixing();

  /// 设置伴奏音量。
  /// 该方法调节混音里伴奏的音量大小。 setAudioMixingSendVolume setAudioMixingPlaybackVolume
  /// @param volume    伴奏发送音量。取值范围为 0~200。默认 100，即原始文件音量。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> setAudioMixingVolume(int volume);

  /// 获取伴奏音量
  /// @return 伴奏音量
  int getAudioMixingVolume();

  /// 播放指定音效文件。
  /// 该方法播放指定的本地或在线音效文件。
  /// 支持的音效文件类型包括 MP3、M4A、AAC、3GP、WMA 和 WAV 格式，支持本地 SD 卡中的文件和在线 URL
  /// @param effectId    指定音效的 ID。每个音效均应有唯一的 ID。
  /// @param option    音效相关参数，包括混音任务类型、混音文件路径等。
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> playEffect(
      int effectId, NEVoiceRoomCreateAudioEffectOption option);

  /// 设置音效音量
  /// @param effectId Int
  /// @param volume Int 默认 100
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> setEffectVolume(int effectId, int volume);

  /// 获取音效音量
  /// @return 音效音量
  int getEffectVolume();

  /// 停止所有音效
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> stopAllEffect();

  /// 停止指定id的音效
  /// @param effectId 音效Id
  /// @return 0：方法调用成功。其他：方法调用失败
  Future<VoidResult> stopEffect(int effectId);
}

/// 初始化参数
class NEVoiceRoomKitOptions {
  NEVoiceRoomKitOptions({
    required this.appKey,
    required this.voiceRoomUrl,
    Map<String, String>? extras,
  }) : extras = extras != null ? Map.from(extras) : const {};

  /// 应用 appKey
  final String appKey;

  /// 语聊房业务接口host
  final String voiceRoomUrl;

  /// 额外参数
  final Map<String, String>? extras;

  @override
  String toString() {
    return 'NEVoiceRoomKitOptions{appKey: $appKey,extras: $extras}';
  }
}

/// 登录监听器
abstract class NEVoiceRoomAuthListener {
  /// 登录事件回调
  /// @param evt 登录事件
  void onVoiceRoomAuthEvent(NEVoiceRoomAuthEvent evt);
}

/// NEVoiceRoomKit配置
/// @property appKey NEVoiceRoom 服务的key
/// @property extras 额外参数

class NEVoiceRoomKitConfig {
  NEVoiceRoomKitConfig({
    required this.appKey,
    Map<String, String>? extras,
  }) : extras = extras != null ? Map.from(extras) : const {};
  final String appKey;
  final Map<String, String>? extras;

  @override
  String toString() {
    return 'NEVoiceRoomKitConfig{appKey: $appKey, extras: $extras}';
  }
}

/// 创建房间参数
///
/// @property title 房间名，支持中英文大小写、数字、特殊字符
/// @property nick 昵称
/// @property seatCount 麦位个数，默认8个,取值范围为1~20
/// @property configId 模版id
/// @property cover 封面，https链接
/// @property extraData 扩展字段

class NECreateVoiceRoomParams {
  final String title;
  final String nick;
  final int seatCount;
  final int configId;
  final String? cover;
  final String? extraData;

  NECreateVoiceRoomParams({
    required this.title,
    required this.nick,
    required this.seatCount,
    required this.configId,
    required this.cover,
    this.extraData,
  });

  @override
  String toString() {
    return 'NECreateVoiceRoomParams{title: $title, nick: $nick, seatCount: $seatCount, configId: $configId, cover: $cover, extraData: $extraData}';
  }
}

class NEStartVoiceRoomParams {
  final String title;
  final String nick;
  final int seatCount;
  final int configId;
  final String? cover;
  final String roomName;
  final int liveType;
  final NEVoiceRoomSeatRequestApprovalMode? seatApplyMode;
  final NEVoiceRoomSeatInvitationConfirmMode? seatInviteMode;

  NEStartVoiceRoomParams({
    required this.title,
    required this.nick,
    required this.seatCount,
    required this.configId,
    required this.cover,
    required this.roomName,
    required this.liveType,
    this.seatApplyMode,
    this.seatInviteMode,
  });

  @override
  String toString() {
    return 'NEStartVoiceRoomParams{title: $title, nick: $nick, seatCount: $seatCount, configId: $configId, cover: $cover, liveType: $liveType, seatApplyMode: $seatApplyMode, seatInviteMode: $seatInviteMode}';
  }
}

/// 上麦申请是否需要管理员同意
enum NEVoiceRoomSeatRequestApprovalMode { off, on }

/// 管理员抱麦是否需要成员同意
enum NEVoiceRoomSeatInvitationConfirmMode { off, on }

/// 创建房间选项
class NECreateVoiceRoomOptions {}

/// 加入房间参数，支持中英文大小写、数字、特殊字符
///
/// @property roomUuid 房间id
/// @property nick 昵称,最大字符长度64
/// @property avatar 头像
/// @property role 角色，支持HOST、AUDIENCE
/// @property liveRecordId 直播id
/// @property extraData 扩展字段

class NEJoinVoiceRoomParams {
  final String roomUuid;
  final String nick;
  final String avatar;
  final NEVoiceRoomRole role;
  final int liveRecordId;
  final Map<String, String>? extraData;

  NEJoinVoiceRoomParams({
    required this.roomUuid,
    required this.nick,
    required this.avatar,
    required this.role,
    required this.liveRecordId,
    this.extraData,
  });

  @override
  String toString() {
    return 'NEJoinVoiceRoomParams{roomUuid: $roomUuid, nick: $nick, avatar: $avatar, role: $role, liveRecordId: $liveRecordId, extraData: $extraData}';
  }
}

/// 加入房间选项
class NEJoinVoiceRoomOptions {
  final bool enableMyAudioDeviceOnJoinRtc = true;
}

/// 通用回调
/// @param T 数据
abstract class NEVoiceRoomCallback<T> {
  /// 成功回调
  /// @param t 数据
  void onSuccess(T? t);

  /// 失败回调
  /// @param code 错误码
  /// @param msg 错误信息
  void onFailure(int code, String msg);
}

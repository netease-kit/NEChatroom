// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 直播模式
/// @property appId 应用Id
/// @property roomUuid 房间Id
/// @property roomName 房间名
/// @property liveRecordId 直播Id
/// @property userUuId 用户id
/// @property status  直播记录是否有效 1: 有效 -1 无效
/// @property liveType Int
/// @property live 直播状态
/// @property liveTopic 直播标题
/// @property cover 直播封面
/// @property rewardTotal 打赏总额
/// @property audienceCount 观众人数
/// @property onSeatCount 上麦人数
/// @property liveConfig 拉流配置
/// @property seatUserReward 用户打赏信息
/// @constructor
class NEVoiceRoomLiveModel {
  String? appId;
  String? roomUuid;
  String? roomName;
  int? liveRecordId;
  String? userUuId;
  int? status;
  int? liveType;
  int? live;
  String? liveTopic;
  String? cover;
  int? rewardTotal;
  int? audienceCount;
  int? onSeatCount;
  String? liveConfig;
  List<SeatUserReward>? seatUserReward;

  NEVoiceRoomLiveModel(
      this.appId,
      this.roomUuid,
      this.roomName,
      this.liveRecordId,
      this.userUuId,
      this.status,
      this.liveType,
      this.live,
      this.liveTopic,
      this.cover,
      this.rewardTotal,
      this.audienceCount,
      this.onSeatCount,
      this.liveConfig,
      this.seatUserReward);

  NEVoiceRoomLiveModel.fromJson(Map? json) {
    appId = json?['appId'];
    roomUuid = json?['roomUuid'];
    roomName = json?['roomName'];
    liveRecordId = json?['liveRecordId'];
    userUuId = json?['userUuId'];
    status = json?['status'];
    liveType = json?['liveType'];
    live = json?['live'];
    liveTopic = json?['liveTopic'];
    cover = json?['cover'];
    rewardTotal = json?['rewardTotal'];
    audienceCount = json?['audienceCount'];
    onSeatCount = json?['onSeatCount'];
    liveConfig = json?['liveConfig'];
    seatUserReward = (json?['seatUserReward'] as List<dynamic>?)
        ?.map((e) => SeatUserReward.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'roomUuid': roomUuid,
        'roomName': roomName,
        'liveRecordId': liveRecordId,
        'userUuId': userUuId,
        'status': status,
        'liveType': liveType,
        'live': live,
        'liveTopic': liveTopic,
        'cover': cover,
        'rewardTotal': rewardTotal,
        'audienceCount': audienceCount,
        'onSeatCount': onSeatCount,
        'liveConfig': liveConfig,
        'seatUserReward': seatUserReward,
      };

  @override
  String toString() {
    return 'NEVoiceRoomLiveModel{appId: $appId, roomUuid: $roomUuid, roomName: $roomName, liveRecordId: $liveRecordId, userUuId: $userUuId, status:$status, liveType: $liveType, live: $live, liveTopic: $liveTopic, cover: $cover, rewardTotal: $rewardTotal, audienceCount: $audienceCount, onSeatCount: $onSeatCount, liveConfig: $liveConfig}';
  }
}

class SeatUserReward {
  late String? userUuid;
  late String? userName;
  late String? icon;
  late int seatIndex;
  late int rewardTotal;

  SeatUserReward(this.userUuid, this.userName, this.icon, this.seatIndex,
      this.rewardTotal);

  SeatUserReward.fromJson(Map? json) {
    userUuid = json?['userUuid'];
    userName = json?['userName'];
    icon = json?['icon'];
    seatIndex = json?['seatIndex'];
    rewardTotal = json?['rewardTotal'];
  }

  @override
  String toString() {
    return 'SeatUserReward{userUuid: $userUuid, userName: $userName, icon: $icon, seatIndex: $seatIndex, rewardTotal: $rewardTotal}';
  }
}

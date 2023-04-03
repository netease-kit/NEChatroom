// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 直播模式
/// @property appId 应用Id
/// @property roomUuid 房间Id
/// @property liveRecordId 直播Id
/// @property userUuId String
/// @property liveType Int
/// @property live 直播状态
/// @property liveTopic 直播标题
/// @property cover 直播封面
/// @property rewardTotal 打赏总额
/// @property audienceCount 观众人数
/// @property onSeatCount 上麦人数
/// @property liveConfig 拉流配置
/// @constructor
class NEVoiceRoomLiveModel {
  String? appId;
  String? roomUuid;
  int? liveRecordId;
  String? userUuId;
  int? liveType;
  int? live;
  String? liveTopic;
  String? cover;
  int? rewardTotal;
  int? audienceCount;
  int? onSeatCount;
  String? liveConfig;

  NEVoiceRoomLiveModel(
      this.appId,
      this.roomUuid,
      this.liveRecordId,
      this.userUuId,
      this.liveType,
      this.live,
      this.liveTopic,
      this.cover,
      this.rewardTotal,
      this.audienceCount,
      this.onSeatCount,
      this.liveConfig);

  NEVoiceRoomLiveModel.fromJson(Map? json) {
    appId = json?['appId'];
    roomUuid = json?['roomUuid'];
    liveRecordId = json?['liveRecordId'];
    userUuId = json?['userUuId'];
    liveType = json?['liveType'];
    live = json?['live'];
    liveTopic = json?['liveTopic'];
    cover = json?['cover'];
    rewardTotal = json?['rewardTotal'];
    audienceCount = json?['audienceCount'];
    onSeatCount = json?['onSeatCount'];
    liveConfig = json?['liveConfig'];
  }

  Map<String, dynamic> toJson() => {
        'appId': appId,
        'roomUuid': roomUuid,
        'liveRecordId': liveRecordId,
        'userUuId': userUuId,
        'liveType': liveType,
        'live': live,
        'liveTopic': liveTopic,
        'cover': cover,
        'rewardTotal': rewardTotal,
        'audienceCount': audienceCount,
        'onSeatCount': onSeatCount,
        'liveConfig': liveConfig,
      };

  @override
  String toString() {
    return 'NEVoiceRoomLiveModel{appId: $appId, roomUuid: $roomUuid, liveRecordId: $liveRecordId, userUuId: $userUuId, liveType: $liveType, live: $live, liveTopic: $liveTopic, cover: $cover, rewardTotal: $rewardTotal, audienceCount: $audienceCount, onSeatCount: $onSeatCount, liveConfig: $liveConfig}';
  }
}

## v1.0.5(Feb 8, 2023)
### New Features
* 接口新增 
    -NEVoiceRoomListener新增如下接口：
        - onRtcAudioVolumeIndication 成员说话音量上报
        - onReceiveBatchGift 收到批量礼物回调
        
    -NEVoiceRoomKit 新增如下接口：
        - sendBatchGift 批量礼物发送
    
* Model更改    
    - Update NEVoiceRoomLiveModel 
        - 新增字段：seatUserReward 打赏信息
    - Add NEVoiceRoomBatchSeatUserReward: 打赏详情 

## v1.0.4(Jan 12, 2023)
### New Features
* NEVoiceRoomKit新增如下接口：
  - getRoomInfo 查询房间信息
  - setPlayingPosition 指定播放位置
  - pauseEffect 暂停播放音效文件
  - resumeEffect 继续播放音效文件

* NEVoiceRoomListener新增如下接口：
    - onMemberJoinChatroom 成员进入聊天室回调
    - onAudioEffectTimestampUpdate 背景音乐播放回调
    - onAudioEffectFinished 本地音效文件播放已结束回调

* 新增NELiveType类，表示直播类型
* NECreateVoiceRoomParams新增liveType，表示直播类型
* NEVoiceRoomCreateAudioEffectOption
    新增参数startTimestamp表示音效文件的开始播放时间
    新增参数progressInterval表示播放进度回调间隔

* 依赖版本 
  NERoomKit:1.11.0

## v1.0.3(DEC 7, 2022)
### New Features
  - 新增礼物功能，对齐KTV逻辑
  - 兼容 NIM 9.6.4 版本
  - 兼容 NERtc 4.6.29 版本
  - 兼容 NERoom 1.10.0 版本


## v1.0.0(September 30, 2022)
### New Features
    - 首次发布版本
    - Compatibility
    - 兼容 NERoom 1.8.2 版本

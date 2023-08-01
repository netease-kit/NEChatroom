## v1.5.0(July 31, 2023)
### New Features
### 接口改动
  * NEVoiceRoomRoomService 新增方法 
      - authenticate 实名认证
  * NEVoiceRoomKit+Seat 接口改动
      - muteSeat 变私有方法
      - unmuteSeat 变私有方法
    
### 内部改动
  * mute 逻辑下沉
  * 多租户适配：头部信息新增`appKey` 字段
  * 加入房间 _joinRoom 接口新增`role`字段


## v1.4.0(Jun 19, 2023)
### API Changes
* `NEVoiceRoomKitConfig.extras` 新增baseUrl参数,支持业务层传入语聊房Server baseUrl。
* 删除`NEVoiceRoomKit.sendGift`和`NEVoiceRoomListener.onReceiveGift`。

### Compatibility
* 兼容 `NIM` 9.10.0 版本
* 兼容 `NERtc` 4.6.50 版本
* 兼容 `NERoom` 1.15.0 版本

## v1.3.0(May 4, 2023)
### New Features
### API Changes
* `NEVoiceRoomKit.getVoiceRoomList` 重命名为 `NEVoiceRoomKit.getRoomList`， 并且不需要再填写liveType。
* `NEVoiceRoomKitConfig`新增reuseIM参数，是否复用IM

## v1.2.0(Mar 15, 2023)
### New Features
* NEVoiceRoomKit 新增 getCurrentRoomInfo，用于获取当前所在的房间信息，如果没在房间则获取到nil
* NEVoiceRoomKit 新增 stopEffect，用于对不同的effectId分开处理

### BUG Fix
* 解决onAudioOutputDeviceChanged不上报的问题


## v1.1.0(Feb 8, 2023)
### New Features
* 接口变更
  - NEVoiceRoomListener中的onRtcAudioVolumeIndication拆分为onRtcRemoteAudioVolumeIndication、onRtcLocalAudioVolumeIndication，可以更方便区分自己的音量上报和其他成员的音量上报
  
* NEVoiceRoomKit 新增方法 
    - addPreviewListener 新增监听
    - removePreviewListener 移出监听
    - previewRoom 房间预览 对象初始化 （internal）
    - startLastmileProbeTest 开始通话前网络质量探测。
    - stopLastmileProbeTest 停止通话前网络质量探测。
    - uploadLog 日志上传
    
* 新增 NEVoiceRoomPreviewListener 监听协议
    - onVoiceRoomRtcLastmileQuality 报告本地用户的网络质量。
    - onVoiceRoomRtcLastmileProbeResult 报告通话前网络上下行 last mile 质量。
* NEVoiceRoomModels 新增Model 和 Enum
    - NEVoiceRoomRtcLastmileProbeConfig 网络探测配置
    - NEVoiceRoomRtcLastmileProbeResultState 质量探测结果的状态。
    - NEVoiceRoomRtcNetworkStatusType 网络质量类型
    - NEVoiceRoomRtcLastmileProbeResult 网络质量探测结果
    - NEVoiceRoomRtcLastmileProbeOneWayResult 网络质量探测结果
    
* NEVoiceRoomKit 新增内部属性
    - previewListeners preview监听器数组
    - previewRoomContext preview操作对象
    
* NEVoiceRoomAudioPlayService 修改配置
    - rtcController.setAudioProfile: .music -> .chatRoom
* NEPreviewVoiceRoomParams 新增类
    - NEPreviewVoiceRoomParams 房间预览参数
    - NEPreviewVoiceRoomOptions 房间预览配置
* NEVoiceRoomKit 方法修改
    - isHeadSetPlugging:内部修改，耳机判断新增类型判断 :bluetoothHFP      
    - NEVoiceRoomKit 添加context为空时的处理


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

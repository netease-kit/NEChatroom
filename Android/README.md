## 云信语聊房（Android）

本文主要展示如何集成云信的NIMSDK以及NERtcSDK，快速实现语音聊天室功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的nertcvoiceroom库工程，单独使用组件。

### 环境准备

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话】功能。
2. 在控制台中【App Key管理】获取App Key。
3. 下载[场景Demo]()，将/build.gradle中的NimAppKey和NERTCAppKey更换为自己的App Key，将BaseUrl替换为自己的服务器链接，NERTCAppKey可以和NimAppKey不一样。

### 运行示例项目

**注意：在运行前，请联系商务经理开通非安全模式（因Demo中RTCSDK中的token传空）。**

1. 下载完成场景Demo后，使用Android Studio打开工程，配置NimAppKey和NERTCAppKey后，运行即可。
2. 修改build参数，在/build.gradle中定义了build相关参数，如下表

| key | value |
| - | - |
| compileSdkVersion | 30 |
| buildToolsVersion | 30.0.0 |
| minSdkVersion | 18 |
| targetSdkVersion | 30 |
| ndkAbis | all |

2. 修改sdk参数，在/build.gradle中定义了sdk相关参数，如下表

| key | value | note
| - | - | - |
| nimVersion | 8.2.0 | nim相关版本
| nertcVersion | 3.9.103 | NERTC版本

### 使用示例项目
源码Demo的包含两个模块，app和nertcvoiceroom。nertcvoiceroom实现了对语音聊天室业务逻辑的组件封装，而app实现ui的搭建。

1. 基于Demo修改适配

2. 使用nertcvoiceroom组件库工程搭建

#### **NERtcVoiceRoom**接口分类
1. 操作接口
- **NERtcVoiceRoom**
- **Anchor**
- **Audience**
- **AudioPlay**

2. 回调接口
- **RoomCallback**
- **Anchor.Callback**
- **Audience.Callback**
- **AudioPlay.Callback**

#### **NERtcVoiceRoom**使用
- 主播创建聊天室，观众选择聊天室
- 初始化

```java
    NERtcVoiceRoom voiceRoom = NERtcVoiceRoom.sharedInstance(context);
    voiceRoom.init(appKey, roomCallback);
```

- 主播初始化

```java
    Anchor anchor = voiceRoom.getAnchor();
    AudioPlay audioPlay = voiceRoom.getAudioPlay();
    anchor.setCallback(anchorCallback);
    audioPlay.setCallback(audioPlayCallback);
```

- 观众初始化

```java
    Audience audience = voiceRoom.getAudience();
    audience.setCallback(audienceCallback);
```

- 进入房间

```java
    voiceRoom.initRoom(voiceRoomInfo, user);
    voiceRoom.enterRoom(anchorMode);
```

- 房间操作

```java
    // 设置采集音量
    voiceRoom.setAudioCaptureVolume(volume);
    // 启动耳返
    voiceRoom.enableEarback(enable);
```

- 主播操作

```java
    // 通过连麦请求
    anchor.approveSeatApply(seat, callback);
```

- 播放操作

```java
    // 播放或暂停
    audioPlay.playOrPauseMixing();
```

- 观众操作

```java
    // 请求连麦
    audience.applySeat(seat, callback);
```

#### NERtcVoiceRoom API

| NERtcVoiceRoom | 语聊房 |
| - | - |
| sharedInstance | 获取实例 |
| destroySharedInstance | 销毁实例 |
| init | 初始化 |
| setAudioQuality | 设置音质 |
| initRoom | 初始化房间 |
| enterRoom | 进入房间 |
| leaveRoom | 离开房间 |
| startLocalAudio | 开启本地语音 |
| stopLocalAudio | 停止本地语音 |
| muteLocalAudio | 本地静音 |
| isLocalAudioMute | 本地是否静音 |
| setSpeaker | 设置开启扬声器 |
| setAudioCaptureVolume | 设置采集音量 |
| muteRoomAudio | 房间静音 |
| isRoomAudioMute | 房间是否静音 |
| enableEarback | 开启耳返 |
| sendTextMessage | 发送房间文本消息 |
| getAudioPlay | 获取播放接口 |
| getAudience | 获取观众接口 |
| getAnchor | 获取主播接口 |

| RoomCallback | 房间回调 |
| - | - |
| onEnterRoom | 进入房间 |
| onLeaveRoom | 离开房间 |
| onRoomDismiss | 房间被解散 |
| onOnlineUserCount | 当前在线用户数量更新 |
| onAnchorInfo | 主播信息更新 |
| onAnchorMute | 主播静音状态 |
| onAnchorVolume | 主播说话音量 |
| onMute | 静音状态 |
| updateSeats | 更新所有麦位信息 |
| updateSeat | 更新麦位信息 |
| onSeatVolume | 麦位说话音量 |
| onVoiceRoomMessage | 收到消息 |

| Audience | 观众操作 |
| - | - |
| applySeat | 申请上麦 |
| cancelSeatApply | 取消申请上麦 |
| leaveSeat | 下麦 |
| getSeat | 获取当前麦位 |

| Audience.Callback | 观众回调 |
| - | - |
| onSeatApplyDenied | 上麦请求被拒绝 |
| onEnterSeat | 进入麦位 |
| onLeaveSeat | 离开麦位 |
| onSeatMuted | 麦位被屏蔽语音 |
| onSeatClosed | 麦位被关闭 |
| onTextMuted | 是否被禁言 |

| Anchor | 主播操作 |
| - | - |
| approveSeatApply | 通过上麦请求 |
| denySeatApply | 拒绝上麦请求 |
| openSeat | 打开麦位 |
| closeSeat | 关闭麦位 |
| muteSeat | 静音麦位 |
| inviteSeat | 抱上麦位 |
| kickSeat | 踢下麦位 |
| fetchSeats | 获取服务器最新麦位列表 |
| getSeat | 获取本地麦位 |
| getApplySeats | 获取当前上麦请求列表 |
| getRoomQuery | 检查是否在房间内 |

| Anchor.Callback | 主播回调 |
| - | - |
| onApplySeats | 上麦请求列表 |

| AudioPlay | 播放操作 |
| - | - |
| setMixingVolume | 设置伴音音量 |
| setMixingFile | 设置伴音文件 |
| getMixingFile | 获取伴音文件 |
| playOrPauseMixing | 播放或暂停当前伴音文件 |
| playNextMixing | 播放下一个伴音文件 |
| playMixing | 播放伴音文件 |
| setEffectVolume | 设置音效音量 |
| setEffectFile | 设置音效文件 |
| playEffect | 播放音效文件 |
| stopEffect | 停止播放音效文件 |
| stopAllEffects | 停止播放所有音效 |

| AudioPlay.Callback | 播放回调 |
| - | - |
| onAudioMixingPlayState | 伴音播放状态 |
| onAudioMixingPlayError | 伴音播放错误 |
| onAudioEffectPlayFinished | 音效播放完成 |

### 功能实现

#### **NERtcVoiceRoom**使用到的SDK功能

- **NERtcEx**房间相关

| api | usage |
| - | - |
| init | 初始化 |
| release | 释放实例 |
| setAudioProfile | 设置音质 |
| joinChannel | 进入语音通道 |
| leaveChannel | 离开语音通道 |
| enableLocalAudio | 启用本地语音，包括采集和发送，观众上麦后开启，下麦后关闭 |
| setRecordDeviceMute | 录音设备静音，开启关闭话筒 |
| isRecordDeviceMute | 获取录音设备静音状态 |
| adjustRecordingSignalVolume | 调整录音音量，设置采集音量 |
| subscribeAllRemoteAudioStreams | 订阅房间内所有远端声音 |
| enableEarback | 启用耳返 |
| setSpeakerphoneOn | 打开扬声器，进入房间后默认使用 |
| enableAudioVolumeIndication | 开启音量汇报，实现房间内说话音量 |
| setPlayoutDeviceMute | 开启关闭房间声音（包含伴音，音效） |

- **NERtcEx**播放相关

| api | usage |
| - | - |
| setAudioMixingSendVolume | 设置伴音发送音量（同步设置发送和播放） |
| setAudioMixingPlaybackVolume | 设置伴音播放音量（同步设置发送和播放） |
| startAudioMixing | 开始播放伴音 |
| stopAudioMixing | 停止播放伴音 |
| pauseAudioMixing | 暂停播放伴音 |
| resumeAudioMixing | 继续播放伴音 |
| setEffectPlaybackVolume | 设置音效发送音量（同步设置发送和播放） |
| setEffectSendVolume | 设置音效播放音量（同步设置发送和播放） |
| playEffect | 开始播放音效 |
| stopEffect | 停止播放音效 |
| stopAllEffects | 停止播放所有音效 |

- **NERtcCallbackEx**回调相关

| api | usage |
| - | - |
| onJoinChannel | 进入语音通道，此时房间才加入成功 |
| onLeaveChannel | 离开语音通道，此时房间才完全离开 |
| onAudioMixingStateChanged | 处理伴音播放状态 |
| onAudioEffectFinished | 处理音效播放状态 |
| onRemoteAudioVolumeIndication | 处理音量汇报 |

- **ChatRoomService**相关

| api | usage |
| - | - |
| enterChatRoom | 进入聊天室，进入成功后，再进入语音通道 |
| exitChatRoom | 退出聊天室 |
| fetchRoomInfo | 获取聊天室信息，人数，创建者等 |
| fetchRoomMembers | 获取聊天室成员列表 |
| fetchQueue | 获取聊天室队列信息，麦位列表信息 |
| updateQueue | 更新聊天室队列信息，麦位列表信息 |
| sendMessage | 发送聊天室消息，只发送文本消息，使用了扩展字段type来区分是普通消息还是麦位变化提示消息 |

- **ChatRoomServiceObserver.observeReceiveMessage**

| event | usage |
| - | - |
| ChatRoomQueueChange | 队列变更，用于接收麦位变更 |
| ChatRoomMemberIn | 生成进入房间消息 |
| ChatRoomMemberExit | 生成退出房间消息 |
| ChatRoomRoomMuted | 房间禁言 |
| ChatRoomRoomDeMuted | 房间解除禁言 |
| ChatRoomMemberTempMuteAdd | 禁言列表增加 |
| ChatRoomMemberTempMuteRemove | 禁言列表移除 |
| ChatRoomInfoUpdated | 聊天室信息变更，人数变化等 |
| MsgTypeEnum.text | 接收文本消，普通消息和麦位变化提示消息 |

- **ChatRoomServiceObserver.observeKickOutEvent**

处理踢出，房间被解散

- **MsgService.sendCustomNotification**

发送指令消息（麦位消息，观众发送给主播）

- **MsgServiceObserve.observeCustomNotification**

接收指令消息（麦位消息，主播接收）



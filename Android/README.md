## 云信语聊房（Android）

本文主要展示如何集成云信的NIMSDK以及NERtcSDK，快速实现语音聊天室功能。您可以直接基于我们的Demo修改适配，也可以使用我们提供的nertcvoiceroom库工程，单独使用组件。

### 环境准备

1. 登录[网易云控制台](https://app.yunxin.163.com/index?clueFrom=nim&from=nim#/)，点击【应用】>【创建】创建自己的App，在【功能管理】中申请开通【信令】和【音视频通话】功能。
2. 在控制台中【App Key管理】获取App Key。
3. 下载[场景Demo]()，将/build.gradle中的NimAppKey和G2AppKey更换为自己的App Key，G2AppKey可以和NimAppKey不一样。

### 运行示例项目

**注意：在运行前，请联系商务经理开通非安全模式（因Demo中RTCSDK中的token传空）。**

1. 下载完成场景Demo后，使用Android Studio打开工程，配置NimAppKey和G2AppKey后，运行即可。
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
| nimVersion | 7.8.4 | nim相关版本
| nertcVersion | 3.6.0 | G2版本

### 使用示例项目
源码Demo的包含两个模块，app和nertcvoiceroom。nertcvoiceroom实现了对语音聊天室业务逻辑的组件封装，而app实现ui的搭建。

1. 基于Demo修改适配

2. 使用nertcvoiceroom组件库工程搭建

### 功能实现
1. NERtcVoiceRoom组件：

   ![](https://github.com/netease-im/NEVideoCall-1to1/blob/feature/feature_iOS/iOS/NLiteAVDemo/Images/image-20200902204955182.png)

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
- 获取**NERtcVoiceRoom**对象，注册回调，初始化，加入房间
- 主播侧，获取**Anchor**对象，注册回调，获取**AudioPlay**对象，注册回调
- 观众侧，获取**Audience**对象，注册回调

#### **NERtcVoiceRoom**使用到的SDK功能
- **NERtcEx** 语音通道加入退出，本地语音采集，发送，静音，远程语音订阅，音量控制，混音播放。
- **ChatRoomService** 聊天室进入退出，获取聊天室信息，成员列表，麦位（队列）列表，更新麦位（队列），消息发送
- **ChatRoomServiceObserver** 接收聊天室通知消息，包括：成员变更，麦位（队列）变更，禁言控制。
- **MsgService** 发送指令消息（麦位消息，观众发送给主播）
- **MsgServiceObserve** 接收指令消息（麦位消息，主播接收）

#### NERtcVoiceRoom API

| NERtcVoiceRoom | 语聊房 |
| - | - |
| sharedInstance | 获取实例 |
| destroySharedInstance | 销毁实例 |
| init | 初始化 |
| setAudioQuality | 设置音质 |
| listen | 监听操作 |
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
| onChatRoomInfo | 房间信息更新 |
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
| checkInRoom | 检查是否在房间内 |

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

| AudioPlay.Callback | 播放回调 |
| - | - |
| onAudioMixingPlayState | 伴音播放状态 |
| onAudioMixingPlayError | 伴音播放错误 |
| onAudioEffectPlayFinished | 音效播放完成 |

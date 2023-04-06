## v1.2.0(Mar 15, 2023)
### New Features
* NEListenTogetherKit 新增 getCurrentRoomInfo，用于获取当前所在的房间信息，如果没在房间则获取到nil
* NEListenTogetherKit 新增 stopEffect，用于对不同的effectId分开处理

### BUG Fix
* 解决onAudioOutputDeviceChanged不上报的问题

## v1.0.6(Feb 22, 2023)
### New Features
* 接口变更
  - NEListenTogetherKitListener中的onRtcAudioVolumeIndication拆分为onRtcRemoteAudioVolumeIndication、onRtcLocalAudioVolumeIndication，可以更方便区分自己的音量上报和其他成员的音量上报
- NEListenTogetherLocalized.h 方法名修改

- NEListenTogetherKit 添加context为空时的处理

# NEChatroom-iOS-ObjC

这个开源示例项目演示了如何快速集成 网易云信 新一代（G2）音视频 SDK，创建语音聊天室。

# 功能介绍

该示例项目中包含了以下功能：

- 创建语音聊天室；
- 使用文字或语音进行多对多互动通信；
- 增加耳返功能；
- 自定义采集音量；
- 播放背景音乐和音效；
- 将聊天室内成员抱上麦；
- 加入已经创建好的语音聊天室；
- 非聊天室创建人申请上麦；

# 环境准备

- Xcode 10.0+
- iOS真机设备
- 支持模拟器运行，但是部分功能无法使用

# 运行示例项目

该部分主要讲解如何编译和运行实例程序。

#### 获取AppKey

在编译和启动实例程序前，您需要首先获取一个可用的App Key:

1. 若您已经与专属客户经理取得联系，可直接向他获取Appkey；

2. 若您并未与专属客户经理取得联系那么请按后续步骤获取Appkey;

3. 首先在 [网易云信](https://id.163yun.com/register?h=media&t=media&clueFrom=nim&from=bdjjnim0035&referrer=https://app.yunxin.163.com/?clueFrom=nim&from=bdjjnim0035) 注册账号;

4. 然后在「应用」一栏中创建您的项目;

5. 等待专属客户经理联系您，并向他获取Appkey;

6. 将AppKey填写进NTESDemoConfig.h

```objective-c
NSString *const AppKey = <#请填入您的APPKey#>;
```

### 集成实时音视频SDK

1. 进入Demo根路径，执行 `Pod install`;

2. 使用Xcode打开NEChatroom-iOS-ObjC.xcworkspace，连接iPhone/iPad测试设备，设置有效的开发者签名后即可运行;

### 功能实现

IM部分

1. 初始化IM SDK

```objective-c
[[NIMSDK sharedSDK] registerWithAppID:<#申请的appKey#>
                                  cerName:<#推送证书名#>];
```

2. IM登录

```objective-c
[[[NIMSDK sharedSDK] loginManager] login:<#IM账号#>
                                       token:<#IM令牌#>
                                  completion:^(NSError *error) {
          if (error == nil) {
              // IM登录成功
          } else {
              // IM登录失败
          }
     }];
```

3. 进入聊天室，需要在IM登录成功且进入聊天室成功之后执行下述代码，才能在聊天室里实现语音功能

```objective-c
[[NIMSDK sharedSDK].chatroomManager enterChatroom:<#NIMChatroomEnterRequest:进入聊天室的请求#>
                                           completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
        if (!error) {
            // 进入聊天室成功
        } else {
            // 进入聊天室失败
        }
    }];
```

4. 离开聊天室

```objective-c
[[NIMSDK sharedSDK].chatroomManager exitChatroom:<#聊天室ID#> completion:nil];
```

5. 获取聊天室成员信息

```objective-c
[[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:<#NIMChatroomMembersByIdsRequest:进入聊天室的请求#>
                                                       completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (!error) {
            // 获取聊天室成员信息成功
        } else {
            // 获取聊天室成员信息失败
        }
    }];
```

6. IM发送消息

```objective-c
[[NIMSDK sharedSDK].chatManager sendMessage:<#要发送的信息#> toSession:<#信息接受方#> error:nil];
```

7. 收到消息

```objective-c
- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:_roomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType) {
            case NIMMessageTypeText:
                // 文本类型消息
                break;
            case NIMMessageTypeCustom:
            {
                // 自定义类型消息
                break;
            }
            case NIMMessageTypeNotification:{
                // 通知类型消息
                break;
            }

            default:
                break;
        }
    }
}
```

音视频SDK部分

1. 初始化音视频SDK，配置音视频相关参数。

```objective-c
- (void)setupRTCEngine
{
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.appKey = [NTESDemoConfig sharedConfig].appKey;
    context.engineDelegate = self;
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    [coreEngine setAudioProfile:kNERtcAudioProfileHighQualityStereo scenario:kNERtcAudioScenarioMusic];
    [coreEngine setupEngineWithContext:context];
    // 订阅音频音量回调(下句代码表示每隔1000ms调用一次音频音量代理方法)
    [coreEngine enableAudioVolumeIndication:YES interval:1000];
}
```

2. 加入和离开房间。调用SDK接口加入和退出音视频房间。在本示例中，是在加入聊天室成功后，再加入音视频通道，进而实现音频通话能力;

注意: 非安全模式下, 加入音频房间接口中，token可以传空字符串。默认使用安全模式, 关于如何获取token, 请参照 [开发文档](https://dev.yunxin.163.com/docs/product/%E9%9F%B3%E8%A7%86%E9%A2%91%E9%80%9A%E8%AF%9DG2/%E6%9C%8D%E5%8A%A1%E7%AB%AFAPI%E6%96%87%E6%A1%A3?pos=toc-2-14)

```objective-c
[[NERtcEngine sharedEngine] joinChannelWithToken:<#token#>
                                         channelName:<#频道名#>
                                               myUid:<#用户ID#>
                                          completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            // 加入房间失败
        } else {
            // 加入房间成功
        }
    }];
```

3. 本地用户的音乐文件播放状态改变回调。

```objective-c
- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state errorCode:(NERtcAudioMixingErrorCode)errorCode
{
    //
}
```

4. 本地用户瞬时音量的回调。

```objective-c
- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state errorCode:(NERtcAudioMixingErrorCode)errorCode
{
    //
}
```

5. 提示频道内谁正在说话及说话者音量的回调

```objective-c
-(void)onRemoteAudioVolumeIndication:(nullable NSArray<NERtcAudioVolumeInfo*> *)speakers totalVolume:(int)totalVolume
{
    //
}
```

6. 关于语音过程中伴音的设置

```objective-c
// 开始播放伴音
[[NERtcEngine sharedEngine] startAudioMixingWithOption:options];

// 停止播放伴音
[[NERtcEngine sharedEngine] stopAudioMixing];

// 设置伴音的发送音量
[[NERtcEngine sharedEngine] setAudioMixingSendVolume:value];

// 设置伴音的回放音量
[[NERtcEngine sharedEngine] setAudioMixingPlaybackVolume:value];
```

7. 关于语音过程中音效的设置

```objective-c
// 播放音效 eid-音效ID opt-音效配置项
[[NERtcEngine sharedEngine] playEffectWitdId:eid effectOption:opt];

// 停止播放所有音效
[[NERtcEngine sharedEngine] stopAllEffects];

// 设置音效的发送音量 eid-音效ID value-音效值
[[NERtcEngine sharedEngine] setEffectSendVolumeWithId:eid volume:value];

// 设置音效的回放音量 eid-音效ID value-音效值
[[NERtcEngine sharedEngine] setEffectPlaybackVolumeWithId:eid volume:value];
```
### 修改 Demo 源代码

以下表格列出了各个 ObjC 文件或文件夹及其所对应的 UI 界面或功能实现，以便于您进行二次调整：

| 文件或文件夹 | 功能描述 |
| - | - |
| NTESDemoConfig | 该文件用于配置 appKey, 证书名称, 请求host |
| NTESHomePageViewController | 语音聊天室列表页面逻辑 |
| NTESChatroomViewController | 语音聊天室页面逻辑 |
| NTESSettingPanelView | 设置面板视图: 包含设置耳返、采集音量 |
| NTESChatroomHeaderView | 语音聊天室头部视图 |
| NTESAudioPlayerManager | 伴音/音效管理器 |
| NTESChatroomHandler | 语音聊天室 IM SDK 协议处理类 |
| NTESMicInviteeListViewController | 拉人上麦, 在聊天室内的待邀请的成员列表页 |
| Logger/ | 日志功能相关类 |
| Service/ | Demo请求 / 数据中心 / 系统管理类 |
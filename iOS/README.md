网易云信为您提供开源的示例项目，您可以参考本文档快速跑通示例项目，体验语聊房的效果。

## 开发环境要求

在开始运行示例项目之前，请确保开发环境满足以下要求：
| 环境要求                                                        | 说明                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
|  iOS 版本  |  11.0 及以上的 iPhone 或者 iPad 真机   |
|  CPU 架构 | ARM64、ARMV7   |
| IDE | XCode   |
| 其他 | 安装 CocoaPods  |

## 前提条件

请确认您已完成以下操作：
- [已创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)
- [已开通相关能力](https://doc.yunxin.163.com/docs/TA3ODAzNjE/zQ4MTI0Njc?platformId=50616)
- 已配置 NERoom 的消息抄送地址（http://yiyong.netease.im/nemo/entertainmentLive/nim/notify），具体请联系网易云信技术支持



## 运行示例项目

::: note notice
- 语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。

- 若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。

:::

  
1. 克隆[语聊房示例项目源码](https://github.com/netease-kit/NEChatroom/tree/master/iOS)仓库至您本地工程。
    ::: note note
    示例项目源码请存放至全英文的路径下。
    :::

2. 打开终端，在 (VoiceRoomKit/LiveAudioRoom) Podfile 所在文件夹中执行如下命令进行安装：

    ```
    pod install 
    ```

3. 在 `VoiceRoomKit/LiveAudioRoom/LiveAudioRoom/AppKey.swift` 中，替换您自己的 App Key 和 App Secret 。 
   

    ```
    // MARK: 请填写您的AppKey和AppSecret
    let APP_KEY: String = "your appkey" // 请填写应用对应的AppKey，可在云信控制台的“AppKey管理”页面获取
    let APP_SECRET: String = "your secret" // 请填写应用对应的AppSecret，可在云信控制台的“AppKey管理”页面获取

    // MARK: 如果您的AppKey为海外，填ture；如果您的AppKey为中国国内，填false
    let IS_OVERSEA = false

    // MARK: BASE_URL的默认地址仅用于跑通体验Demo，请勿用于正式产品上线。在产品上线前，请换为您自己实际的服务端地址
    let BASE_URL: String = "https://yiyong.netease.im" //云信派对服务端中国国内的体验地址
    let BASE_URL_OVERSEA: String = "http://yiyong-sg.netease.im"  //云信派对服务端海外的体验地址

    ```


    ::: note note
    - 获取 AppKey 和 AppSecret 的方法请参见<a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console#获取-appkey" target="_blank">创建应用并获取 AppKey</a>。
    - 配置文件中的 BASE_URL 地址 `http://yiyong.netease.im`为云信派对服务端体验地址，该地址仅用于体验 Demo，请勿用于生产环境。 您可以使用云信派对 Demo 体验 1 小时音视频通话。
    - 如果您的应用的 AppKey 为海外，`IS_OVERSEA` 的值请设置为 `ture`。
    :::


  

4. 运行工程。

    建议在真机上运行，不支持模拟器调试。





## 示例项目结构

```
┌── VoiceRoomKit
│   ├── NEVoiceRoomKit                                 # 一起听基于NERoom封装组件
│   │   ├── NEVoiceRoomKit  
│   │   │   ├── NEVoiceRoomKit                         # 单例对象
│   │   │   ├── NEVoiceRoomKit+Auth                    # 单例对象拓展登录相关接口
│   │   │   ├── NEVoiceRoomKit+Message                 # 单例对象拓展消息相关接口
│   │   │   ├── NEVoiceRoomKit+Room                    # 单例对象拓展房间相关接口
│   │   │   ├── NEVoiceRoomKit+Rtc                     # 单例对象拓展RTC相关接口
│   │   │   ├── NEVoiceRoomKit+Seat                    # 单例对象拓展麦位相关接口
│   │   │   └──  NEVoiceRoomKit+Preview                # 单例对象预操作相关接口
│   │   ├── Service
│   │   │   ├── NEVoiceRoomAudioPlayService            # 音乐接口具体实现
│   │   │   └── NEVoiceRoomRoomService                 #房间相关具体实现
│   │   ├── Public
│   │   │   ├── NEVoiceRoomAuthListener                # 登录监听
│   │   │   ├── NEVoiceRoomPreviewListener             # 预操作监听
│   │   │   ├── NEVoiceRoomListener                    # 语聊房监听
│   │   │   ├── NEListenTogetherKitChorusActionType    # 业务逻辑信令定义
│   │   │   ├── Common 文件夹                           # 通用定义
│   │   │   ├── Message 文件夹                          # 文本消息相关model定义
│   │   │   ├── Music 文件夹                            # 歌曲相关model定义
│   │   │   ├── Reward 文件夹                           # 礼物相关model定义
│   │   │   ├── Room 文件夹                             # 房间相关model定义
│   │   │   └── Seat 文件夹                             # 麦位相关model定义
│   │   │   
│   ├── LiveAudioRoom                                  # 项目入口
│   ├── NEVoiceRoomUIKit                   
│   │    ├── NEOpenRoomViewController                   # 创建语聊房视图控制器
│   │    │    ├── NEUICreateRoomNameView                # 房间名输入框
│   │    │    └── UIButton                              # 创建房间按钮
│   │    ├── NEVoiceRoomViewController                  # 语聊房视图控制器
│   │    │   ├── NEVoiceRoomViewController+Seat         # 语聊房麦位相关逻辑
│   │    │   ├── NEVoiceRoomViewController+UI           # 语聊房布局相关
│   │    │   ├── NEVoiceRoomViewController+Utils        # 语聊房其他逻辑
│   │    │   ├── NEVoiceRoomHeaderView                  # 头部视图
│   │    │   ├── NEVoiceRoomFooterView                  # 底部工具栏，包含输入框等控件
│   │    │   ├── NEVoiceRoomChatView                    # 聊天室视图，显示系统通知消息、普通文本消息以及礼物息
│   │    │   ├── NEUIKeyboardToolbarView                # 聊天室文本输入框
│   │    │   ├── NEUIConnectListView                    # 主播顶部弹框
│   │    │   ├── NEUIMicQueueView                       # 麦位视图
│   │    │   └── NEVoiceRoomInfo                        # 语聊房信息
│   │    └── NEChatRoomListViewController               # 语聊房列表视图控制器
│   │        ├── NEUIEmptyListView                      # 空列表提示视图
│   │        └── NEUILiveListCell                       # 语聊歌房信息预览
│   └── NEOrderSong                                     # 点歌台相关封装，NEVoiceroomUIKit 使用
│        ├── NEOrderSong                                # 单例对象
│        ├── NEOrderSong+Auth                           # 单例对象拓展登录相关接口
│        ├── NEOrderSong+CopyrightedMedia               # 单例对象拓展版权相关接口
│        ├── NEOrderSong+Message                        #  单例对象拓展消息相关接口
│        ├── NEOrderSong+Music                          #  单例对象拓展音乐相关接口
│        ├── NEOrderSong+Room                           #  单例对象拓展版权相关接口
│        ├── NEOrderSong+Song                           #  单例对象拓展播放回调接口
│        ├── Public
│        │   ├── NEVoiceRoomAuthListener                # 登录监听
│        │   ├── NEVoiceRoomCopyrightedMediaListener    # 版权监听
│        │   ├── NEVoiceRoomListener                    # 点歌台监听
│        │   ├── Common 文件夹                           # 通用定义
│        │   └── Music 文件夹                            # 歌曲相关model定义
│        └── Private                    
│            ├── NEVoiceRoomPrivateModels               # 模型定义
│            ├── Log 文件夹                              # 日志功能
│            ├── Network 文件夹                          # 网络功能
│            │   └── NEVoiceRoomAPI                     # 接口定义
│            └── Service 文件夹                          # 日志功能
│                ├── NEVoiceRoomAudioPlayService        # 播放配置中心
│                ├── NEVoiceRoomAudioPlayService+Delegate # 播放扩展业务回调
│                ├── NEVoiceRoomCopyrightedMediaService  # 版权Token相关处理
│                ├── NEVoiceRoomMusicService            # 点歌台接口实现
│                └── NEVoiceRoomRoomService             # Token更新接口实现
├── UIKit                                               # 自定义的UI拓展
├── third_party/lottie                                  # lottie 动画源码
├── PodConfigs                                          # pod 配置文件
└── OneOnOne/NELoginSample                              # 登录页面
```

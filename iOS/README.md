网易云信为您提供开源的示例项目，您可以参考本文档快速跑通示例项目，体验语聊房的效果。
# 目录结构


```
┌── NEOrderSong                        # 点歌台相关封装，NEVoiceroomUIKit 使用
│    ├── NEOrderSong                    # 单例对象
│    ├── NEOrderSong+Auth                    # 单例对象拓展登录相关接口
│    ├── NEOrderSong+CopyrightedMedia                    # 单例对象拓展版权相关接口
│    ├── NEOrderSong+Message                    #  单例对象拓展消息相关接口
│    ├── NEOrderSong+Music                    #  单例对象拓展音乐相关接口
│    ├── NEOrderSong+Room                    #  单例对象拓展版权相关接口
│    ├── NEOrderSong+Song                    #  单例对象拓展播放回调接口
│    ├── Public
│    │   ├── NEVoiceRoomAuthListener # 登录监听
│    │   ├── NEVoiceRoomCopyrightedMediaListener # 版权监听
│    │   ├── NEVoiceRoomListener # 点歌台监听
│    │   ├── Common 文件夹 # 通用定义
│    │   └── Music 文件夹 # 歌曲相关model定义
│    └── Private                    
│        ├── NEVoiceRoomPrivateModels # 模型定义
│        ├── Log 文件夹 # 日志功能
│        ├── Network 文件夹 # 网络功能
│        │   └── NEVoiceRoomAPI # 接口定义
│        └── Service 文件夹 # 日志功能
│            ├── NEVoiceRoomAudioPlayService # 播放配置中心
│            ├── NEVoiceRoomAudioPlayService+Delegate # 播放扩展业务回调
│            ├── NEVoiceRoomCopyrightedMediaService  # 版权Token相关处理
│            ├── NEVoiceRoomMusicService  # 点歌台接口实现
│            └── NEVoiceRoomRoomService  # Token更新接口实现
│
│
│
│
├── NEUIKit                            # 自定义的UI拓展
│
├── NEVoiceRoomExample                 # 项目入口
│
└── NEVoiceRoomUIKit                   #
    ├── NEOpenRoomViewController                   # 创建语聊房视图控制器
    │    ├── NEUICreateRoomNameView                 # 房间名输入框
    │    └── UIButton                               # 创建房间按钮
    ├── NEVoiceRoomViewController                  # 语聊房视图控制器
    │   ├── NEVoiceRoomViewController+Seat         # 语聊房麦位相关逻辑
    │   ├── NEVoiceRoomViewController+UI           # 语聊房布局相关
    │   ├── NEVoiceRoomViewController+Utils        # 语聊房其他逻辑
    │   ├── NEVoiceRoomHeaderView                  # 头部视图
    │   ├── NEVoiceRoomFooterView                  # 底部工具栏，包含输入框等控件
    │   ├── NEVoiceRoomChatView                    # 聊天室视图，显示系统通知消息、普通文本消息以及礼物息
    │   ├── NEUIKeyboardToolbarView                # 聊天室文本输入框
    │   ├── NEUIConnectListView                    # 主播顶部弹框
    │   ├── NEUIMicQueueView                       # 麦位视图
    │   └── NEVoiceRoomInfo                        # 语聊房信息
    └── NEChatRoomListViewController               # 语聊房列表视图控制器
        ├── NEUIEmptyListView                      # 空列表提示视图
        └── NEUILiveListCell                       # 语聊歌房信息预览
```


# 开发环境要求
在开始运行示例项目之前，请确保开发环境满足以下要求：
| 环境要求                                                        | 说明                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
|  iOS 版本  |  11.0 及以上的 iPhone 或者 iPad 真机   |
|  CPU 架构 | ARM64、ARMV7   |
| IDE | XCode   |
| 其他 | 安装 CocoaPods  |

# 前提条件

请确认您已完成以下操作：
- [已创建应用并获取AppKey](https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console)
- [已开通相关能力](https://doc.yunxin.163.com/docs/TA3ODAzNjE/zQ4MTI0Njc?platformId=50616)
- 已配置 NERoom 的消息抄送地址（http://yiyong.netease.im/nemo/entertainmentLive/nim/notify），具体请联系网易云信技术支持


# 运行示例项目

> 注意：
>
>- 语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。
>
>- 若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。
> - 以下源码跑通无须部署服务端即可体验，请按照以下步骤设置客户端源码配置。

1. 克隆示例项目源码仓库至您本地工程。
2. 打开终端，在 Podfile 所在文件夹中执行如下命令进行安装：

    ```
    pod install 
    ```

4. 在 NEVoiceRoomExample/NEVoiceRoomExample/AppEnv/Define/AppKey.h 中 ，替换以下信息

    ```
    /// 服务器host
    static NSString *const kApiHost = @"https://127.0.0.1:9981";
    static NSString *const APP_KEY_MAINLAND = @"your mainland appKey";  // 国内用户填写
    // AccountId
    static NSString *const accountId = @"";
    // accessToken
    static NSString *const accessToken = @"";
    
    如果需要配置海外环境，则修改以下内容
    static BOOL isOverSea = NO;  // 是否是海外环境
    static NSString *const APP_KEY_OVERSEA = @"your oversea appKey";  // 海外用户填写
    ```


   > 说明：
   >
   > - 获取 AppKey 和 AppSecret 的方法请参见<a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console#获取-appkey" target="_blank">创建应用并获取 AppKey</a>。
   >- 配置文件中的 kApiHost 地址 `http://yiyong.netease.im`为云信派对服务端体验地址，该地址仅用于体验 Demo，请勿用于生产环境。 您可以使用云信派对 Demo 体验 1 小时音视频通话。
   > - 和服务端联调时，客户端源码的配置请参见[常见问题处理](#常见问题处理)。
    
5. 运行工程。

    建议在真机上运行，不支持模拟器调试。


## 常见问题处理

**和服务端联调时，客户端源码需要修改哪些配置？**

在开发调试阶段，开发者集成语聊房服务端 nemo 后，在[语聊房客户端源码](https://github.com/netease-kit/NEChatroom/tree/master/iOS)上需要修改如下配置，才能和服务器调通， 使用服务端下发的账号和 Token 进行登录。

在 `OneOnOneSample/OneOnOneSample/AppKey.swift` 文件中，配置如下参数：


参数 | 描述
---- | -------------- |
APP_KEY_MAINLAND| 请填写您应用对应的 AppKey。获取 AppKey 和 AppSecret 的方法请参见<a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console#获取-appkey" target="_blank">获取 App Key</a>| 
APP_SECRET_MAINLAND | 请填写您应用对应的 AppSecret。 |
kApiHost | 请填写1 对 1 娱乐社交服务端域名地址，并确保客户端能访问该地址 | 
accountId |账号 ID。 请填写1 对 1 娱乐社交服务端工程返回的`userUuid` 的值 |
accessToken | 请填写1 对 1 娱乐社交服务端工程返回的`userToken`的值|
nickName |用户昵称。请填写1 对 1 娱乐社交服务端工程返回的`userName`的值 |
avatar  |用户头像。请填写1 对 1 娱乐社交服务端工程返回的`icon`的值

```
// 国内服务器地址
let kApiHost: String = "https://yiyong.netease.im"

// 国外服务器地址
let kOverSeaApiHost: String = "https://yiyong-sg.netease.im"

// 数据收集
let kApiDataHost: String = "https://statistic.live.126.net"

// MARK: 海外环境与国内环境的切换可以在我的页面中进行修改

// 请填写您的appKey,国内环境请填写APP_KEY_MAINLAND，海外环境请填写APP_KEY_OVERSEA
let APP_KEY_MAINLAND: String = "your mainland appKey" // 国内用户填写AppKey

let APP_SECRET_MAINLAND: String = "your mainland appSecret" // 国内用户填写AppSecret

let APP_KEY_OVERSEA: String = "your oversea appKey" // 海外用户填写AppKey

let APP_SECRET_OVERSEA: String = "your oversea appSecret" // 海外用户填写AppSecret

// 获取userUuid和对应的userToken，请参考https://doc.yunxin.163.com/neroom/docs/TY1NzM5MjQ?platform=server

// AccountId
var accountId: String = ""
// accessToken
var accessToken: String = ""

// MARK: 以下内容选填

// nickName
var nickName: String = "nickName"

// avatar
var avatar: String = "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/default/g2-demo-avatar-imgs/86117910480687104.jpg"

```

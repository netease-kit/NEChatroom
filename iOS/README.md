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
- 已根据[跑通语聊房服务端源码](https://doc.yunxin.163.com/group-voice-room/docs/jA3NDY0MjA?platform=server)运行语聊房服务端


# 运行示例项目

> 注意：
>
>语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。
>
>若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。

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
   > 以下参数的值请填写[跑通语聊房服务端源码](https://doc.yunxin.163.com/group-voice-room/docs/jA3NDY0MjA?platform=server) 时返回的内容：
   >  - `accountId`：服务端源码返回的 `userUuid` 的值
   > - `accessToken`：服务端源码返回的`userToken`的值
    
5. 运行工程。
建议在真机上运行，不支持模拟器调试。

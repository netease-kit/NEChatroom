# 目录结构


```
┌── NEListenTogetherKit                # 一起听基于NERoom封装组件
│   ├── NEListenTogetherKit  
│   │   ├── NEListenTogetherKit            # 单例对象
│   │   ├── NEListenTogetherKit+Auth        # 单例对象拓展登录相关接口
│   │   ├── NEListenTogetherKit+CopyrightedMedia # 单例对象拓展版权相关接口
│   │   ├── NEListenTogetherKit+Message # 单例对象拓展消息相关接口
│   │   ├── NEListenTogetherKit+Music  # 单例对象拓展音乐相关接口
│   │   ├── NEListenTogetherKit+Room  # 单例对象拓展房间相关接口
│   │   ├── NEListenTogetherKit+Rtc  # 单例对象拓展RTC相关接口
│   │   ├── NEListenTogetherKit+Seat # 单例对象拓展麦位相关接口
│   │   └──  NEListenTogetherKit+Song # 单例对象拓展播放回调相关接口
│   │   
│   ├── Service
│   │   ├── NEListenTogetherKitAudioPlayService # 播放具体实现
│   │   ├── NEListenTogetherKitAudioPlayService+Delegate # 播放回调
│   │   ├── NEListenTogetherKitCopyrightedMediaService  # 版权Token相关处理
│   │   ├── NEListenTogetherKitMusicService  # 音乐接口具体实现
│   │   └──NEListenTogetherKitRoomService #房间相关具体实现
│   │   
│   ├── Public
│   │   ├── NEListenTogetherKitAuthListener # 登录监听
│   │   ├── NEListenTogetherKitCopyrightedMediaListener # 版权监听
│   │   ├── NEListenTogetherKitListener # 一起听监听
│   │   ├── NEListenTogetherKitChorusActionType # 业务逻辑信令定义
│   │   ├── Common 文件夹 # 通用定义
│   │   ├── Message 文件夹 # 文本消息相关model定义
│   │   ├── Music 文件夹 # 歌曲相关model定义
│   │   ├── Reward 文件夹 # 礼物相关model定义
│   │   ├── Room 文件夹 # 房间相关model定义
│   │   └── Seat 文件夹 # 麦位相关model定义
│   │
│   │   
│   │
├── NEListenTogetherUIKit              # 一起听UI视图
│   ├── NEListenTogetherRoomListViewController # 语聊房列表视图控制器
│   │   ├── NEListenTogetherUIEmptyListView   # 空列表提示视图
│   │   └── NEListenTogetherUILiveListCell    # 语聊歌房信息预览
│   │
│   ├── NEListenTogetherOpenRoomViewController # 创建语聊房视图控制器
│   │   ├── NEListenTogetherUICreateRoomNameView #创建房间视图
│   │   └── UIButton                             # 创建房间按钮
│   │
│   │
│   │
│   │
│   ├──NEListenTogetherViewController   #语聊房视图控制器
│   │   ├── NEListenTogetherViewController+Seat #语聊房麦位相关逻辑
│   │   ├── NEListenTogetherViewController+UI #语聊房布局相关
│   │   ├── NEListenTogetherViewController+Utils #语聊房其他逻辑
│   │   ├── NEListenTogetherHeaderView                  # 头部视图
│   │   ├── NEListenTogetherFooterView                  # 底部工具栏，包含输入框等控件
│   │   ├── NEListenTogetherChatView                    # 聊天室视图，显示系统通知消息、普通文本消息以及礼物息
│   │   ├── NEListenTogetherKeyboardToolbarView                # 聊天室文本输入框
│   │   ├── NEListenTogetherUIConnectListView                    # 主播顶部弹框
│   │   ├── NEListenTogetherMicQueueView                       # 麦位视图
│   │   ├── NEListenTogetherLyricActionView                       # 歌词展示页面
│   │   ├── NEListenTogetherLyricControlView                       # 播放控制器
│   │   ├── NEListenTogetherPickSongView                       # 歌曲列表视图
│   │   ├── PlayingStatus                       # 播放状态
│   │   ├── PlayingAction                       # 歌曲下载完成状态标记位，歌曲基于何种操作下开始
│   │   └── NEListenTogetherInfo                        # 语聊房信息
│   │   
├── NEOrderSong                        # 点歌台相关封装，NEVoiceroomUIKit 使用
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
- [已创建应用并获取AppKey](https://doc.yunxin.163.com/jcyOTA0ODM/docs/jcwMDQ2MTg)
- [已开通相关能力](https://doc.yunxin.163.com/docs/TA3ODAzNjE/zQ4MTI0Njc?platformId=50616)
- 已开通统一登录功能，具体请联系网易云信商务经理。

# 运行示例项目

> 注意：
>
>语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。
>
>若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。

1. 克隆示例项目源码仓库至您本地工程。
2. 在 Podfile 文件中添加类似如下命令导入目标文件。
```
pod 'NEVoiceRoomKit'
```
3. 打开终端，在 Podfile 所在文件夹中执行如下命令进行安装：

```
pod install 
```

4. 在 NEVoiceRoomExample/NEVoiceRoomExample/AppEnv/Category/AppDelegate+VoiceRoom.m中，替换您自己的AppKey。

```
- (NSString *)getAppkey {
 return @"your App Key "
}
```

5. 运行工程。
建议在真机上运行，不支持模拟器调试。
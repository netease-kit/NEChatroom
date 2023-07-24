# 云信语聊房

网易云信为您提供开源的示例项目，您可以参考本文档快速跑通示例项目，体验语聊房效果。


## 前提条件

在开始运行示例项目之前，请确保您已完成以下操作：
- <a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console" target="_blank">已创建应用并获取 App Key</a>
- <a href="https://doc.yunxin.163.com/group-voice-room/docs/DUwOTA0MTg?platform=flutter" target="_blank">已开通IM 即时通讯、聊天室、音视频通话2.0 和 NERoom 房间组件</a>
- 已根据[跑通语聊房服务端源码](https://doc.yunxin.163.com/group-voice-room/docs/jA3NDY0MjA?platform=server)运行语聊房服务端

## 开发环境要求
不同的目标平台，开发环境要求也不同，具体如下：
- [Flutter](https://docs.flutter.dev/release/archive?tab=windows#macos) 3.10.0 及以上版本
- Dart 3.0.0 及以上版本
- 如果您的目标平台是 iOS：

    - Xcode 11.0 及以上版本
    - 请确保您的项目已设置有效的开发者签名
    - macOS 操作系统
    - 11.0 及以上的 iPhone 或者 iPad 真机

- 如果您的目标平台是 Android：

    - [Android Studio](https://developer.android.com/studio/releases?hl=zh-cn) 4.1 及以上版本
    - macOS 或 Windows 操作系统
    - Android 系统 5.0 及以上版本的真机

- [安装 Flutter 和 Dart 插件](https://docs.flutter.dev/get-started/editor?)


## 注意事项

示例项目需要在 **RTC 调试模式**下使用，此时无需传入 Token。修改鉴权方式的方法请参见 <a href="https://doc.yunxin.163.com/nertc/docs/TQ0MTI2ODQ?platform=android" target="_blank">Token 鉴权</a> 。

您可以在集成开发阶段使用调试模式进行应用开发与测试。但是出于安全考虑，应用正式上线前，请在控制台中将指定应用的鉴权方式改回安全模式。

  

## 运行示例源码

注意：

语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。

若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。

  
1. 克隆<a href="https://github.com/netease-kit/NEChatroom/tree/master/Flutter" target="_blank">语聊房组件的示例项目源码</a>仓库至您本地工程。


2. 配置应用的 App Key。

    在 `voiceroomkit-ui/lib/app_config.dart ` 文件中配置应用的 App Key。

    ```
    // 请填写您的appKey,如果您的APP是国内环境，请填写onlineAppKey，如果是海外环境，请填写overSeaAppKey
    static const String onlineAppKey = "your mainland appKey";// 国内用户填写

    static const String overSeaAppKey = "your oversea appKey";// 海外用户填写

    static const String account = "your account"; // 请填写您的账号
    static const String token = "your token"; // 请填写您的token
    static const String nickname = "your nickname"; // 请填写您的昵称
    static const String avatar = "your avatar"; // 请填写您的头像
    // 跑通Server Demo(https://github.com/netease-kit/nemo)后，替换为实际的host
    static const String baseurl = 'your host';
    ```
    说明：
   
    以下参数的值请填写[跑通语聊房服务端源码](https://doc.yunxin.163.com/group-voice-room/docs/jA3NDY0MjA?platform=server) 时返回的内容：
    - `account`：服务端源码返回的 `userUuid` 的值
    - `token`：服务端源码返回的`userToken`的值
    - `avatar`：服务端源码返回的`icon`的值
    - `nickname`：服务端源码返回的`userName`的值
    
4. 在工程根目录执行如下命令引入依赖。
    ```
    flutter pub get
    ```
5. 编译运行。

    - iOS
      1. 打开终端，在 `Podfile` 所在文件夹中执行如下命令进行安装：
          ```
          pod install
          ``` 
      2. 完成安装后，通过 Xcode 打开 `NEVoiceRoomExample.xcworkspace` 工程。
  
      3. 编译并运行 Demo 工程。


   - Android
 
      i.在工程根目录执行如下命令：
      ```
       flutter run
      ```
      
      ii.使用 Android Studio（4.1及以上的版本）打开源码工程，单击运行即可。


 


6. 选中设备直接运行，即可体验 Demo。

    建议在真机上运行，不支持模拟器调试。


## 示例项目结构


示例代码lib目录结构说明如下：

```

├── app_config.dart  app配置
├── base       基础模
├── constants  常量
├── generated  字符串国际化（intl自动生成目录）
├── l10n       字符串国际化
├── main.dart  app入口 
├── model      数据模型
├── pages      页面 
├── utils      工具类
├── viewmodel  页面逻辑
└── widgets    ui组件


```

    

  

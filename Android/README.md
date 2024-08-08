网易云信为您提供开源的示例项目，您可以参考本文档快速跑通示例项目，体验语聊房效果。
# 目录结构


```
NEVoiceRoomKit              # 语聊房业务核心类
NEVoiceRoomListener         # 房间事件
voiceroomkit-ui 重点类：
AnchorActivity.java         # 语聊房主播端界面
AudienceActivity.java       # 语聊房观众端界面
SeatAdapter.java            # 语聊房麦位适配器
VoiceRoomViewModel.java     # 语聊房ViewModel
```


# 开发环境要求
在开始运行示例项目之前，请确保开发环境满足以下要求：
| 环境要求                                                        | 说明                                                      |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
|  JDK 版本  |  1.8.0 及以上版本   |
|  Android API 版本 | API 21、Android Studio 5.0 及以上版本   |
| CPU架构 | ARM 64、ARM V7   |
| IDE | Android Studio  |
| 其他 |  依赖 Androidx，不支持 support 库。android 系统 5.0 及以上版本的真机 |

# 前提条件

在开始运行示例项目之前，请确保您已完成以下操作：
- <a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console" target="_blank">已创建应用并获取 App Key</a>
- <a href="https://doc.yunxin.163.com/group-voice-room/docs/TgwODc0MTM?platform=android" target="_blank">已开通IM 即时通讯、聊天室、音视频通话2.0 和 NERoom 房间组件</a>
- [已配置 NERoom 的消息抄送地址（http://yiyong.netease.im/nemo/entertainmentLive/nim/notify）](https://doc.yunxin.163.com/docs/zU3Mjk0MTk/zYxNzIzMTE?platformId=121094)

    ![neroom消息抄送地址.png](https://yx-web-nosdn.netease.im/common/8cd222db079b0bbe16b3b246be350268/neroom消息抄送地址.png)

# 运行示例项目

> **注意**：
>
>**语聊房的示例源码仅供开发者接入参考，实际应用开发场景中，请结合具体业务需求修改使用。**
>
>**若您计划将源码用于生产环境，请确保应用正式上线前已经过全面测试，以免因兼容性等问题造成损失。**

1. 克隆示例项目源码仓库至您本地工程。
2. 开启 Android 设备的开发者选项，通过 USB 连接线将 Android 设备接入电脑。
3. 通过 Android Studio 打开项目，在 ` app\src\main\java\com\netease\yunxin\app\voiceroom\config\AppConfig.java ` 文件中配置应用的 App Key。    

    

    ```
    // 请填写您的AppKey和AppSecret
    private static final String APP_KEY = "your AppKey"; // 请填写应用对应的AppKey，可在云信控制台的”AppKey管理“页面获取
    public static final String APP_SECRET = "your AppSecret"; // 请填写应用对应的AppSecret，可在云信控制台的”AppKey管理“页面获取
    public static final boolean IS_OVERSEA = false; // 如果您的AppKey为海外，填ture；如果您的AppKey为中国国内，填false
    /**
     * 默认的BASE_URL地址仅用于跑通体验Demo，请勿用于正式产品上线。在产品上线前，请换为您自己实际的服务端地址
    */
    public static final String BASE_URL = "https://yiyong.netease.im/";   //云信派对服务端国内的体验地址
    public static final String BASE_URL_OVERSEA = "https://yiyong-sg.netease.im/";   //云信派对服务端海外的体验地址
     ```

    > **注意**：
    >- 获取 App Key 和 App Secret 的方法请参见<a href="https://doc.yunxin.163.com/console/docs/TIzMDE4NTA?platform=console#获取-appkey" target="_blank">获取 App Key</a>。
    >- BASE_URL 地址 `https://yiyong.netease.im`和BASE_URL_OVERSEA 地址 `https://yiyong-sg.netease.im`为云信派对服务端体验地址，该地址仅用于体验 Demo，单次最大体验时长为1小时，**请勿用于生产环境**。
    >- 如果您的应用是海外环境，BASE_URL 地址请填写`http://yiyong-sg.netease.im`。
    >- 如果您的应用的 AppKey 为海外，IS_OVERSEA 的值请设置为 ture。
    


4. 在 Android Studio 中，单击 **Sync Project with Gradle Files** 按钮，同步工程依赖。
5. 选中设备直接运行，即可体验 Demo。

# 注意
- 该源码仅供开发者接入时参考，网易云信不负责源码的后续维护。若开发者计划将该源码用于生产环境，请确保发布前进行充分测试，避免发生潜在问题造成损失。
- 该源码中提供的业务后台地址仅用于跑通示例源码，如果您需要上线正式产品，请自行编写、搭建自己的业务后台。


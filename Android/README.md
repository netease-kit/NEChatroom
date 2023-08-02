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
- <a href="https://doc.yunxin.163.com/docs/TA3ODAzNjE/DcyNzA2NTA?platformId=50612" target="_blank">已开通IM 即时通讯、聊天室、音视频通话2.0 和 NERoom 房间组件</a>
- 已根据[跑通语聊房服务端源码](https://doc.yunxin.163.com/group-voice-room/docs/jA3NDY0MjA?platform=server)运行语聊房服务端

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
   private static final String APP_KEY = "your AppKey"; // 填入您的AppKey,可在云信控制台AppKey管理处获取
   public static final String APP_SECRET = "your AppSecret"; // 填入您的AppSecret,可在云信控制台AppKey管理处获取
   public static final boolean IS_OVERSEA = false; // 海外用户填ture,国内用户填false
   /**
   * BASE_URL为服务端地址,请在跑通Server Demo(https://github.com/netease-kit/nemo)后，替换为您自己实际的服务端地址
   * "http://yiyong.netease.im/"仅用于跑通体验Demo,请勿用于正式产品上线
     */
     public static final String BASE_URL = "http://yiyong.netease.im/";

   /**
   * 云信IM账号，说明：账号信息为空，则默认自动生成一个账号
     */
     public static String userUuid = "";
     /**
   * 用户Token，说明：账号信息为空，则默认自动生成一个账号
     */
     public static String userToken = "";

   /**
   * 云信IM账号 token，说明：账号信息为空，则默认自动生成一个账号
     */
     public  static String imToken = "";

   // 以下内容选填
   /**
   * 用户名
     */
     public static String userName = "";
     /**
   * 头像
     */
     public static String icon = "";
   
       ```

4. 在 Android Studio 中，单击 Sync Project with Gradle Files 按钮，同步工程依赖。
5. 选中设备直接运行，即可体验 Demo。

# NEVoiceRoomUIKit

> 语聊房语聊UI模块。

## Change Log

[change log](CHANGELOG.md)

## 本地引用

### 其他Kit引用
如果是其他Kit引用NEVoiceRoomUIKit，就在对应Kit的podspec文件中添加依赖。

```
  s.dependency 'NEVoiceRoomUIKit'
```

由于podspec中无法通过路径来依赖本地的pod库，所以，需要在根目录的pod文件中找到对应的example工程来添加对该Kit的依赖。

```
  pod 'NEVoiceRoomUIKit', :path => 'VoiceRoomKit/NEVoiceRoomUIKit/NEVoiceRoomUIKit.podspec'
```

## Pod引用
- 打开 Podfile 文件，在对应的target中 添加pod依赖，具体内容如下
    pod 'NEVoiceRoomUIKit'
    
## 编译
- 在根目录执行pod install，运行NEKaraoke工程，确保本地工作正常。

- 打开项目根目录，运行build_frame.sh 脚本，具体执行命令如下
    sh build_frame.sh  --project Pods/Pods.xcodeproj  --targetName NEVoiceRoomUIKit --version x.x.x -z
- 完成上一步，根目录下会生成build目录，对应的frameWork即指定的 target frameWork
    
    
## 发布 目前开源，无发布版本



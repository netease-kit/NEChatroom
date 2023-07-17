// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:voiceroomkit_ui/base/data_center.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';

import 'base/device_manager.dart';
import 'base/global_preferences.dart';

class AppConfig {
  factory AppConfig() => _instance ??= AppConfig._internal();
  final tag = "AppConfig";
  static AppConfig? _instance;

  AppConfig._internal();

  // 请填写您的appKey,如果您的APP是国内环境，请填写onlineAppKey，如果是海外环境，请填写overSeaAppKey
  static const String onlineAppKey =
      "your mainland appKey"; // 国内用户填写

  static const String overSeaAppKey =
      "your oversea appKey"; // 海外用户填写

  static const String account = "your account"; // 请填写您的账号
  static const String token = "your token"; // 请填写您的token
  static const String nickname = "your nickname"; // 请填写您的昵称
  static const String avatar = "your avatar"; // 请填写您的头像
  // 跑通Server Demo(https://github.com/netease-kit/nemo)后，替换为实际的host
  static const String baseurl = 'your base url';

  late int onlineScope = 4;

  late int sgScope = 4;

  late int onlineParentScope = 5;

  late int sgParentScope = 5;

  late String versionName;

  late String versionCode;

  String appKey = "";

  int scope = 11;

  int parentScope = 7;

  int configId = 569;

  String language = languageCodeZh;

  bool isOverSea = false;

  bool get isZh => language == languageCodeZh;

  Future init() async {
    await initVoiceRoomConfig();
    await DeviceManager().init();
    await loadPackageInfo();
    return Future.value();
  }

  Future<void> initVoiceRoomConfig() async {
    isOverSea =
        await GlobalPreferences().dataCenter == DataCenter.oversea.index;
    if (isOverSea) {
      appKey = overSeaAppKey;
      configId = 75;
    } else {
      appKey = onlineAppKey;
      configId = 569;
    }
    VoiceRoomKitLog.i(tag,
        "initVoiceRoomConfig,isOverSea:$isOverSea,appKey:$appKey,configId:$configId");
  }


  Future<void> loadPackageInfo() async {
    var info = await PackageInfo.fromPlatform();
    versionCode = info.buildNumber;
    versionName = info.version;
  }

  static Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }

  static Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
}

const languageCodeZh = "zh";
const languageCodeEn = "en";

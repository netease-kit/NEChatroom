// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:device_info/device_info.dart';
import 'package:package_info/package_info.dart';
import 'package:voiceroomkit_ui/base/data_center.dart';

import 'base/device_manager.dart';
import 'base/global_preferences.dart';

class AppConfig {
  factory AppConfig() => _instance ??= AppConfig._internal();
  final tag = "AppConfig";
  static AppConfig? _instance;

  AppConfig._internal();

  // 请填写应用对应的AppKey，可在云信控制台的”AppKey管理“页面获取
  static const String _appKey = "your appKey";
  // 请填写应用对应的AppSecret，可在云信控制台的”AppKey管理“页面获取
  static const String _appSecret = "your sercet";
  // 如果您的AppKey为海外，填ture；如果您的AppKey为中国国内，填false
  static bool _isOverSea = false;

  // 默认的BASE_URL地址仅用于跑通体验Demo，请勿用于正式产品上线。在产品上线前，请换为您自己实际的服务端地址
  static const String _baseUrl = 'https://yiyong.netease.im';
  static const String _baseUrlOversea = 'https://yiyong-sg.netease.im';

  String get appKey => _appKey;
  String get appSecret => _appSecret;
  String get baseUrl => _isOverSea ? _baseUrlOversea : _baseUrl;
  int get configId => _isOverSea ? 75 : 569;
  Map<String, String> get extras => _isOverSea ? {'serverUrl':'oversea', 'baseUrl':baseUrl}: {'baseUrl':baseUrl};

  late String versionName;

  late String versionCode;

  String language = languageCodeZh;

  bool get isZh => language == languageCodeZh;

  Future init() async {
    await initVoiceRoomConfig();
    await DeviceManager().init();
    await loadPackageInfo();
    return Future.value();
  }

  Future<void> initVoiceRoomConfig() async {
    AppConfig._isOverSea =
        await GlobalPreferences().dataCenter == DataCenter.oversea.index;
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

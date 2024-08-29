// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class ServersConfig {
  static final String _serverUrl = 'https://roomkit-dev.netease.im';

  int get connectTimeout => 30000;

  int get receiveTimeout => 10000;

  static final ServersConfig _instance = ServersConfig._();

  ServersConfig._();

  factory ServersConfig() => _instance;

  String? _privateServerUrl;

  set serverUrl(String url) {
    if (TextUtils.isNotEmpty(url)) {
      _privateServerUrl = url;
    }
  }

  String get baseUrl {
    var baseUrl = TextUtils.isNotEmpty(_privateServerUrl)
        ? _privateServerUrl
        : _serverUrl;
    return baseUrl!;
  }

  String? userUuid;
  String? token;
  String? deviceId;
  String? appkey;
}

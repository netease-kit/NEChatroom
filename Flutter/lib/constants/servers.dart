// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:voiceroomkit_ui/app_config.dart';

class Servers {
  /// 隐私协议链接
  static const _urlPrivacyZh = "https://yunxin.163.com/clauses?serviceType=3";

  static const _urlPrivacyEn = "https://commsease.com/en/clauses?serviceType=3";

  String get urlPrivacy => AppConfig().isZh ? _urlPrivacyZh : _urlPrivacyEn;

  /// 用户政策链接
  static const _urlUserPoliceZh = "https://yunxin.163.com/clauses";

  static const _urlUserPoliceEN =
      "https://commsease.com/en/clauses?serviceType=0";

  String get urlUserPolice =>
      AppConfig().isZh ? _urlUserPoliceZh : _urlUserPoliceEN;

  /// 免责声明
  static const _urlDisclaimerZh =
      "https://yunxin.163.com/clauses?serviceType=0";

  static const _urlDisclaimerEN =
      "https://commsease.com/en/clauses?serviceType=0";

  String get urlDisclaimer =>
      AppConfig().isZh ? _urlDisclaimerZh : _urlDisclaimerEN;

  /// 免费试用
  static const _urlFreeTrailZh =
      "https://id.163yun.com/register?h=media&t=media&clueFrom=nim&referrer=https%3A%2F%2Fapp.yunxin.163.com%2F";

  static const _urlFreeTrailEn =
      "https://id.commsease.com/register?h=media&t=media&from=commsease%7Chttps%3A%2F%2Fcommsease.com%2Fen&clueFrom=overseas&locale=en_US&i18nEnable=true&referrer=https%3A%2F%2Fconsole.commsease.com";

  String get urlFreeTrail =>
      AppConfig().isZh ? _urlFreeTrailZh : _urlFreeTrailEn;
}

var servers = Servers();

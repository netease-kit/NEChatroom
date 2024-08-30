// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class LoginInfo {
  final String accountId;
  final String accountToken;
  String? nickname;
  String? account;
  String? avatar;

  LoginInfo({
    required this.accountId,
    required this.accountToken,
    this.nickname,
    this.account,
    this.avatar,
  });

  LoginInfo.fromJson(Map json)
      : accountId = (json['accountId'] ?? json['userId']) as String,
        accountToken = (json['accountToken'] ?? json['accessToken']) as String,
        nickname = json['nickname'] as String?,
        account = (json['user'] ?? json['mobile']) as String?,
        avatar = json['avatar'] as String?;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['accountId'] = accountId;
    map['accountToken'] = accountToken;
    map['nickname'] = nickname;
    map['account'] = account;
    map['avatar'] = avatar;
    return map;
  }
}

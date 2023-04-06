// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef AppKey_h
#define AppKey_h

/// 服务器host
static NSString *const kApiHost = @"https://yiyong.netease.im";

// Chatroom host address
static NSString *const kChatRoomHost = @"http://yiyong-voice-chat.netease.im";

/// 数据收集
static NSString *const kApiDataHost = @"https://statistic.live.126.net";

static BOOL isOverSea = NO;  // 是否是海外环境

// 请填写您的appKey,如果您的APP是国内环境，请填写APP_KEY_MAINLAND，如果是海外环境，请填写APP_KEY_OVERSEA
static NSString *const APP_KEY_MAINLAND = @"your mainland appKey";  // 国内用户填写
static NSString *const APP_KEY_OVERSEA = @"your oversea appKey";  // 海外用户填写

// 获取userUuid和对应的userToken，请参考https://doc.yunxin.163.com/neroom/docs/TY1NzM5MjQ?platform=server

// AccountId
static NSString *const accountId = @"";
// accessToken
static NSString *const accessToken = @"";

#endif /* AppKey_h */

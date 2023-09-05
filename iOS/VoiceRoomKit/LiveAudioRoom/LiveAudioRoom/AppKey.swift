// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

// MARK: 请填写您的AppKey和AppSecret

let APP_KEY: String = "your appkey" // 请填写应用对应的AppKey，可在云信控制台的”AppKey管理“页面获取
let APP_SECRET: String = "your secret" // 请填写应用对应的AppSecret，可在云信控制台的”AppKey管理“页面获取

// MARK: 如果您的AppKey为海外，填ture；如果您的AppKey为中国国内，填false

let IS_OVERSEA = false

// MARK: 默认的BASE_URL地址仅用于跑通体验Demo，请勿用于正式产品上线。在产品上线前，请换为您自己实际的服务端地址

let BASE_URL: String = "https://yiyong.netease.im"
let BASE_URL_OVERSEA: String = "https://yiyong-sg.netease.im"

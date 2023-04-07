// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

public class StringUtils {

  /**
   * 格式化展示云币数量，超过99999 展示为 99999+
   *
   * @param coinCount 云币总数
   * @return 云币数字符串
   */
  public static String formatCoinCount(long coinCount) {
    if (coinCount <= 99999) {
      return String.valueOf(coinCount);
    }
    return "99999+";
  }
}

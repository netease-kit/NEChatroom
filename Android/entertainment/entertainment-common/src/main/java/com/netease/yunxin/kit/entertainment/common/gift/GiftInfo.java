// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import java.util.Objects;

public class GiftInfo {

  /** 礼物id */
  private int giftId;
  /** 礼物名称 */
  private String name;
  /** 价值云币数量 */
  private long coinCount;
  /** 静态图资源 */
  private int staticIconResId;
  /** 动态图资源 */
  private int dynamicIconResId;

  public GiftInfo(
      int giftId, String name, long coinCount, int staticIconResId, int dynamicIconResId) {
    this.giftId = giftId;
    this.name = name;
    this.coinCount = coinCount;
    this.staticIconResId = staticIconResId;
    this.dynamicIconResId = dynamicIconResId;
  }

  public int getGiftId() {
    return giftId;
  }

  public String getName() {
    return name;
  }

  public long getCoinCount() {
    return coinCount;
  }

  public int getStaticIconResId() {
    return staticIconResId;
  }

  public int getDynamicIconResId() {
    return dynamicIconResId;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    GiftInfo giftInfo = (GiftInfo) o;
    return giftId == giftInfo.giftId
        && coinCount == giftInfo.coinCount
        && staticIconResId == giftInfo.staticIconResId
        && dynamicIconResId == giftInfo.dynamicIconResId
        && Objects.equals(name, giftInfo.name);
  }

  @Override
  public int hashCode() {
    return Objects.hash(giftId, name, coinCount, staticIconResId, dynamicIconResId);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.gift;

import android.util.*;
import com.netease.yunxin.app.listentogether.utils.*;
import com.netease.yunxin.kit.listentogether.*;
import java.util.*;

public class GiftCache {

  private static SparseArray<GiftInfo> TOTAL_GIFT = new SparseArray<>();

  static {
    // 礼物-荧光棒
    TOTAL_GIFT.append(
        1,
        new GiftInfo(
            1,
            Utils.getApp().getString(R.string.listen_glow_stick),
            9,
            R.drawable.listen_icon_gift_lifght_stick,
            R.raw.listen_anim_gift_light_stick));
    // 礼物-安排
    TOTAL_GIFT.append(
        2,
        new GiftInfo(
            2,
            Utils.getApp().getString(R.string.listen_arrange),
            99,
            R.drawable.listen_icon_gift_plan,
            R.raw.listen_anim_gift_plan));
    // 礼物-跑车
    TOTAL_GIFT.append(
        3,
        new GiftInfo(
            3,
            Utils.getApp().getString(R.string.listen_sports_car),
            199,
            R.drawable.listen_icon_gift_super_car,
            R.raw.listen_anim_gift_super_car));
    // 礼物-火箭
    TOTAL_GIFT.append(
        4,
        new GiftInfo(
            4,
            Utils.getApp().getString(R.string.listen_rockets),
            999,
            R.drawable.listen_icon_gift_rocket,
            R.raw.listen_anim_gift_rocket));
  }

  /**
   * 获取礼物详情
   *
   * @param giftId 礼物id
   */
  public static GiftInfo getGift(int giftId) {
    return TOTAL_GIFT.get(giftId);
  }

  /** 获取礼物列表 */
  public static List<GiftInfo> getGiftList() {
    List<GiftInfo> list = new ArrayList<>();
    list.add(getGift(1));
    list.add(getGift(2));
    list.add(getGift(3));
    list.add(getGift(4));
    return list;
  }
}

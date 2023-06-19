// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import java.util.HashSet;

public class GiftHelper {
  private final HashSet<Integer> selectSeatSet = new HashSet<>();

  private static volatile GiftHelper mInstance;

  private GiftHelper() {}

  public static GiftHelper getInstance() {
    if (null == mInstance) {
      synchronized (GiftHelper.class) {
        if (mInstance == null) {
          mInstance = new GiftHelper();
        }
      }
    }
    return mInstance;
  }

  public void init() {
    //默认选中第一个房主
    selectSeatSet.add(0);
  }

  public void add(int position) {
    selectSeatSet.add(position);
  }

  public void remove(int position) {
    selectSeatSet.remove(position);
  }

  public HashSet<Integer> getSelectedSeatSet() {
    return selectSeatSet;
  }

  public void clear() {
    selectSeatSet.clear();
  }
}

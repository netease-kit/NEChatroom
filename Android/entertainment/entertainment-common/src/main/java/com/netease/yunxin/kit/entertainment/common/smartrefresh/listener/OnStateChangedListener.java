// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.listener;

import static androidx.annotation.RestrictTo.Scope.LIBRARY;
import static androidx.annotation.RestrictTo.Scope.LIBRARY_GROUP;
import static androidx.annotation.RestrictTo.Scope.SUBCLASSES;

import androidx.annotation.NonNull;
import androidx.annotation.RestrictTo;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshLayout;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.constant.RefreshState;

/** 刷新状态改变监听器 Created by scwang on 2017/5/26. */
public interface OnStateChangedListener {
  /**
   * 【仅限框架内调用】状态改变事件 {@link RefreshState}
   *
   * @param refreshLayout RefreshLayout
   * @param oldState 改变之前的状态
   * @param newState 改变之后的状态
   */
  @RestrictTo({LIBRARY, LIBRARY_GROUP, SUBCLASSES})
  void onStateChanged(
      @NonNull RefreshLayout refreshLayout,
      @NonNull RefreshState oldState,
      @NonNull RefreshState newState);
}

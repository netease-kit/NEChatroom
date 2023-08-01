// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.api;

import android.animation.ValueAnimator.AnimatorUpdateListener;
import android.view.MotionEvent;
import android.view.View;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.listener.ScrollBoundaryDecider;

/** 刷新内容组件 Created by scwang on 2017/5/26. */
public interface RefreshContent {

  @NonNull
  View getView();

  @NonNull
  View getScrollableView();

  void onActionDown(MotionEvent e);

  void setUpComponent(RefreshKernel kernel, View fixedHeader, View fixedFooter);

  void setScrollBoundaryDecider(ScrollBoundaryDecider boundary);

  void setEnableLoadMoreWhenContentNotFull(boolean enable);

  void moveSpinner(int spinner, int headerTranslationViewId, int footerTranslationViewId);

  boolean canRefresh();

  boolean canLoadMore();

  AnimatorUpdateListener scrollContentWhenFinished(int spinner);
}

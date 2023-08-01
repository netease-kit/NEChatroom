// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.simple;

import android.graphics.PointF;
import android.view.View;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.listener.ScrollBoundaryDecider;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.util.SmartUtil;

/** 滚动边界 Created by scwang on 2017/7/8. */
public class SimpleBoundaryDecider implements ScrollBoundaryDecider {

  //<editor-fold desc="Internal">
  public PointF mActionEvent;
  public ScrollBoundaryDecider boundary;
  public boolean mEnableLoadMoreWhenContentNotFull = true;
  //</editor-fold>

  //<editor-fold desc="ScrollBoundaryDecider">
  @Override
  public boolean canRefresh(View content) {
    if (boundary != null) {
      return boundary.canRefresh(content);
    }
    //mActionEvent == null 时 canRefresh 不会动态递归搜索
    return SmartUtil.canRefresh(content, mActionEvent);
  }

  @Override
  public boolean canLoadMore(View content) {
    if (boundary != null) {
      return boundary.canLoadMore(content);
    }
    //mActionEvent == null 时 canLoadMore 不会动态递归搜索
    return SmartUtil.canLoadMore(content, mActionEvent, mEnableLoadMoreWhenContentNotFull);
  }
  //</editor-fold>
}

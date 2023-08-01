// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.util;

import android.view.View;
import android.view.ViewGroup;
import androidx.coordinatorlayout.widget.CoordinatorLayout;
import com.google.android.material.appbar.AppBarLayout;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshKernel;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.listener.CoordinatorLayoutListener;

/** Design 兼容包缺省尝试 Created by scwang on 2018/1/29. */
public class DesignUtil {

  public static void checkCoordinatorLayout(
      View content, RefreshKernel kernel, final CoordinatorLayoutListener listener) {
    try { //try 不能删除，不然会出现兼容性问题
      if (content instanceof CoordinatorLayout) {
        kernel.getRefreshLayout().setEnableNestedScroll(false);
        ViewGroup layout = (ViewGroup) content;
        for (int i = layout.getChildCount() - 1; i >= 0; i--) {
          View view = layout.getChildAt(i);
          if (view instanceof AppBarLayout) {
            ((AppBarLayout) view)
                .addOnOffsetChangedListener(
                    new AppBarLayout.OnOffsetChangedListener() {
                      @Override
                      public void onOffsetChanged(AppBarLayout appBarLayout, int verticalOffset) {
                        listener.onCoordinatorUpdate(
                            verticalOffset >= 0,
                            (appBarLayout.getTotalScrollRange() + verticalOffset) <= 0);
                      }
                    });
          }
        }
      }
    } catch (Throwable e) {
      e.printStackTrace();
    }
  }
}

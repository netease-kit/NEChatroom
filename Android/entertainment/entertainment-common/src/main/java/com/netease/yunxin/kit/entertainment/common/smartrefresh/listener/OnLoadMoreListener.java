// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.listener;

import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshLayout;

/** 加载更多监听器 Created by scwang on 2017/5/26. */
public interface OnLoadMoreListener {
  void onLoadMore(@NonNull RefreshLayout refreshLayout);
}

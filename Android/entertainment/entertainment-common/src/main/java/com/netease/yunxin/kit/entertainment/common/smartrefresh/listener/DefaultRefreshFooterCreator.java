// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.listener;

import android.content.Context;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshFooter;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshLayout;

/** 默认Footer创建器 Created by scwang on 2018/1/26. */
public interface DefaultRefreshFooterCreator {
  @NonNull
  RefreshFooter createRefreshFooter(@NonNull Context context, @NonNull RefreshLayout layout);
}

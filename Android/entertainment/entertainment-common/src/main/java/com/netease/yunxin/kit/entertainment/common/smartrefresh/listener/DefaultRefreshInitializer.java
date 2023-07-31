// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.listener;

import android.content.Context;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshLayout;

/** 默认全局初始化器 Created by scwang on 2018/5/29 0029. */
public interface DefaultRefreshInitializer {
  void initialize(@NonNull Context context, @NonNull RefreshLayout layout);
}

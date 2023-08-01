// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.wrapper;

import android.annotation.SuppressLint;
import android.view.View;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshFooter;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.simple.SimpleComponent;

/** 刷新底部包装 Created by scwang on 2017/5/26. */
@SuppressLint("ViewConstructor")
public class RefreshFooterWrapper extends SimpleComponent implements RefreshFooter {

  public RefreshFooterWrapper(View wrapper) {
    super(wrapper);
  }
}

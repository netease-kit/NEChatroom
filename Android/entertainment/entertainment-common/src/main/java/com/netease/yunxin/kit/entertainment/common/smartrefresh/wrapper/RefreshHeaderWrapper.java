// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.smartrefresh.wrapper;

import android.annotation.SuppressLint;
import android.view.View;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshHeader;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.simple.SimpleComponent;

/** 刷新头部包装 Created by scwang on 2017/5/26. */
@SuppressLint("ViewConstructor")
public class RefreshHeaderWrapper extends SimpleComponent implements RefreshHeader {

  public RefreshHeaderWrapper(View wrapper) {
    super(wrapper);
  }
}

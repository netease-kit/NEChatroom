// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.content.Context;
import android.util.AttributeSet;
import com.airbnb.lottie.LottieAnimationView;

/** 当礼物接收到礼物发送时如果为未展示状态则忽略当前礼物动画，即使当前onDetachWindow 也不会暂停动画， 当直播结束手动调用资源释放 */
public class GifAnimationView extends LottieAnimationView {

  public GifAnimationView(Context context) {
    super(context);
  }

  public GifAnimationView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public GifAnimationView(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
  }

  @Override
  public boolean isShown() {
    return true;
  }

  @Override
  public boolean isAnimating() {
    return false;
  }
}

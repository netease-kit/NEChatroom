// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.LayoutRes;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.R;

/** 礼物数量选择 */
public class GiftNumSelectDialog extends Dialog {
  private View rootView;
  private GiftNumSelectCallback callback;

  public GiftNumSelectDialog(@NonNull Context context, GiftNumSelectCallback callback) {
    super(context, R.style.GiftNumSelectDialogTheme);
    rootView = LayoutInflater.from(getContext()).inflate(contentLayoutId(), null);
    this.callback = callback;
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    final Window window = getWindow();
    if (window != null) {
      window.getDecorView().setPadding(0, 0, SizeUtils.dp2px(38), SizeUtils.dp2px(40));
      WindowManager.LayoutParams wlp = window.getAttributes();
      wlp.gravity = Gravity.BOTTOM | Gravity.RIGHT;
      wlp.width = WindowManager.LayoutParams.WRAP_CONTENT;
      wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
      window.setAttributes(wlp);
    }

    setContentView(rootView);
    setCanceledOnTouchOutside(true);
    GiftNumSelectView giftNumSelectView = findViewById(R.id.gift_number_select);
    giftNumSelectView.setGiftNumSelectCallback(
        giftCount -> {
          if (callback != null) {
            callback.giftCountSelect(giftCount);
          }
          dismiss();
        });
  }

  protected @LayoutRes int contentLayoutId() {
    return R.layout.view_gift_dialog_number_select;
  }

  @Override
  public void show() {
    try {
      super.show();
    } catch (WindowManager.BadTokenException e) {
      e.printStackTrace();
    }
  }

  public interface GiftNumSelectCallback {
    void giftCountSelect(int giftCount);
  }
}

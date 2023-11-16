// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.netease.yunxin.kit.entertainment.common.R;

/** 送礼按钮 */
public class GiftSendButton extends ConstraintLayout {
  private ImageView iv;
  private TextView tvNumber;
  private TextView tvSend;

  public GiftSendButton(Context context) {
    super(context);
    init(context);
  }

  public GiftSendButton(Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public GiftSendButton(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  private void init(Context context) {
    LayoutInflater.from(context).inflate(R.layout.view_gift_send_button, this);
    iv = findViewById(R.id.iv);
    tvNumber = findViewById(R.id.tv_number);
    tvSend = findViewById(R.id.tv_send);
    iv.setImageResource(R.drawable.ec_arrow_up);
    tvNumber.setText("1");
    GiftNumSelectDialog giftNumberSelectDialog =
        new GiftNumSelectDialog(getContext(), giftCount -> tvNumber.setText(giftCount + ""));
    giftNumberSelectDialog.setOnDismissListener(
        dialog -> iv.setImageResource(R.drawable.ec_arrow_up));
    iv.setOnClickListener(
        v -> {
          if (giftNumberSelectDialog.isShowing()) {
            giftNumberSelectDialog.dismiss();
            iv.setImageResource(R.drawable.ec_arrow_up);
          } else {
            giftNumberSelectDialog.show();
            iv.setImageResource(R.drawable.ec_arrow_down);
          }
        });
    tvNumber.setOnClickListener(
        v -> {
          if (giftNumberSelectDialog.isShowing()) {
            giftNumberSelectDialog.dismiss();
            iv.setImageResource(R.drawable.ec_arrow_up);
          } else {
            giftNumberSelectDialog.show();
            iv.setImageResource(R.drawable.ec_arrow_down);
          }
        });
    tvSend.setOnClickListener(
        v -> {
          if (sendCallback != null) {
            sendCallback.onSend(Integer.parseInt(tvNumber.getText().toString()));
          }
        });
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    sendCallback = null;
  }

  public void setSendCallback(GiftSendCallback sendCallback) {
    this.sendCallback = sendCallback;
  }

  private GiftSendCallback sendCallback;

  public interface GiftSendCallback {
    void onSend(int giftCount);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.app.Activity;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.helper.EffectPlayHelper;

/** Created by luc on 1/28/21. */
public class ChatRoomAudioDialog extends BottomBaseDialog {
  private final EffectPlayHelper audioPlay;

  public ChatRoomAudioDialog(@NonNull Activity activity, EffectPlayHelper effectPlayHelper) {
    super(activity);
    this.audioPlay = effectPlayHelper;
  }

  @Override
  protected void renderTopView(FrameLayout parent) {
    TextView titleView = new TextView(getContext());
    titleView.setText(getContext().getString(R.string.voiceroom_audio_effect));
    titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
    titleView.setGravity(Gravity.CENTER);
    titleView.setTextColor(Color.parseColor("#ff333333"));
    FrameLayout.LayoutParams layoutParams =
        new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    parent.addView(titleView, layoutParams);
  }

  @Override
  protected void renderBottomView(FrameLayout parent) {
    View bottomView =
        LayoutInflater.from(getContext()).inflate(R.layout.view_dialog_more_audio, parent);

    bottomView
        .findViewById(R.id.tv_audio_effect_1)
        .setOnClickListener(v -> audioPlay.playEffect(0));
    bottomView
        .findViewById(R.id.tv_audio_effect_2)
        .setOnClickListener(v -> audioPlay.playEffect(1));
  }
}

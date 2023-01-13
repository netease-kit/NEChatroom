// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.dialog;

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
import com.netease.yunxin.app.listentogether.helper.AudioPlayHelper;
import com.netease.yunxin.kit.listentogether.R;
import java.util.List;

/** Created by luc on 1/28/21. */
public class ChatRoomAudioDialog extends BottomBaseDialog {
  private final AudioPlayHelper audioPlay;

  public ChatRoomAudioDialog(
      @NonNull Activity activity,
      AudioPlayHelper audioPlayHelper,
      List<MusicItem> audioMixingMusicInfos) {
    super(activity);
    this.audioPlay = audioPlayHelper;
  }

  @Override
  protected void renderTopView(FrameLayout parent) {
    TextView titleView = new TextView(getContext());
    titleView.setText(getContext().getString(R.string.listen_bgm));
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
        LayoutInflater.from(getContext()).inflate(R.layout.listen_view_dialog_more_audio, parent);

    bottomView
        .findViewById(R.id.tv_audio_effect_1)
        .setOnClickListener(v -> audioPlay.playEffect(0));
    bottomView
        .findViewById(R.id.tv_audio_effect_2)
        .setOnClickListener(v -> audioPlay.playEffect(1));
  }

  public static class MusicItem {
    private final String order;
    private final String name;
    private final String singer;

    public MusicItem(String order, String name, String singer) {
      this.order = order;
      this.name = name;
      this.singer = singer;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;

      MusicItem musicItem = (MusicItem) o;

      if (!order.equals(musicItem.order)) return false;
      if (!name.equals(musicItem.name)) return false;
      return singer.equals(musicItem.singer);
    }

    @Override
    public int hashCode() {
      int result = order.hashCode();
      result = 31 * result + name.hashCode();
      result = 31 * result + singer.hashCode();
      return result;
    }
  }
}

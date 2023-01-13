// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.SeekBar;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.lifecycle.LifecycleOwner;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.ordersong.ui.R;
import com.netease.yunxin.kit.ordersong.ui.databinding.OrderedSongOptionsBinding;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;

/** 点歌台已点歌曲控制栏，暂停、播放、切歌、调整音量 */
public class OrderedSongOptionView extends ConstraintLayout {
  private static final String TAG = "OrderedSongOptionView";
  private OrderedSongOptionsBinding viewBinding;
  private OrderSongViewModel orderSongViewModel;

  public OrderedSongOptionView(@NonNull Context context) {
    super(context);
    init(context, null);
  }

  public OrderedSongOptionView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs);
  }

  public OrderedSongOptionView(
      @NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context, attrs);
  }

  private void init(Context context, AttributeSet attrs) {
    LayoutInflater layoutInflater = LayoutInflater.from(context);
    viewBinding = OrderedSongOptionsBinding.inflate(layoutInflater, this, true);
    viewBinding.ivPause.setImageResource(R.drawable.order_pause);
    viewBinding.ivPause.setOnClickListener(
        v -> {
          orderSongViewModel.getPauseOrResumeEvent().postValue(null);
        });

    viewBinding.ivSwitchSong.setOnClickListener(
        v -> orderSongViewModel.getSwitchSongEvent().postValue(null));
    viewBinding.seekbar.setProgress(100);
    viewBinding.seekbar.setOnSeekBarChangeListener(
        new SeekBar.OnSeekBarChangeListener() {
          @Override
          public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            if (orderSongViewModel != null) {
              orderSongViewModel.getVolumeChangedEvent().postValue(seekBar.getProgress());
            }
          }

          @Override
          public void onStartTrackingTouch(SeekBar seekBar) {}

          @Override
          public void onStopTrackingTouch(SeekBar seekBar) {}
        });
  }

  public void setViewModel(OrderSongViewModel orderSongViewModel) {
    this.orderSongViewModel = orderSongViewModel;
    orderSongViewModel
        .getOrderedSongOptionRefreshEvent()
        .observe(
            (LifecycleOwner) getContext(),
            aBoolean -> {
              ALog.i(TAG, "pause:" + aBoolean);
              if (aBoolean) {
                viewBinding.ivPause.setImageResource(R.drawable.order_play);
              } else {
                viewBinding.ivPause.setImageResource(R.drawable.order_pause);
              }
            });
  }

  public void setVolume(int volume) {
    viewBinding.seekbar.setProgress(volume);
  }
}

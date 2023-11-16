// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.StringUtils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.BaseAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.SeatGridAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.VoiceRoomViewModel;
import java.util.ArrayList;
import java.util.List;

/** 两排（表格）类型的座位列表 */
public class NESeatGridView extends LinearLayout {
  protected RecyclerView recyclerView;
  protected SeatGridAdapter seatAdapter;

  protected HeadImageView ivAnchorAvatar;

  protected LottieAnimationView lavAnchorAvatar;

  protected ImageView ivAnchorAudioCloseHint;

  protected TextView tvAnchorNick;

  protected TextView tvAnchorReward;

  private BaseAdapter.ItemClickListener<RoomSeat> itemClickListener;

  public NESeatGridView(Context context) {
    this(context, null);
  }

  public NESeatGridView(Context context, @Nullable AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public NESeatGridView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    LayoutInflater.from(context).inflate(R.layout.view_seat_grid, this);
    initView();
  }

  private void initView() {

    ivAnchorAvatar = findViewById(R.id.iv_liver_avatar);
    lavAnchorAvatar = findViewById(R.id.lav_avatar_lottie_view);
    ivAnchorAudioCloseHint = findViewById(R.id.iv_liver_audio_close_hint);
    tvAnchorNick = findViewById(R.id.tv_liver_nick);
    tvAnchorReward = findViewById(R.id.tv_user_reward);

    recyclerView = findViewById(R.id.recyclerview_seat);
    recyclerView.setLayoutManager(new GridLayoutManager(getContext(), 4));
    seatAdapter = new SeatGridAdapter(null, getContext());
    seatAdapter.setItemClickListener(
        new BaseAdapter.ItemClickListener<RoomSeat>() {
          @Override
          public void onItemClick(RoomSeat model, int position) {
            if (itemClickListener != null) {
              itemClickListener.onItemClick(model, position);
            }
          }
        });
    recyclerView.setAdapter(seatAdapter);
  }

  public void updateAnchorUI(String nick, String avatar, boolean isAudioOn) {
    ivAnchorAvatar.loadAvatar(avatar);
    tvAnchorNick.setText(nick);
    ivAnchorAudioCloseHint.setImageResource(
        isAudioOn ? R.drawable.icon_seat_open_micro : R.drawable.icon_seat_close_micro);
  }

  public void updateAnchorAudio(boolean isMute) {
    ivAnchorAudioCloseHint.setImageResource(
        isMute ? R.drawable.icon_seat_close_micro : R.drawable.icon_seat_open_micro);
  }

  public void updateAnchorReward(int reward) {
    if (reward > 0) {
      tvAnchorReward.setVisibility(View.VISIBLE);
      tvAnchorReward.setText(StringUtils.formatCoinCount(reward));
    } else {
      tvAnchorReward.setVisibility(View.INVISIBLE);
    }
  }

  public void refresh() {
    if (seatAdapter != null) {
      seatAdapter.notifyDataSetChanged();
    }
  }

  public void refresh(List<RoomSeat> seatList) {
    if (seatList == null) {
      return;
    }
    List<RoomSeat> audienceSeats = new ArrayList<>();
    for (RoomSeat model : seatList) {
      if (model != null) {
        // 主播申请的位置是主播信息
        if (model.getSeatIndex() == VoiceRoomViewModel.ANCHOR_SEAT_INDEX) {
          final NEVoiceRoomMember member = model.getMember();
          if (member != null && VoiceRoomUtils.isHost(member.getAccount())) {
            updateAnchorUI(member.getName(), member.getAvatar(), member.isAudioOn());
          }
        } else {
          audienceSeats.add(model);
        }
      }
    }

    if (seatAdapter != null) {
      seatAdapter.setItems(audienceSeats);
      seatAdapter.notifyDataSetChanged();
    }
  }

  public void refreshItem(int index) {
    if (seatAdapter != null) {
      seatAdapter.notifyItemChanged(index);
    }
  }

  public List<RoomSeat> getItems() {
    return seatAdapter == null ? null : seatAdapter.getDataList();
  }

  public void setItemClickListener(BaseAdapter.ItemClickListener<RoomSeat> itemClickListener) {
    this.itemClickListener = itemClickListener;
  }

  public void showAvatarAnimal(boolean showAvatarAnimal) {
    if (showAvatarAnimal) {
      lavAnchorAvatar.setVisibility(View.VISIBLE);
      if (lavAnchorAvatar.isAnimating()) {
        return;
      }
      lavAnchorAvatar.setRepeatCount(LottieDrawable.INFINITE);
      lavAnchorAvatar.playAnimation();
    } else {
      lavAnchorAvatar.setVisibility(View.INVISIBLE);
      lavAnchorAvatar.cancelAnimation();
      lavAnchorAvatar.setProgress(0);
    }
  }
}

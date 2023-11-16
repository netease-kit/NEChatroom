// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.StringUtils;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import java.util.List;

public class SeatGridAdapter extends BaseAdapter<RoomSeat> {

  public SeatGridAdapter(List<RoomSeat> seats, Context context) {
    super(seats, context);
  }

  @Override
  protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
    return new SeatViewHolder(layoutInflater.inflate(R.layout.view_grid_item_seat, parent, false));
  }

  @SuppressLint("UseCompatLoadingForDrawables")
  @Override
  protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
    RoomSeat seat = getItem(position);
    if (seat == null) {
      return;
    }
    SeatViewHolder viewHolder = (SeatViewHolder) holder;
    int status = seat.getStatus();
    NEVoiceRoomMember member = seat.getMember();

    // 用户音频状态显示
    final ImageView ivStatusHint = viewHolder.ivStatusHint;
    if (member == null || status == RoomSeat.Status.APPLY) {
      ivStatusHint.setVisibility(View.GONE);
    } else {
      ivStatusHint.setVisibility(View.VISIBLE);
      if (member.isAudioOn()) {
        ivStatusHint.setImageResource(R.drawable.icon_seat_open_micro);
      } else {
        ivStatusHint.setImageResource(
            member.isAudioBanned()
                ? R.drawable.icon_audio_banned
                : R.drawable.icon_seat_close_micro);
      }
    }

    // 波纹动画
    showLottieAnimal(viewHolder.lavAvatar, false);
    if (member != null) {
      showLottieAnimal(viewHolder.lavAvatar, seat.isSpeaking());
    }

    // 申请中动画
    showLottieAnimal(viewHolder.applying, status == RoomSeat.Status.APPLY);

    if (status == RoomSeat.Status.ON) {
      viewHolder.ivUserStatus.setVisibility(View.GONE);
    } else {
      viewHolder.ivUserStatus.setVisibility(View.VISIBLE);
      int image = R.drawable.seat_add_member;
      if (status == RoomSeat.Status.CLOSED) {
        image = R.drawable.close;
      } else if (status == RoomSeat.Status.APPLY) {
        image = 0;
      }
      viewHolder.ivUserStatus.setImageResource(image);
    }

    // 头像和昵称
    if (member != null) { //麦上有人
      viewHolder.ivAvatar.loadAvatar(member.getAvatar());
      viewHolder.ivAvatar.setVisibility(View.VISIBLE);
      viewHolder.avatarBg.setVisibility(View.VISIBLE);
      viewHolder.tvNick.setVisibility(View.VISIBLE);
      viewHolder.tvNick.setText(member.getName());
    } else {
      viewHolder.tvNick.setText(
          String.format(context.getString(R.string.voiceroom_seat), position + 1));
      viewHolder.circle.setVisibility(View.INVISIBLE);
      viewHolder.ivAvatar.setVisibility(View.INVISIBLE);
      viewHolder.avatarBg.setVisibility(View.INVISIBLE);
    }

    // 头像装饰
    viewHolder.circle.setVisibility(
        status == RoomSeat.Status.ON && member != null ? View.VISIBLE : View.INVISIBLE);

    if (seat.getRewardTotal() > 0) {
      viewHolder.tvUserReward.setVisibility(View.VISIBLE);
      viewHolder.tvUserReward.setText(StringUtils.formatCoinCount(seat.getRewardTotal()));
    } else {
      viewHolder.tvUserReward.setVisibility(View.INVISIBLE);
    }
  }

  private void showLottieAnimal(LottieAnimationView lottieAnimationView, boolean showAnimal) {
    if (showAnimal) {
      lottieAnimationView.setVisibility(View.VISIBLE);
      if (lottieAnimationView.isAnimating()) {
        return;
      }
      lottieAnimationView.setRepeatCount(LottieDrawable.INFINITE);
      lottieAnimationView.playAnimation();
    } else {
      lottieAnimationView.setVisibility(View.INVISIBLE);
      lottieAnimationView.cancelAnimation();
      lottieAnimationView.setProgress(0);
    }
  }

  public class SeatViewHolder extends RecyclerView.ViewHolder {
    HeadImageView ivAvatar;
    ImageView ivStatusHint;
    ImageView ivUserStatus;
    TextView tvNick;
    ImageView circle;
    View avatarBg;
    LottieAnimationView applying;
    LottieAnimationView lavAvatar;

    TextView tvUserReward;

    SeatViewHolder(@NonNull View itemView) {
      super(itemView);
      ivAvatar = itemView.findViewById(R.id.iv_seat_avatar);
      ivStatusHint = itemView.findViewById(R.id.iv_seat_audio_status);
      tvNick = itemView.findViewById(R.id.tv_seat_name);
      ivUserStatus = itemView.findViewById(R.id.iv_seat_status);
      circle = itemView.findViewById(R.id.circle);
      avatarBg = itemView.findViewById(R.id.seat_avatar_bg);
      applying = itemView.findViewById(R.id.lav_seat_apply);
      lavAvatar = itemView.findViewById(R.id.lav_avatar_lottie_view);
      tvUserReward = itemView.findViewById(R.id.tv_user_reward);
    }
  }
}

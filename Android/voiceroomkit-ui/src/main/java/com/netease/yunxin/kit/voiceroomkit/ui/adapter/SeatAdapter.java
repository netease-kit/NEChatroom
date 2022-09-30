// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import java.util.List;

public class SeatAdapter extends BaseAdapter<VoiceRoomSeat> {

  public SeatAdapter(List<VoiceRoomSeat> seats, Context context) {
    super(seats, context);
  }

  @Override
  protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
    return new SeatViewHolder(layoutInflater.inflate(R.layout.view_item_seat, parent, false));
  }

  @Override
  protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
    VoiceRoomSeat seat = getItem(position);
    if (seat == null) {
      return;
    }
    SeatViewHolder viewHolder = (SeatViewHolder) holder;
    int status = seat.getStatus();
    NEVoiceRoomMember member = seat.getMember();

    // 用户音频状态显示
    final ImageView ivStatusHint = viewHolder.ivStatusHint;
    if (member == null || status == VoiceRoomSeat.Status.APPLY) {
      ivStatusHint.setVisibility(View.GONE);
    } else {
      ivStatusHint.setVisibility(View.VISIBLE);
      if (member.isAudioOn()) {
        ivStatusHint.setImageResource(R.drawable.icon_seat_open_micro);
      } else {
        ivStatusHint.setImageResource(
            member.isAudioBanned()
                ? R.drawable.audio_be_muted_status
                : R.drawable.icon_seat_close_micro);
      }
    }

    // 申请中动画
    LottieAnimationView applying = viewHolder.applying;
    if (status == VoiceRoomSeat.Status.APPLY) {
      applying.setVisibility(View.VISIBLE);
      applying.setRepeatCount(LottieDrawable.INFINITE);
      applying.playAnimation();

    } else {
      applying.setVisibility(View.GONE);
      applying.cancelAnimation();
    }

    if (status == VoiceRoomSeat.Status.ON) {
      viewHolder.iv_user_status.setVisibility(View.GONE);
    } else {
      viewHolder.iv_user_status.setVisibility(View.VISIBLE);
      int image = R.drawable.seat_add_member;
      if (status == VoiceRoomSeat.Status.CLOSED) {
        image = R.drawable.close;
      } else if (status == VoiceRoomSeat.Status.APPLY) {
        image = 0;
      }
      viewHolder.iv_user_status.setImageResource(image);
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
          String.format(context.getString(R.string.voiceroom_seat), seat.getSeatIndex() - 1));
      viewHolder.circle.setVisibility(View.INVISIBLE);
      viewHolder.ivAvatar.setVisibility(View.INVISIBLE);
      viewHolder.avatarBg.setVisibility(View.INVISIBLE);
    }

    // 头像装饰
    viewHolder.circle.setVisibility(
        status == VoiceRoomSeat.Status.ON && member != null ? View.VISIBLE : View.INVISIBLE);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.adapter;

import android.annotation.SuppressLint;
import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import java.util.List;

public class SeatListAdapter extends BaseAdapter<RoomSeat> {

  public SeatListAdapter(List<RoomSeat> seats, Context context) {
    super(seats, context);
  }

  @Override
  protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
    return new SeatViewHolder(layoutInflater.inflate(R.layout.view_list_item_seat, parent, false));
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
    final ImageView ivStatusHint = viewHolder.seatAudioStatus;
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

    if (status == RoomSeat.Status.ON) {
      viewHolder.seatStatus.setVisibility(View.GONE);
    } else {
      viewHolder.seatStatus.setVisibility(View.VISIBLE);
      int image = R.drawable.seat_list_add_member;
      if (status == RoomSeat.Status.CLOSED) {
        image = R.drawable.seat_list_close;
      } else if (status == RoomSeat.Status.APPLY) {
        image = 0;
      }
      viewHolder.seatStatus.setImageResource(image);
    }

    // 头像和昵称
    if (member != null) { //麦上有人
      viewHolder.seatAvatar.loadAvatar(member.getAvatar());
      viewHolder.seatAvatar.setVisibility(View.VISIBLE);
      viewHolder.seatAvatarBg.setVisibility(View.VISIBLE);
      viewHolder.seatNick.setVisibility(View.VISIBLE);
      viewHolder.seatNick.setText(member.getName());
    } else {
      viewHolder.seatNick.setText(
          String.format(context.getString(R.string.voiceroom_seat), position));
      viewHolder.seatAvatar.setVisibility(View.INVISIBLE);
      viewHolder.seatAvatarBg.setVisibility(View.INVISIBLE);
    }

    if (!TextUtils.isEmpty(seat.getExt())) {
      viewHolder.seatExt.setVisibility(View.VISIBLE);
      viewHolder.seatExt.setText(seat.getExt());
    } else {
      viewHolder.seatExt.setVisibility(View.GONE);
    }
  }

  public static class SeatViewHolder extends RecyclerView.ViewHolder {
    HeadImageView seatAvatar;
    ImageView seatAudioStatus;
    ImageView seatStatus;
    TextView seatNick;
    View seatAvatarBg;
    LottieAnimationView seatApplying;
    TextView seatExt;

    SeatViewHolder(@NonNull View itemView) {
      super(itemView);
      seatAvatar = itemView.findViewById(R.id.iv_seat_avatar);
      seatAudioStatus = itemView.findViewById(R.id.iv_seat_audio_status);
      seatNick = itemView.findViewById(R.id.tv_seat_name);
      seatStatus = itemView.findViewById(R.id.iv_seat_status);
      seatAvatarBg = itemView.findViewById(R.id.seat_avatar_bg);
      seatApplying = itemView.findViewById(R.id.lav_seat_apply);
      seatExt = itemView.findViewById(R.id.tv_seat_ext);
    }
  }
}

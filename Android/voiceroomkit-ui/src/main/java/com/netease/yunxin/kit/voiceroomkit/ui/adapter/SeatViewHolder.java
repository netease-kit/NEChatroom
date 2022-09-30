// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.adapter;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.HeadImageView;

public class SeatViewHolder extends RecyclerView.ViewHolder {
  HeadImageView ivAvatar;
  ImageView ivStatusHint;
  ImageView iv_user_status;
  TextView tvNick;
  ImageView circle;
  View avatarBg;
  LottieAnimationView applying;

  SeatViewHolder(@NonNull View itemView) {
    super(itemView);
    ivAvatar = itemView.findViewById(R.id.iv_user_avatar);
    ivStatusHint = itemView.findViewById(R.id.iv_user_status_hint);
    tvNick = itemView.findViewById(R.id.tv_user_nick);
    iv_user_status = itemView.findViewById(R.id.iv_user_stats);
    circle = itemView.findViewById(R.id.circle);
    avatarBg = itemView.findViewById(R.id.avatar_bg);
    applying = itemView.findViewById(R.id.lav_apply);
  }
}
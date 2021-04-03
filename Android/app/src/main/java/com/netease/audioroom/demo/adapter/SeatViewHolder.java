package com.netease.audioroom.demo.adapter;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.airbnb.lottie.LottieAnimationView;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.widget.HeadImageView;

public class SeatViewHolder extends RecyclerView.ViewHolder {
    HeadImageView ivAvatar;
    ImageView ivStatusHint;
    ImageView iv_user_status;
    TextView tvNick;
    ImageView circle;
    ImageView ivUserSinging;
    View avatarBg;
    LottieAnimationView applying;

    SeatViewHolder(@NonNull View itemView) {
        super(itemView);
        ivAvatar = itemView.findViewById(R.id.iv_user_avatar);
        ivStatusHint = itemView.findViewById(R.id.iv_user_status_hint);
        tvNick = itemView.findViewById(R.id.tv_user_nick);
        iv_user_status = itemView.findViewById(R.id.iv_user_stats);
        circle = itemView.findViewById(R.id.circle);
        ivUserSinging = itemView.findViewById(R.id.iv_user_singing);
        avatarBg = itemView.findViewById(R.id.avatar_bg);
        applying = itemView.findViewById(R.id.lav_apply);
    }
}

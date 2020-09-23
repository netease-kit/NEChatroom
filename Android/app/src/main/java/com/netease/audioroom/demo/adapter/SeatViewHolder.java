package com.netease.audioroom.demo.adapter;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.widget.HeadImageView;

public class SeatViewHolder extends RecyclerView.ViewHolder {
    HeadImageView ivAvatar;
    ImageView ivStatusHint;
    ImageView iv_user_status;
    TextView tvNick;
    ImageView circle;

    SeatViewHolder(@NonNull View itemView) {
        super(itemView);
        ivAvatar = itemView.findViewById(R.id.iv_user_avatar);
        ivStatusHint = itemView.findViewById(R.id.iv_user_status_hint);
        tvNick = itemView.findViewById(R.id.tv_user_nick);
        iv_user_status = itemView.findViewById(R.id.iv_user_stats);
        circle = itemView.findViewById(R.id.circle);
    }
}

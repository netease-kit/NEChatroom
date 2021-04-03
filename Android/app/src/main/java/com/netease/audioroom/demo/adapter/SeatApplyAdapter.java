package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.yunxin.kit.alog.ALog;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.widget.HeadImageView;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class SeatApplyAdapter extends BaseAdapter<VoiceRoomSeat> {
    public interface IApplyAction {
        void refuse(VoiceRoomSeat seat);

        void agree(VoiceRoomSeat seat);
    }

    IApplyAction applyAction;
    ArrayList<VoiceRoomSeat> seats;

    public SeatApplyAdapter(ArrayList<VoiceRoomSeat> seats, Context context) {
        super(seats, context);
        this.seats = seats;
    }


    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new ApplyViewHolder(layoutInflater.inflate(R.layout.apply_item_layout, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        VoiceRoomSeat seat = getItem(position);
        if (seat == null) {
            return;
        }
        ApplyViewHolder viewHolder = (ApplyViewHolder) holder;
        VoiceRoomUser user = seat.getUser();
        if (user != null) {
            int index = seat.getIndex() + 1;
            ImageLoader.with(context).load(user.getAvatar()).error(R.drawable.nim_avatar_default).into(viewHolder.ivAvatar);
            viewHolder.tvContent.setText(user.getNick() + "\t申请麦位(" + index + ")");
            viewHolder.ivRefuse.setOnClickListener((v) -> applyAction.refuse(seat));
            viewHolder.ivAfree.setOnClickListener((v) ->
                    applyAction.agree(seat));
        } else {
            ALog.e("偶现看不到申请者情形", user.toString());
        }


    }

    private class ApplyViewHolder extends RecyclerView.ViewHolder {
        HeadImageView ivAvatar;
        ImageView ivRefuse;
        ImageView ivAfree;
        TextView tvContent;

        public ApplyViewHolder(@NonNull View itemView) {
            super(itemView);
            ivAvatar = itemView.findViewById(R.id.item_requestlink_headicon);
            ivRefuse = itemView.findViewById(R.id.refuse);
            ivAfree = itemView.findViewById(R.id.agree);
            tvContent = itemView.findViewById(R.id.item_requestlink_content);
        }
    }

    public void setApplyAction(IApplyAction applyAction) {
        this.applyAction = applyAction;
    }
}

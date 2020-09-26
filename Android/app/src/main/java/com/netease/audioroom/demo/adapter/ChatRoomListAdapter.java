package com.netease.audioroom.demo.adapter;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.audioroom.demo.util.CommonUtil;

import java.util.ArrayList;

public class ChatRoomListAdapter extends BaseAdapter<VoiceRoomInfo> {
    ArrayList<VoiceRoomInfo> dataList;

    public ChatRoomListAdapter(ArrayList<VoiceRoomInfo> dataList, Context context) {
        super(dataList, context);
    }


    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new ChatRoomHolder(layoutInflater.inflate(R.layout.item_chat_room_list, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ChatRoomHolder roomHolder = (ChatRoomHolder) holder;
        VoiceRoomInfo demoRoomInfo = getItem(position);
        if (demoRoomInfo == null) {
            return;
        }
        CommonUtil.loadImage(context, demoRoomInfo.getThumbnail(), roomHolder.ivBg, R.drawable.chat_room_default_bg, 0);
        roomHolder.tvRoomName.setText(demoRoomInfo.getName());
        roomHolder.tvMember.setText(demoRoomInfo.getOnlineUserCount() + "人");
    }


    private class ChatRoomHolder extends RecyclerView.ViewHolder {

        ImageView ivBg;

        TextView tvRoomName;

        TextView tvMember;

        ChatRoomHolder(View itemView) {
            super(itemView);

            ivBg = itemView.findViewById(R.id.iv_chat_room_bg);
            tvRoomName = itemView.findViewById(R.id.tv_chat_room_name);
            tvMember = itemView.findViewById(R.id.tv_chat_room_member_num);
        }
    }

    public void refrshList(ArrayList<VoiceRoomInfo> dataList) {
        this.dataList = dataList;
        notifyDataSetChanged();

    }

}

package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.util.CommonUtil;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;

import java.util.List;

public class MemberListAdapter extends BaseAdapter<VoiceRoomUser> {


    public MemberListAdapter(List<VoiceRoomUser> dataList, Context context) {
        super(dataList, context);
    }

    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new ChatRoomHolder(layoutInflater.inflate(R.layout.item_chatroom_list, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ChatRoomHolder roomHolder = (ChatRoomHolder) holder;
        VoiceRoomUser member = getItem(position);
        if (member == null) {
            return;
        }
        CommonUtil.loadImage(context, member.getAvatar(), roomHolder.ivBg);
        roomHolder.tvRoomName.setText(member.getNick());
    }


    private class ChatRoomHolder extends RecyclerView.ViewHolder {
        ImageView ivBg;
        TextView tvRoomName;


        ChatRoomHolder(View itemView) {
            super(itemView);
            ivBg = itemView.findViewById(R.id.headview);
            tvRoomName = itemView.findViewById(R.id.chatroom_name);

        }
    }
}

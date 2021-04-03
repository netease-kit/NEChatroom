package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;
import com.netease.audioroom.demo.util.IconFontUtil;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public class ChatRoomListAdapter extends BaseAdapter<VoiceRoomInfo> {

    public ChatRoomListAdapter(Context context) {
        super(new ArrayList<>(), context);
    }


    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new ChatRoomHolder(layoutInflater.inflate(R.layout.item_chat_room_list, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ChatRoomHolder viewHolder = (ChatRoomHolder) holder;
        VoiceRoomInfo info = getItem(position);
        if (info == null) {
            return;
        }
        ImageLoader.with(context).load(info.getThumbnail()).error(R.drawable.chat_room_default_bg)
                   .roundedCornerCenterCrop(ScreenUtil.dip2px(context, 4)).into(viewHolder.ivBg);
        viewHolder.tvRoomName.setText(info.getName());
        viewHolder.tvMember.setText(getCurrentCount(info.getOnlineUserCount()));
        viewHolder.tvAnchorName.setText(info.getNickname());
        if (info.getRoomType() == ChatRoomNetConstants.ROOM_TYPE_CHAT) {
            viewHolder.tvCurrentMusicName.setVisibility(View.GONE);
        } else {
            if (TextUtils.isEmpty(info.getCurrentMusicName())) {
                viewHolder.tvCurrentMusicName.setVisibility(View.GONE);
            } else {
                viewHolder.tvCurrentMusicName.setVisibility(View.VISIBLE);
                IconFontUtil.getInstance().setFontText(viewHolder.tvCurrentMusicName, IconFontUtil.MUSIC,
                                                       " "+info.getCurrentMusicName());
            }
        }
    }

    public void refreshList(List<VoiceRoomInfo> dataList) {
        if (dataList == null) {
            return;
        }
        setItems(dataList);
        notifyDataSetChanged();

    }

    private static class ChatRoomHolder extends RecyclerView.ViewHolder {

        ImageView ivBg;

        TextView tvRoomName;

        TextView tvMember;

        TextView tvAnchorName;

        TextView tvCurrentMusicName;

        ChatRoomHolder(View itemView) {
            super(itemView);
            ivBg = itemView.findViewById(R.id.iv_chat_room_bg);
            tvRoomName = itemView.findViewById(R.id.tv_chat_room_name);
            tvMember = itemView.findViewById(R.id.tv_chat_room_member_num);
            tvAnchorName = itemView.findViewById(R.id.tv_chat_room_anchor_name);
            tvCurrentMusicName = itemView.findViewById(R.id.current_play_music);
        }
    }

    private String getCurrentCount(int count){
        if (count < 10000) {
            return count + "人";
        }
        DecimalFormat decimalFormat = new DecimalFormat("#.#");
        return decimalFormat.format(count / 10000.f) + "w人";
    }
}

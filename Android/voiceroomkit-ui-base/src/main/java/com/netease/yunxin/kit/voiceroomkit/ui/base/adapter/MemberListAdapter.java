// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.VoiceRoomUser;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.OnItemClickListener;
import java.util.ArrayList;
import java.util.List;

public class MemberListAdapter extends RecyclerView.Adapter<MemberListAdapter.ChatRoomHolder> {
  private static final int TYPE_EMPTY = 1;
  private static final int TYPE_NORMAL = 2;

  private final List<VoiceRoomUser> members = new ArrayList<>();
  private final Context context;
  private OnItemClickListener<Integer> onItemClickListener;

  public MemberListAdapter(List<VoiceRoomUser> dataList, Context context) {
    if (dataList != null && !dataList.isEmpty()) {
      this.members.addAll(dataList);
    }
    this.context = context;
  }

  public MemberListAdapter(Context context) {
    this(null, context);
  }

  public void updateDataSource(List<VoiceRoomUser> members) {
    if (members == null) {
      return;
    }
    this.members.clear();
    this.members.addAll(members);
    notifyDataSetChanged();
  }

  public void setOnItemClickListener(OnItemClickListener<Integer> onItemClickListener) {
    this.onItemClickListener = onItemClickListener;
  }

  @Override
  public int getItemCount() {
    return members.isEmpty() ? 1 : members.size();
  }

  @NonNull
  @Override
  public ChatRoomHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    if (viewType == TYPE_EMPTY) {
      return new ChatRoomHolder(
          LayoutInflater.from(context)
              .inflate(R.layout.view_item_dialog_members_empty, parent, false),
          context,
          false);
    }
    return new ChatRoomHolder(
        LayoutInflater.from(context).inflate(R.layout.item_chatroom_list, parent, false),
        context,
        true);
  }

  @Override
  public void onBindViewHolder(@NonNull ChatRoomHolder holder, int position) {
    if (getItemViewType(position) == TYPE_EMPTY) {
      return;
    }
    VoiceRoomUser member = members.get(position);
    if (member == null) {
      return;
    }
    holder.ivBg.loadAvatar(member.getAvatar());
    holder.tvRoomName.setText(member.getNick());
    holder.itemView.setOnClickListener(
        v -> {
          if (onItemClickListener != null) {
            onItemClickListener.onItemClick(position);
          }
        });
  }

  @Override
  public int getItemViewType(int position) {
    return members.isEmpty() ? TYPE_EMPTY : TYPE_NORMAL;
  }

  public static class ChatRoomHolder extends RecyclerView.ViewHolder {
    HeadImageView ivBg;
    TextView tvRoomName;

    ChatRoomHolder(View itemView, Context context, boolean needInit) {
      super(itemView);
      if (!needInit) {
        ((TextView) (itemView.findViewById(R.id.tv_empty_comment)))
            .setText(context.getString(R.string.voiceroom_no_members));
        return;
      }
      ivBg = itemView.findViewById(R.id.headview);
      tvRoomName = itemView.findViewById(R.id.chatroom_name);
    }
  }
}

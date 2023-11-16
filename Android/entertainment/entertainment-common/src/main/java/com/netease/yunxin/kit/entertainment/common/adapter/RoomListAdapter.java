// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ItemVoiceRoomListBinding;
import com.netease.yunxin.kit.entertainment.common.model.RoomModel;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

public class RoomListAdapter extends RecyclerView.Adapter<RoomListAdapter.RoomViewHolder> {

  protected final Context context;
  private final List<RoomModel> roomInfoList;
  private static OnItemClickListener itemOnClickListener;

  public RoomListAdapter(Context context) {
    this.context = context;
    roomInfoList = new ArrayList<>();
  }

  public void refreshList(List<RoomModel> dataList) {
    roomInfoList.clear();
    roomInfoList.addAll(dataList);
    notifyDataSetChanged();
  }

  public void loadMore(List<RoomModel> dataList) {
    roomInfoList.addAll(dataList);
    notifyDataSetChanged();
  }

  public boolean isEmptyPosition(int position) {
    return position == 0 && roomInfoList.isEmpty();
  }

  @NonNull
  @Override
  public RoomViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    ItemVoiceRoomListBinding binding =
        ItemVoiceRoomListBinding.inflate(LayoutInflater.from(context), parent, false);
    return new RoomViewHolder(binding, context);
  }

  @Override
  public void onBindViewHolder(@NonNull RoomViewHolder holder, int position) {
    RoomModel roomInfo = roomInfoList.get(position);
    holder.setData(roomInfo);
  }

  @Override
  public int getItemCount() {
    return roomInfoList.size();
  }

  public static class RoomViewHolder extends RecyclerView.ViewHolder {

    protected final ItemVoiceRoomListBinding binding;
    private final Context context;

    public RoomViewHolder(ItemVoiceRoomListBinding binding, Context context) {
      super(binding.getRoot());
      this.binding = binding;
      this.context = context;
    }

    public void setData(RoomModel info) {
      ImageLoader.with(context)
          .load(info.getCover())
          .error(R.drawable.chat_room_default_bg)
          .roundedCornerCenterCrop(SizeUtils.dp2px(4))
          .into(binding.ivChatRoomBg);
      binding.tvChatRoomName.setText(info.getRoomName());
      binding.tvChatRoomAnchorName.setText(info.getAnchorNick());
      binding.tvChatRoomMemberNum.setText(getCurrentCount(info.getAudienceCount()));
      binding
          .getRoot()
          .setOnClickListener(
              v -> {
                if (itemOnClickListener != null) {
                  itemOnClickListener.onClick(info);
                }
              });
    }

    private String getCurrentCount(int count) {
      if (count < 10000) {
        return String.format(context.getString(R.string.voiceroom_people_online2), count);
      }
      DecimalFormat decimalFormat = new DecimalFormat("#.#");
      return String.format(
          context.getString(R.string.voiceroom_people_online_ten_thousand),
          decimalFormat.format(count / 10000.f));
    }
  }

  public void setItemOnClickListener(OnItemClickListener itemOnClickListener) {
    this.itemOnClickListener = itemOnClickListener;
  }

  public interface OnItemClickListener {
    void onClick(RoomModel info);
  }
}

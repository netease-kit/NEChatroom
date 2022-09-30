// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom.roomlist.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.app.voiceroom.R;
import com.netease.yunxin.app.voiceroom.databinding.ItemVoiceRoomListBinding;
import com.netease.yunxin.app.voiceroom.utils.NavUtils;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

public class VoiceRoomListAdapter
    extends RecyclerView.Adapter<VoiceRoomListAdapter.VoiceRoomHolder> {

  private Context context;
  private List<NEVoiceRoomInfo> roomInfoList;

  public VoiceRoomListAdapter(Context context) {
    this.context = context;
    roomInfoList = new ArrayList<>();
  }

  public void refreshList(List<NEVoiceRoomInfo> dataList) {
    roomInfoList.clear();
    roomInfoList.addAll(dataList);
    notifyDataSetChanged();
  }

  public void loadMore(List<NEVoiceRoomInfo> dataList) {
    roomInfoList.addAll(dataList);
    notifyDataSetChanged();
  }

  public boolean isEmptyPosition(int position) {
    return position == 0 && roomInfoList.isEmpty();
  }

  @NonNull
  @Override
  public VoiceRoomHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    ItemVoiceRoomListBinding binding =
        ItemVoiceRoomListBinding.inflate(LayoutInflater.from(context), parent, false);
    return new VoiceRoomHolder(binding, context);
  }

  @Override
  public void onBindViewHolder(@NonNull VoiceRoomHolder holder, int position) {
    NEVoiceRoomInfo roomInfo = roomInfoList.get(position);
    holder.setData(roomInfo);
  }

  @Override
  public int getItemCount() {
    return roomInfoList.size();
  }

  public static class VoiceRoomHolder extends RecyclerView.ViewHolder {

    private ItemVoiceRoomListBinding binding;
    private Context context;

    VoiceRoomHolder(ItemVoiceRoomListBinding binding, Context context) {
      super(binding.getRoot());
      this.binding = binding;
      this.context = context;
    }

    public void setData(NEVoiceRoomInfo info) {
      ImageLoader.with(context)
          .load(info.getLiveModel().getCover())
          .error(R.drawable.chat_room_default_bg)
          .roundedCornerCenterCrop(SizeUtils.dp2px(4))
          .into(binding.ivChatRoomBg);
      binding.tvChatRoomName.setText(info.getLiveModel().getLiveTopic());
      binding.tvChatRoomMemberNum.setText(
          getCurrentCount(
              info.getLiveModel().getAudienceCount() + info.getLiveModel().getOnSeatCount()));
      binding.tvChatRoomAnchorName.setText(info.getAnchor().getNick());
      binding.getRoot().setOnClickListener(v -> NavUtils.toVoiceRoomAudiencePage(context, info));
    }

    private String getCurrentCount(int count) {
      if (count < 10000) {
        return String.format(context.getString(R.string.app_people_online), count);
      }
      DecimalFormat decimalFormat = new DecimalFormat("#.#");
      return String.format(
          context.getString(R.string.app_people_online_ten_thousand),
          decimalFormat.format(count / 10000.f));
    }
  }
}

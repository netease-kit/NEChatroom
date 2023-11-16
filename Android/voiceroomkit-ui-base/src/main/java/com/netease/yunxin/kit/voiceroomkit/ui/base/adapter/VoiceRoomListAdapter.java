// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.entertainment.common.adapter.RoomListAdapter;
import com.netease.yunxin.kit.entertainment.common.databinding.ItemVoiceRoomListBinding;
import com.netease.yunxin.kit.entertainment.common.model.RoomModel;

public class VoiceRoomListAdapter extends RoomListAdapter {

  public VoiceRoomListAdapter(Context context) {
    super(context);
  }

  @NonNull
  @Override
  public RoomViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    ItemVoiceRoomListBinding binding =
        ItemVoiceRoomListBinding.inflate(LayoutInflater.from(context), parent, false);
    return new VoiceRoomViewHolder(binding, context);
  }

  public static class VoiceRoomViewHolder extends RoomViewHolder {

    public VoiceRoomViewHolder(ItemVoiceRoomListBinding binding, Context context) {
      super(binding, context);
    }

    @Override
    public void setData(RoomModel info) {
      super.setData(info);
      binding.ivType.setVisibility(View.GONE);
    }
  }
}

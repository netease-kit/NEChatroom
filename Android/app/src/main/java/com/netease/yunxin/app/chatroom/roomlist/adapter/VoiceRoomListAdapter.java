// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.roomlist.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.databinding.ItemVoiceRoomListBinding;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherCallback;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.NELiveType;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.floatplay.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.ClickUtils;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
import kotlin.Unit;

public class VoiceRoomListAdapter
    extends RecyclerView.Adapter<VoiceRoomListAdapter.VoiceRoomHolder> {

  private final Context context;
  private final List<NEVoiceRoomInfo> roomInfoList;
  private int liveType;
  private static final int ROOM_MAX_AUDIENCE_COUNT = 1;

  public VoiceRoomListAdapter(Context context, int liveType) {
    this.context = context;
    this.liveType = liveType;
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
    return new VoiceRoomHolder(binding, context, liveType);
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

    private final ItemVoiceRoomListBinding binding;
    private final Context context;
    private int liveType;

    VoiceRoomHolder(ItemVoiceRoomListBinding binding, Context context, int liveType) {
      super(binding.getRoot());
      this.binding = binding;
      this.context = context;
      this.liveType = liveType;
    }

    public void setData(NEVoiceRoomInfo info) {
      ImageLoader.with(context)
          .load(info.getLiveModel().getCover())
          .error(R.drawable.chat_room_default_bg)
          .roundedCornerCenterCrop(SizeUtils.dp2px(4))
          .into(binding.ivChatRoomBg);
      binding.tvChatRoomName.setText(info.getLiveModel().getLiveTopic());
      binding.tvChatRoomAnchorName.setText(info.getAnchor().getNick());
      int audienceCount = 0;
      if (info.getLiveModel().getAudienceCount() != null) {
        audienceCount = info.getLiveModel().getAudienceCount();
      }
      if (liveType == NELiveType.LIVE_TYPE_TOGETHER_LISTEN) {
        binding.ivType.setVisibility(View.VISIBLE);
      } else {
        binding.ivType.setVisibility(View.GONE);
      }
      binding.tvChatRoomMemberNum.setText(getCurrentCount(audienceCount + 1));
      binding
          .getRoot()
          .setOnClickListener(
              v -> {
                if (ClickUtils.isFastClick()) {
                  return;
                }
                if (NetworkUtils.isConnected()) {
                  if (info.getLiveModel().getLiveType() == NELiveType.LIVE_TYPE_TOGETHER_LISTEN) {
                    handleJoinListenTogetherRoom(info);
                  } else {
                    handleJoinVoiceRoom(info);
                  }
                } else {
                  ToastUtils.INSTANCE.showShortToast(
                      context, context.getString(R.string.common_network_error));
                }
              });
    }

    private void handleJoinVoiceRoom(NEVoiceRoomInfo info) {
      if (FloatPlayManager.getInstance().isShowFloatView()) {
        if (FloatPlayManager.getInstance().getVoiceRoomInfo() != null
            && FloatPlayManager.getInstance()
                .getVoiceRoomInfo()
                .getRoomUuid()
                .equals(info.getLiveModel().getRoomUuid())) {
          FloatPlayManager.getInstance().stopFloatPlay();
          NavUtils.toVoiceRoomAudiencePage(context, info, false);
        } else {
          AlertDialog.Builder builder = new AlertDialog.Builder(context);
          builder.setTitle(context.getString(R.string.app_tip));
          builder.setMessage(context.getString(R.string.app_click_roomlist_tips));
          builder.setCancelable(true);
          builder.setPositiveButton(
              context.getString(R.string.app_sure),
              (dialog, which) -> {
                NEVoiceRoomKit.getInstance()
                    .leaveRoom(
                        new NEVoiceRoomCallback<Unit>() {
                          @Override
                          public void onSuccess(@Nullable Unit unit) {
                            NavUtils.toVoiceRoomAudiencePage(context, info, true);
                          }

                          @Override
                          public void onFailure(int code, @Nullable String msg) {}
                        });
                dialog.dismiss();
              });
          builder.setNegativeButton(
              context.getString(R.string.app_cancel), (dialog, which) -> dialog.dismiss());
          AlertDialog alertDialog = builder.create();
          alertDialog.show();
        }
      } else {
        NavUtils.toVoiceRoomAudiencePage(context, info, true);
      }
    }

    private void handleJoinListenTogetherRoom(NEVoiceRoomInfo info) {
      if (FloatPlayManager.getInstance().isShowFloatView()) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(context.getString(R.string.app_tip));
        builder.setMessage(context.getString(R.string.app_click_roomlist_tips));
        builder.setCancelable(true);
        builder.setPositiveButton(
            context.getString(R.string.app_sure),
            (dialog, which) -> {
              NEVoiceRoomKit.getInstance()
                  .leaveRoom(
                      new NEVoiceRoomCallback<Unit>() {
                        @Override
                        public void onSuccess(@Nullable Unit unit) {
                          joinListenTogetherRoom(info);
                        }

                        @Override
                        public void onFailure(int code, @Nullable String msg) {}
                      });
              dialog.dismiss();
            });
        builder.setNegativeButton(
            context.getString(R.string.app_cancel), (dialog, which) -> dialog.dismiss());
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
      } else {
        joinListenTogetherRoom(info);
      }
    }

    private void joinListenTogetherRoom(NEVoiceRoomInfo info) {
      NEListenTogetherKit.getInstance()
          .getRoomInfo(
              info.getLiveModel().getLiveRecordId(),
              new NEListenTogetherCallback<NEListenTogetherRoomInfo>() {
                @Override
                public void onSuccess(@Nullable NEListenTogetherRoomInfo neVoiceRoomInfo) {
                  if (neVoiceRoomInfo.getLiveModel() != null
                      && neVoiceRoomInfo.getLiveModel().getAudienceCount()
                          >= ROOM_MAX_AUDIENCE_COUNT) {
                    ToastUtils.INSTANCE.showShortToast(
                        context, context.getString(R.string.listen_join_live_error));
                  } else {
                    NavUtils.toListenTogetherAudiencePage(context, info);
                  }
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ToastUtils.INSTANCE.showShortToast(
                      context, context.getString(R.string.app_room_not_exist));
                }
              });
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

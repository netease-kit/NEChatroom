// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.SeatUtils;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomSeatItem;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** 送礼头像选择 */
public class SelectMemberSendGiftView extends RecyclerView {
  private static final int ALL_COUNT = 9;
  private static final int ANCHOR_INDEX = 1;
  private final ArrayList<RoomSeat> list = new ArrayList<>();
  private MemberAdapter memberAdapter;
  private final NEVoiceRoomListenerAdapter listener =
      new NEVoiceRoomListenerAdapter() {
        @Override
        public void onSeatListChanged(@NonNull List<NEVoiceRoomSeatItem> seatItems) {
          handleSeatItemListChanged(seatItems);
        }
      };

  public SelectMemberSendGiftView(@NonNull Context context) {
    super(context);
    init(context);
  }

  public SelectMemberSendGiftView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public SelectMemberSendGiftView(
      @NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  @SuppressLint("NotifyDataSetChanged")
  private void init(Context context) {
    setLayoutManager(new GridLayoutManager(context, ALL_COUNT));
    list.add(
        new RoomSeat(
            ANCHOR_INDEX, RoomSeat.Status.ON, RoomSeat.Reason.NONE, VoiceRoomUtils.getHost()));
    for (int i = 2; i <= ALL_COUNT; i++) {
      list.add(new RoomSeat(i));
    }
    memberAdapter = new MemberAdapter(list);
    setAdapter(memberAdapter);
    memberAdapter.notifyDataSetChanged();
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(listener);
    NEVoiceRoomKit.getInstance()
        .getSeatInfo(
            new NEVoiceRoomCallback<NEVoiceRoomSeatInfo>() {

              @Override
              public void onSuccess(@Nullable NEVoiceRoomSeatInfo seatInfo) {
                if (seatInfo != null) {
                  handleSeatItemListChanged(seatInfo.getSeatItems());
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {}
            });
  }

  public List<String> getSelectUserUuid() {
    return memberAdapter.getSelectUserUuid();
  }

  @Override
  protected void onDetachedFromWindow() {
    super.onDetachedFromWindow();
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(listener);
  }

  private void handleSeatItemListChanged(List<NEVoiceRoomSeatItem> seatItems) {
    if (seatItems == null) seatItems = Collections.emptyList();
    List<RoomSeat> seats = SeatUtils.transNESeatItem2VoiceRoomSeat(seatItems);
    setData(seats);
  }

  public void setData(List<RoomSeat> seatList) {
    for (RoomSeat roomSeat : seatList) {
      if (!roomSeat.isOn()) {
        GiftHelper.getInstance().remove(roomSeat.getSeatIndex() - 1);
      }
    }
    memberAdapter.setData(seatList);
  }

  public void setActivityContext(Activity activity) {
    memberAdapter.setActivityContext(activity);
  }

  public static class MemberAdapter extends Adapter<ViewHolder> {
    private List<RoomSeat> list;
    private Activity activity;

    public MemberAdapter(List<RoomSeat> list) {
      this.list = list;
    }

    public void setActivityContext(Activity activity) {
      this.activity = activity;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
      return new MemberViewHolder(
          LayoutInflater.from(parent.getContext())
              .inflate(R.layout.view_item_select_member_send_gift, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
      MemberViewHolder memberViewHolder = (MemberViewHolder) holder;
      if (position == 0) {
        memberViewHolder.tv.setText(Utils.getApp().getString(R.string.host));
      } else {
        memberViewHolder.tv.setText(position + "");
      }
      RoomSeat roomSeat = list.get(position);
      memberViewHolder.ivAvatar.setImageBitmap(null);
      if (roomSeat != null && roomSeat.isOn() && roomSeat.getMember() != null) {
        memberViewHolder.ivAvatar.loadAvatar(list.get(position).getMember().getAvatar());
      } else {
        Bitmap bitmap =
            BitmapFactory.decodeResource(Utils.getApp().getResources(), R.drawable.seat_holder);
        memberViewHolder.ivAvatar.setImageBitmap(bitmap);
      }
      memberViewHolder.itemView.setOnClickListener(
          v -> {
            if (GiftHelper.getInstance().getSelectedSeatSet().contains(position)) {
              GiftHelper.getInstance().remove(position);
            } else {
              if (roomSeat != null && roomSeat.isOn() && roomSeat.getMember() != null) {
                GiftHelper.getInstance().add(position);
              }
            }
            notifyDataSetChanged();
          });
      if (GiftHelper.getInstance().getSelectedSeatSet().contains(position)) {
        memberViewHolder.tv.setTextColor(Color.parseColor("#337EFF"));
        memberViewHolder.ivSelectedBg.setVisibility(VISIBLE);
      } else {
        memberViewHolder.tv.setTextColor(Color.parseColor("#333333"));
        memberViewHolder.ivSelectedBg.setVisibility(GONE);
      }
    }

    @Override
    public int getItemCount() {
      return list.size();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void setData(List<RoomSeat> seatList) {
      this.list = seatList;
      notifyDataSetChanged();
    }

    public List<String> getSelectUserUuid() {
      ArrayList<String> userUuids = new ArrayList<>();
      for (Integer integer : GiftHelper.getInstance().getSelectedSeatSet()) {
        if (list.get(integer).getMember() != null && list.get(integer).isOn()) {
          userUuids.add(list.get(integer).getMember().getAccount());
        }
      }
      return userUuids;
    }
  }

  public static class MemberViewHolder extends ViewHolder {
    private TextView tv;
    private HeadImageView ivAvatar;
    private ImageView ivSelectedBg;

    public MemberViewHolder(@NonNull View itemView) {
      super(itemView);
      tv = itemView.findViewById(R.id.tv);
      ivAvatar = itemView.findViewById(R.id.iv_avatar);
      ivSelectedBg = itemView.findViewById(R.id.iv_selected_bg);
    }
  }
}

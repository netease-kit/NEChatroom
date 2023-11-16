// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.LinearLayout;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.BaseAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.SeatListAdapter;
import java.util.List;

/** 单排（横向）类型的座位列表 */
public class NESeatListView extends LinearLayout {

  protected RecyclerView recyclerView;

  protected SeatListAdapter seatAdapter;

  private BaseAdapter.ItemClickListener<RoomSeat> itemClickListener;

  public NESeatListView(Context context) {
    this(context, null);
  }

  public NESeatListView(Context context, @Nullable AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public NESeatListView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    LayoutInflater.from(context).inflate(R.layout.view_seat_list, this);
    initView();
  }

  private void initView() {
    recyclerView = findViewById(R.id.recyclerview_seat);
    recyclerView.setLayoutManager(
        new LinearLayoutManager(getContext(), RecyclerView.HORIZONTAL, false));
    seatAdapter = new SeatListAdapter(null, getContext());
    seatAdapter.setItemClickListener(
        new BaseAdapter.ItemClickListener<RoomSeat>() {
          @Override
          public void onItemClick(RoomSeat model, int position) {
            if (itemClickListener != null) {
              itemClickListener.onItemClick(model, position);
            }
          }
        });
    recyclerView.setAdapter(seatAdapter);
  }

  public void refresh() {
    if (seatAdapter != null) {
      seatAdapter.notifyDataSetChanged();
    }
  }

  public void refresh(List<RoomSeat> seats) {
    if (seatAdapter != null) {
      seatAdapter.setItems(seats);
      seatAdapter.notifyDataSetChanged();
    }
  }

  public void refreshItem(int index) {
    if (seatAdapter != null) {
      seatAdapter.notifyItemChanged(index);
    }
  }

  public List<RoomSeat> getItems() {
    return seatAdapter == null ? null : seatAdapter.getDataList();
  }

  public void setItemClickListener(BaseAdapter.ItemClickListener<RoomSeat> itemClickListener) {
    this.itemClickListener = itemClickListener;
  }
}

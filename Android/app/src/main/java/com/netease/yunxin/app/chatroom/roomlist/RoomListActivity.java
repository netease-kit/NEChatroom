// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.roomlist;

import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.activity.BaseActivity;
import com.netease.yunxin.app.chatroom.activity.CreateRoomActivity;
import com.netease.yunxin.app.chatroom.databinding.ActivityRoomListBinding;
import com.netease.yunxin.app.chatroom.roomlist.adapter.VoiceRoomListAdapter;
import com.netease.yunxin.app.chatroom.view.FooterView;
import com.netease.yunxin.app.chatroom.view.HeaderView;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomLiveState;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList;
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.IconFontUtil;
import com.scwang.smart.refresh.layout.api.RefreshLayout;
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener;
import com.scwang.smart.refresh.layout.listener.OnRefreshListener;

public class RoomListActivity extends BaseActivity
    implements OnRefreshListener, OnLoadMoreListener {

  private ActivityRoomListBinding binding;
  private int pageNum = 1;
  public static final int PAGE_SIZE = 20;
  public static final int SPAN_COUNT = 2;
  private int tempPageNum = 1;
  private VoiceRoomListAdapter adapter;
  private GridLayoutManager layoutManager;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityRoomListBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.getRoot());
    setEvent();
    init();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  private void setEvent() {
    binding.ivCreateRoom.setImageResource(R.drawable.icon_live_start);
    binding.ivBack.setOnClickListener(v -> finish());
    binding.ivCreateRoom.setOnClickListener(
        v -> {
          Intent intent = new Intent(this, CreateRoomActivity.class);
          startActivity(intent);
        });
    binding.refreshLayout.setRefreshHeader(new HeaderView(this));
    binding.refreshLayout.setRefreshFooter(new FooterView(this));
    binding.refreshLayout.setOnRefreshListener(this);
    binding.refreshLayout.setOnLoadMoreListener(this);
  }

  private void init() {
    adapter = new VoiceRoomListAdapter(this);
    layoutManager = new GridLayoutManager(this, SPAN_COUNT);
    layoutManager.setSpanSizeLookup(new MySpanSizeLookup());
    binding.rvRoomList.setAdapter(adapter);
    binding.rvRoomList.addItemDecoration(new MyItemDecoration());
    binding.rvRoomList.setLayoutManager(layoutManager);
    IconFontUtil.getInstance().setFontText(binding.roomListEmptyIcon, IconFontUtil.ROOM_LIST_EMPTY);
  }

  @Override
  protected void onResume() {
    super.onResume();
    refresh();
  }

  private void refresh() {
    tempPageNum = 1;
    NEVoiceRoomKit.getInstance()
        .getVoiceRoomList(
            NEVoiceRoomLiveState.Live,
            tempPageNum,
            PAGE_SIZE,
            new NEVoiceRoomCallback<NEVoiceRoomList>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomList neVoiceRoomList) {
                pageNum = tempPageNum;
                if (neVoiceRoomList.getList() == null || neVoiceRoomList.getList().isEmpty()) {
                  binding.emptyView.setVisibility(View.VISIBLE);
                  binding.rvRoomList.setVisibility(View.GONE);
                } else {
                  binding.emptyView.setVisibility(View.GONE);
                  binding.rvRoomList.setVisibility(View.VISIBLE);
                  adapter.refreshList(neVoiceRoomList.getList());
                }
                binding.refreshLayout.finishRefresh(true);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                tempPageNum = pageNum;
                binding.refreshLayout.finishRefresh(false);
              }
            });
  }

  private void loadMore() {
    tempPageNum++;
    NEVoiceRoomKit.getInstance()
        .getVoiceRoomList(
            NEVoiceRoomLiveState.Live,
            tempPageNum,
            PAGE_SIZE,
            new NEVoiceRoomCallback<NEVoiceRoomList>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomList neVoiceRoomList) {
                pageNum = tempPageNum;
                adapter.loadMore(neVoiceRoomList.getList());
                binding.refreshLayout.finishLoadMore(true);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                tempPageNum = pageNum;
                binding.refreshLayout.finishLoadMore(false);
              }
            });
  }

  @Override
  public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
    loadMore();
  }

  @Override
  public void onRefresh(@NonNull RefreshLayout refreshLayout) {
    refresh();
  }

  class MyItemDecoration extends RecyclerView.ItemDecoration {

    @Override
    public void getItemOffsets(
        @NonNull Rect outRect,
        @NonNull View view,
        @NonNull RecyclerView parent,
        @NonNull RecyclerView.State state) {
      int pixel8 = ScreenUtil.dip2px(8f);
      int pixel4 = ScreenUtil.dip2px(4f);
      int position = parent.getChildAdapterPosition(view);
      int left;
      int right;
      if (position % 2 == 0) {
        left = pixel8;
        right = pixel4;
      } else {
        left = pixel4;
        right = pixel8;
      }
      outRect.set(left, pixel4, right, pixel4);
    }
  }

  class MySpanSizeLookup extends GridLayoutManager.SpanSizeLookup {

    @Override
    public int getSpanSize(int position) {
      // 如果是空布局，让它占满一行
      if (adapter.isEmptyPosition(position)) {
        return layoutManager.getSpanCount();
      } else {
        return 1;
      }
    }
  }
}

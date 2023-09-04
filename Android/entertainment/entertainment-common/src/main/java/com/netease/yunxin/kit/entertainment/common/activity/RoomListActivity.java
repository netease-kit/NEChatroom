// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.adapter.RoomListAdapter;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivityRoomListBinding;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.api.RefreshLayout;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.listener.OnLoadMoreListener;
import com.netease.yunxin.kit.entertainment.common.smartrefresh.listener.OnRefreshListener;
import com.netease.yunxin.kit.entertainment.common.widget.FooterView;
import com.netease.yunxin.kit.entertainment.common.widget.HeaderView;

public abstract class RoomListActivity extends BaseActivity
    implements OnRefreshListener, OnLoadMoreListener {

  public static final int ROOM_MAX_AUDIENCE_COUNT = 1;
  protected ActivityRoomListBinding binding;
  protected int pageNum = 1;
  public static final int PAGE_SIZE = 20;
  public static final int SPAN_COUNT = 2;
  protected int tempPageNum = 1;
  protected RoomListAdapter adapter;
  private GridLayoutManager layoutManager;
  protected boolean isOversea = false;
  protected int configId;

  protected String userName;

  protected String avatar;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityRoomListBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.getRoot());
    isOversea = getIntent().getBooleanExtra(RoomConstants.INTENT_IS_OVERSEA, false);
    configId = getIntent().getIntExtra(RoomConstants.INTENT_KEY_CONFIG_ID, 0);
    userName = getIntent().getStringExtra(RoomConstants.INTENT_USER_NAME);
    avatar = getIntent().getStringExtra(RoomConstants.INTENT_AVATAR);
    init();
    setEvent();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  protected void setEvent() {
    binding.ivBack.setOnClickListener(v -> finish());
    binding.refreshLayout.setRefreshHeader(new HeaderView(this));
    binding.refreshLayout.setRefreshFooter(new FooterView(this));
    binding.refreshLayout.setOnRefreshListener(this);
    binding.refreshLayout.setOnLoadMoreListener(this);
  }

  private void init() {
    adapter = getRoomListAdapter();
    layoutManager = new GridLayoutManager(this, SPAN_COUNT);
    layoutManager.setSpanSizeLookup(new MySpanSizeLookup());
    binding.rvRoomList.setAdapter(adapter);
    binding.rvRoomList.addItemDecoration(new MyItemDecoration());
    binding.rvRoomList.setLayoutManager(layoutManager);
  }

  protected abstract RoomListAdapter getRoomListAdapter();

  @Override
  protected void onResume() {
    super.onResume();
    refresh();
  }

  protected void refresh() {
    tempPageNum = 1;
  }

  protected void loadMore() {
    tempPageNum++;
  }

  @Override
  public void onLoadMore(@NonNull RefreshLayout refreshLayout) {
    loadMore();
  }

  @Override
  public void onRefresh(@NonNull RefreshLayout refreshLayout) {
    refresh();
  }

  static class MyItemDecoration extends RecyclerView.ItemDecoration {

    @Override
    public void getItemOffsets(
        @NonNull Rect outRect,
        @NonNull View view,
        @NonNull RecyclerView parent,
        @NonNull RecyclerView.State state) {
      int pixel8 = SizeUtils.dp2px(8f);
      int pixel4 = SizeUtils.dp2px(4f);
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

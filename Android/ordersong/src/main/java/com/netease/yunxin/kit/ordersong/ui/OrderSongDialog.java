// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.netease.yunxin.kit.common.ui.adapter.BaseFragmentAdapter;
import com.netease.yunxin.kit.common.utils.ScreenUtils;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongListener;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.ui.base.BaseBottomDialogFragment;
import com.netease.yunxin.kit.ordersong.ui.fragment.OrderListFragment;
import com.netease.yunxin.kit.ordersong.ui.fragment.OrderedListFragment;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** 已点歌单dialog */
public class OrderSongDialog extends BaseBottomDialogFragment {

  OrderListFragment orderFragment;
  OrderedListFragment orderedFragment;
  private TabLayoutMediator mediator;
  private TabLayout.Tab tabToOrder;
  private TabLayout.Tab tabOrdered;
  private TabLayout tabLayout;
  private ViewPager2 viewPager;
  private OrderSongViewModel orderSongViewModel;
  private int volume = 100;
  private String roomUuid = null;
  private final NEOrderSongListener orderSongListener =
      new NEOrderSongListener() {

        @Override
        public void onSongOrdered(Song song) {}

        @Override
        public void onSongDeleted(Song song) {}

        @Override
        public void onOrderedSongListChanged() {
          orderSongViewModel.refreshOrderedSongs();
        }

        @Override
        public void onSongSwitched(Song song) {}

        @Override
        public void onSongStarted(Song song) {
          orderSongViewModel.refreshOrderedSongs();
        }

        @Override
        public void onSongPaused(Song song) {}

        @Override
        public void onSongResumed(Song song) {}
      };

  public OrderSongDialog(int volume) {
    this.volume = volume;
  }

  @Override
  protected int getResourceLayout() {
    return R.layout.dialog_ordered_music_layout;
  }

  @SuppressLint("StringFormatInvalid")
  @Override
  protected void initView(View rootView) {
    orderSongViewModel = new ViewModelProvider(requireActivity()).get(OrderSongViewModel.class);
    List<Fragment> fragments = new ArrayList<>();
    orderFragment = new OrderListFragment();
    orderedFragment = new OrderedListFragment();
    Bundle arguments = new Bundle();
    arguments.putInt(OrderedListFragment.VOLUME, volume);
    orderedFragment.setArguments(arguments);
    fragments.add(orderFragment);
    fragments.add(orderedFragment);

    tabLayout = rootView.findViewById(R.id.tabLayout);

    tabToOrder = tabLayout.newTab();
    tabToOrder.setText(getString(R.string.tab_to_order));
    tabOrdered = tabLayout.newTab();
    tabOrdered.setText(getString(R.string.tab_ordered, 0));
    tabLayout.addTab(tabOrdered);
    tabLayout.addTab(tabToOrder);

    viewPager = ((ViewPager2) (rootView.findViewById(R.id.viewPager)));

    BaseFragmentAdapter fragmentAdapter = new BaseFragmentAdapter(this);
    fragmentAdapter.setFragmentList(fragments);
    viewPager.setAdapter(fragmentAdapter);
    viewPager.setOffscreenPageLimit(1);
    mediator =
        new TabLayoutMediator(
            tabLayout,
            viewPager,
            (tab, position) -> {
              switch (position) {
                case 0:
                  tab.setText(getString(R.string.tab_to_order));
                  break;
                case 1:
                  tab.setText(getString(R.string.tab_ordered, 0));
                  break;
                default:
                  break;
              }
            });

    mediator.attach();
  }

  @Override
  protected void initIntent() {}

  @SuppressLint("StringFormatInvalid")
  @Override
  protected void initData() {
    orderSongViewModel
        .getOrderSongListChangeEvent()
        .observe(
            getViewLifecycleOwner(),
            orderSongs -> {
              Objects.requireNonNull(tabLayout.getTabAt(1))
                  .setText(getString(R.string.tab_ordered, orderSongs.size()));
            });

    orderSongViewModel
        .getPerformOrderSongEvent()
        .observe(
            getViewLifecycleOwner(),
            orderSongModel -> {
              orderSongViewModel.getPerformDownloadSongEvent().postValue(orderSongModel);
            });

    NEOrderSongService.INSTANCE.addListener(orderSongListener);
  }

  @Override
  protected void initParams() {
    Window window = getDialog().getWindow();
    if (window != null) {
      window.setBackgroundDrawableResource(R.drawable.shape_utils_dialog_bg);

      WindowManager.LayoutParams params = window.getAttributes();
      params.gravity = Gravity.BOTTOM;
      // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
      params.width = ViewGroup.LayoutParams.MATCH_PARENT;
      params.height = ScreenUtils.getDisplayHeight() * 3 / 4;
      window.setAttributes(params);
    }
    setCancelable(true); //设置点击外部是否消失
  }

  /** 跳转到已点歌曲 */
  private void goBack() {
    dismiss();
  }

  @Override
  public void onDestroy() {
    NEOrderSongService.INSTANCE.removeListener(orderSongListener);
    super.onDestroy();
  }
}

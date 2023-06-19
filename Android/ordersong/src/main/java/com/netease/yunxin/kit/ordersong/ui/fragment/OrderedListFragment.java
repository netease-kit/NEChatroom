// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import com.netease.yunxin.kit.common.ui.fragments.BaseFragment;
import com.netease.yunxin.kit.ordersong.ui.adapter.OrderedAdapter;
import com.netease.yunxin.kit.ordersong.ui.databinding.OrderedListLayoutBinding;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;

/** chat message read state page */
public class OrderedListFragment extends BaseFragment {
  private OrderedListLayoutBinding binding;
  private OrderedAdapter adapter;
  private OrderSongViewModel orderSongViewModel;
  private static final String TAG = "OrderedListFragment";
  public static final String VOLUME = "volume";

  @Nullable
  @Override
  public View onCreateView(
      @NonNull LayoutInflater inflater,
      @Nullable ViewGroup container,
      @Nullable Bundle savedInstanceState) {
    orderSongViewModel = new ViewModelProvider(requireActivity()).get(OrderSongViewModel.class);
    binding = OrderedListLayoutBinding.inflate(inflater, container, false);
    Bundle arguments = getArguments();
    if (arguments != null) {
      binding.songOptionView.setVolume(arguments.getInt(VOLUME, 100));
    }
    initView();
    refresh();
    return binding.getRoot();
  }

  @Override
  public void onResume() {
    super.onResume();
    refresh();
  }

  private void initView() {
    binding.songOptionView.setViewModel(orderSongViewModel);
    LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
    binding.recyclerView.setLayoutManager(layoutManager);
    adapter = new OrderedAdapter(orderSongViewModel);
    binding.recyclerView.setAdapter(adapter);
    adapter.setItemClickListener(
        (item, position) -> orderSongViewModel.getSwitchSongEvent().postValue(item));

    orderSongViewModel
        .getOrderSongListChangeEvent()
        .observe(
            getViewLifecycleOwner(),
            orderSongs -> {
              if (orderSongs != null && !orderSongs.isEmpty()) {
                binding.recyclerView.setVisibility(View.VISIBLE);
                binding.llyEmpty.setVisibility(View.GONE);
                adapter.refresh(orderSongs);
                binding.songOptionView.setVisibility(View.VISIBLE);
              } else {
                binding.recyclerView.setVisibility(View.GONE);
                binding.llyEmpty.setVisibility(View.VISIBLE);
                binding.songOptionView.setVisibility(View.INVISIBLE);
              }
            });
    orderSongViewModel
        .getRefreshOrderedListEvent()
        .observe(getViewLifecycleOwner(), aBoolean -> refresh());
  }

  private void refresh() {
    orderSongViewModel.refreshOrderSongs();
  }
}

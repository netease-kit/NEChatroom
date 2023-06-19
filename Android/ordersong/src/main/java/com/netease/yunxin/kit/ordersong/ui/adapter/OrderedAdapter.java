// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.adapter;

import static com.netease.yunxin.kit.ordersong.core.model.NEOrderSongStatus.STATUS_SINGING;
import static com.netease.yunxin.kit.ordersong.core.model.NEOrderSongStatus.STATUS_WAIT;

import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.common.ui.activities.adapter.CommonMoreAdapter;
import com.netease.yunxin.kit.common.ui.activities.viewholder.BaseMoreViewHolder;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.ui.widgets.datepicker.DateFormatUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.copyrightedmedia.api.NECopyrightedMedia;
import com.netease.yunxin.kit.ordersong.core.model.NEOrderSong;
import com.netease.yunxin.kit.ordersong.ui.R;
import com.netease.yunxin.kit.ordersong.ui.databinding.OrderedItemLayoutBinding;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;
import java.util.Locale;

/** 歌曲列表适配器 */
public class OrderedAdapter extends CommonMoreAdapter<NEOrderSong, OrderedItemLayoutBinding> {
  private OrderSongViewModel orderSongViewModel;

  public OrderedAdapter(OrderSongViewModel orderSongViewModel) {
    this.orderSongViewModel = orderSongViewModel;
  }

  @NonNull
  @Override
  public BaseMoreViewHolder<NEOrderSong, OrderedItemLayoutBinding> getViewHolder(
      @NonNull ViewGroup parent, int viewType) {
    OrderedItemLayoutBinding binding =
        OrderedItemLayoutBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
    return new OrderedItemViewHolder(binding);
  }

  public class OrderedItemViewHolder
      extends BaseMoreViewHolder<NEOrderSong, OrderedItemLayoutBinding> {

    public OrderedItemViewHolder(@NonNull OrderedItemLayoutBinding binding) {
      super(binding);
    }

    @Override
    public void bind(NEOrderSong item) {
      getBinding().songCover.setCornerRadius(SizeUtils.dp2px(5));
      if (item.getOrderSong().getStatus() == STATUS_SINGING) {
        getBinding().songOrder.setVisibility(View.GONE);
        getBinding().songSinging.setVisibility(View.VISIBLE);
        getBinding().musicIcon.setVisibility(View.VISIBLE);
      } else if (item.getOrderSong().getStatus() == STATUS_WAIT) {
        getBinding().songOrder.setVisibility(View.VISIBLE);
        getBinding().songSinging.setVisibility(View.INVISIBLE);
        getBinding().musicIcon.setVisibility(View.INVISIBLE);
      } else {
        getBinding().songOrder.setVisibility(View.VISIBLE);
        getBinding().songSinging.setVisibility(View.INVISIBLE);
        getBinding().musicIcon.setVisibility(View.INVISIBLE);
      }
      getBinding().orderCancel.setVisibility(View.VISIBLE);
      getBinding()
          .orderCancel
          .setOnClickListener(
              v -> {
                getDataList().remove(item);
                notifyDataSetChanged();
                deleteSong(v, item.getOrderSong().getOrderId());
              });
      getBinding()
          .songOrder
          .setText(String.format(Locale.CHINA, "%02d", getBindingAdapterPosition() + 1));
      if (TextUtils.isEmpty(item.getOrderSong().getSongCover())) {
        getBinding().songCover.setData(R.drawable.icon_song_cover, "");
      } else {
        getBinding().songCover.setData(item.getOrderSong().getSongCover(), "");
      }

      getBinding().songName.setText(item.getOrderSong().getSongName());
      if (TextUtils.isEmpty(item.getOrderSongUser().getIcon())) {
        getBinding().userAvatar.setData(R.drawable.default_avatar, "");
      } else {
        getBinding().userAvatar.setData(item.getOrderSongUser().getIcon(), "");
      }

      getBinding().songName.setText(item.getOrderSong().getSongName());
      getBinding().userName.setText(item.getOrderSongUser().getUserName());
      getBinding().songSize.setText(DateFormatUtils.long2StrHS(item.getOrderSong().getSongTime()));
    }
  }

  public void deleteSong(View view, long orderId) {
    orderSongViewModel.deleteSong(
        orderId,
        new NECopyrightedMedia.Callback<Boolean>() {
          @Override
          public void success(@Nullable Boolean info) {}

          @Override
          public void error(int code, @Nullable String msg) {
            if (code == -1) {
              ToastUtils.INSTANCE.showShortToast(
                  view.getContext(), view.getContext().getString(R.string.singing_network_error));
            }
          }
        });
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.gift;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.R;
import java.util.Arrays;
import java.util.List;

public class GiftNumSelectView2 extends RecyclerView {
  public interface GiftNumSelectCallback {
    void giftCountSelect(int giftCount);
  }

  public void setGiftNumSelectCallback(GiftNumSelectCallback giftNumSelectCallback) {
    this.giftNumSelectCallback = giftNumSelectCallback;
  }

  private GiftNumSelectCallback giftNumSelectCallback;
  private final List<Integer> list = Arrays.asList(1314, 520, 66, 20, 6, 1);

  public GiftNumSelectView2(@NonNull Context context) {
    super(context);
    init(context);
  }

  public GiftNumSelectView2(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public GiftNumSelectView2(
      @NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  @SuppressLint("NotifyDataSetChanged")
  private void init(Context context) {
    setLayoutManager(new LinearLayoutManager(context));
    addItemDecoration(
        new ItemDecoration() {
          @Override
          public void getItemOffsets(
              @NonNull Rect outRect,
              @NonNull View view,
              @NonNull RecyclerView parent,
              @NonNull State state) {
            if (parent.getChildAdapterPosition(view) == 0) {
              outRect.set(0, SizeUtils.dp2px(20f), 0, 0);
            } else {
              outRect.set(0, SizeUtils.dp2px(6f), 0, 0);
            }
          }
        });
    GiftNumberSelectAdapter giftNumberSelectAdapter = new GiftNumberSelectAdapter(list);
    setAdapter(giftNumberSelectAdapter);
    giftNumberSelectAdapter.notifyDataSetChanged();
    giftNumberSelectAdapter.setCallback(
        giftCount -> {
          if (giftNumSelectCallback != null) {
            giftNumSelectCallback.giftCountSelect(giftCount);
          }
        });
  }

  public static class GiftNumberSelectAdapter extends Adapter<ViewHolder> {
    private List<Integer> list;
    private int selectedPosition = 5;

    public void setCallback(GiftNumSelectCallback callback) {
      this.callback = callback;
    }

    private GiftNumSelectCallback callback;

    public GiftNumberSelectAdapter(List<Integer> list) {
      this.list = list;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
      return new GiftNumberSelectHolder(
          LayoutInflater.from(parent.getContext())
              .inflate(R.layout.view_item_gift_num_select, parent, false));
    }

    @Override
    public void onBindViewHolder(
        @NonNull ViewHolder holder, @SuppressLint("RecyclerView") int position) {
      GiftNumberSelectHolder giftNumberSelectHolder = (GiftNumberSelectHolder) holder;
      giftNumberSelectHolder.tv.setText(list.get(position) + "");
      if (selectedPosition == position) {
        giftNumberSelectHolder.tv.setTextColor(Color.parseColor("#337EFF"));
        giftNumberSelectHolder.tv.setBackgroundResource(R.drawable.gift_num_selected2);
      } else {
        giftNumberSelectHolder.tv.setTextColor(Color.parseColor("#333333"));
        giftNumberSelectHolder.tv.setBackgroundResource(R.drawable.gift_num_unselected);
      }
      giftNumberSelectHolder.itemView.setOnClickListener(
          v -> {
            selectedPosition = position;
            notifyDataSetChanged();
            if (callback != null) {
              callback.giftCountSelect(list.get(position));
            }
          });
    }

    @Override
    public int getItemCount() {
      return list.size();
    }

    public interface GiftNumSelectCallback {
      void giftCountSelect(int giftCount);
    }
  }

  public static class GiftNumberSelectHolder extends ViewHolder {
    private TextView tv;

    public GiftNumberSelectHolder(@NonNull View itemView) {
      super(itemView);
      tv = itemView.findViewById(R.id.tv);
    }
  }
}

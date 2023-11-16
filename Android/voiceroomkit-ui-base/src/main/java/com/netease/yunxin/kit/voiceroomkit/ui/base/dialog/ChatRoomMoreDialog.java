// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.app.Activity;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.LiveBaseAdapter;
import java.util.ArrayList;
import java.util.List;

/** 主播端底部更多弹窗 */
public class ChatRoomMoreDialog extends BottomBaseDialog {
  private final List<MoreItem> itemList;
  protected OnItemClickListener clickListener;
  private LiveBaseAdapter adapter;

  public ChatRoomMoreDialog(@NonNull Activity activity, List<MoreItem> itemList) {
    super(activity);
    this.itemList = new ArrayList<>(itemList.size());
    for (MoreItem item : itemList) {
      if (item == null || !item.visible) {
        continue;
      }
      this.itemList.add(item);
    }
    createAdapter();
  }

  public ChatRoomMoreDialog registerOnItemClickListener(OnItemClickListener listener) {
    this.clickListener = listener;
    return this;
  }

  public void updateData() {
    if (adapter != null) {
      adapter.notifyDataSetChanged();
    }
  }

  private void createAdapter() {
    adapter =
        new LiveBaseAdapter<MoreItem>(getContext(), itemList) {

          @Override
          protected int getLayoutId(int viewType) {
            return R.layout.view_item_dialog_bottom_more;
          }

          @Override
          protected LiveViewHolder onCreateViewHolder(View itemView) {
            return new LiveViewHolder(itemView);
          }

          @Override
          protected void onBindViewHolder(LiveViewHolder holder, MoreItem itemData) {
            ImageView ivIcon = holder.getView(R.id.iv_item_icon);
            ivIcon.setImageResource(itemData.iconResId);
            ivIcon.setEnabled(itemData.enable);

            TextView tvName = holder.getView(R.id.tv_item_name);
            tvName.setText(itemData.name);

            holder.itemView.setOnClickListener(
                v -> {
                  if (clickListener != null) {
                    clickListener.onItemClick(ChatRoomMoreDialog.this, v, itemData);
                  }
                });
          }
        };
  }

  @Override
  protected void renderTopView(FrameLayout parent) {
    TextView titleView = new TextView(getContext());
    titleView.setText(getContext().getString(R.string.voiceroom_more));
    titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
    titleView.setGravity(Gravity.CENTER);
    titleView.setTextColor(Color.parseColor("#ff333333"));
    FrameLayout.LayoutParams layoutParams =
        new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    parent.addView(titleView, layoutParams);
  }

  @Override
  protected void renderBottomView(FrameLayout parent) {
    RecyclerView rvList = new RecyclerView(getContext());
    rvList.setPadding(0, 0, 0, SizeUtils.dp2px(10));
    rvList.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
    FrameLayout.LayoutParams layoutParams =
        new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    parent.addView(rvList, layoutParams);

    rvList.setLayoutManager(new GridLayoutManager(getContext(), 4));
    rvList.setAdapter(adapter);
  }

  public static class MoreItem {
    public int id;
    public int iconResId;
    public String name;
    public boolean enable = true;
    public boolean visible = true;

    public MoreItem(int id, int iconResId, String name) {
      this.id = id;
      this.iconResId = iconResId;
      this.name = name;
    }

    public MoreItem setEnable(boolean enable) {
      this.enable = enable;
      return this;
    }

    public MoreItem setVisible(boolean visible) {
      this.visible = visible;
      return this;
    }
  }

  public interface OnItemClickListener {
    boolean onItemClick(ChatRoomMoreDialog dialog, View itemView, MoreItem item);
  }
}

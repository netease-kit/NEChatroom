// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.adapter;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import java.util.List;

public class FunctionAdapter extends CommonAdapter<FunctionAdapter.FunctionItem> {
  public static final int TYPE_VIEW_TITLE = 0;
  public static final int TYPE_VIEW_CONTENT = 1;

  public FunctionAdapter(Context context, List<FunctionItem> dataSource) {
    super(context, dataSource);
  }

  @Override
  public int getItemViewType(int position) {
    return getItem(position).type;
  }

  @Override
  protected int getLayoutId(int viewType) {
    int layoutId;
    if (viewType == TYPE_VIEW_CONTENT) {
      layoutId = R.layout.view_item_function;
    } else {
      layoutId = R.layout.view_item_function_title;
    }
    return layoutId;
  }

  @Override
  protected ItemViewHolder onCreateViewHolder(View itemView, int viewType) {
    return new ItemViewHolder(itemView);
  }

  @Override
  protected void onBindViewHolder(ItemViewHolder holder, FunctionItem itemData) {
    if (itemData.type == TYPE_VIEW_TITLE) {
      TextView tvName = holder.getView(R.id.tv_title_name);
      tvName.setText(itemData.nameStr);
      return;
    }
    ImageView icon = holder.getView(R.id.iv_function_icon);
    ImageLoader.with(icon.getContext().getApplicationContext()).load(itemData.iconResId).into(icon);
    TextView tvName = holder.getView(R.id.tv_function_name);
    tvName.setText(itemData.nameStr);
    TextView tvDesc = holder.getView(R.id.tv_function_desc);
    tvDesc.setText(itemData.descStr);
    holder.itemView.setOnClickListener(
        v -> {
          if (itemData.action != null) {
            itemData.action.run();
          }
        });
  }

  public static class FunctionItem {
    public int type = TYPE_VIEW_CONTENT;

    public final int iconResId;

    public final String nameStr;

    public final String descStr;

    public final Runnable action;

    public FunctionItem(int type, String nameStr) {
      this.type = type;
      this.nameStr = nameStr;
      this.iconResId = -1;
      this.action = null;
      this.descStr = null;
    }

    public FunctionItem(int iconResId, String nameStr, Runnable action) {
      this(iconResId, nameStr, null, action);
    }

    public FunctionItem(int iconResId, String nameStr, String descStr, Runnable action) {
      this.iconResId = iconResId;
      this.nameStr = nameStr;
      this.descStr = descStr;
      this.action = action;
    }
  }
}

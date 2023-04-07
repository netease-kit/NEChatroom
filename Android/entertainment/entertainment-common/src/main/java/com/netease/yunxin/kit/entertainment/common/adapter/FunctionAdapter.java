// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.adapter;

import android.content.Context;
import android.view.View;
import android.widget.TextView;
import com.airbnb.lottie.LottieAnimationView;
import com.netease.yunxin.kit.entertainment.common.R;
import java.util.List;

public class FunctionAdapter extends CommonAdapter<FunctionAdapter.FunctionItem> {
  public static final int TYPE_VIEW_TITLE = 0;
  public static final int TYPE_VIEW_CONTENT = 1;

  public FunctionAdapter(Context context, List<FunctionItem> dataSource) {
    super(context, dataSource);
  }

  @Override
  protected int getLayoutId(int viewType) {
    return R.layout.view_item_function;
  }

  @Override
  protected ItemViewHolder onCreateViewHolder(View itemView, int viewType) {
    return new ItemViewHolder(itemView);
  }

  @Override
  protected void onBindViewHolder(ItemViewHolder holder, FunctionItem itemData) {
    //    holder.getView(R.id.rl_root).setBackgroundResource(itemData.bgResId);

    LottieAnimationView lottieAnimationView = holder.getView(R.id.lav_lottie_view);
    if (lottieAnimationView != null) {
      lottieAnimationView.setBackgroundResource(itemData.bgResId);
      lottieAnimationView.setAnimation(itemData.bgLottieResId);
    }

    TextView tvName = holder.getView(R.id.tv_function_name);
    if (tvName != null) {
      tvName.setText(itemData.nameStr);
    }
    TextView tvDesc = holder.getView(R.id.tv_function_desc);
    if (tvDesc != null) {
      tvDesc.setText(itemData.descStr);
      holder.itemView.setOnClickListener(
          v -> {
            if (itemData.action != null) {
              itemData.action.run();
            }
          });
    }
  }

  public static class FunctionItem {
    public final String nameStr;

    public final String descStr;

    public final int bgResId;

    public final int bgLottieResId;

    public final Runnable action;

    public FunctionItem(String nameStr) {
      this(nameStr, null);
    }

    public FunctionItem(String nameStr, Runnable action) {
      this(nameStr, null, action);
    }

    public FunctionItem(String nameStr, String descStr, Runnable action) {
      this(nameStr, descStr, 0, 0, action);
    }

    public FunctionItem(
        String nameStr, String descStr, int bgResId, int bgLottieResId, Runnable action) {
      this.nameStr = nameStr;
      this.descStr = descStr;
      this.bgResId = bgResId;
      this.bgLottieResId = bgLottieResId;
      this.action = action;
    }
  }
}

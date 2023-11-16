// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil;
import java.util.ArrayList;
import java.util.List;

/** 选择房间背景 */
public class SelectRoomBgView extends RecyclerView {
  private BgAdapter bgAdapter;

  public SelectRoomBgView(@NonNull Context context) {
    super(context);
    init(context);
  }

  public SelectRoomBgView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context);
  }

  public SelectRoomBgView(
      @NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context);
  }

  private void init(Context context) {
    setLayoutManager(new GridLayoutManager(context, 2));
    bgAdapter = new BgAdapter();
    setAdapter(bgAdapter);
    addItemDecoration(
        new ItemDecoration() {
          @Override
          public void getItemOffsets(
              @NonNull Rect outRect,
              @NonNull View view,
              @NonNull RecyclerView parent,
              @NonNull State state) {
            super.getItemOffsets(outRect, view, parent, state);
            if (parent.getChildAdapterPosition(view) % 2 == 0) {
              outRect.left = SizeUtils.dp2px(20);
              outRect.right = SizeUtils.dp2px(5.5f);
            } else {
              outRect.left = SizeUtils.dp2px(5.5f);
              outRect.right = SizeUtils.dp2px(20);
            }
            outRect.bottom = SizeUtils.dp2px(11);
          }
        });
  }

  public void setData(List<String> list) {
    bgAdapter.setData(list);
  }

  public void setOnSelectBgListener(OnSelectBgListener listener) {
    bgAdapter.setOnSelectBgListener(listener);
  }

  public String getSelectBg() {
    return bgAdapter.getSelectBg();
  }

  public static class BgAdapter extends Adapter<BgViewHolder> {
    private List<String> list = new ArrayList<>();
    private OnSelectBgListener listener;
    private int selectPosition = 0;

    public void setOnSelectBgListener(OnSelectBgListener listener) {
      this.listener = listener;
    }

    public void setData(List<String> list) {
      this.list = list;
      notifyDataSetChanged();
    }

    @NonNull
    @Override
    public BgViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
      return new BgViewHolder(
          LayoutInflater.from(parent.getContext())
              .inflate(R.layout.ec_item_room_bg, parent, false));
    }

    @Override
    public void onBindViewHolder(
        @NonNull BgViewHolder holder, @SuppressLint("RecyclerView") int position) {
      String bgItem = list.get(position);
      ImageLoader.with(holder.itemView.getContext()).load(bgItem).into(holder.ivBg);
      holder.iv.setVisibility(selectPosition == position ? View.VISIBLE : View.GONE);
      holder.ivStroke.setVisibility(selectPosition == position ? View.VISIBLE : View.GONE);
      ViewGroup.LayoutParams layoutParams = holder.itemView.getLayoutParams();
      layoutParams.width = (ScreenUtil.getDisplayWidth() - SizeUtils.dp2px(51)) / 2;
      layoutParams.height = layoutParams.width;
      holder.itemView.setLayoutParams(layoutParams);
      holder.itemView.setOnClickListener(
          v -> {
            selectPosition = position;
            notifyDataSetChanged();
            if (listener != null) {
              listener.onSelectBg(bgItem);
            }
          });
    }

    @Override
    public int getItemCount() {
      return list.size();
    }

    public String getSelectBg() {
      return list.get(selectPosition);
    }
  }

  public static class BgViewHolder extends ViewHolder {
    private ImageView ivBg;
    private ImageView iv;
    private ImageView ivStroke;

    public BgViewHolder(@NonNull View itemView) {
      super(itemView);
      ivBg = itemView.findViewById(R.id.iv_bg);
      iv = itemView.findViewById(R.id.iv);
      ivStroke = itemView.findViewById(R.id.iv_stroke);
    }
  }

  public interface OnSelectBgListener {
    void onSelectBg(String cover);
  }
}

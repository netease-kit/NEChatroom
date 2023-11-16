// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.adapter;

import android.content.Context;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public abstract class CommonAdapter<T> extends RecyclerView.Adapter<CommonAdapter.ItemViewHolder> {
  private Context context;
  private List<T> dataSource;

  public CommonAdapter(Context context, List<T> dataSource) {
    this.context = context;
    this.dataSource = new ArrayList<>(dataSource);
  }

  @NonNull
  @Override
  public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
    return onCreateViewHolder(
        LayoutInflater.from(context).inflate(getLayoutId(viewType), parent, false), viewType);
  }

  protected abstract int getLayoutId(int viewType);

  protected abstract ItemViewHolder onCreateViewHolder(View itemView, int viewType);

  protected abstract void onBindViewHolder(ItemViewHolder holder, T itemData);

  @Override
  public int getItemCount() {
    if (dataSource != null) {
      return dataSource.size();
    } else {
      return 0;
    }
  }

  @Override
  public void onBindViewHolder(@NonNull ItemViewHolder holder, int position) {
    T itemData = getItem(position);
    if (itemData == null) {
      return;
    }
    onBindViewHolder(holder, itemData);
  }

  protected T getItem(int position) {
    if (position < 0 || position >= getItemCount()) {
      return null;
    } else {
      return dataSource.get(position);
    }
  }

  public static class ItemViewHolder extends RecyclerView.ViewHolder {
    private SparseArray<View> viewCache = new SparseArray<>();

    public ItemViewHolder(@NonNull View itemView) {
      super(itemView);
    }

    @SuppressWarnings("unchecked")
    public <T extends View> T getView(int viewId) {
      View view = viewCache.get(viewId);
      if (view == null) {
        view = itemView.findViewById(viewId);
        viewCache.put(viewId, view);
      }
      return (T) view;
    }
  }
}

package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

public abstract class CommonAdapter<T> extends RecyclerView.Adapter<CommonAdapter.ItemViewHolder> {
    protected List<T> dataSource;
    protected Context context;

    public CommonAdapter(Context context, List<T> dataSource) {
        this.context = context;
        this.dataSource = new ArrayList<>(dataSource);
    }

    @NonNull
    @Override
    public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return onCreateViewHolder(LayoutInflater.from(context).inflate(getLayoutId(viewType), parent, false), viewType);
    }

    protected abstract int getLayoutId(int viewType);

    protected abstract ItemViewHolder onCreateViewHolder(View itemView, int viewType);

    @Override
    public void onBindViewHolder(@NonNull ItemViewHolder holder, int position) {
        T itemData = getItem(position);
        if (itemData == null) {
            return;
        }
        onBindViewHolder(holder, itemData);
    }

    protected abstract void onBindViewHolder(ItemViewHolder holder, T itemData);

    @Override
    public int getItemCount() {
        return dataSource != null ? dataSource.size() : 0;
    }

    protected T getItem(int position) {
        if (position < 0 || position >= getItemCount()) {
            return null;
        }
        return dataSource.get(position);
    }

    public static class ItemViewHolder extends RecyclerView.ViewHolder {
        private SparseArray<View> viewCache = new SparseArray<>();

        public ItemViewHolder(@NonNull View itemView) {
            super(itemView);
        }

        @SuppressWarnings("unchecked")
        public <T extends View> T getView(int viewId) {
            View result = viewCache.get(viewId);
            if (result == null) {
                result = itemView.findViewById(viewId);
                viewCache.put(viewId, result);
            }
            return (T) result;
        }
    }
}

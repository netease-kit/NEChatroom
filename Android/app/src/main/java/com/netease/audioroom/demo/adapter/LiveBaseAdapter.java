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

public abstract class LiveBaseAdapter<T> extends RecyclerView.Adapter<LiveBaseAdapter.LiveViewHolder> {
    protected final List<T> dataSource = new ArrayList<>();
    protected final Context context;

    public LiveBaseAdapter(Context context) {
        this.context = context;
    }

    public LiveBaseAdapter(Context context, List<T> dataSource) {
        this.context = context;
        if (dataSource != null) {
            this.dataSource.addAll(dataSource);
        }
    }

    @NonNull
    @Override
    public LiveViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return onCreateViewHolder(LayoutInflater.from(context).inflate(getLayoutId(viewType), parent, false));
    }

    protected abstract int getLayoutId(int viewType);

    protected abstract LiveViewHolder onCreateViewHolder(View itemView);

    @Override
    public void onBindViewHolder(@NonNull LiveViewHolder holder, int position) {
        T itemData = getItem(position);
        if (itemData == null) {
            return;
        }
        onBindViewHolder(holder, itemData, position);
    }

    protected void onBindViewHolder(LiveViewHolder holder, T itemData, int position) {
        onBindViewHolder(holder, itemData);
    }

    protected void onBindViewHolder(LiveViewHolder holder, T itemData) {

    }

    public void updateDataSource(List<T> newDataSource) {
        this.dataSource.clear();
        if (newDataSource != null && !newDataSource.isEmpty()) {
            this.dataSource.addAll(newDataSource);
        }
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        return dataSource.size();
    }

    protected T getItem(int position) {
        if (position < 0 || position >= getItemCount()) {
            return null;
        }
        return dataSource.get(position);
    }

    public static class LiveViewHolder extends RecyclerView.ViewHolder {
        private final SparseArray<View> viewCache = new SparseArray<>();

        public LiveViewHolder(@NonNull View itemView) {
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

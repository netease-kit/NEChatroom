package com.netease.audioroom.demo.base.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.audioroom.demo.R;

import java.util.ArrayList;
import java.util.List;

public abstract class BaseAdapter<T> extends RecyclerView.Adapter {

    public static final int TYPE_HEADER = 0;
    public static final int TYPE_NORMAL = 1;

    private final List<T> dataList;
    protected Context context;
    protected LayoutInflater layoutInflater;

    private View mHeaderView;

    private ItemClickListener<T> itemClickListener;
    private ItemLongClickListener<T> itemLongClickListener;


    private View.OnClickListener clickListenerInner = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            onClickInner(view);
        }
    };

    private View.OnLongClickListener longClickListenerInner = new View.OnLongClickListener() {
        @Override
        public boolean onLongClick(View view) {

            return onLongClickInner(view);
        }
    };


    private void onClickInner(View itemView) {
        if (itemClickListener == null) {
            return;
        }
        T model = (T) itemView.getTag(R.id.base_adapter_model_tag);
        int position = (int) itemView.getTag(R.id.base_adapter_position_tag);
        itemClickListener.onItemClick(model, position);

    }

    private boolean onLongClickInner(View itemView) {
        if (itemLongClickListener == null) {
            return false;
        }
        T model = (T) itemView.getTag(R.id.base_adapter_model_tag);
        int position = (int) itemView.getTag(R.id.base_adapter_position_tag);
        return itemLongClickListener.onItemLongClick(model, position);
    }


    public BaseAdapter(List<T> dataList, Context context) {
        if (dataList == null) {
            dataList = new ArrayList<>();
        }
        this.dataList = dataList;
        this.context = context;
        this.layoutInflater = LayoutInflater.from(context);
    }

    @NonNull
    @Override
    public final RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RecyclerView.ViewHolder viewHolder = onCreateBaseViewHolder(parent, viewType);

        viewHolder.itemView.setOnClickListener(clickListenerInner);
        viewHolder.itemView.setOnLongClickListener(longClickListenerInner);
        return viewHolder;
    }


    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        onBindBaseViewHolder(holder, position);
        holder.itemView.setTag(R.id.base_adapter_model_tag, dataList.get(position));
        holder.itemView.setTag(R.id.base_adapter_position_tag, position);
    }


    @Override
    public int getItemCount() {
        return dataList.size();
    }


    @Nullable
    public final T getItem(int position) {
        if (position < 0 || position >= dataList.size()) {
            return null;
        }

        return dataList.get(position);
    }

    public final void setItems(List<T> newDataList) {
        if (newDataList == null) {
            return;
        }
        dataList.clear();
        dataList.addAll(newDataList);
        notifyDataSetChanged();
    }


    public final void appendItem(T model) {
        if (model == null) {
            return;
        }
        dataList.add(model);
        notifyItemInserted(dataList.size() - 1);
    }


    public final void appendItems(List<T> items) {
        if (items == null) {
            return;
        }
        int start = dataList.size();
        dataList.addAll(items);
//        notifyItemRangeChanged(start, items.size());
        notifyDataSetChanged();


    }


    public final void updateItem(int position, T model) {
        if (model == null || position < 0 || position >= dataList.size()) {
            return;
        }
        dataList.set(position, model);
        notifyItemChanged(position);
    }

    public final void removeItemAt(int position) {
        if (position < 0 || position >= dataList.size()) {
            return;
        }
        dataList.remove(position);
        notifyItemRemoved(position);
    }

    public final void clearAll() {
        dataList.clear();
        notifyDataSetChanged();
    }

    public final void setItemClickListener(ItemClickListener<T> itemClickListener) {
        this.itemClickListener = itemClickListener;
    }

    public final void setItemLongClickListener(ItemLongClickListener<T> itemLongClickListener) {
        this.itemLongClickListener = itemLongClickListener;
    }

    protected abstract RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType);


    protected abstract void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position);


    public interface ItemClickListener<T> {
        void onItemClick(T model, int position);
    }

    public interface ItemLongClickListener<T> {
        boolean onItemLongClick(T model, int position);
    }

    @Override
    public int getItemViewType(int position) {
        if (mHeaderView == null) return TYPE_NORMAL;
        if (position == 0) return TYPE_HEADER;
        return TYPE_NORMAL;
    }


    public void setHeaderView(View headerView) {
        mHeaderView = headerView;
        notifyItemInserted(0);
    }

    public View getHeaderView() {
        return mHeaderView;
    }

    public List<T> getDataList() {
        return dataList;
    }

}

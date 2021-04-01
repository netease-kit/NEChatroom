package com.netease.audioroom.demo.dialog;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.text.Html;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;

import java.util.ArrayList;

public class BottomMenuDialog extends BaseDialogFragment {
    public final static String BOTTOMMENUS = "bottommenus";

    ArrayList<String> dataList;

    View rootView;
    RecyclerView recyclerView;
    MyAdapter adapter;


    public interface ItemClickListener {
        void onItemClick(ArrayList<String> dataArray, int position);
    }

    ItemClickListener itemClickListener;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NO_TITLE, R.style.request_dialog_fragment);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.dialog_bottom_menu, container, false);

        if (getArguments() != null) {
            dataList = getArguments().getStringArrayList(BOTTOMMENUS);
        }
        final Window window = getDialog().getWindow();
        window.setBackgroundDrawableResource(android.R.color.transparent);
        window.getDecorView().setPadding(0, 0, 0, 0);
        WindowManager.LayoutParams wlp = window.getAttributes();
        wlp.gravity = Gravity.BOTTOM;
        wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
        wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        window.setAttributes(wlp);
        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        initView();
    }

    private void initView() {
        recyclerView = rootView.findViewById(R.id.dialog_bottom_menu_recyclerView);
        if (dataList != null && dataList.size() != 0) {
            adapter = new MyAdapter(dataList, getActivity());
            recyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
            recyclerView.addItemDecoration(new VerticalItemDecoration(Color.GRAY, 1));
            recyclerView.setAdapter(adapter);
            adapter.setItemClickListener((model, position) ->
                    itemClickListener.onItemClick(dataList, position)
            );
        }
    }


    public void setItemClickListener(ItemClickListener itemClickListener) {
        this.itemClickListener = itemClickListener;
    }

    class MyAdapter extends BaseAdapter<String> {

        public MyAdapter(ArrayList<String> dataList, Context context) {
            super(dataList, context);
        }

        @Override
        protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
            return new MyViewHolder(layoutInflater.inflate(R.layout.item_dialog_bottom_menu,
                    parent, false));
        }

        @Override
        protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
            MyViewHolder myViewHolder = (MyViewHolder) holder;
            myViewHolder.textView.setText(Html.fromHtml(getItem(position)));
        }

        private class MyViewHolder extends RecyclerView.ViewHolder {
            TextView textView;

            public MyViewHolder(View itemView) {
                super(itemView);
                textView = itemView.findViewById(R.id.dialog_bottom_menu_textview);
                textView.setTextColor(getActivity().getResources().getColor(R.color.color_525252));
                textView.setBackgroundColor(getActivity().getResources().getColor(R.color.color_ffffff));
                textView.setGravity(Gravity.CENTER);
                textView.setTextSize(18);
            }
        }
    }
}

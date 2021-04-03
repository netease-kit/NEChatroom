package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView.ViewHolder;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Music;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.List;

/**
 * 歌单adapter
 */
public class MusicMenuAdapter extends BaseAdapter<Music> {

    public MusicMenuAdapter(List<Music> dataList, Context context) {
        super(dataList, context);
    }

    @Override
    protected ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
        return new MusicMenuViewHolder(layoutInflater.inflate(R.layout.item_music_menu_list, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull ViewHolder holder, int position) {
        Music music = getDataList().get(position);
        if(music == null) return;
        MusicMenuViewHolder viewHolder = (MusicMenuViewHolder) holder;
        ImageLoader.with(context).load(music.avatar).roundedCorner(ScreenUtil.dip2px(context, 4)).into(viewHolder.ivMusicAvatar);
        viewHolder.tvMusicName.setText(music.name);
        viewHolder.tvMusicAuthor.setText(music.singer);
        viewHolder.tvOrder.setOnClickListener(v -> {
            MusicSing.shareInstance().addMusic(music, new RequestCallback<Void>() {
                @Override
                public void onSuccess(Void param) {

                }

                @Override
                public void onFailed(int code) {
                    ToastHelper.showToast("点歌失败：" + code);
                }

                @Override
                public void onException(Throwable exception) {

                }
            });
        });
    }



    static class MusicMenuViewHolder extends ViewHolder{

        public ImageView ivMusicAvatar;

        public TextView tvMusicName;

        public TextView tvMusicAuthor;

        public TextView tvOrder;

        public MusicMenuViewHolder(@NonNull View itemView) {
            super(itemView);
            ivMusicAvatar = itemView.findViewById(R.id.iv_music_avatar);
            tvMusicName = itemView.findViewById(R.id.tv_music_name);
            tvMusicAuthor = itemView.findViewById(R.id.tv_music_author);
            tvOrder = itemView.findViewById(R.id.tv_order);
        }
    }
}

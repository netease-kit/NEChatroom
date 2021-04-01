package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.airbnb.lottie.LottieAnimationView;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.List;

/**
 * 已点歌单
 */
public class MusicOrderedAdapter extends RecyclerView.Adapter {
    private static final int TYPE_EMPTY = 1;
    private static final int TYPE_NORMAL = 2;

    VoiceRoomUser user;

    List<MusicOrderedItem> dataList;

    Context context;

    protected LayoutInflater layoutInflater;

    public MusicOrderedAdapter(List<MusicOrderedItem> dataList, Context context, VoiceRoomUser user) {
        this.dataList = dataList;
        this.context = context;
        this.user = user;
        this.layoutInflater = LayoutInflater.from(context);
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == TYPE_EMPTY) {
            return new EmptyViewHolder(layoutInflater.inflate(R.layout.view_item_dialog_members_empty, parent, false));
        }
        return new MusicOrderedViewHolder(layoutInflater.inflate(R.layout.item_music_ordered_list, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (getItemViewType(position) == TYPE_EMPTY) {
            return;
        }
        if (dataList.get(position) == null) {
            return;
        }
        MusicOrderedViewHolder viewHolder = (MusicOrderedViewHolder) holder;
        MusicOrderedItem musicOrderedItem = dataList.get(position);

        viewHolder.tvMusicAuthorName.setText(musicOrderedItem.musicName + "-" + musicOrderedItem.musicAuthor);
        viewHolder.tvUserName.setText(musicOrderedItem.userNickname);
        ImageLoader.with(context).load(musicOrderedItem.musicAvatar).roundedCorner(ScreenUtil.dip2px(context, 4)).into(viewHolder.ivMusicAvatar);
        ImageLoader.with(context).circleLoad(musicOrderedItem.userAvatar, viewHolder.ivUserAvatar);
        if (position > 0) {
            viewHolder.tvOrder.setVisibility(View.VISIBLE);
            viewHolder.tvOrder.setText("0" + position);
            if (TextUtils.equals(musicOrderedItem.userId, user.account)) {
                viewHolder.tvCancel.setVisibility(View.VISIBLE);
                viewHolder.tvCancel.setOnClickListener(v -> MusicSing.shareInstance().removeMusic(musicOrderedItem, new RequestCallback<Void>() {
                    @Override
                    public void onSuccess(Void param) {
                        ToastHelper.showToast("取消成功");
                    }

                    @Override
                    public void onFailed(int code) {

                    }

                    @Override
                    public void onException(Throwable exception) {

                    }
                }));
            } else {
                viewHolder.tvCancel.setVisibility(View.GONE);
            }
            viewHolder.tvPlaying.setVisibility(View.GONE);
            viewHolder.lavPlaying.setVisibility(View.INVISIBLE);
        } else {
            viewHolder.tvPlaying.setVisibility(View.VISIBLE);
            viewHolder.lavPlaying.setVisibility(View.VISIBLE);
            viewHolder.tvCancel.setVisibility(View.GONE);
            viewHolder.tvOrder.setVisibility(View.INVISIBLE);
            viewHolder.lavPlaying.setAnimation("ani/playing.json");
            viewHolder.lavPlaying.loop(true);
            viewHolder.lavPlaying.playAnimation();
        }
    }

    @Override
    public int getItemViewType(int position) {
        if (dataList == null || dataList.size() == 0) {
            return TYPE_EMPTY;
        } else {
            return TYPE_NORMAL;
        }
    }

    public final void setItems(List<MusicOrderedItem> newDataList) {
        if (newDataList == null) {
            return;
        }
        dataList.clear();
        dataList.addAll(newDataList);
        notifyDataSetChanged();
    }

    @Override
    public int getItemCount() {
        if (dataList == null || dataList.size() == 0) {
            return 1;
        }
        return dataList.size();
    }

    static class EmptyViewHolder extends RecyclerView.ViewHolder {

        public EmptyViewHolder(@NonNull View itemView) {
            super(itemView);
            TextView textView = itemView.findViewById(R.id.tv_empty_comment);
            textView.setText("还没有人点歌哦");
        }
    }

    static class MusicOrderedViewHolder extends RecyclerView.ViewHolder {

        public ImageView ivMusicAvatar;
        public TextView tvOrder;
        public TextView tvMusicAuthorName;
        public ImageView ivUserAvatar;
        public TextView tvUserName;
        public LottieAnimationView lavPlaying;
        public TextView tvCancel;
        public TextView tvPlaying;

        public MusicOrderedViewHolder(@NonNull View itemView) {
            super(itemView);
            tvOrder = itemView.findViewById(R.id.tv_order);
            ivMusicAvatar = itemView.findViewById(R.id.iv_music_avatar);
            lavPlaying = itemView.findViewById(R.id.lav_playing);
            tvMusicAuthorName = itemView.findViewById(R.id.tv_music_author_name);
            ivUserAvatar = itemView.findViewById(R.id.iv_user_avatar);
            tvUserName = itemView.findViewById(R.id.tv_user_nick);
            tvCancel = itemView.findViewById(R.id.tv_cancel);
            tvPlaying = itemView.findViewById(R.id.tv_playing);
        }
    }
}

package com.netease.audioroom.demo.dialog;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.airbnb.lottie.LottieAnimationView;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.LiveBaseAdapter;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.VolumeSetup;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;

import java.util.Arrays;
import java.util.List;

/**
 * Created by luc on 1/28/21.
 */
public class ChatRoomAudioDialog extends BottomBaseDialog {
    private final AudioPlay audioPlay;

    private View playOrPause;

    private InnerMusicAdapter adapter;

    /**
     * 混音文件信息
     */
    private List<ChatRoomAudioDialog.MusicItem> audioMixingMusicInfos;

    private final AudioPlay.Callback callback = new AudioPlay.Callback() {
        @Override
        public void onAudioMixingPlayState(int state, int index) {
            playOrPause.setSelected(state == AudioPlay.AudioMixingPlayState.STATE_PLAYING);
            adapter.setFocusItem(index);
        }

        @Override
        public void onAudioMixingPlayError() {
            ToastHelper.showToast("伴音发现错误");
        }

        @Override
        public void onAudioEffectPlayFinished(int index) {
        }

        @Override
        public void onAudioReset() {
            resetStatus();
        }

        @Override
        public void onError(String msg) {
            ToastHelper.showToast(msg);
        }
    };

    public ChatRoomAudioDialog(@NonNull Activity activity, NERtcVoiceRoom voiceRoom, List<ChatRoomAudioDialog.MusicItem> audioMixingMusicInfos) {
        super(activity);
        this.audioPlay = voiceRoom.getAudioPlay();
        this.audioPlay.setCallback(callback);
        this.audioMixingMusicInfos = audioMixingMusicInfos;
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("背景音乐");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, layoutParams);
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        View bottomView = LayoutInflater.from(getContext()).inflate(R.layout.view_dialog_more_audio, parent);

        bottomView.findViewById(R.id.tv_audio_effect_1).setOnClickListener(v -> audioPlay.playEffect(0));
        bottomView.findViewById(R.id.tv_audio_effect_2).setOnClickListener(v -> audioPlay.playEffect(1));

        RecyclerView rvList = bottomView.findViewById(R.id.rv_music_list);
        rvList.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
        rvList.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        if (audioMixingMusicInfos == null || audioMixingMusicInfos.size() == 0) {
            audioMixingMusicInfos = Arrays.asList(
                    new MusicItem("01", "音乐1", "歌手1"),
                    new MusicItem("02", "音乐2", "歌手2"),
                    new MusicItem("03", "音乐3", "歌手3")
            );
        }
        adapter = new InnerMusicAdapter(getContext(), audioPlay, audioMixingMusicInfos);
        rvList.setAdapter(adapter);

        bottomView.findViewById(R.id.iv_music_next).setOnClickListener(v -> audioPlay.playNextMixing());
        playOrPause = bottomView.findViewById(R.id.iv_music_play_or_pause);
        playOrPause.setOnClickListener(v -> audioPlay.playOrPauseMixing());

        int currentState = audioPlay.getCurrentState();
        if (currentState == AudioPlay.AudioMixingPlayState.STATE_PLAYING) {
            playOrPause.setSelected(true);
            adapter.setFocusItem(audioPlay.getPlayingMixIndex());
        } else if (currentState == AudioPlay.AudioMixingPlayState.STATE_PAUSED) {
            adapter.setFocusItem(audioPlay.getPlayingMixIndex());
        } else {
            playOrPause.setSelected(false);
        }

        SeekBar volumeBar = bottomView.findViewById(R.id.sb_music_bar);
        volumeBar.setProgress(audioPlay.getMixingVolume(false));
        volumeBar.setOnSeekBarChangeListener(new VolumeSetup() {
            @Override
            protected void onVolume(int volume) {
                audioPlay.setEffectVolume(volume);
                audioPlay.setMixingVolume(volume, false);
            }
        });
    }

    public void resetStatus() {
        playOrPause.setSelected(false);
        if (adapter != null) {
            adapter.resetStatus();
        }
    }

    public static class MusicItem {
        private final String order;
        private final String name;
        private final String singer;

        public MusicItem(String order, String name, String singer) {
            this.order = order;
            this.name = name;
            this.singer = singer;
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;

            MusicItem musicItem = (MusicItem) o;

            if (!order.equals(musicItem.order)) return false;
            if (!name.equals(musicItem.name)) return false;
            return singer.equals(musicItem.singer);
        }

        @Override
        public int hashCode() {
            int result = order.hashCode();
            result = 31 * result + name.hashCode();
            result = 31 * result + singer.hashCode();
            return result;
        }
    }

    private static class InnerMusicAdapter extends LiveBaseAdapter<MusicItem> {
        private final AudioPlay audioPlay;
        private MusicItem currentItem = null;

        public InnerMusicAdapter(Context context, AudioPlay audioPlay, List<MusicItem> dataSource) {
            super(context, dataSource);
            this.audioPlay = audioPlay;
        }

        @Override
        protected int getLayoutId(int viewType) {
            return R.layout.view_item_dialog_music;
        }

        @Override
        protected LiveViewHolder onCreateViewHolder(View itemView) {
            return new LiveViewHolder(itemView);
        }

        @Override
        protected void onBindViewHolder(LiveViewHolder holder, MusicItem itemData, int position) {
            TextView tvOrder = holder.getView(R.id.tv_music_order);
            tvOrder.setText(itemData.order);

            TextView tvName = holder.getView(R.id.tv_music_name);
            tvName.setText(itemData.name);

            TextView tvSinger = holder.getView(R.id.tv_music_singer);
            tvSinger.setText(itemData.singer);

            LottieAnimationView lavPlaying = holder.getView(R.id.lav_playing);

            holder.itemView.setOnClickListener(v -> {
                if (audioPlay.playMixing(position)) {
                    this.currentItem = itemData;
                    notifyDataSetChanged();
                }
            });


            if (itemData.equals(currentItem)) {
                tvName.setTextColor(Color.parseColor("#ff337eff"));
                tvOrder.setVisibility(View.INVISIBLE);
                lavPlaying.setVisibility(View.VISIBLE);
                lavPlaying.setAnimation("ani/playing.json");
                lavPlaying.loop(true);
                lavPlaying.playAnimation();
            } else {
                tvName.setTextColor(Color.parseColor("#ff222222"));
                tvOrder.setVisibility(View.VISIBLE);
                lavPlaying.setVisibility(View.GONE);
            }

        }

        public void setFocusItem(int index) {
            this.currentItem = getItem(index);
            notifyDataSetChanged();
        }

        public void resetStatus() {
            this.currentItem = null;
            notifyDataSetChanged();
        }
    }
}

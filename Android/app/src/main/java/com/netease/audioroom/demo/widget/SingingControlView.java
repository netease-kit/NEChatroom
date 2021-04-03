package com.netease.audioroom.demo.widget;

import android.content.Context;
import android.os.CountDownTimer;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.lrc.LrcView;
import com.netease.audioroom.demo.widget.lrc.LyricDown;
import com.netease.yunxin.android.lib.picture.ImageLoader;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CustomAttachmentType;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.MusicControl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Lrc;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.LyricList;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.LyricListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.List;

/**
 * 演唱区控制view
 */
public class SingingControlView extends LinearLayout implements LyricListener {

    private TextView tvSingingMusicName;

    private TextView tvNextMusic;

    private LrcView lrcView;

    private TextView tvOrderSong;

    private FrameLayout flySing;

    private HeadImageView ivUserAvatar;

    private TextView tvUserNick;

    private TextView tvTime;

    private TextView tvMusicName;

    private LinearLayout llyReady;

    private RelativeLayout rlySing;

    private LinearLayout llyNoOrderSong;

    private NERtcVoiceRoom voiceRoom;

    private ImageView ivSoundSetting;

    private ImageView ivPause;

    private ImageView ivBackground;

    private ImageView ivNext;

    private LinearLayout llyControl;

    private LinearLayout llyMusicInfo;

    private TextView tvContinue;

    private TextView tvPaused;

    private boolean isSelfSong;//是否是自己的歌

    private CountDownTimer timer;//准备倒计时

    private SingControlCallBack controlCallBack;

    boolean isAnchor;//是否是主播

    private VoiceRoomUser userInfo;

    private boolean paused;//已暂停

    private long timestamp;//时长

    public SingingControlView(Context context) {
        super(context);
        initView();
    }

    public SingingControlView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        initView();
    }

    public SingingControlView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView();
    }

    public void setUserInfo(VoiceRoomUser roomUser) {
        this.userInfo = roomUser;
    }

    public void setVoiceRoom(NERtcVoiceRoom voiceRoom) {
        this.voiceRoom = voiceRoom;
    }

    public void onMusicStateChange(int type) {
        if (type == CustomAttachmentType.MUSIC_PAUSE) {
            changeMusicState(true, false);
        } else if (type == CustomAttachmentType.MUSIC_RESUME) {
            changeMusicState(false, false);
        }
    }

    public void setControlCallBack(SingControlCallBack controlCallBack) {
        this.controlCallBack = controlCallBack;
    }

    public void setAnchor(boolean anchor) {
        isAnchor = anchor;
    }

    public boolean getPaused() {
        return paused;
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.view_sing_control_layout, this, true);
        tvSingingMusicName = findViewById(R.id.tv_music_singing);
        tvNextMusic = findViewById(R.id.tv_music_next);
        lrcView = findViewById(R.id.lrc_view);
        tvOrderSong = findViewById(R.id.tv_order);
        flySing = findViewById(R.id.fly_singing);
        llyNoOrderSong = findViewById(R.id.lly_no_ordered_song);
        ivUserAvatar = findViewById(R.id.iv_user_avatar);
        tvUserNick = findViewById(R.id.tv_user_nick);
        tvMusicName = findViewById(R.id.tv_music_name);
        tvTime = findViewById(R.id.tv_time);
        llyReady = findViewById(R.id.lly_ready);
        rlySing = findViewById(R.id.rly_music_singing);
        llyControl = findViewById(R.id.lly_control);
        ivSoundSetting = findViewById(R.id.iv_set_sound);
        ivPause = findViewById(R.id.iv_pause);
        ivNext = findViewById(R.id.iv_next_music);
        ivBackground = findViewById(R.id.iv_bg);
        tvContinue = findViewById(R.id.tv_continue);
        llyMusicInfo = findViewById(R.id.lly_music_info_sing);
        tvPaused = findViewById(R.id.tv_paused);
        ImageLoader.with(getContext()).load(R.drawable.sing_view_bg).roundedCorner(ScreenUtil.dip2px(getContext(), 10)).into(ivBackground);

        ivPause.setOnClickListener(v -> {
            if (!ivPause.isSelected()) {
                changeMusicState(true, true);
            } else {
                changeMusicState(false, true);
            }
        });

        tvContinue.setOnClickListener(v -> changeMusicState(false, true));

        ivNext.setOnClickListener(v -> {
            MusicSing.shareInstance().nextMusic(null);
            if (isSelfSong) {
                voiceRoom.getAudioPlay().stopKtvMusic();
            }
        });

        ivSoundSetting.setOnClickListener(v -> {
            if (controlCallBack != null) {
                controlCallBack.showAudioSettingDialog();
            }
        });
    }

    public void updateNextSong(MusicOrderedItem music) {
        if (music == null) {
            tvNextMusic.setVisibility(GONE);
        } else {
            tvNextMusic.setVisibility(VISIBLE);
            tvNextMusic.setText("下一首:" + music.musicName);
        }
    }

    /**
     * 歌曲状态变化
     *
     * @param isPause 是否暂停
     * @param bySelf  是否自己操作
     */
    private void changeMusicState(boolean isPause, boolean bySelf) {
        if (isPause) {
            paused = true;
            ivPause.setSelected(true);
            if (isAnchor || isSelfSong) {
                tvContinue.setVisibility(VISIBLE);
            } else {
                tvPaused.setVisibility(VISIBLE);
            }
            if (bySelf) {
                MusicSing.shareInstance().sendCustomMessage(new MusicControl(CustomAttachmentType.MUSIC_PAUSE, userInfo.getNick()));
            }
            if (isSelfSong) {
                MusicSing.shareInstance().updateStatusAndTimestamp(null, MusicOrderedItem.STATUS_PAUSE, timestamp);
                voiceRoom.getAudioPlay().pauseKtvMusic();
            }
        } else {
            paused = false;
            ivPause.setSelected(false);
            tvContinue.setVisibility(GONE);
            tvPaused.setVisibility(GONE);
            if (bySelf) {
                MusicSing.shareInstance().sendCustomMessage(new MusicControl(CustomAttachmentType.MUSIC_RESUME, userInfo.getNick()));
            }
            if (isSelfSong) {
                MusicSing.shareInstance().updateStatusAndTimestamp(null, MusicOrderedItem.STATUS_DEFAULT, timestamp);
                voiceRoom.getAudioPlay().resumeKtvMusic();
            }
        }
    }


    /**
     * 开始唱歌
     *
     * @param currentMusic
     * @param isMySong        是否是我的歌
     * @param needUpdateLyric 是否需要更新歌词
     */
    public void onMusicSing(MusicOrderedItem currentMusic, boolean isMySong, boolean needUpdateLyric) {
        if (currentMusic == null) {
            return;
        }
        isSelfSong = isMySong;
        resetMusic();
        llyNoOrderSong.setVisibility(GONE);
        flySing.setVisibility(VISIBLE);
        rlySing.setVisibility(VISIBLE);
        llyReady.setVisibility(GONE);
        MusicSing.shareInstance().setLyricListener(this);
        tvSingingMusicName.setText(currentMusic.musicName);
        ivPause.setSelected(false);
        paused = false;
        tvContinue.setVisibility(GONE);
        if (isMySong || isAnchor) {
            llyControl.setVisibility(VISIBLE);
            ivSoundSetting.setVisibility(VISIBLE);
            if (isMySong) {
                llyMusicInfo.setVisibility(INVISIBLE);
                voiceRoom.getAudioPlay().setKtvMusicPlay(currentMusic);
                flySing.setBackground(ResourcesCompat.getDrawable(getResources(), R.drawable.singer_singing_song_round_bg, null));
            } else {
                llyMusicInfo.setVisibility(VISIBLE);
                flySing.setBackground(ResourcesCompat.getDrawable(getResources(), R.drawable.singing_song_round_bg, null));
            }
            tvPaused.setVisibility(GONE);
        } else {
            llyControl.setVisibility(INVISIBLE);
            llyMusicInfo.setVisibility(VISIBLE);
            flySing.setBackground(ResourcesCompat.getDrawable(getResources(), R.drawable.singing_song_round_bg, null));
            if (currentMusic.status == MusicOrderedItem.STATUS_PAUSE) {
                tvPaused.setVisibility(VISIBLE);
                if (currentMusic.timestamp > 0) {
                    onReceiveSeiTimestamp(currentMusic.timestamp);
                }
            } else {
                tvPaused.setVisibility(GONE);
            }
        }
        if (needUpdateLyric) {
            updateLyric(currentMusic);
        }
    }

    public void noSongOrdered() {
        llyNoOrderSong.setVisibility(VISIBLE);
        flySing.setVisibility(GONE);
    }

    /**
     * 准备
     *
     * @param currentMusic 当前歌曲
     * @param isMySong     是否是我的歌
     */
    public void onReady(MusicOrderedItem currentMusic, boolean isMySong) {
        isSelfSong = isMySong;
        resetMusic();
        llyNoOrderSong.setVisibility(GONE);
        flySing.setVisibility(VISIBLE);
        rlySing.setVisibility(GONE);
        llyReady.setVisibility(VISIBLE);
        ivUserAvatar.loadAvatar(currentMusic.userAvatar);
        tvMusicName.setText(currentMusic.musicName);
        tvUserNick.setText(currentMusic.userNickname + " 请准备");
        tvTime.setText(3 + "秒后播放");
        startTimer(currentMusic, isMySong);
        updateLyric(currentMusic);
        timestamp = 0;
    }

    public void cancelReady() {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
    }

    private void resetMusic() {
        if (!isSelfSong) {
            voiceRoom.getAudioPlay().stopKtvMusic();
        }
    }


    /**
     * 开始准备倒计时
     *
     * @param currentMusic
     * @param isMySong
     */
    private void startTimer(MusicOrderedItem currentMusic, boolean isMySong) {
        if (timer != null) {
            timer.cancel();
            timer = null;
        }
        final int countTimeSec = currentMusic.countTimeSec;
        timer = new CountDownTimer(countTimeSec * 1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                int timeSec = (int) (millisUntilFinished / 1000);
                tvTime.setText(millisUntilFinished / 1000 + "秒后播放");
                if (isMySong && timeSec < countTimeSec) {
                    MusicSing.shareInstance().updateMusicTime(currentMusic, timeSec);
                }
            }

            @Override
            public void onFinish() {
                onMusicSing(currentMusic, isMySong, false);
                if (isMySong) {
                    MusicSing.shareInstance().updateMusicTime(currentMusic,0);
                }
            }
        };
        timer.start();
    }



    @Override
    public void onReceiveSeiTimestamp(long timestamp) {
        this.timestamp = timestamp;
        lrcView.updateTime(timestamp);
    }

    public void setOrder(OnClickListener listener){
        tvOrderSong.setOnClickListener(listener);
    }

    private void updateLyric(MusicOrderedItem music) {
        List<Lrc> lrcList = LyricList.getInstance().getLyric(music);
        if (lrcList != null && lrcList.size() > 0) {
            lrcView.setLrcData(lrcList);
        } else {
            LyricDown.download(music.musicLyricUrl, new LyricDown.DownloadListener() {
                @Override
                public void onSuccess(List<Lrc> lrcs) {
                    lrcView.setLrcData(lrcs);
                    LyricList.getInstance().addLyric(music, lrcs);
                    if (timestamp > 0) {
                        lrcView.updateTime(timestamp);
                    }
                }

                @Override
                public void onFail(String errorInfo) {
                    ToastHelper.showToast(errorInfo);
                }
            });
        }
    }

    public interface SingControlCallBack {

        /**
         * 显示调音台回调
         */
        void showAudioSettingDialog();
    }

}

package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.action.INetworkReconnection;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.BottomMenuDialog;
import com.netease.audioroom.demo.dialog.SeatApplyDialog;
import com.netease.audioroom.demo.dialog.TopTipsDialog;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.util.AudioChooser;
import com.netease.audioroom.demo.util.CommonUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.LoadingCallback;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import static com.netease.audioroom.demo.dialog.BottomMenuDialog.BOTTOMMENUS;

/**
 * 主播页
 */
public class AnchorActivity extends VoiceRoomBaseActivity implements Anchor.Callback, AudioPlay.Callback {
    private static final int CODE_SELECT_FILE = 10001;
    private static final int CODE_INVITE_SEAT = 10002;

    public static void start(Context context, VoiceRoomInfo voiceRoomInfo) {
        Intent intent = new Intent(context, AnchorActivity.class);
        intent.putExtra(EXTRA_VOICE_ROOM_INFO, voiceRoomInfo);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_from_left);
        }
    }

    private TextView tvApplyHint;

    private TextView tvMusicPlayHint;
    private ImageView ivPauseOrPlay;
    private FrameLayout musicContainer;
    private TextView tvMusic1;
    private TextView tvMusic2;
    private TextView tvFileMusic;
    private TextView tvEffect1;
    private TextView tvEffect2;

    private TopTipsDialog topTipsDialog;
    private BottomMenuDialog bottomMenuDialog;
    private SeatApplyDialog seatApplyDialog;

    private Anchor anchor;

    private AudioPlay audioPlay;

    @Override
    protected int getContentViewID() {
        return R.layout.activity_live;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        enterRoom(true);
        checkMusicFiles();
    }

    @Override
    public void onBackPressed() {
        if (musicContainer.getVisibility() == View.VISIBLE) {
            musicContainer.setVisibility(View.GONE);
            return;
        }
        super.onBackPressed();
    }

    @Override
    protected void onResume() {
        super.onResume();
        setNetworkReconnection(new INetworkReconnection() {
            @Override
            public void onNetworkReconnection() {
                if (topTipsDialog != null) {
                    topTipsDialog.dismiss();
                }
            }

            @Override
            public void onNetworkInterrupt() {
                Bundle bundle = new Bundle();
                TopTipsDialog.Style style = topTipsDialog.new Style(
                        "网络断开",
                        0,
                        R.drawable.neterrricon,
                        0);
                bundle.putParcelable(topTipsDialog.TAG, style);
                topTipsDialog.setArguments(bundle);
                if (!topTipsDialog.isVisible()) {
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                    topTipsDialog.setClickListener(() -> {
                    });
                }
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == CODE_SELECT_FILE) {
            if (resultCode == RESULT_OK) {
                if (data != null) {
                    AudioChooser.result(this, data, new AudioChooser.Callback<String>() {
                        @Override
                        public void call(String path) {
                            if (!TextUtils.isEmpty(path)) {
                                setAudioFixingFilePath(path);
                                audioPlay.setMixingFile(2, path);
                            }
                        }
                    });
                }
            }
        } else if (requestCode == CODE_INVITE_SEAT) {
            if (resultCode == RESULT_OK) {
                if (data != null) {
                    //抱麦
                    loadService.showCallback(LoadingCallback.class);
                    //被抱用户
                    VoiceRoomUser user = (VoiceRoomUser) data.getSerializableExtra(MemberSelectActivity.RESULT_MEMBER);
                    if (user != null) {
                        inviteSeat(user);
                    }
                }
            }
        }
    }

    @Override
    protected void setupBaseView() {
        topTipsDialog = new TopTipsDialog();
        tvApplyHint = findViewById(R.id.apply_hint);
        tvMusicPlayHint = findViewById(R.id.tv_music_play_hint);
        ivPauseOrPlay = findViewById(R.id.iv_pause_or_play);
        ImageView ivNext = findViewById(R.id.iv_next);
        musicContainer = findViewById(R.id.fl_music_container);

        tvMusic1 = musicContainer.findViewById(R.id.tv_music_1);
        tvMusic2 = musicContainer.findViewById(R.id.tv_music_2);
        tvFileMusic = musicContainer.findViewById(R.id.tv_music_file);
        tvEffect1 = musicContainer.findViewById(R.id.tv_audio_effect_1);
        tvEffect2 = musicContainer.findViewById(R.id.tv_audio_effect_2);
        SeekBar skMusicVolume = musicContainer.findViewById(R.id.music_song_volume_control);
        SeekBar skEffectVolume = musicContainer.findViewById(R.id.audio_effect_volume_control);
        skEffectVolume.setOnSeekBarChangeListener(new VolumeSetup() {
            @Override
            protected void onVolume(int volume) {
                audioPlay.setEffectVolume(volume);
            }
        });

        ImageView ivMuteOtherText = findViewById(R.id.iv_mute_other_text);
        ivMuteOtherText.setVisibility(View.VISIBLE);
        ivMuteOtherText.setOnClickListener(view -> MuteMembersActivity.start(AnchorActivity.this, voiceRoomInfo));
        tvApplyHint.setOnClickListener(view -> showApplySeats(anchor.getApplySeats()));
        ivPauseOrPlay.setOnClickListener(view -> audioPlay.playOrPauseMixing());
        ivNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!audioPlay.playNextMixing()) {
                    ToastHelper.showToast("播放下一首失败");
                }
            }
        });
        findViewById(R.id.iv_more_action).setOnClickListener(view -> musicContainer.setVisibility(View.VISIBLE));
        musicContainer.setOnClickListener(view -> musicContainer.setVisibility(View.GONE));
        findViewById(R.id.rl_music_action_container).setOnClickListener(view -> {});
        skMusicVolume.setOnSeekBarChangeListener(new VolumeSetup() {
            @Override
            protected void onVolume(int volume) {
                audioPlay.setMixingVolume(volume);
            }
        });
        tvMusic1.setOnClickListener(view -> audioPlay.playMixing(0));
        tvMusic2.setOnClickListener(view -> audioPlay.playMixing(1));
        tvFileMusic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (TextUtils.isEmpty(audioPlay.getMixingFile(2))) {
                    ToastHelper.showToast("请先选择好文件");
                    return;
                }
                audioPlay.playMixing(2);
            }
        });
        tvEffect1.setOnClickListener(view -> changeEffect(view, 0));
        tvEffect2.setOnClickListener(view -> changeEffect(view, 1));
        findViewById(R.id.tv_select_file).setOnClickListener(view -> AudioChooser.choose(AnchorActivity.this, CODE_SELECT_FILE));

        tvApplyHint.setVisibility(View.INVISIBLE);
        tvApplyHint.setClickable(true);
    }

    private void changeEffect(View effectView, int index) {
        if (audioPlay.stopAllEffects()) {
            tvEffect1.setSelected(false);
            tvEffect2.setSelected(false);
        }
        effectView.setSelected(audioPlay.playEffect(index));
    }

    @Override
    protected void onSeatItemClick(VoiceRoomSeat seat, int position) {
        Bundle bundle = new Bundle();
        bottomMenuDialog = new BottomMenuDialog();
        ArrayList<String> items = new ArrayList<>();
        switch (seat.getStatus()) {
            case Status.INIT:
                items.add("将成员抱上麦位");
                items.add("屏蔽麦位");
                items.add("关闭麦位");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "将成员抱上麦位":
                            onSeatAction(bottomMenuDialog, seat, "将成员抱上麦位");
                            break;
                        case "屏蔽麦位":
                            onSeatAction(bottomMenuDialog, seat, "屏蔽麦位");
                            break;
                        case "关闭麦位":
                            onSeatAction(bottomMenuDialog, seat, "关闭麦位");
                            break;
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;
                    }
                });
                break;
            case Status.APPLY:
                ToastHelper.showToast("正在申请");
                break;
            case Status.ON:
                items.add("将TA踢下麦位");
                items.add("屏蔽麦位");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "将TA踢下麦位":
                            onSeatAction(bottomMenuDialog, seat, "将TA踢下麦位");
                            break;
                        case "屏蔽麦位":
                            onSeatAction(bottomMenuDialog, seat, "屏蔽麦位");
                            break;
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;
                    }
                });
                break;
            case Status.CLOSED:
                items.add("打开麦位");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "打开麦位":
                            onSeatAction(bottomMenuDialog, seat, "打开麦位");
                            break;
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;
                    }
                });
                break;
            case Status.FORBID:
                items.add("将成员抱上麦位");
                items.add("解除语音屏蔽");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "将成员抱上麦位":
                            onSeatAction(bottomMenuDialog, seat, "将成员抱上麦位");
                            break;
                        case "解除语音屏蔽":
                            onSeatAction(bottomMenuDialog, seat, "解除语音屏蔽");
                            break;
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;

                    }
                });
                break;
            case Status.AUDIO_MUTED:
            case Status.AUDIO_CLOSED_AND_MUTED:
                items.add("将TA踢下麦位");
                items.add("解除语音屏蔽");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "将TA踢下麦位":
                            onSeatAction(bottomMenuDialog, seat, "将TA踢下麦位");
                            break;
                        case "解除语音屏蔽":
                            onSeatAction(bottomMenuDialog, seat, "解除语音屏蔽");
                            break;
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;

                    }
                });
                break;
            case Status.AUDIO_CLOSED:
                items.add("将TA踢下麦位");
                items.add("屏蔽麦位");
                items.add("取消");
                bundle.putStringArrayList(BOTTOMMENUS, items);
                bottomMenuDialog.setArguments(bundle);
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "将TA踢下麦位":
                            onSeatAction(bottomMenuDialog, seat, "将TA踢下麦位");
                            break;
                        case "屏蔽麦位":
                            onSeatAction(bottomMenuDialog, seat, "屏蔽麦位");
                        case "取消":
                            onSeatAction(bottomMenuDialog, seat, "取消");
                            break;
                    }
                });
                break;

        }
        if (seat.getStatus() != Status.APPLY) {
            bottomMenuDialog.show(getSupportFragmentManager(), bottomMenuDialog.TAG);
        }
    }

    @Override
    protected boolean onSeatItemLongClick(VoiceRoomSeat model, int position) {
        return false;
    }

    @Override
    protected void doLeaveRoom() {
        bottomMenuDialog = new BottomMenuDialog();
        Bundle bundle = new Bundle();
        ArrayList<String> items = new ArrayList<>();
        items.add("<font color=\"#ff4f4f\">退出并解散房间</color>");
        items.add("取消");
        bundle.putStringArrayList(BOTTOMMENUS, items);
        bottomMenuDialog.setArguments(bundle);
        bottomMenuDialog.show(getSupportFragmentManager(), bottomMenuDialog.TAG);
        bottomMenuDialog.setItemClickListener((d, p) -> {
            switch (d.get(p)) {
                case "<font color=\"#ff4f4f\">退出并解散房间</color>":
                    onSeatAction(bottomMenuDialog, null, "退出并解散房间");
                    break;
                case "取消":
                    onSeatAction(bottomMenuDialog, null, "取消");
                    break;
            }
        });
    }

    private void onSeatAction(BottomMenuDialog dialog, VoiceRoomSeat seat, String item) {
        switch (item) {
            case "确定踢下麦位":
                bottomMenuDialog = new BottomMenuDialog();
                bottomMenuDialog.setItemClickListener((d, p) -> {
                    switch (d.get(p)) {
                        case "<font color = \"#ff4f4f\">确定踢下麦位</color>":
                            kickSeat(seat);
                            break;
                        case "取消":
                            bottomMenuDialog.dismiss();
                            break;
                    }
                });
                break;
            case "关闭麦位":
                closeSeat(seat);
                break;
            case "将成员抱上麦位":
                inviteSeat0(seat);
                break;
            case "将TA踢下麦位":
                kickSeat(seat);
                break;
            case "屏蔽麦位":
                muteSeat(seat);
                break;
            case "解除语音屏蔽":
            case "打开麦位":
                openSeat(seat);
                break;
            case "退出并解散房间":
                leaveRoom();
                break;
            case "取消":
                dialog.dismiss();
                break;
        }
        if (dialog.isVisible()) {
            dialog.dismiss();
        }
    }

    private void showApplySeats(List<VoiceRoomSeat> seats) {
        seatApplyDialog = new SeatApplyDialog();
        Bundle bundle = new Bundle();
        bundle.putParcelableArrayList(seatApplyDialog.TAG, new ArrayList<>(seats));
        seatApplyDialog.setArguments(bundle);
        seatApplyDialog.show(getSupportFragmentManager(), seatApplyDialog.TAG);
        seatApplyDialog.setRequestAction(new SeatApplyDialog.IRequestAction() {
            @Override
            public void refuse(VoiceRoomSeat seat) {
                denySeatApply(seat);
            }

            @Override
            public void agree(VoiceRoomSeat seat) {
                approveSeatApply(seat);
            }

            @Override
            public void dismiss() {

            }
        });
    }

    //
    // play music files
    //

    private static String MUSIC_DIR = "music";
    private static String MUSIC1 = "music1.m4a";
    private static String MUSIC2 = "music2.m4a";
    private static String EFFECT1 = "effect1.wav";
    private static String EFFECT2 = "effect2.wav";

    private String extractMusicFile(String path, String name) {
        CommonUtil.copyAssetToFile(this, MUSIC_DIR + "/" + name, path, name);
        return new File(path, name).getAbsolutePath();
    }

    private String ensureMusicDirectory() {
        File dir = getExternalFilesDir(MUSIC_DIR);
        if (dir == null) {
            dir = getDir(MUSIC_DIR, 0);
        }
        if (dir != null) {
            dir.mkdirs();
            return dir.getAbsolutePath();
        }
        return "";
    }

    private void checkMusicFiles() {
        new Thread(() -> {
            String root = ensureMusicDirectory();

            String[] effectPaths = new String[2];
            effectPaths[0] = extractMusicFile(root, EFFECT1);
            effectPaths[1] = extractMusicFile(root, EFFECT2);

            audioPlay.setEffectFile(effectPaths);

            String[] musicPaths = new String[3];
            musicPaths[0] = extractMusicFile(root, MUSIC1);
            musicPaths[1] = extractMusicFile(root, MUSIC2);
            musicPaths[2] = getAudioFixingFilePath();

            audioPlay.setMixingFile(musicPaths);
        }).start();
    }

    private static final String SHARED_PREFERENCES_NAME = "audio_room_pref";
    private static final String KEY_AUDIO_MIXING_FILE_PATH = "audio_mixing_file_path";

    private String getAudioFixingFilePath() {
        return getValueFromSharedPreferences(KEY_AUDIO_MIXING_FILE_PATH);
    }

    private void setAudioFixingFilePath(String path) {
        saveToSharedPreferences(KEY_AUDIO_MIXING_FILE_PATH, path);
    }

    private void saveToSharedPreferences(String key, String value) {
        SharedPreferences preference = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        preference.edit().putString(key, value).apply();
    }

    private String getValueFromSharedPreferences(String key) {
        SharedPreferences preference = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
        return preference.getString(key, null);
    }

    private static CharSequence makeMusicHintText(int index, boolean playing) {
        index++;
        SpannableStringBuilder builder = new SpannableStringBuilder("音乐" + index);
        builder.setSpan(new ForegroundColorSpan(Color.parseColor("#ffa410")),
                0, builder.length(),
                SpannableStringBuilder.SPAN_INCLUSIVE_EXCLUSIVE);
        builder.append(playing ? "播放中" : "已暂停");
        return builder;
    }

    //
    // room call
    //

    @Override
    protected void initVoiceRoom() {
        super.initVoiceRoom();
        anchor = voiceRoom.getAnchor();
        audioPlay = voiceRoom.getAudioPlay();
        anchor.setCallback(this);
        audioPlay.setCallback(this);
    }

    //
    // Anchor.Callback
    //

    @Override
    public void onApplySeats(List<VoiceRoomSeat> seats) {
        int size = seats.size();

        if (size > 0) {
            tvApplyHint.setVisibility(View.VISIBLE);
            tvApplyHint.setText(String.valueOf(size));
        } else {
            tvApplyHint.setVisibility(View.INVISIBLE);
        }

        if (size > 0) {
            if (seatApplyDialog != null
                    && seatApplyDialog.isVisible()) {
                seatApplyDialog.update(seats);
            }
        } else {
            if (seatApplyDialog != null
                    && seatApplyDialog.isVisible()) {
                seatApplyDialog.dismiss();
            }
        }
    }

    //
    // AudioPlay.Callback
    //

    @Override
    public void onAudioMixingPlayState(int state, int index) {
        ivPauseOrPlay.setSelected(state == AudioPlay.AudioMixingPlayState.STATE_PLAYING);
        if (state != AudioPlay.AudioMixingPlayState.STATE_STOPPED) {
            tvMusicPlayHint.setText(makeMusicHintText(index, state == AudioPlay.AudioMixingPlayState.STATE_PLAYING));
        } else {
            tvMusicPlayHint.setText("");
        }
        tvMusic1.setSelected(index == 0 && state != AudioPlay.AudioMixingPlayState.STATE_STOPPED);
        tvMusic2.setSelected(index == 1 && state != AudioPlay.AudioMixingPlayState.STATE_STOPPED);
        tvFileMusic.setSelected(index == 2 && state != AudioPlay.AudioMixingPlayState.STATE_STOPPED);
    }

    @Override
        public void onAudioMixingPlayError() {
        ToastHelper.showToast("伴音发现错误");
    }

    @Override public void onAudioEffectPlayFinished(int index) {
        if (index == 0) {
            tvEffect1.setSelected(false);
        } else if (index == 1) {
            tvEffect2.setSelected(false);
        }
    }

    //
    // RoomCallback
    //

    @Override
    public void onLeaveRoom() {
        Runnable runnable = AnchorActivity.super::onLeaveRoom;
//        closeRoom(runnable);
        runnable.run();
    }

    //
    // Anchor call
    //

    private void approveSeatApply(VoiceRoomSeat seat) {
        final String text = "成功通过连麦请求";

        boolean ret = anchor.approveSeatApply(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                ToastHelper.showToast(text);
            }
        });
        if (!ret) {
            denySeatApply(seat);
        }
    }

    private void denySeatApply(VoiceRoomSeat seat) {
        VoiceRoomUser user = seat.getUser();
        String nick = user != null ? user.getNick() : "";
        final String text = "已拒绝“" + nick + "”的申请";

        anchor.denySeatApply(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                ToastHelper.showToast(text);
            }
        });
    }

    public void openSeat(VoiceRoomSeat seat) {
        String msg = "";
        String msgError = "";
        switch (seat.getStatus()) {
            case Status.CLOSED:
                int position = seat.getIndex() + 1;
                msg = "“麦位" + position + "”已打开”";
                msgError = "“麦位" + position + "”打开失败”";
                break;
            case Status.FORBID:
            case Status.AUDIO_MUTED:
                msg = "“该麦位已“解除语音屏蔽”";
                msgError = "该麦位“解除语音屏蔽”失败";
                break;
            case Status.AUDIO_CLOSED_AND_MUTED:
                msg = "该麦位已“解除语音屏蔽”";
                msgError = "该麦位“解除语音屏蔽”失败";
                break;
        }
        String text = msg;
        String textError = msgError;

        anchor.openSeat(seat, new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                ToastHelper.showToast(text);
            }

            @Override
            public void onFailed(int i) {
                ToastHelper.showToast(textError + " code " + i);
            }

            @Override
            public void onException(Throwable throwable) {
                ToastHelper.showToast(textError + " " + throwable.getMessage());
            }
        });
    }

    private void closeSeat(VoiceRoomSeat seat) {
        final String text = "\"麦位" + (seat.getIndex() + 1) + "\"已关闭";
        anchor.closeSeat(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                ToastHelper.showToast(text);
            }
        });
    }

    private void muteSeat(VoiceRoomSeat seat) {
        final String text = "该麦位语音已被屏蔽，无法发言";
        anchor.muteSeat(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                ToastHelper.showToast(text);
            }
        });
    }

    private int inviteIndex = -1;

    private void inviteSeat0(VoiceRoomSeat seat) {
        inviteIndex = seat.getIndex();
        anchor.fetchSeats(new SuccessCallback<List<VoiceRoomSeat>>() {
            @Override
            public void onSuccess(List<VoiceRoomSeat> param) {
                MemberSelectActivity.selectWithExcludeAccounts(AnchorActivity.this,
                        voiceRoomInfo,
                        getOnSeatAccounts(param), CODE_INVITE_SEAT);
            }
        });
    }

    private static List<String> getOnSeatAccounts(List<VoiceRoomSeat> seats) {
        List<String> accounts = new ArrayList<>();
        for (VoiceRoomSeat seat : seats) {
            if (seat.isOn()) {
                String account = seat.getAccount();
                if (!TextUtils.isEmpty(account)) {
                    accounts.add(account);
                }
            }
        }
        return accounts;
    }

    private void inviteSeat(@NonNull VoiceRoomUser member) {
        anchor.getRoomQuery().isMember(member.getAccount(), new SuccessCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean in) {
                if (!in) {
                    ToastHelper.showToast("操作失败:用户离开房间");
                    return;
                }
                anchor.fetchSeats(new SuccessCallback<List<VoiceRoomSeat>>() {
                    @Override
                    public void onSuccess(List<VoiceRoomSeat> seats) {
                        inviteSeat(member, inviteIndex, seats);
                    }
                });
            }
        });
    }

    private void inviteSeat(@NonNull VoiceRoomUser member,
                            int index,
                            @NonNull List<VoiceRoomSeat> seats) {
        String account = member.getAccount();
        VoiceRoomSeat sel = VoiceRoomSeat.find(seats, account);
        if (sel != null && sel.isOn()) {
            ToastHelper.showToast("操作失败:当前用户已在麦位上");
            return;
        }

        int position = -1;//当前用户申请麦位位置
        if (sel != null && sel.getStatus() == Status.APPLY) {
            position = sel.getIndex();
        }

        //拒绝申请麦位上不是选中用户的观众
        VoiceRoomSeat local = anchor.getSeat(index);
        if (local.getStatus() == Status.APPLY
                && !local.isSameAccount(account)) {
            denySeatApply(local);
        }

        //拒绝选中用户的观众在别的麦位的申请
        if (position != -1 && position != index) {
            denySeatApply(anchor.getSeat(position));
        }
        inviteSeat(new VoiceRoomSeat(index,
                seats.get(index).getStatus() == Status.FORBID ? Status.FORBID : Status.ON, Reason.ANCHOR_INVITE, member
        ));
    }

    private void inviteSeat(VoiceRoomSeat seat) {
        VoiceRoomUser user = seat.getUser();
        String nick = user != null ? user.getNick() : "";
        final String text = "已将" + nick + "抱上麦位" + (seat.getIndex() + 1);

        boolean ret = anchor.inviteSeat(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                ToastHelper.showToast(text);
            }
        });
        if (!ret) {
            denySeatApply(seat);
        }
    }

    private void kickSeat(@NonNull VoiceRoomSeat seat) {
        VoiceRoomUser user = seat.getUser();
        String nick = user != null ? user.getNick() : "";
        final String text = "已将“" + nick + "”踢下麦位";

        anchor.kickSeat(seat, new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                ToastHelper.showToast(text);
            }
        });
    }

    private void closeRoom(Runnable runnable) {
        ChatRoomHttpClient.getInstance().closeRoom(DemoCache.getAccountId(),
                voiceRoomInfo.getRoomId(), new ChatRoomHttpClient.ChatRoomHttpCallback() {
                    @Override
                    public void onSuccess(Object o) {
                        loadService.showSuccess();
                        ToastHelper.showToast("退出房间成功");
                        if (runnable != null) {
                            runnable.run();
                        }
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        ToastHelper.showToast("房间解散失败" + errorMsg);
                        if (runnable != null) {
                            runnable.run();
                        }
                    }
                });
    }
}

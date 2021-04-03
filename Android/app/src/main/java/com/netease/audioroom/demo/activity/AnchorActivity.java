package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaMetadataRetriever;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.ChatRoomAudioDialog;
import com.netease.audioroom.demo.dialog.ChatRoomMoreDialog;
import com.netease.audioroom.demo.dialog.ChoiceDialog;
import com.netease.audioroom.demo.dialog.ListItemDialog;
import com.netease.audioroom.demo.dialog.MemberSelectDialog;
import com.netease.audioroom.demo.dialog.SeatApplyDialog;
import com.netease.audioroom.demo.dialog.TopTipsDialog;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.util.AudioChooser;
import com.netease.audioroom.demo.util.CommonUtil;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.NetworkChange;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.OnItemClickListener;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 主播页
 */
public class AnchorActivity extends VoiceRoomBaseActivity implements Anchor.Callback {
    private static final int CODE_SELECT_FILE = 10001;

    private static final List<ChatRoomMoreDialog.MoreItem> MORE_ITEMS = Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_MICRO_PHONE, R.drawable.selector_more_micro_phone_status, "麦克风"),
//            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_SPEAKER, R.drawable.selector_more_speaker_status, "扬声器"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_EAR_BACK, R.drawable.selector_more_ear_back_status, "耳返"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_MIXER, R.drawable.icon_room_more_mixer, "调音台"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_AUDIO, R.drawable.icon_room_more_audio, "伴音"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_FINISH, R.drawable.icon_room_more_finish, "结束")
    );

    public static void start(Context context, VoiceRoomInfo voiceRoomInfo) {
        Intent intent = new Intent(context, AnchorActivity.class);
        intent.putExtra(EXTRA_VOICE_ROOM_INFO, voiceRoomInfo);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_from_left);
        }
    }

    private TextView tvApplyHint;

    private TopTipsDialog topTipsDialog;
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
        watchNetWork();
    }

    private void watchNetWork() {
        NetworkChange.getInstance().getNetworkLiveData().observeInitAware(this, network -> {
            if (network != null && network.isConnected()) {
                if (topTipsDialog != null) {
                    topTipsDialog.dismiss();
                }
                loadSuccess();
            } else {
                Bundle bundle = new Bundle();
                TopTipsDialog.Style style = topTipsDialog.new Style(getString(R.string.network_broken), 0, R.drawable.neterrricon, 0);
                bundle.putParcelable(topTipsDialog.TAG, style);
                topTipsDialog.setArguments(bundle);
                if (!topTipsDialog.isVisible()) {
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                    topTipsDialog.setClickListener(() -> {
                    });
                }
                showNetError();
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == CODE_SELECT_FILE) {
            if (resultCode == RESULT_OK) {
                if (data != null) {
                    AudioChooser.result(this, data, path -> {
                        if (!TextUtils.isEmpty(path)) {
                            setAudioFixingFilePath(path);
                            audioPlay.setMixingFile(2, path);
                        }
                    });
                }
            }
        }
    }

    @Override
    protected void setupBaseView() {
        singView.setAnchor(true);
        topTipsDialog = new TopTipsDialog();
        tvApplyHint = findViewById(R.id.apply_hint);


        ImageView ivMuteOtherText = findViewById(R.id.iv_mute_other_text);
        ivMuteOtherText.setVisibility(View.VISIBLE);
        ivMuteOtherText.setOnClickListener(view -> MuteMembersActivity.start(AnchorActivity.this, voiceRoomInfo));
        tvApplyHint.setOnClickListener(view -> showApplySeats(anchor.getApplySeats()));

        tvApplyHint.setVisibility(View.INVISIBLE);
        tvApplyHint.setClickable(true);
    }


    @Override
    protected void onSeatItemClick(VoiceRoomSeat seat, int position) {
        if (seat.getStatus() == Status.APPLY) {
            ToastHelper.showToast(getString(R.string.applying_now));
            return;
        }
        OnItemClickListener<String> onItemClickListener = item -> {
            onSeatAction(seat, item);
        };
        List<String> items = new ArrayList<>();
        ListItemDialog itemDialog = new ListItemDialog(AnchorActivity.this);
        switch (seat.getStatus()) {
            // 抱观众上麦（点击麦位）
            case Status.INIT:
                items.add("将成员抱上麦位");
                items.add("屏蔽麦位");
                items.add("关闭麦位");
                break;
            // 当前存在有效用户
            case Status.ON:
                // 当前麦位已经关闭
            case Status.AUDIO_CLOSED:
                items.add("将TA踢下麦位");
                items.add("屏蔽麦位");
                break;
            // 当前麦位已经被关闭
            case Status.CLOSED:
                items.add("打开麦位");
                break;
            // 且当前麦位无人，麦位禁麦触发
            case Status.FORBID:
                items.add("将成员抱上麦位");
                items.add("解除语音屏蔽");
                break;
            // 当前麦位已经禁麦或已经关闭
            case Status.AUDIO_MUTED:
            case Status.AUDIO_CLOSED_AND_MUTED:
                items.add("将TA踢下麦位");
                items.add("解除语音屏蔽");
                break;
        }
        items.add(getString(R.string.cancel));
        itemDialog.setOnItemClickListener(onItemClickListener).show(items);
    }

    @Override
    protected boolean onSeatItemLongClick(VoiceRoomSeat model, int position) {
        return false;
    }

    @Override
    protected void doLeaveRoom() {
        new ChoiceDialog(AnchorActivity.this)
                .setTitle("确认结束直播？")
                .setContent("请确认是否结束直播")
                .setNegative(getString(R.string.cancel),null)
                .setPositive("确认", v -> onSeatAction(null, "退出房间"))
                .show();
    }

    @NonNull
    @Override
    protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
        MORE_ITEMS.get(MORE_ITEM_MICRO_PHONE).setEnable(!voiceRoom.isLocalAudioMute());
        MORE_ITEMS.get(MORE_ITEM_EAR_BACK).setEnable(!voiceRoom.isEarBackEnable());
//        MORE_ITEMS.get(MORE_ITEM_SPEAKER).setEnable(!voiceRoom.isRoomAudioMute());
        return MORE_ITEMS;
    }

    private void onSeatAction(VoiceRoomSeat seat, String item) {
        switch (item) {
            case "确定踢下麦位":
                new ListItemDialog(AnchorActivity.this).setOnItemClickListener(item1 -> {
                    if ("确定踢下麦位".equals(item1)){
                        kickSeat(seat);
                    }
                }).show(Arrays.asList("确定踢下麦位","取消"));
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
            case "退出房间":
                leaveRoom();
                break;
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

    private static final String MUSIC_DIR = "music";
    private static final String MUSIC1 = "music1.mp3";
    private static final String MUSIC2 = "music2.mp3";
    private static final String MUSIC3 = "music3.mp3";
    private static final String EFFECT1 = "effect1.wav";
    private static final String EFFECT2 = "effect2.wav";

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

            String[] musicPaths = new String[4];
            musicPaths[0] = extractMusicFile(root, MUSIC1);
            musicPaths[1] = extractMusicFile(root, MUSIC2);
            musicPaths[2] = extractMusicFile(root, MUSIC3);
            musicPaths[3] = getAudioFixingFilePath();

            audioPlay.setMixingFile(musicPaths);
            if (audioMixingMusicInfos == null) {
                audioMixingMusicInfos = new ArrayList<>();
            }
            audioMixingMusicInfos.clear();
            for (int i = 0; i < musicPaths.length - 1; i++) {
                String path = musicPaths[i];
                audioMixingMusicInfos.add(getMusicInfo("0" + (i + 1), path));
            }
        }).start();
    }

    /**
     * 获取音乐文件信息
     *
     * @param mediaUri 文件路径
     */
    private ChatRoomAudioDialog.MusicItem getMusicInfo(String order, String mediaUri) {
        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        mediaMetadataRetriever.setDataSource(mediaUri);
        String name = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
        String author = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
        return new ChatRoomAudioDialog.MusicItem(order, name, author);
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

    //
    // room call
    //

    @Override
    protected void initVoiceRoom() {
        super.initVoiceRoom();
        anchor = voiceRoom.getAnchor();
        audioPlay = voiceRoom.getAudioPlay();
        anchor.setCallback(this);
    }

    //
    // Anchor.Callback
    //

    @Override
    public void onApplySeats(List<VoiceRoomSeat> seats) {
        int size = seats.size();
        if (size > 0) {
            tvApplyHint.setVisibility(View.VISIBLE);
            tvApplyHint.setText(getString(R.string.apply_micro_has_arrow, size));
        } else {
            tvApplyHint.setVisibility(View.INVISIBLE);
        }
        if (size > 0) {
            if (seatApplyDialog != null && seatApplyDialog.isVisible()) {
                seatApplyDialog.update(seats);
            }
        } else {
            if (seatApplyDialog != null && seatApplyDialog.isVisible()) {
                seatApplyDialog.dismiss();
            }
        }
    }

    //
    // RoomCallback
    //

    @Override
    public void onLeaveRoom() {
        Runnable runnable = AnchorActivity.super::onLeaveRoom;
        closeRoom(runnable);
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
                new MemberSelectDialog(AnchorActivity.this, getOnSeatAccounts(param), member -> {
                    //被抱用户
                    if (member != null) {
                        inviteSeat(member);
                    }
                }).show();
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
        List<VoiceRoomSeat> userSeats = VoiceRoomSeat.find(seats, account);

        for (VoiceRoomSeat seat : userSeats) {
            if (seat != null && seat.isOn()) {
                ToastHelper.showToast("操作失败:当前用户已在麦位上");
                return;
            }
        }

        int position = -1;//当前用户申请麦位位置
        VoiceRoomSeat seat = VoiceRoomSeat.findByStatus(userSeats, account, Status.APPLY);
        if (seat != null) {
            position = seat.getIndex();
        }

        //拒绝申请麦位上不是选中用户的观众
        VoiceRoomSeat local = anchor.getSeat(index);
        if (local.getStatus() == Status.APPLY && !local.isSameAccount(account)) {
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
                        loadSuccess();
                        ToastHelper.showToast("退出房间成功");
                        if (runnable != null) {
                            runnable.run();
                        }
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        if (!Network.getInstance().isConnected()) {
                            ToastHelper.showToast("网络问题导致房间解散失败");
                        } else {
                            ToastHelper.showToast("房间解散失败 " + errorMsg);
                        }
                        if (runnable != null) {
                            runnable.run();
                        }
                    }
                });
    }
}

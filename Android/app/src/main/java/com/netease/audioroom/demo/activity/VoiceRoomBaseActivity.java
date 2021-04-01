package com.netease.audioroom.demo.activity;

import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.gyf.immersionbar.ImmersionBar;
import com.netease.audioroom.demo.BuildConfig;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MessageListAdapter;
import com.netease.audioroom.demo.adapter.SeatAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.ChatRoomAudioDialog;
import com.netease.audioroom.demo.dialog.ChatRoomMixerDialog;
import com.netease.audioroom.demo.dialog.ChatRoomMoreDialog;
import com.netease.audioroom.demo.dialog.ChoiceDialog;
import com.netease.audioroom.demo.dialog.MusicMenuDialog;
import com.netease.audioroom.demo.dialog.NoticeDialog;
import com.netease.audioroom.demo.dialog.NotificationDialog;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.InputUtils;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.util.ViewUtils;
import com.netease.audioroom.demo.widget.HeadImageView;
import com.netease.audioroom.demo.widget.SingingControlView;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
import com.netease.audioroom.demo.widget.VolumeSetup;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomMessage;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicChangeListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.Collections;
import java.util.List;

/**
 * 主播与观众基础页，包含所有的通用UI元素
 */
public abstract class VoiceRoomBaseActivity extends BaseActivity implements RoomCallback,
        ViewTreeObserver.OnGlobalLayoutListener {

    public static final String TAG = "AudioRoom";

    public static final String EXTRA_VOICE_ROOM_INFO = "extra_voice_room_info";

    private static final int KEY_BOARD_MIN_SIZE = ScreenUtil.dip2px(DemoCache.getContext(), 80);

    protected static final int MORE_ITEM_MICRO_PHONE = 0;

//    protected static final int MORE_ITEM_SPEAKER = 1;

    protected static final int MORE_ITEM_EAR_BACK = 2 - 1;

    protected static final int MORE_ITEM_MIXER = 3 - 1;

    protected static final int MORE_ITEM_AUDIO = 4 - 1;

    protected static final int MORE_ITEM_FINISH = 5 - 1;

    protected NERtcVoiceRoom voiceRoom;

    /**
     * 混音文件信息
     */
    protected List<ChatRoomAudioDialog.MusicItem> audioMixingMusicInfos;

    protected ChatRoomMoreDialog.OnItemClickListener onMoreItemClickListener = (dialog, itemView, item) -> {
        switch (item.id) {
            case MORE_ITEM_MICRO_PHONE: {
                item.enable = !voiceRoom.isLocalAudioMute();
                toggleMuteLocalAudio();
                break;
            }
//            case MORE_ITEM_SPEAKER: {
//                item.enable = !voiceRoom.isRoomAudioMute();
//                toggleMuteRoomAudio();
//                break;
//            }
            case MORE_ITEM_EAR_BACK: {
                item.enable = !voiceRoom.isEarBackEnable();
                enableEarback(item.enable);
                break;
            }
            case MORE_ITEM_MIXER: {
                if (dialog != null && dialog.isShowing()) {
                    dialog.dismiss();
                }
                showChatRoomMixerDialog();
                break;
            }
            case MORE_ITEM_AUDIO: {
                if (dialog != null && dialog.isShowing()) {
                    dialog.dismiss();
                }
                new ChatRoomAudioDialog(VoiceRoomBaseActivity.this, voiceRoom, audioMixingMusicInfos).show();
                break;
            }
            case MORE_ITEM_FINISH: {
                if (dialog != null && dialog.isShowing()) {
                    dialog.dismiss();
                }
                doLeaveRoom();
                break;
            }
        }
        return true;
    };

    //ktv
    protected SingingControlView singView;

    protected ConstraintLayout clyAnchorView;

    protected MusicMenuDialog musicMenuDialog;

    protected MusicChangeListener musicChangeListener;

    protected TextView tvOrderMusic;

    protected TextView tvOrderedNum;

    protected boolean isKtvModel;

    //主播基础信息
    protected HeadImageView ivAnchorAvatar;

    protected ImageView ivAnchorAudioCloseHint;

    protected ImageView ivAnchorSiniging;

    protected TextView tvAnchorNick;

    protected TextView tvRoomName;

    protected TextView tvMemberCount;

    private ImageView ivAnchorVolume;

    // 各种控制开关
    protected FrameLayout settingsContainer;

    protected ImageView ivLocalAudioSwitch;

    protected ImageView ivRoomAudioSwitch;

    protected TextView tvInput;

    protected ImageView ivSettingSwitch;

    protected EditText edtInput;

    protected View more;

    //聊天室队列（麦位）
    protected RecyclerView recyclerView;

    protected SeatAdapter seatAdapter;

    //消息列表
    protected RecyclerView rcyChatMsgList;

    private LinearLayoutManager msgLayoutManager;

    protected MessageListAdapter msgAdapter;

    private int rootViewVisibleHeight;

    private View rootView;

    private View announcement;

    private BaseAdapter.ItemClickListener<VoiceRoomSeat> itemClickListener = this::onSeatItemClick;

    private BaseAdapter.ItemLongClickListener<VoiceRoomSeat> itemLongClickListener = this::onSeatItemLongClick;

    protected VoiceRoomInfo voiceRoomInfo;

    protected String anchorUserId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // 屏幕常亮
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        voiceRoomInfo = (VoiceRoomInfo) getIntent().getSerializableExtra(EXTRA_VOICE_ROOM_INFO);
        if (voiceRoomInfo == null) {
            ToastHelper.showToast("聊天室信息不能为空");
            finish();
            return;
        }
        isKtvModel = voiceRoomInfo.getRoomType() == ChatRoomNetConstants.ROOM_TYPE_KTV;
        ImmersionBar.with(this).statusBarDarkFont(false).init();
        initVoiceRoom();
        initViews();
    }

    private void initSingView() {
        singView.setVoiceRoom(voiceRoom);
        singView.setUserInfo(createUser());
        singView.setControlCallBack(() -> showChatRoomMixerDialog());
        musicChangeListener = new MusicChangeListener() {

            @Override
            public void onListChange(List<MusicOrderedItem> musicList, boolean isInit) {
                if (musicList == null || musicList.size() == 0) {
                    singView.noSongOrdered();
                    tvOrderedNum.setVisibility(View.GONE);
                    updateSeat("");
                    voiceRoom.getAudioPlay().onSingFinish(true, false);
                    singView.cancelReady();
                } else {
                    tvOrderedNum.setVisibility(View.VISIBLE);
                    voiceRoom.getAudioPlay().onSingStart();
                    tvOrderedNum.setText(String.valueOf(musicList.size()));
                    if (musicList.size() > 1) {
                        singView.updateNextSong(musicList.get(1));
                    } else {
                        singView.updateNextSong(null);
                    }
                }
            }

            @Override
            public void onSongChange(MusicOrderedItem music, boolean isMy, boolean isInit) {
                if (music == null) {
                    return;
                }
                singView.cancelReady();
                if (music.countTimeSec <= 0) {
                    singView.onMusicSing(music, isMy, true);
                } else {
                    singView.onReady(music, isMy);
                    voiceRoom.getAudioPlay().onSingFinish(false, true);
                }
                updateSeat(music.userId);
            }

            @Override
            public void onError(String msg) {
                ToastHelper.showToast(msg);
            }


        };
    }

    protected void updateSeat(String userId) {
        seatAdapter.setSingUser(userId);
        if (!TextUtils.isEmpty(anchorUserId) && !TextUtils.isEmpty(userId) && TextUtils.equals(userId, anchorUserId)) {
            ivAnchorSiniging.setVisibility(View.VISIBLE);
        } else {
            ivAnchorSiniging.setVisibility(View.GONE);
        }
    }

    private void initViews() {
        findBaseView();
        setupBaseViewInner();
        setupBaseView();
        rootView = getWindow().getDecorView();
        rootView.getViewTreeObserver().addOnGlobalLayoutListener(this);
        requestLivePermission();
    }

    @Override
    protected void onDestroy() {
        if (rootView != null) {
            rootView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
        }
        MusicSing.shareInstance().removeMusicChangeListener(musicChangeListener);
        MusicSing.shareInstance().reset();
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        if (settingsContainer.getVisibility() == View.VISIBLE) {
            settingsContainer.setVisibility(View.GONE);
            return;
        }
        leaveRoom();
        super.onBackPressed();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (Network.getInstance().isConnected()) {
            loadSuccess();
        } else {
            showNetError();
        }
    }

    @Override
    public void onGlobalLayout() {
        int preHeight = rootViewVisibleHeight;
        //获取当前根视图在屏幕上显示的大小
        Rect r = new Rect();
        rootView.getWindowVisibleDisplayFrame(r);
        rootViewVisibleHeight = r.height();
        if (preHeight == 0 || preHeight == rootViewVisibleHeight) {
            return;
        }
        //根视图显示高度变大超过KEY_BOARD_MIN_SIZE，可以看作软键盘隐藏了
        if (rootViewVisibleHeight - preHeight >= KEY_BOARD_MIN_SIZE) {
            scrollToBottom();
            return;
        }
    }

    private void findBaseView() {
        View baseAudioView = findViewById(R.id.rl_base_audio_ui);
        if (baseAudioView == null) {
            throw new IllegalStateException("xml layout must include base_audio_ui.xml layout");
        }
        if (isKtvModel) {
            baseAudioView.setBackgroundResource(R.drawable.ktv_bg_image);
        }
        int barHeight = ImmersionBar.getStatusBarHeight(this);
        baseAudioView.setPadding(baseAudioView.getPaddingLeft(), baseAudioView.getPaddingTop() + barHeight,
                baseAudioView.getPaddingRight(), baseAudioView.getPaddingBottom());
        singView = baseAudioView.findViewById(R.id.sing_view);
        clyAnchorView = baseAudioView.findViewById(R.id.cly_anchor_layout);
        ivAnchorAvatar = baseAudioView.findViewById(R.id.iv_liver_avatar);
        ivAnchorAudioCloseHint = baseAudioView.findViewById(R.id.iv_liver_audio_close_hint);
        ivAnchorSiniging = baseAudioView.findViewById(R.id.iv_anchor_singing);
        tvAnchorNick = baseAudioView.findViewById(R.id.tv_liver_nick);
        tvRoomName = baseAudioView.findViewById(R.id.tv_chat_room_name);
        tvMemberCount = baseAudioView.findViewById(R.id.tv_chat_room_member_count);
        settingsContainer = findViewById(R.id.settings_container);
        tvOrderMusic = findViewById(R.id.tv_order_music);
        tvOrderedNum = findViewById(R.id.tv_ordered_num);
        settingsContainer.setOnClickListener(view -> settingsContainer.setVisibility(View.GONE));
        ivSettingSwitch = baseAudioView.findViewById(R.id.iv_settings);
        ivSettingSwitch.setOnClickListener(view -> settingsContainer.setVisibility(View.VISIBLE));
        findViewById(R.id.settings_action_container).setOnClickListener(view -> {
        });
        SeekBar skRecordingVolume = settingsContainer.findViewById(R.id.recording_volume_control);
        skRecordingVolume.setOnSeekBarChangeListener(new VolumeSetup() {

            @Override
            protected void onVolume(int volume) {
                setAudioCaptureVolume(volume);
            }
        });
        SwitchCompat switchEarBack = settingsContainer.findViewById(R.id.ear_back);
        switchEarBack.setChecked(false);
        switchEarBack.setOnCheckedChangeListener((buttonView, isChecked) -> enableEarback(isChecked));
        more = baseAudioView.findViewById(R.id.iv_room_more);
        more.setOnClickListener(v -> new ChatRoomMoreDialog(VoiceRoomBaseActivity.this, getMoreItems())
                .registerOnItemClickListener(getMoreItemClickListener()).show());
        ivLocalAudioSwitch = baseAudioView.findViewById(R.id.iv_local_audio_switch);
        ivLocalAudioSwitch.setOnClickListener(view -> toggleMuteLocalAudio());
        ivRoomAudioSwitch = baseAudioView.findViewById(R.id.iv_room_audio_switch);
        ivRoomAudioSwitch.setOnClickListener(view -> toggleMuteRoomAudio());
        baseAudioView.findViewById(R.id.iv_leave_room).setOnClickListener(view -> doLeaveRoom());
        ivAnchorVolume = baseAudioView.findViewById(R.id.circle);
        recyclerView = baseAudioView.findViewById(R.id.recyclerview_seat);
        rcyChatMsgList = baseAudioView.findViewById(R.id.rcy_chat_message_list);
        tvInput = baseAudioView.findViewById(R.id.tv_input_text);
        tvInput.setOnClickListener(v -> InputUtils.showSoftInput(VoiceRoomBaseActivity.this, edtInput));
        edtInput = baseAudioView.findViewById(R.id.edt_input_text);
        edtInput.setOnEditorActionListener((v, actionId, event) -> {
            InputUtils.hideSoftInput(VoiceRoomBaseActivity.this, edtInput);
            sendTextMessage();
            return true;
        });
        InputUtils.registerSoftInputListener(this, new InputUtils.InputParamHelper() {

            @Override
            public int getHeight() {
                return baseAudioView.getHeight();
            }

            @Override
            public EditText getInputView() {
                return edtInput;
            }
        });
        announcement = baseAudioView.findViewById(R.id.tv_chat_room_announcement);
        announcement.setOnClickListener(v -> {
            NoticeDialog noticeDialog = new NoticeDialog();
            noticeDialog.show(getSupportFragmentManager(), noticeDialog.TAG);
        });
    }

    protected void doLeaveRoom() {
        leaveRoom();
    }

    private void setupBaseViewInner() {
        String name = voiceRoomInfo.getName();
        name = TextUtils.isEmpty(name) ? voiceRoomInfo.getRoomId() : name;
        tvRoomName.setText(name);
        String count = "在线" + voiceRoomInfo.getOnlineUserCount() + "人";
        tvMemberCount.setText(count);
        if (isKtvModel) {
            setKtvView();
            LinearLayoutManager layoutManager = new LinearLayoutManager(this);
            layoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
            recyclerView.setLayoutManager(layoutManager);
            seatAdapter = new SeatAdapter(null, this, true);
            initSingView();
        } else {
            recyclerView.setLayoutManager(new GridLayoutManager(this, 4));
            seatAdapter = new SeatAdapter(null, this);
        }
        recyclerView.setAdapter(seatAdapter);
        seatAdapter.setItemClickListener(itemClickListener);
        seatAdapter.setItemLongClickListener(itemLongClickListener);
        msgLayoutManager = new LinearLayoutManager(this);
        rcyChatMsgList.setLayoutManager(msgLayoutManager);
        msgAdapter = new MessageListAdapter(null, this);
        rcyChatMsgList.addItemDecoration(new VerticalItemDecoration(Color.TRANSPARENT, ScreenUtil.dip2px(this, 5)));
        rcyChatMsgList.setAdapter(msgAdapter);

    }

    /**
     * 设置KTV布局
     */
    private void setKtvView() {
        tvOrderMusic.setVisibility(View.VISIBLE);
        tvOrderMusic.setOnClickListener((view) -> {
            showMusicMenuDialog();
        });
        ConstraintSet constraintSet = new ConstraintSet();
        constraintSet.clone(clyAnchorView);
        constraintSet.setVisibility(R.id.sing_view, ConstraintSet.VISIBLE);
        constraintSet.clear(R.id.cly_anchor_avatar);
        constraintSet.constrainHeight(R.id.cly_anchor_avatar, ConstraintSet.WRAP_CONTENT);
        constraintSet.constrainWidth(R.id.cly_anchor_avatar, ConstraintSet.WRAP_CONTENT);
        constraintSet.connect(R.id.cly_anchor_avatar, ConstraintSet.TOP, R.id.sing_view, ConstraintSet.BOTTOM);
        constraintSet.connect(R.id.cly_anchor_avatar, ConstraintSet.START, R.id.sing_view, ConstraintSet.START);
        constraintSet.clear(R.id.tv_liver_nick);
        constraintSet.constrainHeight(R.id.tv_liver_nick, ConstraintSet.WRAP_CONTENT);
        constraintSet.constrainWidth(R.id.tv_liver_nick, ScreenUtil.dip2px(this, 40));
        constraintSet.connect(R.id.tv_liver_nick, ConstraintSet.TOP, R.id.cly_anchor_avatar, ConstraintSet.BOTTOM,
                ScreenUtil.dip2px(this, 10));
        constraintSet.connect(R.id.tv_liver_nick, ConstraintSet.START, R.id.cly_anchor_avatar, ConstraintSet.START);
        constraintSet.connect(R.id.tv_liver_nick, ConstraintSet.END, R.id.cly_anchor_avatar, ConstraintSet.END);
        constraintSet.clear(R.id.recyclerview_seat);
        constraintSet.constrainHeight(R.id.recyclerview_seat, ConstraintSet.WRAP_CONTENT);
        constraintSet.constrainWidth(R.id.recyclerview_seat, ConstraintSet.MATCH_CONSTRAINT);
        constraintSet.connect(R.id.recyclerview_seat, ConstraintSet.START, R.id.cly_anchor_avatar, ConstraintSet.END,
                ScreenUtil.dip2px(this, 10));
        constraintSet.connect(R.id.recyclerview_seat, ConstraintSet.END, R.id.sing_view, ConstraintSet.END);
        constraintSet.connect(R.id.recyclerview_seat, ConstraintSet.TOP, R.id.cly_anchor_avatar, ConstraintSet.TOP);
        constraintSet.applyTo(clyAnchorView);
        ConstraintLayout clyAnchorAvatar = findViewById(R.id.cly_anchor_avatar);
        ConstraintSet constraintSetAvatar = new ConstraintSet();
        constraintSetAvatar.clone(clyAnchorAvatar);

        constraintSetAvatar.constrainWidth(R.id.circle, ScreenUtil.dip2px(this, 40));
        constraintSetAvatar.constrainHeight(R.id.circle, ScreenUtil.dip2px(this, 40));
        constraintSetAvatar.constrainWidth(R.id.frame, ScreenUtil.dip2px(this, 40));
        constraintSetAvatar.constrainHeight(R.id.frame, ScreenUtil.dip2px(this, 40));
        constraintSetAvatar.applyTo(clyAnchorAvatar);
        singView.setOrder((view) -> showMusicMenuDialog());
    }

    protected void scrollToBottom() {
        msgLayoutManager.scrollToPosition(msgAdapter.getItemCount() - 1);
    }

    protected abstract int getContentViewID();

    protected abstract void setupBaseView();

    protected abstract void onSeatItemClick(VoiceRoomSeat model, int position);

    protected abstract boolean onSeatItemLongClick(VoiceRoomSeat model, int position);

    @NonNull
    protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
        return Collections.emptyList();
    }

    protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
        return onMoreItemClickListener;
    }
    //
    // NERtcVoiceRoom call
    //

    protected void initVoiceRoom() {
        NERtcVoiceRoom.setAccountMapper(AccountInfo::accountToVoiceUid);
        NERtcVoiceRoom.setMessageTextBuilder(messageTextBuilder);
        voiceRoom = NERtcVoiceRoom.sharedInstance(this);
        voiceRoom.init(BuildConfig.NERTC_APP_KEY, this);
        voiceRoom.initRoom(voiceRoomInfo, createUser());
    }

    @Override
    protected void showNetError() {
        super.showNetError();
        if (isKtvModel) {
            voiceRoom.getAudioPlay().pauseKtvMusic();
        }
    }

    @Override
    protected void loadSuccess() {
        super.loadSuccess();
        if (isKtvModel && singView != null && !singView.getPaused()) {
            voiceRoom.getAudioPlay().resumeKtvMusic();
        }
    }


    protected final void enterRoom(boolean anchorMode) {
        voiceRoom.enterRoom(anchorMode);
    }

    protected final void leaveRoom() {
        voiceRoom.leaveRoom();
    }

    protected final void toggleMuteLocalAudio() {
        boolean muted = voiceRoom.muteLocalAudio(!voiceRoom.isLocalAudioMute());
        if (muted) {
            ToastHelper.showToast("话筒已关闭");
        } else {
            ToastHelper.showToast("话筒已打开");
        }
    }

    protected final void toggleMuteRoomAudio() {
        boolean muted = voiceRoom.muteRoomAudio(!voiceRoom.isRoomAudioMute());
        if (muted) {
            ToastHelper.showToast("已关闭“聊天室声音”");
        } else {
            ToastHelper.showToast("已打开“聊天室声音”");
        }
        ivRoomAudioSwitch.setSelected(muted);
    }

    protected void setAudioCaptureVolume(int volume) {
        voiceRoom.setAudioCaptureVolume(volume);
    }

    protected void enableEarback(boolean enable) {
        voiceRoom.enableEarback(enable);
    }

    private void sendTextMessage() {
        String content = edtInput.getText().toString().trim();
        if (TextUtils.isEmpty(content)) {
            ToastHelper.showToast("请输入消息内容");
            return;
        }
        voiceRoom.sendTextMessage(content);
    }
    //
    // RoomCallback
    //

    @Override
    public void onEnterRoom(boolean success) {
        if (!success) {
            ToastHelper.showToast("进入聊天室失败");
            finish();
        } else {
            loadSuccess();
            if (isKtvModel) {
                MusicSing.shareInstance().addMusicChangeListener(musicChangeListener);
            }
        }
    }

    @Override
    public void onLeaveRoom() {
        finish();
    }

    @Override
    public void onRoomDismiss() {
        if (isKtvModel) {
            voiceRoom.getAudioPlay().onSingFinish(true, false);
        }
        ChoiceDialog dialog = new NotificationDialog(this).setTitle("通知").setContent("该房间已被主播解散").setPositive("知道了",
                v -> {
                    leaveRoom();
                    if (voiceRoomInfo
                            .isSupportCDN()) {
                        finish();
                    }
                });
        dialog.setCancelable(false);
        dialog.show();
    }

    @Override
    public void onOnlineUserCount(int onlineUserCount) {
        String count = "在线" + onlineUserCount + "人";
        tvMemberCount.setText(count);
    }

    @Override
    public void onAnchorInfo(VoiceRoomUser user) {
        ivAnchorAvatar.loadAvatar(user.avatar);
        tvAnchorNick.setText(user.nick);
        anchorUserId = user.account;
    }

    @Override
    public void onAnchorMute(boolean muted) {
        ivAnchorAudioCloseHint.setImageResource(muted ? R.drawable.icon_seat_close_micro : R.drawable.icon_seat_open_micro);
    }

    @Override
    public void onAnchorVolume(int volume) {
        showVolume(ivAnchorVolume, volume);
    }

    @Override
    public void onMute(boolean muted) {
        ivLocalAudioSwitch.setSelected(muted);
    }

    @Override
    public void updateSeats(List<VoiceRoomSeat> seats) {
        seatAdapter.setItems(seats);
    }

    @Override
    public void onMusicStateChange(int type) {
        singView.onMusicStateChange(type);
    }

    @Override
    public void updateSeat(VoiceRoomSeat seat) {
        seatAdapter.updateItem(seat.getIndex(), seat);
    }

    @Override
    public void onSeatVolume(VoiceRoomSeat seat, int volume) {
        if (recyclerView == null) {
            recyclerView = findViewById(R.id.rl_base_audio_ui).findViewById(R.id.recyclerview_seat);
        }
        if (recyclerView.getLayoutManager() == null) {
            recyclerView.setLayoutManager(new GridLayoutManager(this, 4));

        }
        View itemView = recyclerView.getLayoutManager().findViewByPosition(seat.getIndex());
        if (itemView != null) {
            ImageView circle = itemView.findViewById(R.id.circle);
            showVolume(circle, volume);
        }
    }

    @Override
    public void onVoiceRoomMessage(VoiceRoomMessage message) {
        msgAdapter.appendItem(message);
        scrollToBottom();
    }

    private static void showVolume(ImageView view, int volume) {
        volume = toStepVolume(volume);
        if (volume == 0) {
            view.setVisibility(View.INVISIBLE);
        } else {
            view.setVisibility(View.VISIBLE);
        }
    }

    private static int toStepVolume(int volume) {
        int step = 0;
        volume /= 40;
        while (volume > 0) {
            step++;
            volume /= 2;
        }
        if (step > 8) {
            step = 8;
        }
        return step;
    }

    private static final VoiceRoomMessage.MessageTextBuilder messageTextBuilder = new VoiceRoomMessage.MessageTextBuilder() {

        @Override
        public String roomEvent(String nick, boolean enter) {
            String who = "“" + nick + "”";
            String action = enter ? "进了房间" : "离开了房间";
            return who + action;
        }

        @Override
        public String seatEvent(VoiceRoomSeat seat, boolean enter) {
            VoiceRoomUser user = seat.getUser();
            String nick = user != null ? user.getNick() : "";
            String who = "“" + nick + "”";
            String action = enter ? "进入了麦位" : "退出了麦位";
            int position = seat.getIndex() + 1;
            return who + action + position;
        }

        @Override
        public String musicEvent(String nick, boolean isPause) {
            String who = "“" + nick + "”";
            String action = isPause ? "暂停音乐" : "恢复演唱";
            return who + action;
        }

    };

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        int x = (int) ev.getRawX();
        int y = (int) ev.getRawY();
        // 键盘区域外点击收起键盘
        if (!ViewUtils.isInView(edtInput, x, y)) {
            InputUtils.hideSoftInput(VoiceRoomBaseActivity.this, edtInput);
        }
        return super.dispatchTouchEvent(ev);
    }

    private void showMusicMenuDialog() {
        if (musicMenuDialog == null) {
            musicMenuDialog = new MusicMenuDialog();
        }
        musicMenuDialog.setUser(createUser());
        musicMenuDialog.show(getSupportFragmentManager(), musicMenuDialog.TAG);
    }

    /**
     * 显示调音台
     */
    public void showChatRoomMixerDialog() {
        new ChatRoomMixerDialog(VoiceRoomBaseActivity.this, voiceRoom, isKtvModel).show();
    }
}

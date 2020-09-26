package com.netease.audioroom.demo.activity;

import android.graphics.Color;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewTreeObserver;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.audioroom.demo.BuildConfig;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MessageListAdapter;
import com.netease.audioroom.demo.adapter.SeatAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.TipsDialog;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.HeadImageView;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.NetErrCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomMessage;

import java.util.List;

/**
 * 主播与观众基础页，包含所有的通用UI元素
 */
public abstract class VoiceRoomBaseActivity extends BaseActivity implements RoomCallback, ViewTreeObserver.OnGlobalLayoutListener {
    public static final String EXTRA_VOICE_ROOM_INFO = "extra_voice_room_info";

    public static final String TAG = "AudioRoom";

    private static final int KEY_BOARD_MIN_SIZE = ScreenUtil.dip2px(DemoCache.getContext(), 80);

    //主播基础信息
    protected HeadImageView ivAnchorAvatar;
    protected ImageView ivAnchorAudioCloseHint;
    protected TextView tvAnchorNick;
    protected TextView tvRoomName;
    private ImageView ivAnchorVolume;

    // 各种控制开关
    protected FrameLayout settingsContainer;
    protected ImageView ivLocalAudioSwitch;
    protected ImageView ivRoomAudioSwitch;
    protected EditText edtInput;
    protected TextView sendButton;

    //聊天室队列（麦位）
    protected RecyclerView recyclerView;

    protected SeatAdapter seatAdapter;

    //消息列表
    protected RecyclerView rcyChatMsgList;
    private LinearLayoutManager msgLayoutManager;
    protected MessageListAdapter msgAdapter;

    private int rootViewVisibleHeight;
    private View rootView;

    private BaseAdapter.ItemClickListener<VoiceRoomSeat> itemClickListener = this::onSeatItemClick;
    private BaseAdapter.ItemLongClickListener<VoiceRoomSeat> itemLongClickListener = this::onSeatItemLongClick;

    protected VoiceRoomInfo voiceRoomInfo;
    protected NERtcVoiceRoom voiceRoom;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        voiceRoomInfo = (VoiceRoomInfo) getIntent().getSerializableExtra(EXTRA_VOICE_ROOM_INFO);
        if (voiceRoomInfo == null) {
            ToastHelper.showToast("聊天室信息不能为空");
            finish();
            return;
        }

        initVoiceRoom();

        initViews();
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
            loadService.showSuccess();
        } else {
            loadService.showCallback(NetErrCallback.class);
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

        ivAnchorAvatar = baseAudioView.findViewById(R.id.iv_liver_avatar);
        ivAnchorAudioCloseHint = baseAudioView.findViewById(R.id.iv_liver_audio_close_hint);
        tvAnchorNick = baseAudioView.findViewById(R.id.tv_liver_nick);

        tvRoomName = baseAudioView.findViewById(R.id.tv_chat_room_name);

        settingsContainer = findViewById(R.id.settings_container);
        settingsContainer.setOnClickListener(view -> settingsContainer.setVisibility(View.GONE));
        baseAudioView.findViewById(R.id.iv_settings).setOnClickListener(view -> settingsContainer.setVisibility(View.VISIBLE));
        findViewById(R.id.settings_action_container).setOnClickListener(view -> {});
        SeekBar skRecordingVolume = settingsContainer.findViewById(R.id.recording_volume_control);
        skRecordingVolume.setOnSeekBarChangeListener(new VolumeSetup() {
            @Override
            protected void onVolume(int volume) {
                setAudioCaptureVolume(volume);
            }
        });
        SwitchCompat switchEarBack = settingsContainer.findViewById(R.id.ear_back);
        switchEarBack.setChecked(true);
        switchEarBack.setOnCheckedChangeListener((buttonView, isChecked) -> enableEarback(isChecked));


        ivLocalAudioSwitch = baseAudioView.findViewById(R.id.iv_local_audio_switch);
        ivLocalAudioSwitch.setOnClickListener(view -> toggleMuteLocalAudio());
        ivRoomAudioSwitch = baseAudioView.findViewById(R.id.iv_room_audio_switch);
        ivRoomAudioSwitch.setOnClickListener(view -> toggleMuteRoomAudio());
        baseAudioView.findViewById(R.id.iv_leave_room).setOnClickListener(view -> doLeaveRoom());
        ivAnchorVolume = baseAudioView.findViewById(R.id.circle);

        recyclerView = baseAudioView.findViewById(R.id.recyclerview_seat);
        rcyChatMsgList = baseAudioView.findViewById(R.id.rcy_chat_message_list);

        edtInput = baseAudioView.findViewById(R.id.edt_input_text);
        sendButton = baseAudioView.findViewById(R.id.tv_send_text);
        sendButton.setOnClickListener((view) -> sendTextMessage());
    }

    protected void doLeaveRoom() {
        leaveRoom();
    }

    private void setupBaseViewInner() {
        String name = voiceRoomInfo.getName();
        name = "房间：" + (TextUtils.isEmpty(name) ? voiceRoomInfo.getRoomId() : name) + "（" + voiceRoomInfo.getOnlineUserCount() + "人）";
        tvRoomName.setText(name);

        recyclerView.setLayoutManager(new GridLayoutManager(this, 4));
        seatAdapter = new SeatAdapter(null, this);
        recyclerView.setAdapter(seatAdapter);

        seatAdapter.setItemClickListener(itemClickListener);
        seatAdapter.setItemLongClickListener(itemLongClickListener);

        msgLayoutManager = new LinearLayoutManager(this);
        rcyChatMsgList.setLayoutManager(msgLayoutManager);
        msgAdapter = new MessageListAdapter(null, this);
        rcyChatMsgList.addItemDecoration(new VerticalItemDecoration(Color.TRANSPARENT, ScreenUtil.dip2px(this, 9)));
        rcyChatMsgList.setAdapter(msgAdapter);
    }

    protected void scrollToBottom() {
        msgLayoutManager.scrollToPosition(msgAdapter.getItemCount() - 1);
    }

    protected abstract int getContentViewID();

    protected abstract void setupBaseView();

    protected abstract void onSeatItemClick(VoiceRoomSeat model, int position);

    protected abstract boolean onSeatItemLongClick(VoiceRoomSeat model, int position);

    //
    // NERtcVoiceRoom call
    //

    protected void initVoiceRoom() {
        NERtcVoiceRoom.setAccountMapper(AccountInfo::accountToVoiceUid);
        NERtcVoiceRoom.setMessageTextBuilder(messageTextBuilder);
        voiceRoom = NERtcVoiceRoom.sharedInstance(this);
        voiceRoom.init(BuildConfig.G2_APP_KEY, this);
        voiceRoom.initRoom(voiceRoomInfo, createUser());
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

        edtInput.setText("");
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
            loadService.showSuccess();
        }
    }

    @Override
    public void onLeaveRoom() {
        finish();
    }

    @Override
    public void onRoomDismiss() {
        TipsDialog tipsDialog = new TipsDialog();
        Bundle bundle = new Bundle();
        bundle.putString(tipsDialog.TAG, "该房间已被主播解散");
        tipsDialog.setArguments(bundle);
        tipsDialog.show(getSupportFragmentManager(), tipsDialog.TAG);
        tipsDialog.setClickListener(() -> {
            tipsDialog.dismiss();
            leaveRoom();
        });
    }

    @Override
    public void onOnlineUserCount(int onlineUserCount) {
        String name = voiceRoomInfo.getName();
        String roomId = voiceRoomInfo.getRoomId();
        name = "房间：" + (TextUtils.isEmpty(name) ? roomId : name) + "（" + onlineUserCount + "人）";
        tvRoomName.setText(name);
    }

    @Override
    public void onAnchorInfo(VoiceRoomUser user) {
        ivAnchorAvatar.loadAvatar(user.avatar);
        tvAnchorNick.setText(user.nick);
    }

    @Override
    public void onAnchorMute(boolean muted) {
        ivAnchorAudioCloseHint.setVisibility(muted ? View.VISIBLE : View.INVISIBLE);
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
        ImageView circle = recyclerView.getLayoutManager().findViewByPosition(seat.getIndex()).findViewById(R.id.circle);
        showVolume(circle, volume);
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
    };

    protected static class VolumeSetup implements SeekBar.OnSeekBarChangeListener {
        protected void onVolume(int volume) {

        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            if (fromUser) {
                onVolume(progress);
            }
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {

        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {

        }
    }
}

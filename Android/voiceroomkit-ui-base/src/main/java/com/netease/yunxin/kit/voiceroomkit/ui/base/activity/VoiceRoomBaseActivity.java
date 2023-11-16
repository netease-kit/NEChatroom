// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.activity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.common.utils.DeviceUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.common.utils.PermissionUtils;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.activity.BaseActivity;
import com.netease.yunxin.kit.entertainment.common.dialog.ReportDialog;
import com.netease.yunxin.kit.entertainment.common.floatplay.FloatWindowPermissionManager;
import com.netease.yunxin.kit.entertainment.common.gift.GifAnimationView;
import com.netease.yunxin.kit.entertainment.common.gift.GiftCache;
import com.netease.yunxin.kit.entertainment.common.gift.GiftDialog2;
import com.netease.yunxin.kit.entertainment.common.gift.GiftHelper;
import com.netease.yunxin.kit.entertainment.common.gift.GiftRender;
import com.netease.yunxin.kit.entertainment.common.model.RoomModel;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.BluetoothHeadsetUtil;
import com.netease.yunxin.kit.entertainment.common.utils.ClickUtils;
import com.netease.yunxin.kit.entertainment.common.utils.InputUtils;
import com.netease.yunxin.kit.entertainment.common.utils.ReportUtils;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.entertainment.common.utils.ViewUtils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.ui.OrderSongDialog;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomBatchRewardTarget;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMemberVolumeInfo;
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil;
import com.netease.yunxin.kit.voiceroomkit.ui.base.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.kit.voiceroomkit.ui.base.databinding.ActivityVoiceroomBaseBinding;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.CancelApplySeatDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChatRoomAudioDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChatRoomMixerDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.ListItemDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.MemberSelectDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.NoticeDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.NotificationDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.SeatApplyDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.dialog.TopTipsDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.base.helper.EffectPlayHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.base.helper.SeatHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.VoiceRoomSeatEvent;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.VoiceRoomUser;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.KeepAliveService;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.SongPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.base.view.NESeatGridView;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.BackgroundMusicPanel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.ChatRoomMsgRecyclerView;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.OnItemClickListener;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.VolumeSetup;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import kotlin.Unit;

/** 主播与观众基础页，包含所有的通用UI元素 */
public abstract class VoiceRoomBaseActivity extends BaseActivity
    implements ViewTreeObserver.OnGlobalLayoutListener {

  public static final String TAG = "VoiceRoomBaseActivity";
  protected ActivityVoiceroomBaseBinding binding;
  public static List<CharSequence> charSequenceList = new ArrayList<>();

  protected static final int MORE_ITEM_MICRO_PHONE = 0; // 更多菜单麦克风

  protected static final int MORE_ITEM_EAR_BACK = 1; // 更多菜单耳返

  protected static final int MORE_ITEM_MIXER = 2; // 调音台

  protected static final int MORE_ITEM_AUDIO = 3; // 伴音

  protected static final int MORE_ITEM_REPORT = 4; // 举报

  protected static final int MORE_ITEM_FINISH = 5; // 更多菜单 结束房间

  protected List<ChatRoomMoreDialog.MoreItem> moreItems;

  protected TextView tvRoomName;

  protected BackgroundMusicPanel tvBackgroundMusic;

  protected TextView tvMemberCount;

  // 各种控制开关
  protected FrameLayout settingsContainer;

  protected ImageView ivLocalAudioSwitch;

  protected TextView tvInput;

  protected EditText edtInput;

  protected View more;

  protected ChatRoomMsgRecyclerView rcyChatMsgList;

  private GifAnimationView gifAnimationView;

  private View rootView;

  private View announcement;

  private boolean joinRoomSuccess = false;

  protected RoomModel voiceRoomInfo;

  protected VoiceRoomViewModel roomViewModel;

  protected EffectPlayHelper audioPlay;

  protected int earBack = 100;
  protected ChatRoomMoreDialog chatRoomMoreDialog;

  protected List<ChatRoomMoreDialog.MoreItem> moreItemList;

  protected TopTipsDialog topTipsDialog;

  protected ImageView ivGift;

  private GiftRender giftRender;

  protected ImageView ivOrderSong;

  private SeekBar skRecordingVolume;

  private SwitchCompat switchEarBack;

  protected ConstraintLayout baseAudioView;
  protected NESeatGridView seatGridView;
  private SimpleServiceConnection mServiceConnection;

  protected boolean isOverSeaEnv = false;
  private boolean needJoinRoom = true;
  private boolean prepareFloatPlay = false;
  private OrderSongViewModel orderSongViewModel;
  private static final String RECORD_AUDIO_PERMISSION = Manifest.permission.RECORD_AUDIO;
  private boolean callLeaveRoom = false;

  //麦位相关
  private TextView tvApplyHint;
  private SeatApplyDialog seatApplyDialog;
  private ListItemDialog bottomDialog;
  private CancelApplySeatDialog cancelApplySeatDialog;

  private final BluetoothHeadsetUtil.BluetoothHeadsetStatusObserver
      bluetoothHeadsetStatusChangeListener =
          new BluetoothHeadsetUtil.BluetoothHeadsetStatusObserver() {
            @Override
            public void connect() {
              if (!BluetoothHeadsetUtil.hasBluetoothConnectPermission(VoiceRoomBaseActivity.this)) {
                BluetoothHeadsetUtil.requestBluetoothConnectPermission(VoiceRoomBaseActivity.this);
              }
            }

            @Override
            public void disconnect() {}
          };
  private final ActivityResultLauncher<String> requestPermissionLauncher =
      registerForActivityResult(
          new ActivityResultContracts.RequestPermission(),
          isGranted -> {
            if (isGranted) {
              enterRoomInner(
                  voiceRoomInfo.getRoomUuid(),
                  voiceRoomInfo.getNick(),
                  voiceRoomInfo.getAvatar(),
                  voiceRoomInfo.getRole());
            } else {
              ToastX.showShortToast(R.string.need_permission_audio);
              finish();
            }
          });

  protected ChatRoomMoreDialog.OnItemClickListener onMoreItemClickListener =
      (dialog, itemView, item) -> {
        switch (item.id) {
          case MORE_ITEM_MICRO_PHONE:
            {
              toggleMuteLocalAudio();
              break;
            }

          case MORE_ITEM_EAR_BACK:
            {
              if (DeviceUtils.hasEarBack(this)) {
                boolean isEarBackEnable = NEVoiceRoomKit.getInstance().isEarbackEnable();
                if (enableEarBack(!isEarBackEnable) == 0) {
                  item.enable = !isEarBackEnable;
                  dialog.updateData();
                }
              } else {
                ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_earback_tip));
              }
              break;
            }
          case MORE_ITEM_MIXER:
            {
              if (dialog != null && dialog.isShowing()) {
                dialog.dismiss();
              }
              showChatRoomMixerDialog();
              break;
            }
          case MORE_ITEM_AUDIO:
            {
              if (dialog != null && dialog.isShowing()) {
                dialog.dismiss();
              }
              new ChatRoomAudioDialog(VoiceRoomBaseActivity.this, audioPlay).show();
              break;
            }
          case MORE_ITEM_REPORT:
            if (dialog != null && dialog.isShowing()) {
              dialog.dismiss();
            }
            new ReportDialog().show(getSupportFragmentManager(), TAG);
            break;
          case MORE_ITEM_FINISH:
            {
              if (dialog != null && dialog.isShowing()) {
                dialog.dismiss();
              }
              doLeaveRoom();
              break;
            }
        }
        return true;
      };

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // 屏幕常亮
    getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    initIntent();
    if (voiceRoomInfo == null) {
      return;
    }
    roomViewModel = getRoomViewModel();
    orderSongViewModel = new ViewModelProvider(this).get(OrderSongViewModel.class);
    initRoomViewModel();
    binding = ActivityVoiceroomBaseBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    createMoreItems();
    initViews();
    NEOrderSongService.INSTANCE.setRoomUuid(voiceRoomInfo.getRoomUuid());
    NEOrderSongService.INSTANCE.setLiveRecordId(voiceRoomInfo.getLiveRecordId());
    initListeners();
    initData();
    bindForegroundService();
    BluetoothHeadsetUtil.registerBluetoothHeadsetStatusObserver(
        bluetoothHeadsetStatusChangeListener);
    if (BluetoothHeadsetUtil.isBluetoothHeadsetConnected()
        && !BluetoothHeadsetUtil.hasBluetoothConnectPermission(VoiceRoomBaseActivity.this)) {
      BluetoothHeadsetUtil.requestBluetoothConnectPermission(VoiceRoomBaseActivity.this);
    }
    GiftHelper.getInstance().init();
    enterRoom();
    audioPlay.checkMusicFiles();
  }

  private void initRoomViewModel() {
    roomViewModel.init(voiceRoomInfo.getLiveRecordId(), voiceRoomInfo.getRoomUuid());
  }

  protected abstract VoiceRoomViewModel getRoomViewModel();

  private void initIntent() {
    voiceRoomInfo = (RoomModel) getIntent().getSerializableExtra(RoomConstants.INTENT_ROOM_MODEL);
    needJoinRoom = getIntent().getBooleanExtra(NEVoiceRoomUIConstants.NEED_JOIN_ROOM__KEY, true);
    isOverSeaEnv = getIntent().getBooleanExtra(NEVoiceRoomUIConstants.ENV_KEY, false);
    if (voiceRoomInfo == null) {
      ToastUtils.INSTANCE.showShortToast(
          VoiceRoomBaseActivity.this, getString(R.string.voiceroom_chat_message_tips));
      finish();
    }
  }

  private void handleOrderSongUI() {
    if (isOverSeaEnv) {
      ivOrderSong.setVisibility(View.GONE);
    } else {
      ivOrderSong.setVisibility(View.VISIBLE);
    }
  }

  protected void initViews() {
    initBaseView();
    setupBaseViewInner();
    setupBaseView();
    rootView = getWindow().getDecorView();
    rootView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    String countStr = String.format(getString(R.string.voiceroom_people_online), "0");
    tvMemberCount.setText(countStr);
    handleOrderSongUI();
  }

  @Override
  protected void onDestroy() {
    if (rootView != null) {
      rootView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
    }
    if (audioPlay != null) {
      audioPlay.destroy();
    }
    giftRender.release();
    unbindForegroundService();
    GiftHelper.getInstance().clear();
    BluetoothHeadsetUtil.unregisterBluetoothHeadsetStatusObserver(
        bluetoothHeadsetStatusChangeListener);
    super.onDestroy();
  }

  @Override
  public void onBackPressed() {
    if (settingsContainer.getVisibility() == View.VISIBLE) {
      settingsContainer.setVisibility(View.GONE);
      return;
    }
    doLeaveRoom();
    //    super.onBackPressed();
  }

  @Override
  public void onGlobalLayout() {
    //    int preHeight = rootViewVisibleHeight;
    //    //获取当前根视图在屏幕上显示的大小
    //    Rect r = new Rect();
    //    rootView.getWindowVisibleDisplayFrame(r);
    //    rootViewVisibleHeight = r.height();
    //    if (preHeight == 0 || preHeight == rootViewVisibleHeight) {
    //      return;
    //    }
    //    //根视图显示高度变大超过KEY_BOARD_MIN_SIZE，可以看作软键盘隐藏了
    //    if (rootViewVisibleHeight - preHeight >= KEY_BOARD_MIN_SIZE) {
    //      rcyChatMsgList.toLatestMsg();
    //    }
  }

  private void initBaseView() {
    baseAudioView = findViewById(R.id.rl_base_audio_ui);
    loadRoomBg(voiceRoomInfo.getCover());
    if (baseAudioView == null) {
      throw new IllegalStateException("xml layout must include base_audio_ui.xml layout");
    }
    seatGridView = baseAudioView.findViewById(R.id.seat_grid_view);
    tvRoomName = baseAudioView.findViewById(R.id.tv_chat_room_name);
    tvBackgroundMusic = baseAudioView.findViewById(R.id.iv_background_music);
    tvMemberCount = baseAudioView.findViewById(R.id.tv_chat_room_member_count);
    settingsContainer = findViewById(R.id.settings_container);
    skRecordingVolume = settingsContainer.findViewById(R.id.recording_volume_control);
    switchEarBack = settingsContainer.findViewById(R.id.ear_back);
    switchEarBack.setChecked(false);
    more = baseAudioView.findViewById(R.id.iv_room_more);
    ivLocalAudioSwitch = baseAudioView.findViewById(R.id.iv_local_audio_switch);
    ivLocalAudioSwitch.setSelected(true);
    rcyChatMsgList = baseAudioView.findViewById(R.id.rcy_chat_message_list);
    tvInput = baseAudioView.findViewById(R.id.tv_input_text);
    edtInput = baseAudioView.findViewById(R.id.edt_input_text);
    announcement = baseAudioView.findViewById(R.id.tv_chat_room_announcement);
    ivGift = baseAudioView.findViewById(R.id.iv_gift);
    ivOrderSong = baseAudioView.findViewById(R.id.iv_order_song);
    // 沉浸式状态栏，顶部设置margin
    int statusBarHeight = ViewUtils.getStatusBarHeight(this);
    ConstraintLayout.LayoutParams tvRoomNameLayoutParams =
        (ConstraintLayout.LayoutParams) tvRoomName.getLayoutParams();
    tvRoomNameLayoutParams.topToTop = R.id.rl_base_audio_ui;
    tvRoomNameLayoutParams.topMargin = statusBarHeight;
    tvRoomName.setLayoutParams(tvRoomNameLayoutParams);
    View closeImageView = baseAudioView.findViewById(R.id.iv_leave_room);
    ConstraintLayout.LayoutParams closeImgLayoutParams =
        (ConstraintLayout.LayoutParams) closeImageView.getLayoutParams();
    closeImgLayoutParams.topToTop = R.id.rl_base_audio_ui;
    closeImgLayoutParams.topMargin = statusBarHeight;
    closeImageView.setLayoutParams(closeImgLayoutParams);
    initGiftAnimation(baseAudioView);

    //麦位相关
    topTipsDialog = new TopTipsDialog();
    tvApplyHint = findViewById(R.id.apply_hint);
    tvApplyHint.setOnClickListener(
        view -> showApplySeats(SeatHelper.getInstance().getApplySeatList()));

    tvApplyHint.setVisibility(View.INVISIBLE);
    tvApplyHint.setClickable(true);
  }

  private void initListeners() {
    settingsContainer.setOnClickListener(view -> settingsContainer.setVisibility(View.GONE));
    switchEarBack.setOnCheckedChangeListener(
        (buttonView, isChecked) -> {
          if (!DeviceUtils.hasEarBack(VoiceRoomBaseActivity.this)) {
            buttonView.setChecked(false);
            return;
          }
          enableEarBack(isChecked);
        });
    skRecordingVolume.setOnSeekBarChangeListener(
        new VolumeSetup() {
          @Override
          protected void onVolume(int volume) {
            setAudioCaptureVolume(volume);
          }
        });
    more.setOnClickListener(
        v -> {
          moreItemList = getMoreItems();
          chatRoomMoreDialog = new ChatRoomMoreDialog(VoiceRoomBaseActivity.this, moreItemList);
          chatRoomMoreDialog.registerOnItemClickListener(getMoreItemClickListener());
          chatRoomMoreDialog.show();
        });
    ivLocalAudioSwitch.setOnClickListener(view -> toggleMuteLocalAudio());
    baseAudioView.findViewById(R.id.iv_leave_room).setOnClickListener(view -> doLeaveRoom());

    ImageView ivSmallWindow = baseAudioView.findViewById(R.id.iv_small_window);
    ivSmallWindow.setImageResource(R.drawable.voice_room_small_window);
    ivSmallWindow.setOnClickListener(
        v -> {
          if (FloatWindowPermissionManager.INSTANCE.isFloatWindowOpAllowed(
              VoiceRoomBaseActivity.this)) {
            prepareFloatPlay = true;
            onClickSmallWindow();
            finish();
          } else {
            FloatWindowPermissionManager.INSTANCE.requestFloatWindowPermission(
                VoiceRoomBaseActivity.this);
          }
        });
    tvInput.setOnClickListener(
        v -> {
          InputUtils.showSoftInput(VoiceRoomBaseActivity.this, edtInput);
          edtInput.bringToFront();
        });
    edtInput.setOnEditorActionListener(
        (v, actionId, event) -> {
          InputUtils.hideSoftInput(VoiceRoomBaseActivity.this, edtInput);
          sendTextMessage();
          return true;
        });
    InputUtils.registerSoftInputListener(
        this,
        new InputUtils.InputParamHelper() {

          @Override
          public int getHeight() {
            return baseAudioView.getHeight();
          }

          @Override
          public EditText getInputView() {
            return edtInput;
          }
        });
    announcement.setOnClickListener(
        v -> {
          NoticeDialog noticeDialog = new NoticeDialog();
          noticeDialog.show(getSupportFragmentManager(), "");
        });
    ivGift.setOnClickListener(
        v -> {
          ReportUtils.report(VoiceRoomBaseActivity.this, getPageName(), "chatroom_gift");
          Application application = Utils.getApp();
          if (application != null && !NetworkUtils.isConnected()) {
            ToastUtils.INSTANCE.showShortToast(
                application, application.getString(R.string.network_error));
            return;
          }

          GiftDialog2 giftDialog = new GiftDialog2(VoiceRoomBaseActivity.this);
          giftDialog.show(
              (giftId, giftCount, userUuids) ->
                  NEVoiceRoomKit.getInstance()
                      .sendBatchGift(
                          giftId,
                          giftCount,
                          userUuids,
                          new NEVoiceRoomCallback<Unit>() {
                            @Override
                            public void onSuccess(@Nullable Unit unit) {}

                            @Override
                            public void onFailure(int code, @Nullable String msg) {
                              if (application != null) {
                                ToastUtils.INSTANCE.showShortToast(
                                    application, application.getString(R.string.reward_failed));
                              }
                            }
                          }));
        });
    ivOrderSong.setOnClickListener(
        v -> {
          ReportUtils.report(VoiceRoomBaseActivity.this, getPageName(), "chatroom_order_song");
          showSingingTable();
        });
  }

  private void initData() {
    seatGridView.updateAnchorUI(
        voiceRoomInfo.getAnchorNick(), voiceRoomInfo.getAnchorAvatar(), false);
    audioPlay = new EffectPlayHelper(VoiceRoomBaseActivity.this);
    initDataObserver();
  }

  private void showSingingTable() {
    if (!ClickUtils.isSlightlyFastClick()) {
      if (!NetworkUtils.isConnected()) {
        return;
      }

      OrderSongDialog dialog = new OrderSongDialog(SongPlayManager.getInstance().getVolume());
      dialog.show(getSupportFragmentManager(), TAG);
    }
  }

  protected void doLeaveRoom() {
    leaveRoom();
  }

  @SuppressLint("NotifyDataSetChanged")
  private void setupBaseViewInner() {
    String name = voiceRoomInfo.getRoomName();
    name = TextUtils.isEmpty(name) ? voiceRoomInfo.getRoomUuid() : name;
    tvRoomName.setText(name);
    seatGridView.setItemClickListener(this::onSeatItemClick);
    seatGridView.refresh(roomViewModel.onSeatListData.getValue());
  }

  protected abstract void setupBaseView();

  protected void onSeatItemClick(RoomSeat seat, int position) {
    if (ClickUtils.isFastClick()) {
      return;
    }
    if (isAnchor()) {
      if (seat.getStatus() == RoomSeat.Status.APPLY) {
        ToastUtils.INSTANCE.showShortToast(
            VoiceRoomBaseActivity.this, getString(R.string.voiceroom_applying_now));
        return;
      }
      OnItemClickListener<String> onItemClickListener = item -> onSeatAction(seat, item);
      List<String> items = new ArrayList<>();
      ListItemDialog itemDialog = new ListItemDialog(VoiceRoomBaseActivity.this);
      switch (seat.getStatus()) {
          // 抱观众上麦（点击麦位）
        case RoomSeat.Status.INIT:
          items.add(getString(R.string.voiceroom_invite_seat));
          items.add(getString(R.string.voiceroom_close_seat));
          break;
          // 当前存在有效用户
        case RoomSeat.Status.ON:
          items.add(getString(R.string.voiceroom_kickout_seat));
          final NEVoiceRoomMember member = seat.getMember();
          if (member != null) {
            items.add(
                member.isAudioBanned()
                    ? getString(R.string.voiceroom_unmute_seat)
                    : getString(R.string.voiceroom_mute_seat));
          }
          items.add(getString(R.string.voiceroom_close_seat));
          break;
          // 当前麦位已经被关闭
        case RoomSeat.Status.CLOSED:
          items.add(getString(R.string.voiceroom_open_seat));
          break;
      }
      items.add(getString(R.string.voiceroom_cancel));
      itemDialog.setOnItemClickListener(onItemClickListener).show(items);
    } else {
      switch (seat.getStatus()) {
        case RoomSeat.Status.INIT:
          if (seat.getStatus() == RoomSeat.Status.CLOSED) {
            ToastUtils.INSTANCE.showShortToast(
                this,
                getString(
                    com.netease
                        .yunxin
                        .kit
                        .voiceroomkit
                        .ui
                        .base
                        .R
                        .string
                        .voiceroom_seat_already_closed));
          } else if (roomViewModel.isCurrentUserOnSeat()) {
            ToastUtils.INSTANCE.showShortToast(
                this,
                getString(
                    com.netease
                        .yunxin
                        .kit
                        .voiceroomkit
                        .ui
                        .base
                        .R
                        .string
                        .voiceroom_already_on_seat));
          } else {
            applySeat(seat.getSeatIndex());
          }
          break;
        case RoomSeat.Status.APPLY:
          ToastUtils.INSTANCE.showShortToast(
              this,
              getString(
                  com.netease.yunxin.kit.voiceroomkit.ui.base.R.string.voiceroom_seat_applied));
          break;
        case RoomSeat.Status.ON:
          if (VoiceRoomUtils.isLocal(seat.getAccount())) {
            promptLeaveSeat();
          } else {
            ToastUtils.INSTANCE.showShortToast(
                this,
                getString(
                    com.netease
                        .yunxin
                        .kit
                        .voiceroomkit
                        .ui
                        .base
                        .R
                        .string
                        .voiceroom_seat_already_taken));
          }
          break;
        case RoomSeat.Status.CLOSED:
          ToastUtils.INSTANCE.showShortToast(
              this,
              getString(
                  com.netease
                      .yunxin
                      .kit
                      .voiceroomkit
                      .ui
                      .base
                      .R
                      .string
                      .voiceroom_seat_already_closed));
          break;
      }
    }
  }

  @NonNull
  protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
    boolean isAudioOn =
        NEVoiceRoomKit.getInstance().getLocalMember() != null
            && NEVoiceRoomKit.getInstance().getLocalMember().isAudioOn();
    moreItems.get(MORE_ITEM_MICRO_PHONE).setEnable(isAudioOn);
    moreItems.get(MORE_ITEM_EAR_BACK).setEnable(NEVoiceRoomKit.getInstance().isEarbackEnable());
    return moreItems;
  }

  protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
    return onMoreItemClickListener;
  }

  protected final void enterRoom() {
    if (PermissionUtils.hasPermissions(this, RECORD_AUDIO_PERMISSION)) {
      enterRoomInner(
          voiceRoomInfo.getRoomUuid(),
          voiceRoomInfo.getNick(),
          voiceRoomInfo.getAvatar(),
          voiceRoomInfo.getRole());
    } else {
      requestPermissionLauncher.launch(RECORD_AUDIO_PERMISSION);
    }
  }

  private void enterRoomInner(String roomUuid, String nick, String avatar, String role) {
    tvBackgroundMusic.setRoomUuid(roomUuid);
    if (!needJoinRoom) {
      joinRoomSuccess = true;
      rcyChatMsgList.appendItems(charSequenceList);
      roomViewModel.initDataOnJoinRoom();
    } else {
      roomViewModel.joinRoom(
          roomUuid,
          nick,
          avatar,
          role,
          new NEVoiceRoomCallback<NEVoiceRoomInfo>() {

            @Override
            public void onSuccess(@Nullable NEVoiceRoomInfo neVoiceRoomInfo) {
              joinRoomSuccess = true;
            }

            @Override
            public void onFailure(int code, @Nullable String msg) {
              if (!callLeaveRoom) {
                ToastUtils.INSTANCE.showShortToast(
                    VoiceRoomBaseActivity.this,
                    getString(
                        isAnchor()
                            ? R.string.voiceroom_start_live_error
                            : R.string.voiceroom_join_live_error));
              }
              finish();
            }
          });
    }
  }

  private void updateLocalUI(NEVoiceRoomMember localMember) {
    if (localMember == null) {
      return;
    }
    if (ivLocalAudioSwitch != null) {
      ivLocalAudioSwitch.setSelected(!localMember.isAudioOn());
    }
  }

  @SuppressLint("NotifyDataSetChanged")
  protected void initDataObserver() {
    roomViewModel.localMemberData.observe(this, this::updateLocalUI);
    roomViewModel.toastData.observe(
        this, s -> ToastUtils.INSTANCE.showShortToast(VoiceRoomBaseActivity.this, s));
    roomViewModel.memberCountData.observe(
        this,
        count -> {
          String countStr = String.format(getString(R.string.voiceroom_people_online), count + "");
          tvMemberCount.setText(countStr);
        });
    roomViewModel.onSeatListData.observe(
        this,
        seatList -> {
          seatGridView.refresh(seatList);
        });

    roomViewModel.chatRoomMsgData.observe(
        this,
        charSequence -> {
          charSequenceList.add(charSequence);
          rcyChatMsgList.appendItem(charSequence);
        });

    roomViewModel.roomRtcErrorData.observe(
        this,
        code -> {
          ALog.e(TAG, "roomRtcErrorData code = " + code);
        });

    roomViewModel.roomEndData.observe(
        this,
        endReason -> {
          if (endReason == NEVoiceRoomEndReason.CLOSE_BY_MEMBER
              && !VoiceRoomUtils.isLocalAnchor()) {
            ToastUtils.INSTANCE.showShortToast(
                VoiceRoomBaseActivity.this, getString(R.string.voiceroom_host_close_room));
          }
          finish();
        });

    roomViewModel.rtcLocalAudioVolumeIndicationData.observe(
        this,
        volume -> {
          if (VoiceRoomUtils.isLocalAnchor()) {
            seatGridView.showAvatarAnimal(
                volume > 0 && VoiceRoomUtils.getLocalMember().isAudioOn());
          } else {
            for (RoomSeat roomSeat : seatGridView.getItems()) {
              if (VoiceRoomUtils.isLocal(roomSeat.getAccount())) {
                if (roomSeat.isSpeaking() && volume == 0) {
                  roomSeat.setSpeaking(false);
                  seatGridView.refreshItem(seatGridView.getItems().indexOf(roomSeat));
                } else if (!roomSeat.isSpeaking() && volume > 0) {
                  roomSeat.setSpeaking(true);
                  seatGridView.refreshItem(seatGridView.getItems().indexOf(roomSeat));
                }
              }
            }
          }
        });

    roomViewModel.rtcRemoteAudioVolumeIndicationData.observe(
        this,
        volumes -> {
          Map<String, NEVoiceRoomMemberVolumeInfo> memberVolumeInfoMap = new HashMap<>();
          for (NEVoiceRoomMemberVolumeInfo memberVolumeInfo : volumes) {
            memberVolumeInfoMap.put(memberVolumeInfo.getUserUuid(), memberVolumeInfo);
            if (VoiceRoomUtils.isHost(memberVolumeInfo.getUserUuid())) {
              seatGridView.showAvatarAnimal(
                  memberVolumeInfo.getVolume() > 0
                      && VoiceRoomUtils.getMember(memberVolumeInfo.getUserUuid()).isAudioOn());
            }
          }
          for (RoomSeat roomSeat : seatGridView.getItems()) {
            if (!VoiceRoomUtils.isLocal(roomSeat.getAccount())) {
              if (memberVolumeInfoMap.containsKey(roomSeat.getAccount())
                  && (Objects.requireNonNull(memberVolumeInfoMap.get(roomSeat.getAccount())))
                          .getVolume()
                      > 0) {
                if (!roomSeat.isSpeaking()) {
                  roomSeat.setSpeaking(true);
                  seatGridView.refreshItem(seatGridView.getItems().indexOf(roomSeat));
                }
              } else {
                if (roomSeat.isSpeaking()) {
                  roomSeat.setSpeaking(false);
                  seatGridView.refreshItem(seatGridView.getItems().indexOf(roomSeat));
                }
              }
            }
          }
        });

    roomViewModel.memberAudioBannedData.observe(
        this,
        memberAudioBannedModel -> {
          if (VoiceRoomUtils.isLocal(memberAudioBannedModel.getMember().getAccount())
              && roomViewModel.isCurrentUserOnSeat()) {
            if (memberAudioBannedModel.isBanned()) {
              roomViewModel.muteMyAudio(false);
            } else if (!roomViewModel.isMute()) {
              roomViewModel.unmuteMyAudio(false);
            }
            ToastX.showShortToast(
                getString(
                    memberAudioBannedModel.isBanned()
                        ? R.string.voiceroom_seat_muted
                        : R.string.voiceroom_unmute_seat_tips));
          }
        });

    roomViewModel.memberAudioMuteChangedData.observe(
        this,
        memberAudioMuteChangedModel -> {
          if (VoiceRoomUtils.isLocal(memberAudioMuteChangedModel.getMember().getAccount())) {
            ivLocalAudioSwitch.setSelected(memberAudioMuteChangedModel.isMute());
            getMoreItems()
                .get(VoiceRoomBaseActivity.MORE_ITEM_MICRO_PHONE)
                .setEnable(!memberAudioMuteChangedModel.isMute());
            if (chatRoomMoreDialog != null) {
              chatRoomMoreDialog.updateData();
            }
          }
        });

    roomViewModel.bachRewardData.observe(
        this,
        batchReward -> {
          if (voiceRoomInfo == null) {
            return;
          }

          ALog.i(TAG, "bachRewardData observe giftModel:" + batchReward);
          List<NEVoiceRoomBatchRewardTarget> targets = batchReward.getTargets();
          if (targets.isEmpty()) {
            return;
          }
          for (NEVoiceRoomBatchRewardTarget target : targets) {
            CharSequence batchGiftReward =
                ChatRoomMsgCreator.createBatchGiftReward(
                    VoiceRoomBaseActivity.this,
                    batchReward.getUserName(),
                    target.getUserName(),
                    GiftCache.getGift(batchReward.getGiftId()).getName(),
                    batchReward.getGiftCount(),
                    GiftCache.getGift(batchReward.getGiftId()).getStaticIconResId());
            rcyChatMsgList.appendItem(batchGiftReward);
            charSequenceList.add(batchGiftReward);
            ALog.i(TAG, "target:" + target);
          }
          if (!VoiceRoomUtils.isLocalAnchor()) {
            if (gifAnimationView != null) {
              gifAnimationView.bringToFront();
            }
            giftRender.addGift(GiftCache.getGift(batchReward.getGiftId()).getDynamicIconResId());
          }
        });

    roomViewModel.anchorReward.observe(
        this,
        reward -> {
          seatGridView.updateAnchorReward(reward);
        });
    roomViewModel.earBackData.observe(
        this,
        isOpen -> {
          enableEarBack(isOpen);
          moreItems.get(MORE_ITEM_EAR_BACK).setEnable(isOpen);
          if (chatRoomMoreDialog != null) {
            chatRoomMoreDialog.updateData();
          }
        });
    orderSongViewModel
        .getVolumeChangedEvent()
        .observe(
            this,
            volume -> {
              SongPlayManager.getInstance().setVolume(volume);
            });
    roomViewModel.currentSeatState.observe(
        this,
        new Observer<Integer>() {
          @Override
          public void onChanged(Integer integer) {
            //观众断网重连也会走这个逻辑
            ALog.d(TAG, "initDataObserver currentSeatState,integer:" + integer);
            if (integer != VoiceRoomViewModel.CURRENT_SEAT_STATE_APPLYING) {
              canShowTip = false;
              dismissCancelApplySeatDialog();
            }
            updateAudioSwitchVisible(roomViewModel.isCurrentUserOnSeat());
          }
        });

    // 房间背景
    roomViewModel.roomInfoLiveData.observe(
        this,
        new Observer<NEVoiceRoomInfo>() {
          @Override
          public void onChanged(NEVoiceRoomInfo neVoiceRoomInfo) {
            ALog.i(TAG, "neVoiceRoomInfo:" + neVoiceRoomInfo);
            loadRoomBg(neVoiceRoomInfo.getLiveModel().getCover());
          }
        });
  }

  private void loadRoomBg(String cover) {
    Glide.with(VoiceRoomBaseActivity.this.getApplicationContext())
        .asBitmap()
        .load(cover)
        .into(
            new SimpleTarget<Bitmap>() {
              @Override
              public void onResourceReady(
                  @NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
                baseAudioView.setBackground(new BitmapDrawable(resource));
                ALog.i(TAG, "onResourceReady:" + resource);
              }

              @Override
              public void onLoadCleared(@Nullable Drawable placeholder) {
                super.onLoadCleared(placeholder);
                ALog.i(TAG, "onLoadCleared:" + placeholder);
              }
            });
  }

  protected final void leaveRoom() {
    callLeaveRoom = true;
    if (VoiceRoomUtils.isLocalAnchor()) {
      NEVoiceRoomKit.getInstance()
          .endRoom(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ALog.i(TAG, "endRoom success");
                  ToastUtils.INSTANCE.showShortToast(
                      VoiceRoomBaseActivity.this,
                      getString(R.string.voiceroom_host_close_room_success));
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "endRoom onFailure");
                }
              });
    } else {
      NEVoiceRoomKit.getInstance()
          .leaveRoom(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ALog.i(TAG, "leaveRoom success");
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "leaveRoom onFailure");
                }
              });
    }
    finish();
    if (audioPlay != null) {
      audioPlay.destroy();
    }
  }

  protected final void toggleMuteLocalAudio() {
    if (!joinRoomSuccess) return;
    NEVoiceRoomMember localMember = NEVoiceRoomKit.getInstance().getLocalMember();
    if (localMember == null) return;
    boolean isAudioOn = localMember.isAudioOn();
    ALog.d(
        TAG,
        "toggleMuteLocalAudio,localMember.isAudioOn:"
            + isAudioOn
            + ",localMember.isAudioBanned():"
            + localMember.isAudioBanned());
    if (isAudioOn) {
      roomViewModel.muteMyAudio(true);
    } else {
      if (localMember.isAudioBanned()) {
        ToastUtils.INSTANCE.showShortToast(
            VoiceRoomBaseActivity.this, getString(R.string.voiceroom_audio_banned));
      } else {
        roomViewModel.unmuteMyAudio(true);
      }
    }
  }

  protected void setAudioCaptureVolume(int volume) {
    NEVoiceRoomKit.getInstance().adjustRecordingSignalVolume(volume);
  }

  protected int enableEarBack(boolean enable) {
    if (enable) {
      return NEVoiceRoomKit.getInstance().enableEarback(earBack);
    } else {
      return NEVoiceRoomKit.getInstance().disableEarback();
    }
  }

  protected void sendTextMessage() {
    String content = edtInput.getText().toString().trim();
    if (TextUtils.isEmpty(content)) {
      ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_chat_message_tips));
      return;
    }
    NEVoiceRoomKit.getInstance()
        .sendTextMessage(
            content,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                CharSequence charSequence =
                    ChatRoomMsgCreator.createText(
                        VoiceRoomBaseActivity.this,
                        VoiceRoomUtils.isLocalAnchor(),
                        VoiceRoomUtils.getLocalName(),
                        content);
                rcyChatMsgList.appendItem(charSequence);
                charSequenceList.add(charSequence);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "sendTextMessage failed code = " + code + " msg = " + msg);
              }
            });
  }

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

  /** 显示调音台 */
  public void showChatRoomMixerDialog() {
    new ChatRoomMixerDialog(VoiceRoomBaseActivity.this, audioPlay, isAnchor()).show();
  }

  private void initGiftAnimation(View baseAudioView) {
    gifAnimationView = new GifAnimationView(this);
    int size = ScreenUtil.getDisplayWidth();
    ConstraintLayout.LayoutParams layoutParams = new ConstraintLayout.LayoutParams(size, size);
    layoutParams.topToTop = ConstraintLayout.LayoutParams.PARENT_ID;
    layoutParams.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID;
    ViewGroup root = (ViewGroup) baseAudioView.findViewById(R.id.rl_base_audio_ui);
    root.addView(gifAnimationView, layoutParams);
    giftRender = new GiftRender();
    giftRender.init(gifAnimationView);
  }

  private void bindForegroundService() {
    Intent intent = new Intent();
    intent.setClass(this, KeepAliveService.class);
    mServiceConnection = new SimpleServiceConnection();
    bindService(intent, mServiceConnection, Context.BIND_AUTO_CREATE);
  }

  private void unbindForegroundService() {
    if (mServiceConnection != null) {
      unbindService(mServiceConnection);
    }
  }

  private static class SimpleServiceConnection implements ServiceConnection {
    @Override
    public void onServiceConnected(ComponentName componentName, IBinder service) {

      if (service instanceof KeepAliveService.SimpleBinder) {
        ALog.i(TAG, "onServiceConnect");
      }
    }

    @Override
    public void onServiceDisconnected(ComponentName componentName) {
      ALog.i(TAG, "onServiceDisconnected");
    }
  }

  protected void onSeatAction(RoomSeat seat, String item) {
    if (item.equals(getString(R.string.voiceroom_kickout_seat_sure))) {
      new ListItemDialog(VoiceRoomBaseActivity.this)
          .setOnItemClickListener(
              item1 -> {
                if (getString(R.string.voiceroom_kickout_seat_sure).equals(item1)) {
                  kickSeat(seat);
                }
              })
          .show(
              Arrays.asList(
                  getString(R.string.voiceroom_kickout_seat_sure),
                  getString(R.string.voiceroom_cancel)));
    } else if (item.equals(getString(R.string.voiceroom_close_seat))) {
      closeSeat(seat);
    } else if (item.equals(getString(R.string.voiceroom_invite_seat))) {
      inviteSeat0(seat);
    } else if (item.equals(getString(R.string.voiceroom_kickout_seat))) {
      kickSeat(seat);
    } else if (item.equals(getString(R.string.voiceroom_mute_seat))) {
      muteSeat(seat);
    } else if (item.equals(getString(R.string.voiceroom_unmute_seat))) {
      unmuteSeat(seat);
    } else if (item.equals(getString(R.string.voiceroom_open_seat))) {
      openSeat(seat);
    } else if (item.equals(getString(R.string.voiceroom_leave_room))) {
      leaveRoom();
    }
  }

  private void showApplySeats(List<RoomSeat> seats) {
    seatApplyDialog = new SeatApplyDialog();
    Bundle bundle = new Bundle();
    bundle.putParcelableArrayList(seatApplyDialog.getDialogTag(), new ArrayList<>(seats));
    seatApplyDialog.setArguments(bundle);
    seatApplyDialog.show(getSupportFragmentManager(), seatApplyDialog.getDialogTag());
    seatApplyDialog.setRequestAction(
        new SeatApplyDialog.IRequestAction() {
          @Override
          public void refuse(RoomSeat seat) {
            denySeatApply(seat);
          }

          @Override
          public void agree(RoomSeat seat) {
            approveSeatApply(seat);
          }

          @Override
          public void dismiss() {}
        });
  }

  public void onApplySeats(List<RoomSeat> seats) {
    int size = seats.size();
    if (size > 0) {
      tvApplyHint.setVisibility(View.VISIBLE);
      tvApplyHint.setText(getString(R.string.voiceroom_apply_micro_has_arrow, size));
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
  // Anchor call
  //

  private void approveSeatApply(RoomSeat seat) {
    final String text = getString(R.string.voiceroom_seat_request_success);
    NEVoiceRoomKit.getInstance()
        .approveSeatRequest(
            seat.getAccount(),
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastX.showShortToast(text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "approveSeatApply onFailure code:" + code);
              }
            });
  }

  private void denySeatApply(RoomSeat seat) {
    NEVoiceRoomMember member = seat.getMember();
    if (member == null) return;
    final String text =
        String.format(getString(R.string.voiceroom_deny_seat_apply), member.getName());
    NEVoiceRoomKit.getInstance()
        .rejectSeatRequest(
            seat.getAccount(),
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastX.showShortToast(text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "denySeatApply onFailure code:" + code);
              }
            });
  }

  public void openSeat(RoomSeat seat) {
    int position = seat.getSeatIndex() - 1;
    List<Integer> seatIndices = new ArrayList<>();
    seatIndices.add(seat.getSeatIndex());
    NEVoiceRoomKit.getInstance()
        .openSeats(
            seatIndices,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "openSeats onSuccess");
                ToastX.showShortToast(
                    String.format(getString(R.string.voiceroom_open_seat_success), position));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "openSeats onFailure");
                ToastX.showShortToast(
                    String.format(getString(R.string.voiceroom_open_seat_fail), position));
              }
            });
  }

  protected void closeSeat(RoomSeat seat) {
    List<Integer> list = new ArrayList<>();
    list.add(seat.getSeatIndex());
    NEVoiceRoomKit.getInstance()
        .closeSeats(
            list,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "closeSeat onSuccess");
                ToastX.showShortToast(
                    String.format(
                        getString(R.string.voiceroom_close_seat_tip), seat.getSeatIndex() - 1));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "closeSeat onFailure code:" + code);
              }
            });
  }

  protected void muteSeat(RoomSeat seat) {
    String userId = seat.getAccount();
    if (userId == null) return;

    final String text = getString(R.string.voiceroom_seat_mute_tips);
    NEVoiceRoomKit.getInstance()
        .banRemoteAudio(
            userId,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "muteSeat onSuccess");
                ToastX.showShortToast(text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "muteSeat onFailure code:" + code);
                ToastX.showShortToast(getString(R.string.voiceroom_mute_seat_fail));
              }
            });
  }

  protected void unmuteSeat(RoomSeat seat) {
    String userId = seat.getAccount();
    if (userId == null) return;

    NEVoiceRoomKit.getInstance()
        .unbanRemoteAudio(
            userId,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "muteSeat onSuccess");
                ToastX.showShortToast(getString(R.string.voiceroom_unmute_seat_success));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "muteSeat onFailure code:" + code);
                ToastX.showShortToast(getString(R.string.voiceroom_unmute_seat_fail));
              }
            });
  }

  private int inviteIndex = -1;

  protected void inviteSeat0(RoomSeat seat) {
    inviteIndex = seat.getSeatIndex();
    new MemberSelectDialog(this, this::inviteSeat).show();
  }

  private void inviteSeat(@NonNull VoiceRoomUser member) {
    NEVoiceRoomKit.getInstance()
        .sendSeatInvitation(
            inviteIndex,
            member.account,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                final String text =
                    String.format(
                        getString(R.string.voiceroom_invite_seat_success), member.getNick());
                ToastX.showShortToast(text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "inviteSeat onFailure code:" + code);
                ToastX.showShortToast(getString(R.string.voiceroom_operate_fail));
              }
            });
  }

  protected void kickSeat(@NonNull RoomSeat seat) {
    NEVoiceRoomMember member = seat.getMember();
    if (member == null) return;
    final String text =
        String.format(getString(R.string.voiceroom_kickout_seat_success), member.getName());
    NEVoiceRoomKit.getInstance()
        .kickSeat(
            member.getAccount(),
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.e(TAG, "kickSeat onSuccess");
                ToastX.showShortToast(text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "kickSeat onFailure code:" + code);
                ToastX.showShortToast(getString(R.string.voiceroom_operate_fail));
              }
            });
  }

  private boolean checkMySeat(RoomSeat seat) {
    if (seat != null) {
      if (seat.getStatus() == RoomSeat.Status.CLOSED) {
        ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_seat_already_closed));
        return false;
      } else if (seat.isOn()) {
        ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_already_on_seat));
        return false;
      }
    }
    return true;
  }

  public void applySeat(int index) {
    if (NEVoiceRoomKit.getInstance().getLocalMember() == null) {
      ALog.e(TAG, "not in room");
      return;
    }
    NEVoiceRoomKit.getInstance()
        .submitSeatRequest(
            index,
            true,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "applySeat onFailure code:" + code);
                ToastUtils.INSTANCE.showShortToast(VoiceRoomBaseActivity.this, msg);
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                showApplySeatDialog();
              }
            });
  }

  protected boolean canShowTip = false;

  protected void showApplySeatDialog() {
    if (cancelApplySeatDialog == null) {
      cancelApplySeatDialog = new CancelApplySeatDialog();
      cancelApplySeatDialog.show(getSupportFragmentManager());
    }
    ALog.d(TAG, "onApplySeatSuccess");
    canShowTip = true;
    cancelApplySeatDialog.setClickListener(
        () -> {
          if (bottomDialog != null && bottomDialog.isShowing()) {
            bottomDialog.dismiss();
          }
          bottomDialog =
              new ListItemDialog(VoiceRoomBaseActivity.this)
                  .setOnItemClickListener(
                      item -> {
                        if (getString(R.string.voiceroom_confirm_to_cancel).equals(item)) {
                          cancelSeatApply();
                          canShowTip = false;
                        }
                      });
          bottomDialog.setOnDismissListener(
              dialog1 -> {
                if (canShowTip) {
                  cancelApplySeatDialog.show(getSupportFragmentManager());
                }
              });
          bottomDialog.show(
              Arrays.asList(
                  getString(R.string.voiceroom_confirm_to_cancel),
                  getString(R.string.voiceroom_cancel)));
        });
  }

  private void dismissCancelApplySeatDialog() {
    if (cancelApplySeatDialog != null
        && cancelApplySeatDialog.getDialog() != null
        && cancelApplySeatDialog.getDialog().isShowing()) {
      cancelApplySeatDialog.dismiss();
      cancelApplySeatDialog = null;
    }
  }

  public void cancelSeatApply() {
    NEVoiceRoomKit.getInstance()
        .cancelSeatRequest(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "cancelSeatApply onFailure code:" + code);
                ToastX.showShortToast(getString(R.string.voiceroom_operate_fail));
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastX.showShortToast(getString(R.string.voiceroom_apply_canceled));
              }
            });
  }

  protected void leaveSeat() {
    NEVoiceRoomKit.getInstance()
        .leaveSeat(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "leaveSeat onFailure code:" + code);
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastX.showShortToast(getString(R.string.voiceroom_already_leave_seat));
              }
            });
  }

  public void hintSeatState(VoiceRoomSeatEvent seat, boolean on) {
    if (on) {
      Bundle bundle = new Bundle();
      switch (seat.getReason()) {
        case RoomSeat.Reason.ANCHOR_INVITE:
          {
            int position = seat.getIndex() - 1;
            new NotificationDialog(VoiceRoomBaseActivity.this)
                .setTitle(getString(R.string.voiceroom_notify))
                .setContent(String.format(getString(R.string.voiceroom_on_seated_tips), position))
                .setPositive(
                    getString(R.string.voiceroom_get_it),
                    v -> {
                      canShowTip = false;
                      if (bottomDialog != null && bottomDialog.isShowing()) {
                        bottomDialog.dismiss();
                      }
                    })
                .show();
            break;
          }
          //主播同意上麦
        case RoomSeat.Reason.ANCHOR_APPROVE_APPLY:
          {
            canShowTip = false;
            if (bottomDialog != null && bottomDialog.isShowing()) {
              bottomDialog.dismiss();
            }
            TopTipsDialog topTipsDialog = new TopTipsDialog();
            TopTipsDialog.Style style =
                topTipsDialog
                .new Style(
                    getString(R.string.voiceroom_request_accepted),
                    R.color.color_00000000,
                    R.drawable.right,
                    R.color.color_black);
            bundle.putParcelable(topTipsDialog.getDialogTag(), style);
            topTipsDialog.setArguments(bundle);
            topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.getDialogTag());
            new Handler(Looper.getMainLooper()).postDelayed(topTipsDialog::dismiss, 2000); // 延时2秒
            break;
          }
        default:
          break;
      }
    } else {
      if (seat.getReason() == RoomSeat.Reason.ANCHOR_KICK) {
        new NotificationDialog(this)
            .setTitle(getString(R.string.voiceroom_notify))
            .setContent(getString(R.string.voiceroom_kikout_seat_by_host))
            .setPositive(getString(R.string.voiceroom_get_it), null)
            .show();
      }
    }
  }

  protected void promptLeaveSeat() {
    new ListItemDialog(VoiceRoomBaseActivity.this)
        .setOnItemClickListener(
            item -> {
              if (getString(R.string.voiceroom_dowmseat).equals(item)) {
                leaveSeat();
              }
            })
        .show(
            Arrays.asList(
                getString(R.string.voiceroom_dowmseat), getString(R.string.voiceroom_cancel)));
  }

  public void onSeatApplyDenied(boolean otherOn) {
    if (otherOn) {
      ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_request_rejected));
    } else {

      new NotificationDialog(this)
          .setTitle(getString(R.string.voiceroom_notify))
          .setContent(getString(R.string.voiceroom_request_rejected))
          .setPositive(
              getString(R.string.voiceroom_get_it),
              v -> {
                canShowTip = false;
                if (bottomDialog != null && bottomDialog.isShowing()) {
                  bottomDialog.dismiss();
                }
              })
          .show();
    }
  }

  public void onEnterSeat(VoiceRoomSeatEvent event, boolean last) {
    updateAudioSwitchVisible(true);
    if (!last) {
      hintSeatState(event, true);
    }
  }

  public void onLeaveSeat(VoiceRoomSeatEvent event, boolean bySelf) {
    updateAudioSwitchVisible(false);

    if (!bySelf) {
      hintSeatState(event, false);
    }
  }

  protected void updateAudioSwitchVisible(boolean visible) {
    ivLocalAudioSwitch.setVisibility(visible ? View.VISIBLE : View.GONE);
    moreItems.get(MORE_ITEM_MICRO_PHONE).setVisible(visible);
    moreItems.get(MORE_ITEM_EAR_BACK).setVisible(visible);
    moreItems.get(MORE_ITEM_MIXER).setVisible(visible);
  }

  @Override
  public void finish() {
    if (!prepareFloatPlay) {
      charSequenceList.clear();
    }
    super.finish();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  @Override
  protected ViewUtils.ModeType getStatusBarTextModeType() {
    return ViewUtils.ModeType.NIGHT;
  }

  public abstract void onClickSmallWindow();

  protected void createMoreItems() {}

  protected abstract boolean isAnchor();

  protected abstract String getPageName();
}

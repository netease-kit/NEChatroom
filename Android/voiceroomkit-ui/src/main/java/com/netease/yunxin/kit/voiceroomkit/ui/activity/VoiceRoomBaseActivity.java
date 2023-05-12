// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Rect;
import android.os.Bundle;
import android.os.IBinder;
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
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.airbnb.lottie.LottieAnimationView;
import com.airbnb.lottie.LottieDrawable;
import com.gyf.immersionbar.ImmersionBar;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.DeviceUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.common.utils.PermissionUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.RoomConstants;
import com.netease.yunxin.kit.entertainment.common.activity.BaseActivity;
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
import com.netease.yunxin.kit.entertainment.common.utils.StringUtils;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.entertainment.common.utils.ViewUtils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.ui.OrderSongDialog;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMemberVolumeInfo;
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.adapter.BaseAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.adapter.SeatAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChatRoomAudioDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChatRoomMixerDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChoiceDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.NoticeDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.NotificationDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.TopTipsDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.helper.EffectPlayHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.service.KeepAliveService;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.BackgroundMusicPanel;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.ChatRoomMsgRecyclerView;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.VolumeSetup;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import kotlin.Unit;

/** 主播与观众基础页，包含所有的通用UI元素 */
public abstract class VoiceRoomBaseActivity extends BaseActivity
    implements ViewTreeObserver.OnGlobalLayoutListener {

  public static final String TAG = "AudioRoom";
  public static final String TAG_REPORT_PAGE = "page_chatroom_detail";
  public static List<CharSequence> charSequenceList = new ArrayList<>();
  private static final int KEY_BOARD_MIN_SIZE = SizeUtils.dp2px(80);

  protected static final int MORE_ITEM_MICRO_PHONE = 0; // 更多菜单麦克风

  protected static final int MORE_ITEM_EAR_BACK = 1; // 更多菜单耳返

  protected static final int MORE_ITEM_MIXER = 2; // 调音台

  protected static final int MORE_ITEM_AUDIO = 3; // 伴音

  protected static final int MORE_ITEM_FINISH = 4; // 更多菜单 结束房间

  protected ConstraintLayout clyAnchorView;

  //主播基础信息
  protected HeadImageView ivAnchorAvatar;

  protected LottieAnimationView lavAnchorAvatar;

  protected ImageView ivAnchorAudioCloseHint;

  protected TextView tvAnchorNick;

  protected TextView tvAnchorReward;

  protected TextView tvRoomName;

  protected BackgroundMusicPanel tvBackgroundMusic;

  protected TextView tvMemberCount;

  // 各种控制开关
  protected FrameLayout settingsContainer;

  protected ImageView ivLocalAudioSwitch;

  protected TextView tvInput;

  protected EditText edtInput;

  protected View more;

  protected RecyclerView recyclerView;

  protected SeatAdapter seatAdapter;

  protected ChatRoomMsgRecyclerView rcyChatMsgList;

  private int rootViewVisibleHeight;

  private View rootView;

  private View announcement;

  private boolean joinRoomSuccess = false;

  protected RoomModel voiceRoomInfo;

  protected VoiceRoomViewModel roomViewModel;

  protected EffectPlayHelper audioPlay;

  protected int earBack = 100;

  protected boolean isAnchor = true;

  protected ChatRoomMoreDialog chatRoomMoreDialog;

  protected List<ChatRoomMoreDialog.MoreItem> moreItemList;

  protected TopTipsDialog topTipsDialog;

  protected View netErrorView;

  protected ImageView ivGift;

  private GiftRender giftRender;

  protected ImageView ivOrderSong;

  private SeekBar skRecordingVolume;

  private SwitchCompat switchEarBack;

  private View baseAudioView;
  private SimpleServiceConnection mServiceConnection;

  private boolean isOverSeaEnv = false;
  private boolean needJoinRoom = true;
  private boolean prepareFloatPlay = false;

  private final BaseAdapter.ItemClickListener<RoomSeat> itemClickListener = this::onSeatItemClick;

  private final BaseAdapter.ItemLongClickListener<RoomSeat> itemLongClickListener =
      this::onSeatItemLongClick;

  private static final String RECORD_AUDIO_PERMISSION = Manifest.permission.RECORD_AUDIO;
  private boolean callLeaveRoom = false;
  private final BluetoothHeadsetUtil.BluetoothHeadsetStatusObserver
      bluetoothHeadsetStatusChangeListener =
          new BluetoothHeadsetUtil.BluetoothHeadsetStatusObserver() {
            @Override
            public void connect() {
              if (!BluetoothHeadsetUtil.hasBluetoothConnectPermission()) {
                BluetoothHeadsetUtil.requestBluetoothConnectPermission();
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
              ToastUtils.INSTANCE.showShortToast(
                  VoiceRoomBaseActivity.this, "Record audio permission failed!");
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
    ImmersionBar.with(this).statusBarDarkFont(false).init();
    roomViewModel = getRoomViewModel();
    initRoomViewModel();
    setContentView(getContentViewID());
    initViews();
    NEOrderSongService.INSTANCE.setRoomUuid(voiceRoomInfo.getRoomUuid());
    initListeners();
    initData();
    bindForegroundService();
    BluetoothHeadsetUtil.registerBluetoothHeadsetStatusObserver(
        bluetoothHeadsetStatusChangeListener);
    if (BluetoothHeadsetUtil.isBluetoothHeadsetConnected()
        && !BluetoothHeadsetUtil.hasBluetoothConnectPermission()) {
      BluetoothHeadsetUtil.requestBluetoothConnectPermission();
    }
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
    leaveRoom();
    super.onBackPressed();
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
      rcyChatMsgList.toLatestMsg();
    }
  }

  private void initBaseView() {
    baseAudioView = findViewById(R.id.rl_base_audio_ui);
    if (baseAudioView == null) {
      throw new IllegalStateException("xml layout must include base_audio_ui.xml layout");
    }
    int barHeight = ImmersionBar.getStatusBarHeight(this);
    baseAudioView.setPadding(
        baseAudioView.getPaddingLeft(),
        baseAudioView.getPaddingTop() + barHeight,
        baseAudioView.getPaddingRight(),
        baseAudioView.getPaddingBottom());
    clyAnchorView = baseAudioView.findViewById(R.id.cly_anchor_layout);
    ivAnchorAvatar = baseAudioView.findViewById(R.id.iv_liver_avatar);
    lavAnchorAvatar = baseAudioView.findViewById(R.id.lav_avatar_lottie_view);
    ivAnchorAudioCloseHint = baseAudioView.findViewById(R.id.iv_liver_audio_close_hint);
    tvAnchorNick = baseAudioView.findViewById(R.id.tv_liver_nick);
    tvAnchorReward = baseAudioView.findViewById(R.id.tv_user_reward);
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
    recyclerView = baseAudioView.findViewById(R.id.recyclerview_seat);
    rcyChatMsgList = baseAudioView.findViewById(R.id.rcy_chat_message_list);
    tvInput = baseAudioView.findViewById(R.id.tv_input_text);
    edtInput = baseAudioView.findViewById(R.id.edt_input_text);
    announcement = baseAudioView.findViewById(R.id.tv_chat_room_announcement);
    ivGift = baseAudioView.findViewById(R.id.iv_gift);
    ivOrderSong = baseAudioView.findViewById(R.id.iv_order_song);
    initGiftAnimation(baseAudioView);
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
    baseAudioView
        .findViewById(R.id.iv_small_window)
        .setOnClickListener(
            v -> {
              if (FloatWindowPermissionManager.INSTANCE.isFloatWindowOpAllowed(
                  VoiceRoomBaseActivity.this)) {
                prepareFloatPlay = true;
                Intent intent = new Intent();
                if (isAnchor) {
                  intent.setClass(VoiceRoomBaseActivity.this, AnchorActivity.class);
                  intent.putExtra(NEVoiceRoomUIConstants.ENV_KEY, isOverSeaEnv);
                } else {
                  intent.setClass(VoiceRoomBaseActivity.this, AudienceActivity.class);
                }
                intent.putExtra(NEVoiceRoomUIConstants.NEED_JOIN_ROOM__KEY, false);
                intent.putExtra(RoomConstants.INTENT_ROOM_MODEL, voiceRoomInfo);
                FloatPlayManager.getInstance()
                    .startFloatPlay(VoiceRoomBaseActivity.this, voiceRoomInfo, intent);
                finish();
              } else {
                FloatWindowPermissionManager.INSTANCE.requestFloatWindowPermission(
                    VoiceRoomBaseActivity.this);
              }
            });
    tvInput.setOnClickListener(v -> InputUtils.showSoftInput(VoiceRoomBaseActivity.this, edtInput));
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
          ReportUtils.report(VoiceRoomBaseActivity.this, TAG_REPORT_PAGE, "chatroom_gift");
          Application application = Utils.getApp();
          if (application != null && !NetworkUtils.isConnected()) {
            ToastUtils.INSTANCE.showShortToast(
                application, application.getString(R.string.voiceroom_net_error));
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
          ReportUtils.report(VoiceRoomBaseActivity.this, TAG_REPORT_PAGE, "chatroom_order_song");
          showSingingTable();
        });
  }

  private void initData() {
    audioPlay = new EffectPlayHelper(VoiceRoomBaseActivity.this);
    initDataObserver();
  }

  private void showSingingTable() {
    if (!ClickUtils.isSlightlyFastClick()) {
      if (!NetworkUtils.isConnected()) {
        return;
      }

      OrderSongDialog dialog = new OrderSongDialog(NEVoiceRoomKit.getInstance().getEffectVolume());
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
    recyclerView.setLayoutManager(new GridLayoutManager(this, 4));
    seatAdapter = new SeatAdapter(roomViewModel.onSeatListData.getValue(), this);
    seatAdapter.setItemClickListener(itemClickListener);
    seatAdapter.setItemLongClickListener(itemLongClickListener);
    recyclerView.setAdapter(seatAdapter);
    seatAdapter.notifyDataSetChanged();
    roomViewModel.onSeatListData.observe(
        this, voiceRoomSeats -> seatAdapter.setItems(voiceRoomSeats));
  }

  protected abstract int getContentViewID();

  protected abstract void setupBaseView();

  protected abstract void onSeatItemClick(RoomSeat model, int position);

  protected abstract boolean onSeatItemLongClick(RoomSeat model, int position);

  @NonNull
  protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
    return Collections.emptyList();
  }

  protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
    return onMoreItemClickListener;
  }

  protected void onNetLost() {
    Bundle bundle = new Bundle();
    topTipsDialog = new TopTipsDialog();
    TopTipsDialog.Style style =
        topTipsDialog
        .new Style(getString(R.string.voiceroom_net_disconnected), 0, R.drawable.neterrricon, 0);
    bundle.putParcelable(topTipsDialog.getDialogTag(), style);
    topTipsDialog.setArguments(bundle);
    if (!topTipsDialog.isVisible()) {
      topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.getDialogTag());
    }
    netErrorView.setVisibility(View.VISIBLE);
  }

  protected void onNetAvailable() {
    if (topTipsDialog != null) {
      topTipsDialog.dismiss();
    }
    netErrorView.setVisibility(View.GONE);
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
    boolean isAnchor = NEVoiceRoomRole.HOST.getValue().equals(role);
    if (isAnchor) {
      updateAnchorUI(nick, avatar, true);
    }
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
                        isAnchor
                            ? R.string.voiceroom_start_live_error
                            : R.string.voiceroom_join_live_error));
              }
              finish();
            }
          });
    }
  }

  private void updateLocalUI(NEVoiceRoomMember localMember) {
    ivLocalAudioSwitch.setSelected(!localMember.isAudioOn());
  }

  private void updateAnchorUI(String nick, String avatar, boolean isAudioOn) {
    ivAnchorAvatar.loadAvatar(avatar);
    tvAnchorNick.setText(nick);
    ivAnchorAudioCloseHint.setImageResource(
        isAudioOn ? R.drawable.icon_seat_open_micro : R.drawable.icon_seat_close_micro);
  }

  @SuppressLint("NotifyDataSetChanged")
  protected void initDataObserver() {
    roomViewModel.anchorMemberData.observe(
        this,
        hostMember ->
            updateAnchorUI(hostMember.getName(), hostMember.getAvatar(), hostMember.isAudioOn()));
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
          List<RoomSeat> audienceSeats = new ArrayList<>();
          for (RoomSeat model : seatList) {
            if (model.getSeatIndex() != VoiceRoomViewModel.ANCHOR_SEAT_INDEX) {
              audienceSeats.add(model);
            }
            final NEVoiceRoomMember member = model.getMember();
            if (member != null && VoiceRoomUtils.isHost(member.getAccount())) {
              updateAnchorUI(member.getName(), member.getAvatar(), member.isAudioOn());
            }
          }
          seatAdapter.setItems(audienceSeats);
        });

    roomViewModel.chatRoomMsgData.observe(
        this,
        charSequence -> {
          charSequenceList.add(charSequence);
          rcyChatMsgList.appendItem(charSequence);
        });

    roomViewModel.errorData.observe(
        this,
        endReason -> {
          if (endReason == NEVoiceRoomEndReason.CLOSE_BY_MEMBER) {
            if (!VoiceRoomUtils.isLocalAnchor()) {
              ToastUtils.INSTANCE.showShortToast(
                  VoiceRoomBaseActivity.this, getString(R.string.voiceroom_host_close_room));
            }
            finish();
          } else if (endReason == NEVoiceRoomEndReason.END_OF_RTC) {
            leaveRoom();
          } else {
            finish();
          }
        });
    roomViewModel.rtcLocalAudioVolumeIndicationData.observe(
        this,
        volume -> {
          if (VoiceRoomUtils.isLocalAnchor()) {
            showAvatarAnimal(volume > 0 && VoiceRoomUtils.getLocalMember().isAudioOn());
          } else {
            for (RoomSeat roomSeat : seatAdapter.getDataList()) {
              if (VoiceRoomUtils.isLocal(roomSeat.getAccount())) {
                if (roomSeat.isSpeaking() && volume == 0) {
                  roomSeat.setSpeaking(false);
                  seatAdapter.notifyItemChanged(seatAdapter.getDataList().indexOf(roomSeat));
                } else if (!roomSeat.isSpeaking() && volume > 0) {
                  roomSeat.setSpeaking(true);
                  seatAdapter.notifyItemChanged(seatAdapter.getDataList().indexOf(roomSeat));
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
              showAvatarAnimal(
                  memberVolumeInfo.getVolume() > 0
                      && VoiceRoomUtils.getMember(memberVolumeInfo.getUserUuid()).isAudioOn());
            }
          }
          for (RoomSeat roomSeat : seatAdapter.getDataList()) {
            if (!VoiceRoomUtils.isLocal(roomSeat.getAccount())) {
              if (memberVolumeInfoMap.containsKey(roomSeat.getAccount())
                  && (Objects.requireNonNull(memberVolumeInfoMap.get(roomSeat.getAccount())))
                          .getVolume()
                      > 0) {
                if (!roomSeat.isSpeaking()) {
                  roomSeat.setSpeaking(true);
                  seatAdapter.notifyItemChanged(seatAdapter.getDataList().indexOf(roomSeat));
                }
              } else {
                if (roomSeat.isSpeaking()) {
                  roomSeat.setSpeaking(false);
                  seatAdapter.notifyItemChanged(seatAdapter.getDataList().indexOf(roomSeat));
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
            ChoiceDialog dialog =
                new NotificationDialog(VoiceRoomBaseActivity.this)
                    .setTitle(getString(R.string.voiceroom_notify))
                    .setContent(
                        getString(
                            memberAudioBannedModel.isBanned()
                                ? R.string.voiceroom_seat_muted
                                : R.string.voiceroom_unmute_seat_tips))
                    .setPositive(getString(R.string.voiceroom_get_it), v -> {});
            dialog.setCancelable(false);
            dialog.show();
          }
          seatAdapter.notifyDataSetChanged();
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
          if (VoiceRoomUtils.isHost(memberAudioMuteChangedModel.getMember().getAccount())) {
            ivAnchorAudioCloseHint.setImageResource(
                memberAudioMuteChangedModel.isMute()
                    ? R.drawable.icon_seat_close_micro
                    : R.drawable.icon_seat_open_micro);
          }
          seatAdapter.notifyDataSetChanged();
        });

    roomViewModel.rewardData.observe(
        this,
        reward -> {
          if (voiceRoomInfo == null) {
            return;
          }

          CharSequence giftReward =
              ChatRoomMsgCreator.createGiftReward(
                  VoiceRoomBaseActivity.this,
                  reward.getSendNick(),
                  1,
                  GiftCache.getGift(reward.getGiftId()).getStaticIconResId());
          rcyChatMsgList.appendItem(giftReward);
          charSequenceList.add(giftReward);
          if (!VoiceRoomUtils.isLocalAnchor()) {
            giftRender.addGift(GiftCache.getGift(reward.getGiftId()).getDynamicIconResId());
          }
        });

    roomViewModel.bachRewardData.observe(
        this,
        batchReward -> {
          if (voiceRoomInfo == null) {
            return;
          }

          ALog.i(TAG, "bachRewardData observe giftModel:" + batchReward);
          CharSequence batchGiftReward =
              ChatRoomMsgCreator.createBatchGiftReward(
                  VoiceRoomBaseActivity.this,
                  batchReward.getRewarderUserName(),
                  batchReward.getRewardeeUserName(),
                  GiftCache.getGift(batchReward.getGiftId()).getName(),
                  batchReward.getGiftCount(),
                  GiftCache.getGift(batchReward.getGiftId()).getStaticIconResId());
          rcyChatMsgList.appendItem(batchGiftReward);
          charSequenceList.add(batchGiftReward);
          if (!VoiceRoomUtils.isLocalAnchor()) {
            giftRender.addGift(GiftCache.getGift(batchReward.getGiftId()).getDynamicIconResId());
          }
        });

    roomViewModel.anchorReward.observe(
        this,
        reward -> {
          if (reward > 0) {
            tvAnchorReward.setVisibility(View.VISIBLE);
            tvAnchorReward.setText(StringUtils.formatCoinCount(reward));
          } else {
            tvAnchorReward.setVisibility(View.INVISIBLE);
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

  private void sendTextMessage() {
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
    new ChatRoomMixerDialog(VoiceRoomBaseActivity.this, audioPlay, isAnchor).show();
  }

  private void initGiftAnimation(View baseAudioView) {
    GifAnimationView gifAnimationView = new GifAnimationView(this);
    int size = ScreenUtil.getDisplayWidth();
    ConstraintLayout.LayoutParams layoutParams = new ConstraintLayout.LayoutParams(size, size);
    layoutParams.topToTop = ConstraintLayout.LayoutParams.PARENT_ID;
    layoutParams.bottomToBottom = ConstraintLayout.LayoutParams.PARENT_ID;
    ViewGroup root = (ViewGroup) baseAudioView.findViewById(R.id.rl_base_audio_ui);
    root.addView(gifAnimationView, layoutParams);
    gifAnimationView.bringToFront();
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

  private void showAvatarAnimal(boolean showAvatarAnimal) {
    if (showAvatarAnimal) {
      lavAnchorAvatar.setVisibility(View.VISIBLE);
      if (lavAnchorAvatar.isAnimating()) {
        return;
      }
      lavAnchorAvatar.setRepeatCount(LottieDrawable.INFINITE);
      lavAnchorAvatar.playAnimation();
    } else {
      lavAnchorAvatar.setVisibility(View.INVISIBLE);
      lavAnchorAvatar.cancelAnimation();
      lavAnchorAvatar.setProgress(0);
    }
  }

  @Override
  public void finish() {
    if (!prepareFloatPlay) {
      charSequenceList.clear();
    }
    super.finish();
  }
}

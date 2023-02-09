// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.activity;

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
import android.view.Gravity;
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
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SwitchCompat;
import androidx.lifecycle.ViewModelProvider;
import com.blankj.utilcode.util.PermissionUtils;
import com.gyf.immersionbar.ImmersionBar;
import com.netease.yunxin.app.listentogether.Constants;
import com.netease.yunxin.app.listentogether.activity.base.BaseActivity;
import com.netease.yunxin.app.listentogether.chatroom.ChatRoomMsgCreator;
import com.netease.yunxin.app.listentogether.core.SongPlayManager;
import com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomAudioDialog;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomMixerDialog;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.app.listentogether.dialog.NoticeDialog;
import com.netease.yunxin.app.listentogether.dialog.TopTipsDialog;
import com.netease.yunxin.app.listentogether.gift.GifAnimationView;
import com.netease.yunxin.app.listentogether.gift.GiftCache;
import com.netease.yunxin.app.listentogether.gift.GiftDialog;
import com.netease.yunxin.app.listentogether.gift.GiftRender;
import com.netease.yunxin.app.listentogether.helper.AudioPlayHelper;
import com.netease.yunxin.app.listentogether.model.ListenTogetherRoomModel;
import com.netease.yunxin.app.listentogether.model.VoiceRoomSeat;
import com.netease.yunxin.app.listentogether.service.KeepAliveService;
import com.netease.yunxin.app.listentogether.utils.ClickUtils;
import com.netease.yunxin.app.listentogether.utils.InputUtils;
import com.netease.yunxin.app.listentogether.utils.ListenTogetherUtils;
import com.netease.yunxin.app.listentogether.utils.Utils;
import com.netease.yunxin.app.listentogether.utils.ViewUtils;
import com.netease.yunxin.app.listentogether.viewmodel.ListenTogetherViewModel;
import com.netease.yunxin.app.listentogether.viewmodel.RoomViewModel;
import com.netease.yunxin.app.listentogether.widget.ChatRoomMsgRecyclerView;
import com.netease.yunxin.app.listentogether.widget.ListenTogetherSeatsLayout;
import com.netease.yunxin.app.listentogether.widget.SeatView;
import com.netease.yunxin.app.listentogether.widget.SongOptionPanel;
import com.netease.yunxin.app.listentogether.widget.VolumeSetup;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.DeviceUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogetherkit.api.NEJoinListenTogetherRoomOptions;
import com.netease.yunxin.kit.listentogetherkit.api.NEJoinListenTogetherRoomParams;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherCallback;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListener;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListenerAdapter;
import com.netease.yunxin.kit.listentogetherkit.api.NELiveType;
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.listentogetherkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomMember;
import com.netease.yunxin.kit.listentogetherkit.impl.utils.ScreenUtil;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.ordersong.core.model.Song;
import com.netease.yunxin.kit.ordersong.ui.NEOrderSongCallback;
import com.netease.yunxin.kit.ordersong.ui.OrderSongDialog;
import com.netease.yunxin.kit.ordersong.ui.viewmodel.OrderSongViewModel;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import kotlin.Unit;
import org.jetbrains.annotations.NotNull;

/** 主播与观众基础页，包含所有的通用UI元素 */
public abstract class ListenTogetherBaseActivity extends BaseActivity
    implements ViewTreeObserver.OnGlobalLayoutListener, PermissionUtils.FullCallback {

  public static final String TAG = "RoomBaseActivity";

  private String[] permissions = {
    Manifest.permission.RECORD_AUDIO,
    Manifest.permission.WRITE_EXTERNAL_STORAGE,
    Manifest.permission.READ_PHONE_STATE
  };

  private static final int KEY_BOARD_MIN_SIZE = SizeUtils.dp2px(80);

  private static final int ANCHOR_SEAT_INDEX = 1;
  private static final int AUDIENCE_SEAT_INDEX = 2;

  protected static final int MORE_ITEM_MICRO_PHONE = 0; // 更多菜单麦克风

  protected static final int MORE_ITEM_EAR_BACK = 1; // 更多菜单耳返

  protected static final int MORE_ITEM_MIXER = 2; // 调音台

  protected static final int MORE_ITEM_AUDIO = 3; // 伴音

  protected static final int MORE_ITEM_FINISH = 4; // 更多菜单 结束房间

  protected TextView tvRoomName;

  protected TextView tvMemberCount;

  // 各种控制开关
  protected FrameLayout settingsContainer;

  protected ImageView ivLocalAudioSwitch;

  protected TextView tvInput;

  protected EditText edtInput;

  protected View more;

  //消息列表
  protected ChatRoomMsgRecyclerView rcyChatMsgList;

  private int rootViewVisibleHeight;

  private View rootView;

  private View announcement;

  private boolean joinRoomSuccess = false;

  protected ListenTogetherRoomModel voiceRoomInfo;

  protected RoomViewModel roomViewModel;
  protected ListenTogetherViewModel listenTogetherViewModel;

  protected AudioPlayHelper audioPlay;

  protected int earBack = 100;

  protected boolean isAnchor = true;

  protected ChatRoomMoreDialog chatRoomMoreDialog;

  protected List<ChatRoomMoreDialog.MoreItem> moreItemList;

  protected TopTipsDialog topTipsDialog;

  protected View netErrorView;

  private GiftDialog giftDialog;

  private ImageView ivGift;
  private GiftRender giftRender;
  private ListenTogetherSeatsLayout seatsLayout;
  private SeatView.SeatInfo anchorSeatInfo;
  private SeatView.SeatInfo audienceSeatInfo;
  private SongOptionPanel songOptionPanel;
  private TextView tvOrderSong;
  private OrderSongViewModel orderSongViewModel;
  private static final int ROOM_MEMBER_MAX_COUNT = 2;
  protected int liveType;
  private SimpleServiceConnection mServiceConnection;
  private NEListenTogetherRoomListener roomListener =
      new NEListenTogetherRoomListenerAdapter() {
        @Override
        public void onMemberAudioMuteChanged(
            @NotNull NEListenTogetherRoomMember member,
            boolean mute,
            @org.jetbrains.annotations.Nullable NEListenTogetherRoomMember operateBy) {
          if (ListenTogetherUtils.isMySelf(member.getAccount())) {
            ivLocalAudioSwitch.setSelected(mute);
            getMoreItems().get(ListenTogetherBaseActivity.MORE_ITEM_MICRO_PHONE).setEnable(!mute);
            if (chatRoomMoreDialog != null) {
              chatRoomMoreDialog.updateData();
            }
          }
          if (ListenTogetherUtils.isHost(member.getAccount())) {
            anchorSeatInfo.isMute = mute;
            seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
          } else {
            audienceSeatInfo.isMute = mute;
            seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
          }
        }
      };

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
                boolean isEarBackEnable = NEListenTogetherKit.getInstance().isEarbackEnable();
                if (enableEarBack(!isEarBackEnable) == 0) {
                  item.enable = !isEarBackEnable;
                  dialog.updateData();
                }
              } else {
                ToastUtils.INSTANCE.showShortToast(this, getString(R.string.listen_earback_tip));
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
              new ChatRoomAudioDialog(
                      ListenTogetherBaseActivity.this,
                      audioPlay,
                      audioPlay.getAudioMixingMusicInfos())
                  .show();
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
    liveType = getIntent().getIntExtra(Constants.INTENT_LIVE_TYPE, NELiveType.LIVE_TYPE_VOICE);
    voiceRoomInfo =
        (ListenTogetherRoomModel) getIntent().getSerializableExtra(Constants.INTENT_ROOM_MODEL);
    if (voiceRoomInfo == null) {
      ToastUtils.INSTANCE.showShortToast(
          ListenTogetherBaseActivity.this, getString(R.string.listen_chat_message_tips));
      finish();
      return;
    }
    ImmersionBar.with(this).statusBarDarkFont(false).init();
    roomViewModel = new ViewModelProvider(this).get(RoomViewModel.class);
    orderSongViewModel = new ViewModelProvider(this).get(OrderSongViewModel.class);
    listenTogetherViewModel = new ViewModelProvider(this).get(ListenTogetherViewModel.class);
    setContentView(getContentViewID());
    initViews();
    audioPlay = new AudioPlayHelper(this);
    requestPermissionsIfNeeded();
    bindForegroundService();
  }

  /** 权限检查 */
  private void requestPermissionsIfNeeded() {
    PermissionUtils.permission(permissions).callback(this).request();
  }

  @Override
  public void onGranted(@NonNull List<String> granted) {
    if (permissions.length == granted.size()) {
      enterRoomInner(
          voiceRoomInfo.getRoomUuid(),
          voiceRoomInfo.getNick(),
          voiceRoomInfo.getAvatar(),
          voiceRoomInfo.getLiveRecordId(),
          voiceRoomInfo.getRole());
    }
  }

  @Override
  public void onDenied(@NonNull List<String> deniedForever, @NonNull List<String> denied) {
    ToastUtils.INSTANCE.showShortToast(ListenTogetherBaseActivity.this, "permission failed!");
    finish();
  }

  private void initViews() {
    findBaseView();
    setupBaseViewInner();
    setupBaseView();
    initSeatsInfo();
    rootView = getWindow().getDecorView();
    rootView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    String countStr = String.format(getString(R.string.listen_people_online), "0");
    tvMemberCount.setText(countStr);
  }

  private void initSeatsInfo() {
    anchorSeatInfo = new SeatView.SeatInfo();
    anchorSeatInfo.nickname = voiceRoomInfo.getAnchorNick();
    anchorSeatInfo.avatar = voiceRoomInfo.getAnchorAvatar();
    anchorSeatInfo.isAnchor = true;
    anchorSeatInfo.isOnSeat = true;
    anchorSeatInfo.isMute = false;
    seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
    audienceSeatInfo = new SeatView.SeatInfo();
    audienceSeatInfo.isAnchor = false;
    audienceSeatInfo.isOnSeat = false;
    seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
  }

  @Override
  protected void onDestroy() {
    if (rootView != null) {
      rootView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
    }
    if (audioPlay != null) {
      audioPlay.destroy();
    }
    NEListenTogetherKit.getInstance().removeRoomListener(roomListener);
    giftRender.release();
    SongPlayManager.getInstance().stop();
    unbindForegroundService();
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

  private void findBaseView() {
    View baseAudioView = findViewById(R.id.rl_base_audio_ui);
    if (baseAudioView == null) {
      throw new IllegalStateException("xml layout must include base_audio_ui.xml layout");
    }
    int barHeight = ImmersionBar.getStatusBarHeight(this);
    baseAudioView.setPadding(
        baseAudioView.getPaddingLeft(),
        baseAudioView.getPaddingTop() + barHeight,
        baseAudioView.getPaddingRight(),
        baseAudioView.getPaddingBottom());
    songOptionPanel = baseAudioView.findViewById(R.id.song_option_panel);
    songOptionPanel.setSongPositionCallback(position -> listenTogetherViewModel.seekTo(position));
    songOptionPanel.setLoadingCallback(
        (show) -> {
          if (isAnchor) {
            anchorSeatInfo.isLoadingSong = show;
            seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
          } else {
            audienceSeatInfo.isLoadingSong = show;
            seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
          }
        });
    NEOrderSongService.INSTANCE.setRoomUuid(voiceRoomInfo.getRoomUuid());
    tvRoomName = baseAudioView.findViewById(R.id.tv_chat_room_name);
    tvMemberCount = baseAudioView.findViewById(R.id.tv_chat_room_member_count);
    settingsContainer = findViewById(R.id.settings_container);
    settingsContainer.setOnClickListener(view -> settingsContainer.setVisibility(View.GONE));
    findViewById(R.id.settings_action_container).setOnClickListener(view -> {});
    SeekBar skRecordingVolume = settingsContainer.findViewById(R.id.recording_volume_control);
    skRecordingVolume.setOnSeekBarChangeListener(
        new VolumeSetup() {

          @Override
          protected void onVolume(int volume) {
            setAudioCaptureVolume(volume);
          }
        });
    SwitchCompat switchEarBack = settingsContainer.findViewById(R.id.ear_back);
    switchEarBack.setChecked(false);
    switchEarBack.setOnCheckedChangeListener(
        (buttonView, isChecked) -> {
          if (!DeviceUtils.hasEarBack(ListenTogetherBaseActivity.this)) {
            buttonView.setChecked(false);
            return;
          }
          enableEarBack(isChecked);
        });
    more = baseAudioView.findViewById(R.id.iv_room_more);
    more.setOnClickListener(
        v -> {
          moreItemList = getMoreItems();
          chatRoomMoreDialog =
              new ChatRoomMoreDialog(ListenTogetherBaseActivity.this, moreItemList);
          chatRoomMoreDialog.registerOnItemClickListener(getMoreItemClickListener());
          chatRoomMoreDialog.show();
        });
    ivLocalAudioSwitch = baseAudioView.findViewById(R.id.iv_local_audio_switch);
    ivLocalAudioSwitch.setSelected(true);
    ivLocalAudioSwitch.setOnClickListener(view -> toggleMuteLocalAudio());

    baseAudioView.findViewById(R.id.iv_leave_room).setOnClickListener(view -> doLeaveRoom());

    rcyChatMsgList = baseAudioView.findViewById(R.id.rcy_chat_message_list);
    tvInput = baseAudioView.findViewById(R.id.tv_input_text);
    tvInput.setOnClickListener(
        v -> InputUtils.showSoftInput(ListenTogetherBaseActivity.this, edtInput));
    edtInput = baseAudioView.findViewById(R.id.edt_input_text);
    edtInput.setOnEditorActionListener(
        (v, actionId, event) -> {
          InputUtils.hideSoftInput(ListenTogetherBaseActivity.this, edtInput);
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
    announcement = baseAudioView.findViewById(R.id.tv_chat_room_announcement);
    announcement.setOnClickListener(
        v -> {
          NoticeDialog noticeDialog = new NoticeDialog();
          noticeDialog.show(getSupportFragmentManager(), "");
        });
    initGiftAnimation(baseAudioView);
    ivGift = baseAudioView.findViewById(R.id.iv_gift);
    ivGift.setOnClickListener(
        new View.OnClickListener() {
          @Override
          public void onClick(View v) {
            Application application = Utils.getApp();
            if (!NetworkUtils.isConnected()) {
              ToastUtils.INSTANCE.showShortToast(
                  application, application.getString(R.string.listen_net_error));
              return;
            }

            if (giftDialog == null) {
              giftDialog = new GiftDialog(ListenTogetherBaseActivity.this);
            }
            giftDialog.show(
                giftId ->
                    NEListenTogetherKit.getInstance()
                        .sendGift(
                            giftId,
                            new NEListenTogetherCallback<Unit>() {
                              @Override
                              public void onSuccess(@Nullable Unit unit) {}

                              @Override
                              public void onFailure(int code, @Nullable String msg) {
                                ToastUtils.INSTANCE.showShortToast(
                                    application,
                                    application.getString(R.string.listen_reward_failed));
                              }
                            }));
          }
        });

    seatsLayout = baseAudioView.findViewById(R.id.seats_layout);

    tvOrderSong = baseAudioView.findViewById(R.id.tv_order_song);
    tvOrderSong.setOnClickListener(v -> showSingingTable());

    baseAudioView.findViewById(R.id.iv_order_song).setOnClickListener(v -> showSingingTable());
  }

  private void showSingingTable() {
    if (!ClickUtils.isSlightlyFastClick()) {
      if (!NetworkUtils.isConnected()) {
        return;
      }

      OrderSongDialog dialog =
          new OrderSongDialog(NEListenTogetherKit.getInstance().getEffectVolume());
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
    roomViewModel.getOnSeatListData().observe(this, voiceRoomSeats -> {});
  }

  protected abstract int getContentViewID();

  protected abstract void setupBaseView();

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
        .new Style(
            getString(R.string.listen_net_disconnected), 0, R.drawable.listen_neterrricon, 0);
    bundle.putParcelable(topTipsDialog.TAG, style);
    topTipsDialog.setArguments(bundle);
    if (!topTipsDialog.isVisible()) {
      topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
    }
    netErrorView.setVisibility(View.VISIBLE);
  }

  protected void onNetAvailable() {
    if (topTipsDialog != null) {
      topTipsDialog.dismiss();
    }
    netErrorView.setVisibility(View.GONE);
  }

  private void enterRoomInner(
      String roomUuid, String nick, String avatar, long liveRecordId, String role) {
    NEJoinListenTogetherRoomParams params =
        new NEJoinListenTogetherRoomParams(
            roomUuid, nick, avatar, NEVoiceRoomRole.Companion.fromValue(role), liveRecordId, null);
    boolean isAnchor = NEVoiceRoomRole.HOST.getValue().equals(role);
    ivGift.setVisibility(isAnchor ? View.GONE : View.VISIBLE);
    if (isAnchor) {
      updateAnchorUI(nick, avatar, true);
    }
    NEJoinListenTogetherRoomOptions options = new NEJoinListenTogetherRoomOptions();
    NEListenTogetherKit.getInstance()
        .joinRoom(
            params,
            options,
            new NEListenTogetherCallback<NEListenTogetherRoomInfo>() {

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "joinRoom failed code = " + code + " msg = " + msg);
                if (!TextUtils.isEmpty(msg)) {
                  ToastUtils.INSTANCE.showShortToast(ListenTogetherBaseActivity.this, msg);
                } else {
                  ToastUtils.INSTANCE.showShortToast(
                      ListenTogetherBaseActivity.this,
                      getString(
                          isAnchor
                              ? R.string.listen_start_live_error
                              : R.string.listen_join_live_error));
                }
                finish();
              }

              @Override
              public void onSuccess(@Nullable NEListenTogetherRoomInfo roomInfo) {
                ALog.i(TAG, "joinRoom success");
                if (roomInfo.getLiveModel().getAudienceCount() >= ROOM_MEMBER_MAX_COUNT) {
                  ToastUtils.INSTANCE.showShortToast(
                      ListenTogetherBaseActivity.this,
                      getString(
                          isAnchor
                              ? R.string.listen_start_live_error
                              : R.string.listen_join_live_error));
                  ALog.e(TAG, "joinRoom success but The private room is full");
                  NEListenTogetherKit.getInstance().leaveRoom(null);
                  finish();
                  return;
                }
                joinRoomSuccess = true;
                initViewAfterJoinRoom();
              }
            });
  }

  private void initViewAfterJoinRoom() {
    songOptionPanel.setRoomInfo(voiceRoomInfo);
    initDataObserver();
    roomViewModel.initDataOnJoinRoom();
    listenTogetherViewModel.initialize(voiceRoomInfo);
    if (ListenTogetherUtils.isCurrentHost()) {
      NEListenTogetherKit.getInstance().submitSeatRequest(ANCHOR_SEAT_INDEX, true, null);
    } else {
      NEListenTogetherRoomMember hostMember = ListenTogetherUtils.getHost();
      if (hostMember != null) {
        updateAnchorUI(hostMember.getName(), hostMember.getAvatar(), hostMember.isAudioOn());
      }
      roomViewModel.getSeatInfo();
    }
  }

  private void updateAnchorUI(String nick, String avatar, boolean isAudioOn) {
    anchorSeatInfo.nickname = nick;
    anchorSeatInfo.avatar = avatar;
    anchorSeatInfo.isMute = !isAudioOn;
    seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
  }

  private void initDataObserver() {
    roomViewModel
        .getMemberCountData()
        .observe(
            this,
            count -> {
              String countStr = String.format(getString(R.string.listen_people_online), count + "");
              tvMemberCount.setText(countStr);
            });
    roomViewModel
        .getOnSeatListData()
        .observe(
            this,
            seatList -> {
              List<VoiceRoomSeat> audienceSeats = new ArrayList<>();
              for (VoiceRoomSeat model : seatList) {
                if (model.getSeatIndex() == AUDIENCE_SEAT_INDEX) {
                  audienceSeats.add(model);
                }
                final NEListenTogetherRoomMember member = model.getMember();
                if (member != null && ListenTogetherUtils.isHost(member.getAccount())) {
                  updateAnchorUI(member.getName(), member.getAvatar(), member.isAudioOn());
                }
              }
              if (audienceSeats.size() == 1) {
                NEListenTogetherRoomMember member = audienceSeats.get(0).getMember();
                if (member != null) {
                  audienceSeatInfo.isOnSeat = true;
                  audienceSeatInfo.nickname = member.getName();
                  audienceSeatInfo.avatar = member.getAvatar();
                  audienceSeatInfo.isMute = !member.isAudioOn();
                  audienceSeatInfo.isListenTogether = true;
                  anchorSeatInfo.isListenTogether = true;
                  seatsLayout.setIsListeningTogether(true);
                } else {
                  audienceSeatInfo.isOnSeat = false;
                  audienceSeatInfo.isListenTogether = false;
                  anchorSeatInfo.isListenTogether = false;
                  seatsLayout.setIsListeningTogether(false);
                }
                seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
                seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
              }
            });

    roomViewModel
        .getChatRoomMsgData()
        .observe(this, charSequence -> rcyChatMsgList.appendItem(charSequence));

    roomViewModel
        .getErrorData()
        .observe(
            this,
            endReason -> {
              if (endReason == NEVoiceRoomEndReason.CLOSE_BY_MEMBER) {
                if (!ListenTogetherUtils.isCurrentHost()) {
                  ToastUtils.INSTANCE.showShortToast(
                      ListenTogetherBaseActivity.this, getString(R.string.listen_host_close_room));
                }
                finish();
              } else if (endReason == NEVoiceRoomEndReason.END_OF_RTC) {
                leaveRoom();
              } else {
                finish();
              }
            });

    roomViewModel.rewardData.observe(
        this,
        reward -> {
          if (voiceRoomInfo == null) {
            return;
          }
          rcyChatMsgList.appendItem(
              ChatRoomMsgCreator.createGiftReward(
                  ListenTogetherBaseActivity.this,
                  reward.getSendNick(),
                  1,
                  GiftCache.getGift(reward.getGiftId()).getStaticIconResId()));
          if (!ListenTogetherUtils.isCurrentHost()) {
            giftRender.addGift(GiftCache.getGift(reward.getGiftId()).getDynamicIconResId());
          }
        });

    listenTogetherViewModel
        .getPlayCurrentSongData()
        .observe(
            this,
            orderSong -> {
              tvOrderSong.setVisibility(View.GONE);
              Song songModel = new Song();
              songModel.setOrderId(orderSong.orderId);
              songModel.setSongId(orderSong.songId);
              songModel.setSongName(orderSong.songName);
              songModel.setChannel(orderSong.channel);
              songModel.setSongTime(orderSong.songTime);
              songModel.setSinger(orderSong.singer);
              songModel.setStatus(orderSong.songStatus);
              boolean isPlaying = orderSong.songStatus == ListenTogetherConstant.SONG_PLAYING_STATE;
              seatsLayout.showAnim(isPlaying);
              songOptionPanel.setPauseOrResumeState(isPlaying);
              songOptionPanel.startPlay(
                  songModel,
                  isPlaying,
                  new NEOrderSongCallback<Void>() {
                    @Override
                    public void onSuccess(@Nullable Void unused) {}

                    @Override
                    public void onFailure(int code, @Nullable String msg) {
                      ALog.e(TAG, "startPlaySong onFailure,code:" + code + ",msg:" + msg);
                    }
                  });
            });

    listenTogetherViewModel
        .getShowSongPanelData()
        .observe(
            this,
            aBoolean -> {
              showSongOptionPanel(aBoolean);
            });

    listenTogetherViewModel
        .getChatRoomMsgData()
        .observe(this, charSequence -> rcyChatMsgList.appendItem(charSequence));

    listenTogetherViewModel
        .getShowOtherSongDownLoadingData()
        .observe(
            this,
            pair -> {
              if (isAnchor) {
                audienceSeatInfo.isLoadingSong = pair.first;
                seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
              } else {
                anchorSeatInfo.isLoadingSong = pair.first;
                seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
              }
            });
    listenTogetherViewModel
        .getShowMySongDownLoadingData()
        .observe(
            this,
            pair -> {
              if (isAnchor) {
                anchorSeatInfo.isLoadingSong = pair.first;
                seatsLayout.setAnchorSeatInfo(anchorSeatInfo);
              } else {
                audienceSeatInfo.isLoadingSong = pair.first;
                seatsLayout.setAudienceSeatInfo(audienceSeatInfo);
              }
            });
    listenTogetherViewModel
        .getPlayStateChangedData()
        .observe(
            this,
            integer -> {
              if (integer == ListenTogetherConstant.SONG_START) {
                seatsLayout.showAnim(true);
              } else if (integer == ListenTogetherConstant.SONG_PAUSE) {
                seatsLayout.showAnim(false);
              } else if (integer == ListenTogetherConstant.SONG_RESUME) {
                seatsLayout.showAnim(true);
              }
            });

    listenTogetherViewModel
        .getDeleteSongData()
        .observe(
            this,
            song -> {
              if (song.getNextOrderSong() == null) {
                showSongOptionPanel(false);
              }
            });

    orderSongViewModel
        .getOrderSongListChangeEvent()
        .observe(this, neOrderSongs -> showSongOptionPanel(!neOrderSongs.isEmpty()));

    roomViewModel.anchorAvatarAnimation.observe(
        this, show -> seatsLayout.showAnchorAvatarAnimal(show));

    roomViewModel.audienceAvatarAnimation.observe(
        this, show -> seatsLayout.showAudienceAvatarAnimal(show));

    NEListenTogetherKit.getInstance().addRoomListener(roomListener);
  }

  private void showSongOptionPanel(boolean show) {
    if (show) {
      tvOrderSong.setVisibility(View.GONE);
    } else {
      tvOrderSong.setVisibility(View.VISIBLE);
      songOptionPanel.setVisibility(View.INVISIBLE);
      songOptionPanel.reset();
      seatsLayout.showAnim(false);
    }
  }

  protected final void leaveRoom() {
    if (ListenTogetherUtils.isCurrentHost()) {
      NEListenTogetherKit.getInstance()
          .endRoom(
              new NEListenTogetherCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ALog.i(TAG, "endRoom success");
                  ToastUtils.INSTANCE.showShortToast(
                      ListenTogetherBaseActivity.this,
                      getString(R.string.listen_host_close_room_success));
                  finish();
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "endRoom onFailure");
                }
              });
    } else {
      NEListenTogetherKit.getInstance()
          .leaveSeat(
              new NEListenTogetherCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  NEListenTogetherKit.getInstance()
                      .leaveRoom(
                          new NEListenTogetherCallback<Unit>() {
                            @Override
                            public void onSuccess(@Nullable Unit unit) {
                              ALog.i(TAG, "leaveRoom success");
                              finish();
                            }

                            @Override
                            public void onFailure(int code, @Nullable String msg) {
                              ALog.e(TAG, "leaveRoom onFailure");
                              ToastUtils.INSTANCE.showShortToast(
                                  getApplicationContext(),
                                  "leaveRoom failed code:" + code + ",msg:" + msg);
                            }
                          });
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "leaveSeat onFailure code:" + code + ",msg:" + msg);
                  NEListenTogetherKit.getInstance()
                      .leaveRoom(
                          new NEListenTogetherCallback<Unit>() {
                            @Override
                            public void onSuccess(@Nullable Unit unit) {
                              ALog.i(TAG, "leaveRoom success");
                              finish();
                            }

                            @Override
                            public void onFailure(int code, @Nullable String msg) {
                              ALog.e(TAG, "leaveRoom onFailure");
                              ToastUtils.INSTANCE.showShortToast(
                                  getApplicationContext(),
                                  "leaveRoom failed code:" + code + ",msg:" + msg);
                            }
                          });
                }
              });
    }
  }

  protected final void toggleMuteLocalAudio() {
    if (!joinRoomSuccess) return;
    NEListenTogetherRoomMember localMember = NEListenTogetherKit.getInstance().getLocalMember();
    if (localMember == null) return;
    boolean isAudioOn = localMember.isAudioOn();
    ALog.d(
        TAG,
        "toggleMuteLocalAudio,localMember.isAudioOn:"
            + isAudioOn
            + ",localMember.isAudioBanned():"
            + localMember.isAudioBanned());
    if (isAudioOn) {
      muteMyAudio(
          new NEListenTogetherCallback<Unit>() {
            @Override
            public void onSuccess(@Nullable Unit unit) {
              ToastUtils.INSTANCE.showShortToast(
                  ListenTogetherBaseActivity.this, getString(R.string.listen_mic_off));
            }

            @Override
            public void onFailure(int code, @Nullable String msg) {}
          });
    } else {
      unmuteMyAudio(
          new NEListenTogetherCallback<Unit>() {
            @Override
            public void onSuccess(@Nullable Unit unit) {
              ToastUtils.INSTANCE.showShortToast(
                  ListenTogetherBaseActivity.this, getString(R.string.listen_mic_on));
            }

            @Override
            public void onFailure(int code, @Nullable String msg) {}
          });
    }
  }

  protected void setAudioCaptureVolume(int volume) {
    NEListenTogetherKit.getInstance().adjustRecordingSignalVolume(volume);
  }

  protected int enableEarBack(boolean enable) {
    if (enable) {
      return NEListenTogetherKit.getInstance().enableEarback(earBack);
    } else {
      return NEListenTogetherKit.getInstance().disableEarback();
    }
  }

  private void sendTextMessage() {
    String content = edtInput.getText().toString().trim();
    if (TextUtils.isEmpty(content)) {
      ToastUtils.INSTANCE.showShortToast(this, getString(R.string.listen_chat_message_tips));
      return;
    }
    NEListenTogetherKit.getInstance()
        .sendTextMessage(
            content,
            new NEListenTogetherCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                rcyChatMsgList.appendItem(
                    ChatRoomMsgCreator.createText(
                        ListenTogetherBaseActivity.this,
                        ListenTogetherUtils.isCurrentHost(),
                        ListenTogetherUtils.getCurrentName(),
                        content));
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
      InputUtils.hideSoftInput(ListenTogetherBaseActivity.this, edtInput);
    }
    return super.dispatchTouchEvent(ev);
  }

  /** 显示调音台 */
  public void showChatRoomMixerDialog() {
    new ChatRoomMixerDialog(ListenTogetherBaseActivity.this, audioPlay, isAnchor).show();
  }

  private void initGiftAnimation(View baseAudioView) {
    GifAnimationView gifAnimationView = new GifAnimationView(this);
    int size = ScreenUtil.getDisplayWidth();
    FrameLayout.LayoutParams layoutParams =
        new FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
    layoutParams.width = size;
    layoutParams.height = size;
    layoutParams.gravity = Gravity.BOTTOM;
    layoutParams.bottomMargin = ScreenUtil.dip2px(166f);
    ViewGroup root = (ViewGroup) baseAudioView.findViewById(R.id.rl_base_audio_ui);
    root.addView(gifAnimationView, layoutParams);
    gifAnimationView.bringToFront();
    giftRender = new GiftRender();
    giftRender.init(gifAnimationView);
  }

  public void unmuteMyAudio(NEListenTogetherCallback<Unit> callback) {
    NEListenTogetherKit.getInstance().unmuteMyAudio(callback);
  }

  public void muteMyAudio(NEListenTogetherCallback<Unit> callback) {
    NEListenTogetherKit.getInstance().muteMyAudio(callback);
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

  private class SimpleServiceConnection implements ServiceConnection {
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
}

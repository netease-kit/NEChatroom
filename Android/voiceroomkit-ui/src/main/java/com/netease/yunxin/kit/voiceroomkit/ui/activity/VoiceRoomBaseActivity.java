// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.annotation.SuppressLint;
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
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.gyf.immersionbar.ImmersionBar;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListener;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.base.BaseActivity;
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
import com.netease.yunxin.kit.voiceroomkit.ui.helper.AudioPlayHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomModel;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.InputUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.ViewUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.ChatRoomMsgRecyclerView;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.VolumeSetup;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import kotlin.Unit;
import org.jetbrains.annotations.NotNull;

/** 主播与观众基础页，包含所有的通用UI元素 */
public abstract class VoiceRoomBaseActivity extends BaseActivity
    implements ViewTreeObserver.OnGlobalLayoutListener {

  public static final String TAG = "AudioRoom";

  private static final int KEY_BOARD_MIN_SIZE = SizeUtils.dp2px(80);

  private static final int ANCHOR_SEAT_INDEX = 1;

  protected static final int MORE_ITEM_MICRO_PHONE = 0; // 更多菜单麦克风

  protected static final int MORE_ITEM_EAR_BACK = 1; // 更多菜单耳返

  protected static final int MORE_ITEM_MIXER = 2; // 调音台

  protected static final int MORE_ITEM_AUDIO = 3; // 伴音

  protected static final int MORE_ITEM_FINISH = 4; // 更多菜单 结束房间

  protected ConstraintLayout clyAnchorView;

  protected TextView tvOrderMusic;

  protected TextView tvOrderedNum;

  //主播基础信息
  protected HeadImageView ivAnchorAvatar;

  protected ImageView ivAnchorAudioCloseHint;

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
  protected ChatRoomMsgRecyclerView rcyChatMsgList;

  private int rootViewVisibleHeight;

  private View rootView;

  private View announcement;

  private boolean joinRoomSuccess = false;

  private BaseAdapter.ItemClickListener<VoiceRoomSeat> itemClickListener = this::onSeatItemClick;

  private BaseAdapter.ItemLongClickListener<VoiceRoomSeat> itemLongClickListener =
      this::onSeatItemLongClick;

  protected VoiceRoomModel voiceRoomInfo;

  protected VoiceRoomViewModel roomViewModel;

  protected AudioPlayHelper audioPlay;

  protected int earBack = 100;

  protected boolean isAnchor = true;

  protected ChatRoomMoreDialog chatRoomMoreDialog;

  protected List<ChatRoomMoreDialog.MoreItem> moreItemList;

  protected TopTipsDialog topTipsDialog;

  protected View netErrorView;

  private NEVoiceRoomListener voiceRoomListener =
      new NEVoiceRoomListenerAdapter() {
        @Override
        public void onMemberAudioMuteChanged(
            @NotNull NEVoiceRoomMember member,
            boolean mute,
            @org.jetbrains.annotations.Nullable NEVoiceRoomMember operateBy) {
          if (VoiceRoomUtils.isMySelf(member.getAccount())) {
            ivLocalAudioSwitch.setSelected(mute);
            getMoreItems().get(VoiceRoomBaseActivity.MORE_ITEM_MICRO_PHONE).setEnable(!mute);
            if (chatRoomMoreDialog != null) {
              chatRoomMoreDialog.updateData();
            }
          }
          if (VoiceRoomUtils.isHost(member.getAccount())) {
            ivAnchorAudioCloseHint.setImageResource(
                mute ? R.drawable.icon_seat_close_micro : R.drawable.icon_seat_open_micro);
          }
          seatAdapter.notifyDataSetChanged();
        }

        @Override
        public void onMemberAudioBanned(@NonNull NEVoiceRoomMember member, boolean banned) {
          if (VoiceRoomUtils.isMySelf(member.getAccount()) && roomViewModel.isCurrentUserOnSeat()) {
            ChoiceDialog dialog =
                new NotificationDialog(VoiceRoomBaseActivity.this)
                    .setTitle(getString(R.string.voiceroom_notify))
                    .setContent(
                        getString(
                            banned
                                ? R.string.voiceroom_seat_muted
                                : R.string.voiceroom_unmute_seat_tips))
                    .setPositive(getString(R.string.voiceroom_get_it), v -> {});
            dialog.setCancelable(false);
            dialog.show();
          }
          seatAdapter.notifyDataSetChanged();
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
              boolean isEarBackEnable = NEVoiceRoomKit.getInstance().isEarbackEnable();
              if (enableEarBack(!isEarBackEnable) == 0) {
                item.enable = !isEarBackEnable;
                dialog.updateData();
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
                      VoiceRoomBaseActivity.this, audioPlay, audioPlay.getAudioMixingMusicInfos())
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
    voiceRoomInfo =
        (VoiceRoomModel) getIntent().getSerializableExtra(NEVoiceRoomUIConstants.INTENT_ROOM_MODEL);
    if (voiceRoomInfo == null) {
      ToastUtils.INSTANCE.showShortToast(
          VoiceRoomBaseActivity.this, getString(R.string.voiceroom_chat_message_tips));
      finish();
      return;
    }
    ImmersionBar.with(this).statusBarDarkFont(false).init();
    roomViewModel = new ViewModelProvider(this).get(VoiceRoomViewModel.class);
    setContentView(getContentViewID());
    initViews();
    audioPlay = new AudioPlayHelper(this);
  }

  private void initViews() {
    findBaseView();
    setupBaseViewInner();
    setupBaseView();
    rootView = getWindow().getDecorView();
    rootView.getViewTreeObserver().addOnGlobalLayoutListener(this);
    requestLivePermission();
    String countStr = String.format(getString(R.string.voiceroom_people_online), "0");
    tvMemberCount.setText(countStr);
  }

  @Override
  protected void onDestroy() {
    if (rootView != null) {
      rootView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
    }
    if (audioPlay != null) {
      audioPlay.destroy();
    }
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(voiceRoomListener);
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
    clyAnchorView = baseAudioView.findViewById(R.id.cly_anchor_layout);
    ivAnchorAvatar = baseAudioView.findViewById(R.id.iv_liver_avatar);
    ivAnchorAudioCloseHint = baseAudioView.findViewById(R.id.iv_liver_audio_close_hint);
    tvAnchorNick = baseAudioView.findViewById(R.id.tv_liver_nick);
    tvRoomName = baseAudioView.findViewById(R.id.tv_chat_room_name);
    tvMemberCount = baseAudioView.findViewById(R.id.tv_chat_room_member_count);
    settingsContainer = findViewById(R.id.settings_container);
    tvOrderMusic = findViewById(R.id.tv_order_music);
    tvOrderedNum = findViewById(R.id.tv_ordered_num);
    settingsContainer.setOnClickListener(view -> settingsContainer.setVisibility(View.GONE));
    ivSettingSwitch = baseAudioView.findViewById(R.id.iv_settings);
    ivSettingSwitch.setOnClickListener(view -> settingsContainer.setVisibility(View.VISIBLE));
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
    switchEarBack.setOnCheckedChangeListener((buttonView, isChecked) -> enableEarBack(isChecked));
    more = baseAudioView.findViewById(R.id.iv_room_more);
    more.setOnClickListener(
        v -> {
          moreItemList = getMoreItems();
          chatRoomMoreDialog = new ChatRoomMoreDialog(VoiceRoomBaseActivity.this, moreItemList);
          chatRoomMoreDialog.registerOnItemClickListener(getMoreItemClickListener());
          chatRoomMoreDialog.show();
        });
    ivLocalAudioSwitch = baseAudioView.findViewById(R.id.iv_local_audio_switch);
    ivLocalAudioSwitch.setSelected(true);
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
    announcement = baseAudioView.findViewById(R.id.tv_chat_room_announcement);
    announcement.setOnClickListener(
        v -> {
          NoticeDialog noticeDialog = new NoticeDialog();
          noticeDialog.show(getSupportFragmentManager(), "");
        });
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
    seatAdapter = new SeatAdapter(roomViewModel.getOnSeatListData().getValue(), this);
    seatAdapter.setItemClickListener(itemClickListener);
    seatAdapter.setItemLongClickListener(itemLongClickListener);
    recyclerView.setAdapter(seatAdapter);
    seatAdapter.notifyDataSetChanged();
    roomViewModel
        .getOnSeatListData()
        .observe(
            this,
            voiceRoomSeats -> {
              seatAdapter.setItems(voiceRoomSeats);
            });
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

  protected void onNetLost() {
    Bundle bundle = new Bundle();
    topTipsDialog = new TopTipsDialog();
    TopTipsDialog.Style style =
        topTipsDialog
        .new Style(getString(R.string.voiceroom_net_disconnected), 0, R.drawable.neterrricon, 0);
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

  protected final void enterRoom(
      String roomUuid, String nick, String avatar, long liveRecordId, String role) {
    NEJoinVoiceRoomParams params =
        new NEJoinVoiceRoomParams(
            roomUuid, nick, avatar, NEVoiceRoomRole.Companion.fromValue(role), liveRecordId, null);
    boolean isAnchor = NEVoiceRoomRole.HOST.getValue().equals(role);
    if (isAnchor) {
      updateAnchorUI(nick, avatar, true);
    }
    NEJoinVoiceRoomOptions options = new NEJoinVoiceRoomOptions();
    NEVoiceRoomKit.getInstance()
        .joinRoom(
            params,
            options,
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "joinRoom failed code = " + code + " msg = " + msg);
                ToastUtils.INSTANCE.showShortToast(
                    VoiceRoomBaseActivity.this,
                    getString(
                        isAnchor
                            ? R.string.voiceroom_start_live_error
                            : R.string.voiceroom_join_live_error));
                finish();
              }

              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
                ALog.i(TAG, "joinRoom success");
                joinRoomSuccess = true;
                initViewAfterJoinRoom();
              }
            });
  }

  private void initViewAfterJoinRoom() {
    initDataObserver();
    roomViewModel.initDataOnJoinRoom();
    if (VoiceRoomUtils.isCurrentHost()) {
      NEVoiceRoomKit.getInstance().submitSeatRequest(ANCHOR_SEAT_INDEX, true, null);
    } else {
      NEVoiceRoomMember hostMember = VoiceRoomUtils.getHost();
      if (hostMember != null) {
        updateAnchorUI(hostMember.getName(), hostMember.getAvatar(), hostMember.isAudioOn());
      }
      roomViewModel.getSeatInfo();
    }
  }

  private void updateAnchorUI(String nick, String avatar, boolean isAudioOn) {
    ivAnchorAvatar.loadAvatar(avatar);
    tvAnchorNick.setText(nick);
    ivLocalAudioSwitch.setSelected(!isAudioOn);
    ivAnchorAudioCloseHint.setImageResource(
        isAudioOn ? R.drawable.icon_seat_open_micro : R.drawable.icon_seat_close_micro);
  }

  private void initDataObserver() {
    roomViewModel
        .getMemberCountData()
        .observe(
            this,
            count -> {
              String countStr =
                  String.format(getString(R.string.voiceroom_people_online), count + "");
              tvMemberCount.setText(countStr);
            });
    roomViewModel
        .getOnSeatListData()
        .observe(
            this,
            seatList -> {
              List<VoiceRoomSeat> audienceSeats = new ArrayList<>();
              for (VoiceRoomSeat model : seatList) {
                if (model.getSeatIndex() != ANCHOR_SEAT_INDEX) {
                  audienceSeats.add(model);
                }
                final NEVoiceRoomMember member = model.getMember();
                if (member != null && VoiceRoomUtils.isHost(member.getAccount())) {
                  updateAnchorUI(member.getName(), member.getAvatar(), member.isAudioOn());
                }
              }
              seatAdapter.setItems(audienceSeats);
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
                if (!VoiceRoomUtils.isCurrentHost()) {
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
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(voiceRoomListener);
  }

  protected final void leaveRoom() {
    if (VoiceRoomUtils.isCurrentHost()) {
      NEVoiceRoomKit.getInstance()
          .endRoom(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ALog.i(TAG, "endRoom success");
                  ToastUtils.INSTANCE.showShortToast(
                      VoiceRoomBaseActivity.this,
                      getString(R.string.voiceroom_host_close_room_success));
                  finish();
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
                  finish();
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "leaveRoom onFailure");
                }
              });
    }
  }

  protected final void toggleMuteLocalAudio() {
    if (!joinRoomSuccess) return;
    NEVoiceRoomMember localMember = NEVoiceRoomKit.getInstance().getLocalMember();
    if (localMember == null) return;
    boolean isAudioOn = localMember.isAudioOn();
    if (isAudioOn) {
      NEVoiceRoomKit.getInstance()
          .muteMyAudio(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ToastUtils.INSTANCE.showShortToast(
                      VoiceRoomBaseActivity.this, getString(R.string.voiceroom_mic_off));
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {}
              });
    } else if (!localMember.isAudioBanned()) {
      NEVoiceRoomKit.getInstance()
          .unmuteMyAudio(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ToastUtils.INSTANCE.showShortToast(
                      VoiceRoomBaseActivity.this, getString(R.string.voiceroom_mic_on));
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {}
              });
    }
  }

  protected final void toggleMuteRoomAudio() {
    //        boolean muted = voiceRoom.muteRoomAudio(!voiceRoom.isRoomAudioMute());
    //        if (muted) {
    //            ToastHelper.showToast("已关闭“聊天室声音”");
    //        } else {
    //            ToastHelper.showToast("已打开“聊天室声音”");
    //        }
    //        ivRoomAudioSwitch.setSelected(muted);
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
                rcyChatMsgList.appendItem(
                    ChatRoomMsgCreator.createText(
                        VoiceRoomBaseActivity.this,
                        VoiceRoomUtils.isCurrentHost(),
                        VoiceRoomUtils.getCurrentName(),
                        content));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "sendTextMessage failed code = " + code + " msg = " + msg);
              }
            });
  }

  //
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
}

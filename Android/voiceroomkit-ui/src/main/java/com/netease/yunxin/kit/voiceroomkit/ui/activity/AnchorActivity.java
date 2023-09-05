// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.utils.ClickUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChoiceDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ListItemDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.MemberSelectDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.SeatApplyDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.TopTipsDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.helper.SeatHelper;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomUser;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.AnchorVoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.VoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.widget.OnItemClickListener;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import kotlin.Unit;

/** 主播页 */
public class AnchorActivity extends VoiceRoomBaseActivity {
  private TextView tvApplyHint;

  private SeatApplyDialog seatApplyDialog;

  @Override
  protected int getContentViewID() {
    return R.layout.activity_anchor;
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    netErrorView = findViewById(R.id.view_net_error);
    createMoreItems();
    enterRoom();
    audioPlay.checkMusicFiles();
    watchNetWork();
  }

  @Override
  protected void initViews() {
    super.initViews();
  }

  @Override
  protected VoiceRoomViewModel getRoomViewModel() {
    return new ViewModelProvider(this).get(AnchorVoiceRoomViewModel.class);
  }

  private void createMoreItems() {
    moreItems =
        Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_MICRO_PHONE,
                R.drawable.selector_more_micro_phone_status,
                getString(R.string.voiceroom_mic)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_EAR_BACK,
                R.drawable.selector_more_ear_back_status,
                getString(R.string.voiceroom_earback)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_MIXER,
                R.drawable.icon_room_more_mixer,
                getString(R.string.voiceroom_mixer)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_AUDIO,
                R.drawable.icon_room_more_audio,
                getString(R.string.voiceroom_audio_effect)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_REPORT,
                R.drawable.icon_room_more_report,
                getString(R.string.voiceroom_report)),
            new ChatRoomMoreDialog.MoreItem(
                VoiceRoomBaseActivity.MORE_ITEM_FINISH,
                R.drawable.icon_room_more_finish,
                getString(R.string.voiceroom_end)));
  }

  @Override
  protected void initDataObserver() {
    super.initDataObserver();
    roomViewModel.applySeatListData.observe(this, this::onApplySeats);
    roomViewModel.currentSongChange.observe(
        this,
        song -> {
          tvBackgroundMusic.startPlay(song, true);
        });
    roomViewModel.songDeletedEvent.observe(
        this,
        song -> {
          tvBackgroundMusic.deleteSong(song);
        });
  }

  private void watchNetWork() {
    roomViewModel.netData.observe(
        this,
        state -> {
          if (state == NEVoiceRoomUIConstants.NET_AVAILABLE) { // 网可用
            onNetAvailable();
          } else { // 不可用
            onNetLost();
          }
        });
  }

  @Override
  protected void setupBaseView() {
    topTipsDialog = new TopTipsDialog();
    tvApplyHint = findViewById(R.id.apply_hint);
    tvApplyHint.setOnClickListener(
        view -> showApplySeats(SeatHelper.getInstance().getApplySeatList()));

    tvApplyHint.setVisibility(View.INVISIBLE);
    tvApplyHint.setClickable(true);
  }

  @Override
  protected void onSeatItemClick(RoomSeat seat, int position) {
    if (seat.getStatus() == RoomSeat.Status.APPLY) {
      ToastUtils.INSTANCE.showShortToast(
          AnchorActivity.this, getString(R.string.voiceroom_applying_now));
      return;
    }

    if (ClickUtils.isFastClick()) {
      return;
    }

    OnItemClickListener<String> onItemClickListener = item -> onSeatAction(seat, item);
    List<String> items = new ArrayList<>();
    ListItemDialog itemDialog = new ListItemDialog(AnchorActivity.this);
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
  }

  @Override
  protected boolean onSeatItemLongClick(RoomSeat model, int position) {
    return false;
  }

  @Override
  protected void doLeaveRoom() {
    new ChoiceDialog(AnchorActivity.this)
        .setTitle(getString(R.string.voiceroom_end_live_title))
        .setContent(getString(R.string.voiceroom_end_live_tips))
        .setNegative(getString(R.string.voiceroom_cancel), null)
        .setPositive(
            getString(R.string.voiceroom_sure),
            v -> onSeatAction(null, getString(R.string.voiceroom_leave_room)))
        .show();
  }

  @Override
  public void onBackPressed() {
    new ChoiceDialog(AnchorActivity.this)
        .setTitle(getString(R.string.voiceroom_end_live_title))
        .setContent(getString(R.string.voiceroom_end_live_tips))
        .setNegative(getString(R.string.voiceroom_cancel), null)
        .setPositive(getString(R.string.voiceroom_sure), v -> super.onBackPressed())
        .show();
  }

  private void onSeatAction(RoomSeat seat, String item) {
    if (item.equals(getString(R.string.voiceroom_kickout_seat_sure))) {
      new ListItemDialog(AnchorActivity.this)
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
                ToastUtils.INSTANCE.showShortToast(AnchorActivity.this, text);
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
                ToastUtils.INSTANCE.showShortToast(AnchorActivity.this, text);
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
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this,
                    String.format(getString(R.string.voiceroom_open_seat_success), position));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "openSeats onFailure");
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this,
                    String.format(getString(R.string.voiceroom_open_seat_fail), position));
              }
            });
  }

  private void closeSeat(RoomSeat seat) {
    List<Integer> list = new ArrayList<>();
    list.add(seat.getSeatIndex());
    NEVoiceRoomKit.getInstance()
        .closeSeats(
            list,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "closeSeat onSuccess");
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this,
                    String.format(
                        getString(R.string.voiceroom_close_seat_tip), seat.getSeatIndex() - 1));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "closeSeat onFailure code:" + code);
              }
            });
  }

  private void muteSeat(RoomSeat seat) {
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
                ToastUtils.INSTANCE.showShortToast(AnchorActivity.this, text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "muteSeat onFailure code:" + code);
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this, getString(R.string.voiceroom_mute_seat_fail));
              }
            });
  }

  private void unmuteSeat(RoomSeat seat) {
    String userId = seat.getAccount();
    if (userId == null) return;

    NEVoiceRoomKit.getInstance()
        .unbanRemoteAudio(
            userId,
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "muteSeat onSuccess");
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this, getString(R.string.voiceroom_unmute_seat_success));
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "muteSeat onFailure code:" + code);
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this, getString(R.string.voiceroom_unmute_seat_fail));
              }
            });
  }

  private int inviteIndex = -1;

  private void inviteSeat0(RoomSeat seat) {
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
                ToastUtils.INSTANCE.showShortToast(AnchorActivity.this, text);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "inviteSeat onFailure code:" + code);
                ToastUtils.INSTANCE.showShortToast(
                    AnchorActivity.this, getString(R.string.voiceroom_operate_fail));
              }
            });
  }

  private void kickSeat(@NonNull RoomSeat seat) {
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
}

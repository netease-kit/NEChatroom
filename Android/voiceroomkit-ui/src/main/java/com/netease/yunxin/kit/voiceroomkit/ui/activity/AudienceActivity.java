// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.activity;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProvider;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.R;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.CancelApplySeatDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ChatRoomMoreDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.ListItemDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.NotificationDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.dialog.TopTipsDialog;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeat;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomSeatEvent;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.AudienceVoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.viewmodel.VoiceRoomViewModel;
import java.util.Arrays;
import java.util.List;
import kotlin.Unit;

/** 观众页 */
public class AudienceActivity extends VoiceRoomBaseActivity {
  private List<ChatRoomMoreDialog.MoreItem> moreItems;
  private ListItemDialog bottomDialog;
  private int networkErrorCount;
  private static final int ZERO_COUNT = 0;
  private CancelApplySeatDialog cancelApplySeatDialog;

  @Override
  protected int getContentViewID() {
    return R.layout.activity_audience;
  }

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    createMoreItems();
    super.onCreate(savedInstanceState);
    netErrorView = findViewById(R.id.view_net_error);
    enterRoom();
    watchNetWork();
    isAnchor = false;
    ivGift.setVisibility(View.VISIBLE);
    ivOrderSong.setVisibility(View.GONE);
  }

  @Override
  protected VoiceRoomViewModel getRoomViewModel() {
    return new ViewModelProvider(this).get(AudienceVoiceRoomViewModel.class);
  }

  private void createMoreItems() {
    moreItems =
        Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MICRO_PHONE,
                R.drawable.selector_more_micro_phone_status,
                getString(R.string.voiceroom_mic)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_EAR_BACK,
                R.drawable.selector_more_ear_back_status,
                getString(R.string.voiceroom_earback)),
            new ChatRoomMoreDialog.MoreItem(
                MORE_ITEM_MIXER,
                R.drawable.icon_room_more_mixer,
                getString(R.string.voiceroom_mixer)));
  }

  @Override
  protected void initDataObserver() {
    super.initDataObserver();
    roomViewModel.applySeatListData.observe(this, this::onApplySeats);
    roomViewModel.currentSeatEvent.observe(
        this,
        event -> {
          ALog.d(TAG, "initDataObserver currentSeatEvent,event:" + event);
          switch (event.getReason()) {
            case VoiceRoomSeat.Reason.ANCHOR_INVITE:
            case VoiceRoomSeat.Reason.ANCHOR_APPROVE_APPLY:
              onEnterSeat(event, false);
              break;
            case VoiceRoomSeat.Reason.ANCHOR_DENY_APPLY:
              onSeatApplyDenied(false);
              break;
            case VoiceRoomSeat.Reason.LEAVE:
              onLeaveSeat(event, true);
              break;
            case VoiceRoomSeat.Reason.ANCHOR_KICK:
              onLeaveSeat(event, false);
              break;
          }
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
              if (cancelApplySeatDialog != null) {
                cancelApplySeatDialog.dismiss();
              }
            }
            updateAudioSwitchVisible(roomViewModel.isCurrentUserOnSeat());
          }
        });

    roomViewModel.hostLeaveSeatData.observe(
        this,
        new Observer<Boolean>() {
          @Override
          public void onChanged(Boolean aBoolean) {
            if (aBoolean) {
              leaveRoom();
            }
          }
        });

    roomViewModel.currentSongChange.observe(
        this,
        song -> {
          tvBackgroundMusic.startPlay(song, false);
        });

    roomViewModel.songDeletedEvent.observe(
        this,
        song -> {
          tvBackgroundMusic.deleteSong(song);
        });
  }

  private void onApplySeats(List<VoiceRoomSeat> voiceRoomSeats) {
    if (isContainLocalAccount(voiceRoomSeats)) {
      showApplySeatDialog();
    }
  }

  private boolean isContainLocalAccount(List<VoiceRoomSeat> voiceRoomSeats) {
    for (VoiceRoomSeat voiceRoomSeat : voiceRoomSeats) {
      if (voiceRoomSeat != null
          && TextUtils.equals(voiceRoomSeat.getAccount(), VoiceRoomUtils.getLocalAccount())) {
        return true;
      }
    }
    return false;
  }

  private void watchNetWork() {
    roomViewModel.netData.observe(
        this,
        state -> {
          if (state == NEVoiceRoomUIConstants.NET_AVAILABLE) { // 网可用
            if (networkErrorCount == ZERO_COUNT) {
              return;
            }
            onNetAvailable();
          } else { // 不可用
            onNetLost();
            networkErrorCount++;
          }
        });
  }

  @Override
  protected void setupBaseView() {
    more.setVisibility(View.GONE);
    updateAudioSwitchVisible(false);
  }

  @Override
  protected synchronized void onSeatItemClick(VoiceRoomSeat seat, int position) {
    switch (seat.getStatus()) {
      case VoiceRoomSeat.Status.INIT:
        if (seat.getStatus() == VoiceRoomSeat.Status.CLOSED) {
          ToastUtils.INSTANCE.showShortToast(
              this, getString(R.string.voiceroom_seat_already_closed));
        } else if (roomViewModel.isCurrentUserOnSeat()) {
          ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_already_on_seat));
        } else {
          applySeat(seat.getSeatIndex());
        }
        break;
      case VoiceRoomSeat.Status.APPLY:
        ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_seat_applied));
        break;
      case VoiceRoomSeat.Status.ON:
        if (VoiceRoomUtils.isLocal(seat.getAccount())) {
          promptLeaveSeat();
        } else {
          ToastUtils.INSTANCE.showShortToast(
              this, getString(R.string.voiceroom_seat_already_taken));
        }
        break;
      case VoiceRoomSeat.Status.CLOSED:
        ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_seat_already_closed));
        break;
    }
  }

  @Override
  protected boolean onSeatItemLongClick(VoiceRoomSeat model, int position) {
    return false;
  }

  private boolean checkMySeat(VoiceRoomSeat seat) {
    if (seat != null) {
      if (seat.getStatus() == VoiceRoomSeat.Status.CLOSED) {
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
                ToastUtils.INSTANCE.showShortToast(AudienceActivity.this, msg);
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                showApplySeatDialog();
              }
            });
  }

  private boolean canShowTip = false;

  private void showApplySeatDialog() {

    cancelApplySeatDialog = new CancelApplySeatDialog();

    cancelApplySeatDialog.show(getSupportFragmentManager());
    ALog.d(TAG, "onApplySeatSuccess");
    canShowTip = true;
    cancelApplySeatDialog.setClickListener(
        () -> {
          cancelApplySeatDialog.dismiss();
          if (bottomDialog != null && bottomDialog.isShowing()) {
            bottomDialog.dismiss();
          }
          bottomDialog =
              new ListItemDialog(AudienceActivity.this)
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

  public void cancelSeatApply() {
    NEVoiceRoomKit.getInstance()
        .cancelSeatRequest(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "cancelSeatApply onFailure code:" + code);
                ToastUtils.INSTANCE.showShortToast(
                    AudienceActivity.this, getString(R.string.voiceroom_operate_fail));
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastUtils.INSTANCE.showShortToast(
                    AudienceActivity.this, getString(R.string.voiceroom_apply_canceled));
              }
            });
  }

  private void leaveSeat() {
    NEVoiceRoomKit.getInstance()
        .leaveSeat(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "leaveSeat onFailure code:" + code);
              }

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ToastUtils.INSTANCE.showShortToast(
                    AudienceActivity.this, getString(R.string.voiceroom_already_leave_seat));
              }
            });
  }

  public void hintSeatState(VoiceRoomSeatEvent seat, boolean on) {
    if (on) {
      Bundle bundle = new Bundle();
      switch (seat.getReason()) {
        case VoiceRoomSeat.Reason.ANCHOR_INVITE:
          {
            int position = seat.getIndex() - 1;
            new NotificationDialog(AudienceActivity.this)
                .setTitle(getString(R.string.voiceroom_notify))
                .setContent(String.format(getString(R.string.voiceroom_on_seated_tips), position))
                .setPositive(
                    getString(R.string.voiceroom_get_it),
                    v -> {
                      canShowTip = false;
                      if (bottomDialog != null && bottomDialog.isShowing()) {
                        bottomDialog.dismiss();
                      }
                      if (cancelApplySeatDialog != null) {
                        cancelApplySeatDialog.dismiss();
                      }
                    })
                .show();
            break;
          }
          //主播同意上麦
        case VoiceRoomSeat.Reason.ANCHOR_APPROVE_APPLY:
          {
            canShowTip = false;
            if (bottomDialog != null && bottomDialog.isShowing()) {
              bottomDialog.dismiss();
            }
            if (cancelApplySeatDialog != null) {
              cancelApplySeatDialog.dismiss();
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
      if (cancelApplySeatDialog != null) {
        cancelApplySeatDialog.dismiss();
      }
    } else {
      if (cancelApplySeatDialog != null) {
        cancelApplySeatDialog.dismiss();
      }

      if (seat.getReason() == VoiceRoomSeat.Reason.ANCHOR_KICK) {
        new NotificationDialog(this)
            .setTitle(getString(R.string.voiceroom_notify))
            .setContent(getString(R.string.voiceroom_kikout_seat_by_host))
            .setPositive(getString(R.string.voiceroom_get_it), null)
            .show();
      }
    }
  }

  private void promptLeaveSeat() {
    new ListItemDialog(AudienceActivity.this)
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

  private void updateAudioSwitchVisible(boolean visible) {
    ivLocalAudioSwitch.setVisibility(visible ? View.VISIBLE : View.GONE);
    more.setVisibility(visible ? View.VISIBLE : View.GONE);
    moreItems.get(MORE_ITEM_MICRO_PHONE).setVisible(visible);
    moreItems.get(MORE_ITEM_EAR_BACK).setVisible(visible);
    moreItems.get(MORE_ITEM_MIXER).setVisible(visible);
  }

  @NonNull
  @Override
  protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
    boolean isAudioOn = NEVoiceRoomKit.getInstance().getLocalMember().isAudioOn();
    moreItems.get(MORE_ITEM_MICRO_PHONE).setEnable(isAudioOn);
    moreItems.get(MORE_ITEM_EAR_BACK).setEnable(NEVoiceRoomKit.getInstance().isEarbackEnable());
    return moreItems;
  }

  @Override
  protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
    return onMoreItemClickListener;
  }

  //
  // Audience callback
  //
  public void onSeatApplyDenied(boolean otherOn) {
    if (otherOn) {
      ToastUtils.INSTANCE.showShortToast(this, getString(R.string.voiceroom_request_rejected));
      if (cancelApplySeatDialog != null) {
        cancelApplySeatDialog.dismiss();
      }
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
                if (cancelApplySeatDialog != null && getSupportFragmentManager() != null) {
                  cancelApplySeatDialog.dismiss();
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

  public void onSeatMuted() {
    if (cancelApplySeatDialog != null) {
      cancelApplySeatDialog.dismiss();
    }
    new NotificationDialog(this)
        .setTitle(getString(R.string.voiceroom_notify))
        .setContent(getString(R.string.voiceroom_seat_muted))
        .setPositive(getString(R.string.voiceroom_get_it), null)
        .show();
  }

  public void onSeatClosed() {
    if (cancelApplySeatDialog != null) {
      cancelApplySeatDialog.dismiss();
    }
  }
}

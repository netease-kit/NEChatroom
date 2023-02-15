// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import com.netease.yunxin.kit.listentogether.R;
import com.netease.yunxin.kit.listentogether.databinding.ListenTogetherSeatViewBinding;
import java.io.Serializable;

public class SeatView extends ConstraintLayout {
  private ListenTogetherSeatViewBinding binding;

  public SeatView(@NonNull Context context) {
    super(context);
    init(context, null);
  }

  public SeatView(@NonNull Context context, @Nullable AttributeSet attrs) {
    super(context, attrs);
    init(context, attrs);
  }

  public SeatView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    init(context, attrs);
  }

  private void init(Context context, AttributeSet attributeSet) {
    binding = ListenTogetherSeatViewBinding.inflate(LayoutInflater.from(context), this, true);
  }

  public void setSeatInfo(SeatInfo seatInfo) {
    if (seatInfo.isOnSeat) {
      binding.tvNickname.setText(seatInfo.nickname);
      binding.ivAvatar.setVisibility(VISIBLE);
      binding.ivAvatarHolder.setVisibility(INVISIBLE);
      binding.ivAvatar.loadAvatar(seatInfo.avatar);
      binding.ivMuteState.setVisibility(VISIBLE);
      if (seatInfo.isMute) {
        binding.ivMuteState.setImageResource(R.drawable.listen_icon_mute_state);
      } else {
        binding.ivMuteState.setImageResource(R.drawable.listen_icon_unmute_state);
      }
      if (seatInfo.isListenTogether) {
        if (seatInfo.isAnchor) {
          binding.ivLeftEarphone.setVisibility(VISIBLE);
          binding.ivRightEarphone.setVisibility(GONE);
        } else {
          binding.ivLeftEarphone.setVisibility(GONE);
          binding.ivRightEarphone.setVisibility(VISIBLE);
        }
        binding.ivEarphoneLine.setVisibility(INVISIBLE);
        if (seatInfo.isLoadingSong) {
          binding.tvSongLoading.setVisibility(VISIBLE);
        } else {
          binding.tvSongLoading.setVisibility(INVISIBLE);
        }
      } else {
        binding.ivLeftEarphone.setVisibility(VISIBLE);
        binding.ivRightEarphone.setVisibility(VISIBLE);
        binding.ivEarphoneLine.setVisibility(VISIBLE);
      }
      binding.ivAvatarBg.setVisibility(VISIBLE);
    } else {
      if (seatInfo.isAnchor) {
        binding.tvNickname.setText("anchor");
      } else {
        binding.tvNickname.setText(getContext().getText(R.string.listen_first_seat));
      }
      binding.ivAvatar.setVisibility(INVISIBLE);
      binding.ivAvatarHolder.setVisibility(VISIBLE);
      binding.ivMuteState.setVisibility(INVISIBLE);
      binding.ivEarphoneLine.setVisibility(INVISIBLE);
      binding.ivLeftEarphone.setVisibility(GONE);
      binding.ivRightEarphone.setVisibility(GONE);
      binding.tvSongLoading.setVisibility(INVISIBLE);
      binding.ivAvatarBg.setVisibility(INVISIBLE);
    }
  }

  public static class SeatInfo implements Serializable {
    public String nickname;
    public String avatar;
    public boolean isOnSeat;
    public boolean isAnchor;
    public boolean isMute;
    public boolean isLoadingSong;
    public boolean isListenTogether;
  }
}

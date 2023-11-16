// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.model;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.entertainment.common.utils.SeatUtils;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** 麦位信息 */
public class RoomSeat implements Serializable, Parcelable {

  /** 麦位容量 */
  public static final int SEAT_COUNT = 9;

  public interface Status {
    /** 麦位初始化状态（没人） */
    int INIT = 0;
    /** 正在申请（没人） */
    int APPLY = 1;
    /** 麦位上有人，且能正常发言（有人） */
    int ON = 2;
    /** 麦位关闭（没人） */
    int CLOSED = 3;
  }

  public interface Reason {
    /** 无 */
    int NONE = 0;

    /** 主播同意上麦 */
    int ANCHOR_APPROVE_APPLY = 1;

    /** 主播抱上麦 */
    int ANCHOR_INVITE = 2;

    /** 主播踢下麦 */
    int ANCHOR_KICK = 3;

    /** 下麦 */
    int LEAVE = 4;

    /** 主播拒绝申请 */
    int ANCHOR_DENY_APPLY = 6;
  }

  private final int index;
  private final int status;
  private final int reason;

  private final NEVoiceRoomMember member;

  private int rewardTotal;

  private boolean isSpeaking;

  private String ext;

  public RoomSeat(int index) {
    this(index, Status.INIT, Reason.NONE, null);
  }

  public RoomSeat(int index, int status, int reason, NEVoiceRoomMember member) {
    this.index = index;
    this.status = status;
    this.reason = reason;
    this.member = member;
  }

  public RoomSeat(int index, int status, int reason, NEVoiceRoomMember member, int rewardTotal) {
    this.index = index;
    this.status = status;
    this.reason = reason;
    this.member = member;
    this.rewardTotal = rewardTotal;
  }

  public int getSeatIndex() {
    return index;
  }

  public int getStatus() {
    return status;
  }

  public int getReason() {
    return reason;
  }

  @Nullable
  public NEVoiceRoomMember getMember() {
    return member;
  }

  public String getAccount() {
    return member != null ? member.getAccount() : null;
  }

  public int getRewardTotal() {
    return rewardTotal;
  }

  public void setRewardTotal(int rewardTotal) {
    this.rewardTotal = rewardTotal;
  }

  public boolean isSpeaking() {
    return isSpeaking;
  }

  public void setSpeaking(boolean isSpeaking) {
    this.isSpeaking = isSpeaking;
  }

  public String getExt() {
    return ext;
  }

  public void setExt(String ext) {
    this.ext = ext;
  }

  @Override
  public int describeContents() {
    return 0;
  }

  @Override
  public void writeToParcel(Parcel dest, int flags) {
    dest.writeInt(this.index);
    dest.writeInt(this.status);
    dest.writeInt(this.reason);
    dest.writeInt(this.rewardTotal);
    dest.writeSerializable(member.getAccount());
  }

  public static final Creator<RoomSeat> CREATOR =
      new Creator<RoomSeat>() {
        @Override
        public RoomSeat createFromParcel(Parcel source) {
          return new RoomSeat(
              source.readInt(),
              source.readInt(),
              source.readInt(),
              SeatUtils.getMember(source.readString()),
              source.readInt());
        }

        @Override
        public RoomSeat[] newArray(int size) {
          return new RoomSeat[size];
        }
      };

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    RoomSeat other = (RoomSeat) o;
    return index == (other.index);
  }

  @Override
  public int hashCode() {
    return index;
  }

  public final boolean isOn() {
    return status == Status.ON;
  }

  public boolean isSameAccount(String account) {
    return !TextUtils.isEmpty(account) && member != null && account.equals(member.getAccount());
  }

  @NonNull
  public static List<RoomSeat> find(List<RoomSeat> seats, String account) {
    if (seats == null || seats.isEmpty()) {
      return Collections.emptyList();
    }
    List<RoomSeat> results = new ArrayList<>(seats.size());
    for (RoomSeat seat : seats) {
      if (seat.isSameAccount(account)) {
        results.add(seat);
      }
    }
    return results;
  }
}

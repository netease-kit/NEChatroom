// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.chatroom;

import android.content.Context;
import android.graphics.Color;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;
import com.netease.yunxin.kit.voiceroomkit.ui.R;

public class ChatRoomMsgCreator {

  /** 文字高亮颜色 */
  private static final int HIGH_COLOR = Color.parseColor("#99ffffff");

  private static final int NAME_COLOR = Color.parseColor("#66ffffff");

  /** 文本信息颜色 */
  private static final int COMMON_COLOR = Color.WHITE;

  public static CharSequence createRoomEnter(String userNickName) {
    return new ChatMessageSpannableStr.Builder()
        .append(userNickName, HIGH_COLOR)
        .append(" ")
        .append(
            NEVoiceRoomUI.getInstance().getApplication().getString(R.string.voiceroom_enter_room),
            HIGH_COLOR)
        .build()
        .getMessageInfo();
  }

  public static CharSequence createRoomExit(String userNickName) {
    return new ChatMessageSpannableStr.Builder()
        .append(userNickName, HIGH_COLOR)
        .append(" ")
        .append(
            NEVoiceRoomUI.getInstance().getApplication().getString(R.string.voiceroom_leave_room),
            HIGH_COLOR)
        .build()
        .getMessageInfo();
  }

  public static CharSequence createSeatMessage(String userNickName, String content) {
    return new ChatMessageSpannableStr.Builder()
        .append(userNickName)
        .append(" ")
        .append(content)
        .build()
        .getMessageInfo();
  }

  public static CharSequence createSongMessage(String userName, String content) {
    return new ChatMessageSpannableStr.Builder()
        .append(userName, NAME_COLOR)
        .append(" ")
        .append(content)
        .build()
        .getMessageInfo();
  }

  public static CharSequence createText(Context context, String userNickName, String msg) {
    return createText(context, false, userNickName, msg);
  }

  public static CharSequence createText(
      Context context, Boolean isAnchor, String userNickName, String msg) {
    ChatMessageSpannableStr.Builder builder = new ChatMessageSpannableStr.Builder();
    //    if (isAnchor) {
    //      int width = ScreenUtil.dip2px(30f);
    //      int height = ScreenUtil.dip2px(15f);
    //      builder.append(context, R.drawable.icon_msg_anchor_flag, width, height).append(" ");
    //    }
    return builder
        .append(userNickName, HIGH_COLOR)
        .append(": ", HIGH_COLOR)
        .append(msg, COMMON_COLOR)
        .build()
        .getMessageInfo();
  }
}

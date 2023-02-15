// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.core.constant;

/** 一起听聊天室消息协议 */
public class ListenTogetherCmd {

  /** 向对方询问当前播放进度（NERoom点对点自定义消息） */
  public static final int ASK_PLAYING_POSITION_CMD = 10001;
  /** 向对方同步当前播放进度（NERoom点对点自定义消息） */
  public static final int SYNC_PLAYING_POSITION_CMD = 10002;
  /** 向对方告知本端的当前歌曲是否已经下载完成（NERoom点对点自定义消息） */
  public static final int NOTIFY_OTHER_MY_SONG_IS_READY_CMD = 10003;
}

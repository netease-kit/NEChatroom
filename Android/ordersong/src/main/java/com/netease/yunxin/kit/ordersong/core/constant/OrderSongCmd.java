// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core.constant;

/** 点歌台协议 */
public class OrderSongCmd {
  /** 点歌，聊天室协议（群发） */
  public static final int ORDER_SONG_CMD = 1008;
  /** 取消点歌，聊天室协议（群发） */
  public static final int CANCEL_ORDER_SONG_CMD = 1009;
  /** 切歌，聊天室协议（群发） */
  public static final int SWITCH_SONG_CMD = 1010;
  /** 已点歌曲列表变化，聊天室协议（群发） */
  public static final int ORDERED_SONG_LIST_CHANGED_CMD = 1012;
  /** 开始播放，聊天室协议（群发） */
  public static final int START_PLAY_CMD = 1013;
  /** 暂停播放，聊天室协议（群发） */
  public static final int PAUSE_PLAY_CMD = 1014;
  /** 恢复播放，聊天室协议（群发） */
  public static final int RESUME_PLAY_CMD = 1016;
}

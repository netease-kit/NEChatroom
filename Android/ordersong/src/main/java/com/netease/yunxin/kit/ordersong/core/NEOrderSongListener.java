// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.core;

import com.netease.yunxin.kit.ordersong.core.model.Song;

/** 点歌台监听器 */
public interface NEOrderSongListener {
  /** 点歌回调 */
  void onSongOrdered(Song song);
  /** 删歌回调 */
  void onSongDeleted(Song song);
  /** 点歌列表变化回调 */
  void onOrderedSongListChanged();
  /** 切歌回调 */
  void onSongSwitched(Song song);
  /** 歌曲开始 */
  void onSongStarted(Song song);
  /** 歌曲暂停 */
  void onSongPaused(Song song);
  /** 歌曲恢复 */
  void onSongResumed(Song song);
}

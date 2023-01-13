// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.core;

import com.netease.yunxin.kit.ordersong.core.model.Song;

/** 一起听监听器 */
public interface NEListenTogetherListener {

  /**
   * 对方通知进度改变
   *
   * @param song 歌曲
   * @param position 播放位置，单位ms
   */
  void onSongProgressNotifyChanged(Song song, long position);

  /**
   * 对方的歌曲下载状态变更，
   *
   * @param song 歌曲
   * @param isDownloading true 下载中，false 已下载完
   */
  void onSongOtherDownloadStateChanged(Song song, boolean isDownloading);
}

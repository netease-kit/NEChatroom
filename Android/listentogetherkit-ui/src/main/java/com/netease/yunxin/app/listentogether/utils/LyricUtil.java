// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.utils;

import com.netease.yunxin.kit.copyrightedmedia.api.model.NELyric;
import com.netease.yunxin.kit.copyrightedmedia.api.model.NELyricLine;

public class LyricUtil {
  /** 获取歌曲前奏开始时间戳 */
  public static int getPreludeTimeMillis(NELyric lyric) {
    if (lyric != null
        && lyric.lineModels != null
        && !lyric.lineModels.isEmpty()
        && lyric.lineModels.get(0) != null) {
      return lyric.lineModels.get(0).startTime;
    }
    return 0;
  }

  /** 获取歌曲结束时间戳 */
  public static int getEndTimeMillis(NELyric lyric) {
    if (lyric != null && lyric.lineModels != null && !lyric.lineModels.isEmpty()) {
      NELyricLine lastLine = lyric.lineModels.get(lyric.lineModels.size() - 1);
      return lastLine.startTime + lastLine.interval;
    }
    return 0;
  }
}

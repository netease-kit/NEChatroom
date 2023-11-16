// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.ordersong.ui.util;

import android.media.MediaMetadataRetriever;
import android.os.Build;

import androidx.annotation.RequiresApi;

import java.io.IOException;

public class MediaUtils {

  @RequiresApi(api = Build.VERSION_CODES.GINGERBREAD_MR1)
  public static long getDuration(String path) {
    MediaMetadataRetriever mmr = new MediaMetadataRetriever();
    long duration = 0;
    try {
      mmr.setDataSource(path);
      String time = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
      duration = Long.parseLong(time);
    } catch (Exception ex) {
      ex.printStackTrace();
    } finally {
      mmr.release();
    }
    return duration;
  }
}

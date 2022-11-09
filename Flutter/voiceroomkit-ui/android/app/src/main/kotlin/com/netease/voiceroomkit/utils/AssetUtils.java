// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.voiceroomkit.utils;

import android.content.res.AssetManager;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class AssetUtils {
  private static final String TAG = "AssetUtils";

  public static int copyAsset(AssetManager manager, String src, String dest) {
    return copyAsset(manager, src, dest, true);
  }

  public static int copyAsset(AssetManager manager, String src, String dest, boolean overwrite) {
    if (manager == null) {
      Log.e(TAG, "AssetManager is null");
      return -1;
    }

    File outfile = new File(dest);
    if (outfile.isDirectory()) {
      Log.e(TAG, "copyAsset failed, " + dest + " is a director, use copyAssetRecursive");
      return -1;
    }

    if (!overwrite && outfile.exists()) {
      Log.i(TAG, dest + " is exist, and not overwrite mode, skip");
      return 0;
    }

    InputStream input = null;
    OutputStream output = null;
    try {
      input = manager.open(src);
      output = new FileOutputStream(outfile);
      byte[] buf = new byte[1024];
      int read;
      while ((read = input.read(buf)) != -1) {
        output.write(buf, 0, read);
      }
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      try {
        if (input != null) {
          input.close();
        }
        if (output != null) {
          output.close();
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
    }

    return 0;
  }

  public static int copyAssetRecursive(AssetManager manager, String src, String dest) {
    return copyAssetRecursive(manager, src, dest, true);
  }

  public static int copyAssetRecursive(
      AssetManager manager, String src, String dest, boolean overwrite) {
    int ret = 0;
    if (manager == null) {
      Log.e(TAG, "AssetManager is null");
      ret = -1;
      return ret;
    }

    try {
      String[] list = manager.list(src);
      if (list.length == 0) {
        copyAsset(manager, src, dest, overwrite);
      } else {
        File file = new File(dest);
        file.delete();
        file.mkdir();
        for (String path : list) {
          copyAssetRecursive(
              manager, src + File.separator + path, dest + File.separator + path, overwrite);
        }
      }

    } catch (IOException e) {
      e.printStackTrace();
    }

    return ret;
  }
}

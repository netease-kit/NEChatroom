// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.content.Context;
import java.io.Closeable;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collection;

public class CommonUtil {

  public static boolean isEmpty(Collection collection) {
    return collection == null || collection.isEmpty();
  }

  public static void copyAssetToFile(
      Context context, String assetsName, String savePath, String saveName) {

    File dir = new File(savePath);
    if (!dir.exists()) {
      dir.mkdirs();
    }

    File destFile = new File(dir, saveName);
    InputStream inputStream = null;
    FileOutputStream outputStream = null;
    try {
      inputStream = context.getResources().getAssets().open(assetsName);
      if (destFile.exists() && inputStream.available() == destFile.length()) {
        return;
      }
      destFile.deleteOnExit();
      outputStream = new FileOutputStream(destFile);
      byte[] buffer = new byte[4096];
      int count;
      while ((count = inputStream.read(buffer)) != -1) {
        outputStream.write(buffer, 0, count);
      }

    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      closeQuiet(inputStream);
      closeQuiet(outputStream);
    }
  }

  public static void copyStream(InputStream is, OutputStream os) throws IOException {
    byte[] buffer = new byte[4096];
    int count;
    while ((count = is.read(buffer)) != -1) {
      os.write(buffer, 0, count);
    }
    os.flush();
  }

  public static void closeQuiet(Closeable closeable) {
    if (closeable == null) {
      return;
    }

    try {
      closeable.close();
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}

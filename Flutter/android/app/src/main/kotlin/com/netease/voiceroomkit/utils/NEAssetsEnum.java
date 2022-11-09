// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.voiceroomkit.utils;

public enum NEAssetsEnum {
  EFFECTS("beauty"),
  FILTERS("filters"),
  MAKEUPS("makeups");

  private String assetsPath;

  NEAssetsEnum(String assetsPath) {
    this.assetsPath = assetsPath;
  }

  public String getAssetsPath() {
    return assetsPath;
  }
}

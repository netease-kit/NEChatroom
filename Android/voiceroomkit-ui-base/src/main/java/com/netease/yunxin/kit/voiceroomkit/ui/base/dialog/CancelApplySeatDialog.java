// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.os.Bundle;
import androidx.fragment.app.FragmentManager;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;

public class CancelApplySeatDialog extends TopTipsDialog {
  private static final String TAG = "CancelApplySeatDialog";

  public void show(FragmentManager manager) {
    String tip =
        Utils.getApp().getString(R.string.voiceroom_seat_submited)
            + "<font color=\"#0888ff\">"
            + Utils.getApp().getString(R.string.voiceroom_cancel)
            + "</color>";
    Bundle bundle = new Bundle();
    TopTipsDialog.Style style = new Style(tip, 0, 0, 0);
    bundle.putParcelable(TAG, style);
    setArguments(bundle);
    super.show(manager, getDialogTag());
  }

  @Override
  public String getDialogTag() {
    return TAG;
  }
}

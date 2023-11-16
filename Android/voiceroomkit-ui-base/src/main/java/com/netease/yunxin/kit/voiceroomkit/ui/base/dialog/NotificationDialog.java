// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.app.Activity;
import android.view.View;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;

/** Created by luc on 2020/12/3. */
public class NotificationDialog extends ChoiceDialog {
  public NotificationDialog(@NonNull Activity activity) {
    super(activity);
    setCancelable(false);
  }

  @Override
  protected void renderRootView(View rootView) {
    super.renderRootView(rootView);
    rootView.findViewById(R.id.line_divide).setVisibility(View.GONE);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.fragment;

import android.view.View;
import androidx.fragment.app.Fragment;
import com.netease.yunxin.kit.entertainment.common.utils.ViewUtils;

public class BaseFragment extends Fragment {
  protected void paddingStatusBarHeight(View view) {
    ViewUtils.paddingStatusBarHeight(getActivity(), view);
  }
}

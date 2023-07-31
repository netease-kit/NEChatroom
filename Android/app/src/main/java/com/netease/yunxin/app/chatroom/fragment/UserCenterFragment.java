// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.fragment;

import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.databinding.FragmentUserCenterBinding;
import com.netease.yunxin.app.chatroom.utils.AppUtils;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.dialog.LoadingDialog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.dialog.NetworkInfoDialog;
import com.netease.yunxin.kit.entertainment.common.dialog.PhoneConsultBottomDialog;
import com.netease.yunxin.kit.entertainment.common.fragment.BaseFragment;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomPreviewListener;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeConfig;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeResult;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcLastmileProbeResultState;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcNetworkStatusType;

public class UserCenterFragment extends BaseFragment {
  private static final String TAG = "UserCenterFragment";
  private FragmentUserCenterBinding binding;
  private Dialog loadingDialog;
  private int count = 0;
  private int quality = -1;
  private static final int CALLBACK_TOTAL_COUNT = 2;
  private NEVoiceRoomRtcLastmileProbeResult probeResult;

  private final NEVoiceRoomPreviewListener listener =
      new NEVoiceRoomPreviewListener() {
        @Override
        public void onRtcLastmileQuality(int quality) {
          ALog.d(TAG, "onRtcLastmileQuality,quality:" + quality);
          count++;
          mergeInfo(quality, probeResult);
        }

        @Override
        public void onRtcLastmileProbeResult(NEVoiceRoomRtcLastmileProbeResult result) {
          ALog.d(TAG, "onRtcLastmileProbeResult,result:" + result);
          count++;
          mergeInfo(quality, result);
        }
      };

  @Override
  public void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
  }

  @Nullable
  @Override
  public View onCreateView(
      @NonNull LayoutInflater inflater,
      @Nullable ViewGroup container,
      @Nullable Bundle savedInstanceState) {

    binding = FragmentUserCenterBinding.inflate(inflater, container, false);
    View rootView = binding.getRoot();
    initViews();
    initDataCenter();
    listenNetworkProbInfo();
    return rootView;
  }

  private void listenNetworkProbInfo() {
    NEVoiceRoomKit.getInstance().addPreviewListener(listener);
  }

  private void initViews() {
    initUser();
    binding.logUpload.setOnClickListener(
        v -> {
          NEVoiceRoomKit.getInstance().uploadLog();
          ToastX.showLongToast(R.string.please_wait_five_second_upload);
        });
    binding.networkDetect.setOnClickListener(
        v -> {
          NEVoiceRoomKit.getInstance()
              .startLastmileProbeTest(new NEVoiceRoomRtcLastmileProbeConfig());
          toggleLoading(true);
        });
    binding.commonSetting.setOnClickListener(v -> NavUtils.toCommonSettingPage(requireActivity()));
    binding.phoneConsult.setOnClickListener(
        v -> {
          PhoneConsultBottomDialog dialog = new PhoneConsultBottomDialog(requireActivity());
          dialog.show();
        });
  }

  private void initUser() {
    binding.ivUserPortrait.loadAvatar(AppUtils.getAvatar());
    binding.tvUserName.setText(AppUtils.getUserName());
  }

  private void initDataCenter() {}

  private void toggleLoading(boolean show) {
    if (loadingDialog == null) {
      loadingDialog = new LoadingDialog(requireActivity());
    }
    if (show && !loadingDialog.isShowing()) {
      loadingDialog.show();
    } else if (!show) {
      loadingDialog.dismiss();
      loadingDialog = null;
    }
  }

  private void mergeInfo(int quality, NEVoiceRoomRtcLastmileProbeResult probeResult) {
    this.quality = quality;
    this.probeResult = probeResult;
    if (count == CALLBACK_TOTAL_COUNT) {
      toggleLoading(false);
      NEVoiceRoomKit.getInstance().stopLastmileProbeTest();
      StringBuilder stringBuilder = new StringBuilder();
      stringBuilder
          .append(getString(R.string.network_quality))
          .append(covertQuality(this.quality))
          .append("\n")
          .append(getString(R.string.quality_result))
          .append(covertState(this.probeResult.getState()))
          .append("\n")
          .append(getString(R.string.network_rtt))
          .append(this.probeResult.getRtt() + "ms")
          .append("\n")
          .append(getString(R.string.network_up_packet_loss_rate))
          .append(this.probeResult.getUplinkReport().getPacketLossRate() + "%")
          .append("\n")
          .append(getString(R.string.network_up_jitter))
          .append(this.probeResult.getUplinkReport().getJitter() + "ms")
          .append("\n")
          .append(getString(R.string.network_up_avaliable_band_width))
          .append(this.probeResult.getUplinkReport().getAvailableBandwidth() + "bps")
          .append("\n")
          .append(getString(R.string.network_down_packet_loss_rate))
          .append(this.probeResult.getDownlinkReport().getPacketLossRate() + "%")
          .append("\n")
          .append(getString(R.string.network_down_jitter))
          .append(this.probeResult.getDownlinkReport().getJitter() + "ms")
          .append("\n")
          .append(getString(R.string.network_down_available_band_width))
          .append(this.probeResult.getDownlinkReport().getAvailableBandwidth() + "bps");
      NetworkInfoDialog dialog = new NetworkInfoDialog(requireActivity());
      dialog.setContent(stringBuilder.toString());
      dialog.setDialogCallback(Dialog::dismiss);
      dialog.show();
      count = 0;
      this.quality = -1;
      this.probeResult = null;
    }
  }

  private String covertQuality(int quality) {
    if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_UNKNOWN) {
      return getString(R.string.quality_unknown);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_EXCELLENT) {
      return getString(R.string.quality_excellent);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_GOOD) {
      return getString(R.string.quality_good);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_POOR) {
      return getString(R.string.quality_poor);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_BAD) {
      return getString(R.string.quality_bad);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_VERY_BAD) {
      return getString(R.string.quality_vbad);
    } else if (quality == NEVoiceRoomRtcNetworkStatusType.NETWORK_STATUS_DOWN) {
      return getString(R.string.quality_down);
    }
    return "";
  }

  private String covertState(short state) {
    if (state == NEVoiceRoomRtcLastmileProbeResultState.LASTMILE_PROBE_RESULT_COMPLETE) {
      return getString(R.string.state_result_complete);
    } else if (state
        == NEVoiceRoomRtcLastmileProbeResultState.LASTMILE_PROBE_RESULT_INCOMPLETE_NO_BWE) {
      return getString(R.string.state_result_incomplete_no_bwe);
    } else if (state == NEVoiceRoomRtcLastmileProbeResultState.LASTMILE_PROBE_RESULT_UNAVAILABLE) {
      return getString(R.string.state_result_unavailable);
    }
    return "";
  }

  @Override
  public void onDestroy() {
    NEVoiceRoomKit.getInstance().removePreviewListener(listener);
    super.onDestroy();
  }
}

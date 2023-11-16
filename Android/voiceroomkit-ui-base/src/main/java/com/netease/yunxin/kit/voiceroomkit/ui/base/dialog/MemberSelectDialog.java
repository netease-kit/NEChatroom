// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.activity.ComponentActivity;
import androidx.annotation.NonNull;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.impl.utils.ScreenUtil;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.MemberListAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.model.VoiceRoomUser;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.AnchorVoiceRoomViewModel;
import com.netease.yunxin.kit.voiceroomkit.ui.base.viewmodel.VoiceRoomViewModel;
import java.util.ArrayList;
import java.util.List;

/** Created by luc on 1/29/21. */
public class MemberSelectDialog extends BottomBaseDialog {

  private final OnMemberChosenListener listener;
  private MemberListAdapter adapter;
  private final VoiceRoomViewModel viewModel;

  public MemberSelectDialog(@NonNull ComponentActivity activity, OnMemberChosenListener listener) {
    super(activity);
    this.listener = listener;
    viewModel = new ViewModelProvider(activity).get(AnchorVoiceRoomViewModel.class);
  }

  @Override
  protected void renderTopView(FrameLayout parent) {
    TextView titleView = new TextView(getContext());
    titleView.setText(getContext().getString(R.string.voiceroom_select_member));
    titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
    titleView.setGravity(Gravity.CENTER);
    titleView.setTextColor(Color.parseColor("#ff333333"));
    FrameLayout.LayoutParams titleLayoutParams =
        new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
    parent.addView(titleView, titleLayoutParams);

    ImageView cancelView = new ImageView(getContext());
    cancelView.setImageResource(R.drawable.icon_room_memeber_back_arrow);
    cancelView.setPadding(ScreenUtil.dip2px(20), 0, 0, 0);
    FrameLayout.LayoutParams cancelLayoutParams =
        new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
    parent.addView(cancelView, cancelLayoutParams);

    cancelView.setOnClickListener(v -> dismiss());
  }

  @Override
  protected void renderBottomView(FrameLayout parent) {
    RecyclerView rvMemberList = new RecyclerView(getContext());
    rvMemberList.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
    int height = (int) (ScreenUtil.getDisplayHeight() * 0.8 - ScreenUtil.dip2px(48));
    FrameLayout.LayoutParams layoutParams =
        new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, height);
    rvMemberList.setLayoutManager(new LinearLayoutManager(getContext()));
    adapter = new MemberListAdapter(getContext());
    rvMemberList.setAdapter(adapter);
    parent.addView(rvMemberList, layoutParams);

    fetchRoomMembers();
  }

  private void fetchRoomMembers() {
    List<NEVoiceRoomMember> members = NEVoiceRoomKit.getInstance().getAllMemberList();
    List<VoiceRoomUser> users = new ArrayList<>();
    for (NEVoiceRoomMember member : members) {
      if (!viewModel.isUserOnSeat(member.getAccount())
          && !VoiceRoomUtils.isLocal(member.getAccount())) {
        users.add(new VoiceRoomUser(member));
      }
    }
    adapter.updateDataSource(users);
    adapter.setOnItemClickListener(
        item -> {
          VoiceRoomUser member = users.get(item);
          if (listener != null) {
            listener.onMemberChosen(member);
          }
          dismiss();
        });
  }

  public interface OnMemberChosenListener {
    void onMemberChosen(VoiceRoomUser member);
  }
}

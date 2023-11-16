// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.dialog;

import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.model.RoomSeat;
import com.netease.yunxin.kit.entertainment.common.widget.HeadImageView;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomMember;
import com.netease.yunxin.kit.voiceroomkit.ui.base.R;
import com.netease.yunxin.kit.voiceroomkit.ui.base.adapter.BaseAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.widget.VerticalItemDecoration;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class SeatApplyDialog extends BaseDialogFragment {

  private static final String tag = "SeatApplyDialog";

  RecyclerView requesterRecyclerView;

  SeatApplyAdapter adapter;

  View view;

  TextView title;

  TextView tvDismiss;

  private final List<RoomSeat> seats = new ArrayList<>();

  public interface IRequestAction {

    void refuse(RoomSeat seat);

    void agree(RoomSeat seat);

    void dismiss();
  }

  IRequestAction requestAction;

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setStyle(DialogFragment.STYLE_NO_TITLE, R.style.request_dialog_fragment);
  }

  @Nullable
  @Override
  public View onCreateView(
      LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
    Bundle bundle = getArguments();
    if (bundle != null) {
      ArrayList<RoomSeat> seats = getArguments().getParcelableArrayList(getDialogTag());
      if (seats != null) {
        this.seats.addAll(seats);
      }
    } else {
      dismiss();
    }
    view = inflater.inflate(R.layout.apply_list_dialog_layout, container, false);
    // 设置宽度为屏宽、靠近屏幕底部。
    final Window window = getDialog().getWindow();
    window.setBackgroundDrawableResource(R.color.color_00000000);
    WindowManager.LayoutParams wlp = window.getAttributes();
    wlp.gravity = Gravity.TOP;
    wlp.width = WindowManager.LayoutParams.MATCH_PARENT;
    wlp.height = WindowManager.LayoutParams.WRAP_CONTENT;
    window.setAttributes(wlp);
    return view;
  }

  @Override
  public void onResume() {
    super.onResume();
    initView();
    initListener();
  }

  private void initView() {
    requesterRecyclerView = view.findViewById(R.id.requesterRecyclerView);
    requesterRecyclerView.setLayoutManager(new LinearLayoutManager(getActivity()));
    int padding = SizeUtils.dp2px(16);
    requesterRecyclerView.addItemDecoration(
        new VerticalItemDecoration(
            getResources().getColor(R.color.color_33ffffff), 1, padding, padding));
    title = view.findViewById(R.id.title);
    tvDismiss = view.findViewById(R.id.dismiss);
    buildHeadView();
    refresh();
  }

  private void buildHeadView() {
    adapter = new SeatApplyAdapter(new ArrayList<>(), getActivity());
    requesterRecyclerView.setAdapter(adapter);
    requesterRecyclerView.setLayoutManager(
        new LinearLayoutManager(getContext()) {

          @Override
          public void onMeasure(
              RecyclerView.Recycler recycler,
              RecyclerView.State state,
              int widthSpec,
              int heightSpec) {
            int count = state.getItemCount();
            if (count > 0) {
              if (count > 4) {
                count = 4;
              }
              int realHeight = 0;
              int realWidth = 0;
              for (int i = 0; i < count; i++) {
                View view = recycler.getViewForPosition(0);
                if (view != null) {
                  measureChild(view, widthSpec, heightSpec);
                  int measuredWidth = View.MeasureSpec.getSize(widthSpec);
                  int measuredHeight = view.getMeasuredHeight();
                  realWidth = realWidth > measuredWidth ? realWidth : measuredWidth;
                  realHeight += measuredHeight;
                }
                setMeasuredDimension(realWidth, realHeight);
              }
            } else {
              super.onMeasure(recycler, state, widthSpec, heightSpec);
            }
          }
        });
  }

  public void initListener() {
    adapter.setApplyAction(
        new SeatApplyAdapter.IApplyAction() {

          @Override
          public void refuse(RoomSeat seat) {
            requestAction.refuse(seat);
          }

          @Override
          public void agree(RoomSeat seat) {
            requestAction.agree(seat);
          }
        });
    tvDismiss.setOnClickListener((v) -> dismiss());
  }

  public void setRequestAction(IRequestAction requestAction) {
    this.requestAction = requestAction;
  }

  public void update(Collection<RoomSeat> seats) {
    this.seats.clear();
    this.seats.addAll(seats);
    if (isVisible()) {
      refresh();
    }
  }

  private void refresh() {
    title.setText(getString(R.string.voiceroom_apply_micro_has_arrow, seats.size()));
    adapter.setItems(seats);
  }

  @Override
  public void onDismiss(DialogInterface dialog) {
    super.onDismiss(dialog);
    requestAction.dismiss();
  }

  public static class SeatApplyAdapter extends BaseAdapter<RoomSeat> {
    public interface IApplyAction {
      void refuse(RoomSeat seat);

      void agree(RoomSeat seat);
    }

    IApplyAction applyAction;
    ArrayList<RoomSeat> seats;

    public SeatApplyAdapter(ArrayList<RoomSeat> seats, Context context) {
      super(seats, context);
      this.seats = seats;
    }

    @Override
    protected RecyclerView.ViewHolder onCreateBaseViewHolder(ViewGroup parent, int viewType) {
      return new ApplyViewHolder(layoutInflater.inflate(R.layout.apply_item_layout, parent, false));
    }

    @Override
    protected void onBindBaseViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
      RoomSeat seat = getItem(position);
      if (seat == null) {
        return;
      }
      ApplyViewHolder viewHolder = (ApplyViewHolder) holder;
      NEVoiceRoomMember member = seat.getMember();
      if (member != null) {
        int index = seat.getSeatIndex() - 1;
        ImageLoader.with(context)
            .load(member.getAvatar())
            .error(R.drawable.nim_avatar_default)
            .into(viewHolder.ivAvatar);
        String content =
            String.format(
                context.getString(R.string.voiceroom_apply_seat_num), member.getName(), index);
        viewHolder.tvContent.setText(content);
        viewHolder.ivRefuse.setOnClickListener((v) -> applyAction.refuse(seat));
        viewHolder.ivAfree.setOnClickListener((v) -> applyAction.agree(seat));
      } else {
        ALog.e(tag, "member is null");
      }
    }

    private class ApplyViewHolder extends RecyclerView.ViewHolder {
      HeadImageView ivAvatar;
      ImageView ivRefuse;
      ImageView ivAfree;
      TextView tvContent;

      public ApplyViewHolder(@NonNull View itemView) {
        super(itemView);
        ivAvatar = itemView.findViewById(R.id.item_requestlink_headicon);
        ivRefuse = itemView.findViewById(R.id.refuse);
        ivAfree = itemView.findViewById(R.id.agree);
        tvContent = itemView.findViewById(R.id.item_requestlink_content);
      }
    }

    public void setApplyAction(IApplyAction applyAction) {
      this.applyAction = applyAction;
    }
  }
}

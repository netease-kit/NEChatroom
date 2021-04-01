package com.netease.audioroom.demo.dialog;

import android.app.ActionBar;
import android.app.Activity;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MemberListAdapter;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * Created by luc on 1/29/21.
 */
public class MemberSelectDialog extends BottomBaseDialog {

    private final OnMemberChosenListener listener;
    private MemberListAdapter adapter;

    private final Anchor anchor;

    private final List<String> excludeAccounts = new ArrayList<>();

    public MemberSelectDialog(@NonNull Activity activity, OnMemberChosenListener listener) {
        this(activity, null, listener);
    }

    public MemberSelectDialog(@NonNull Activity activity, List<String> accounts, OnMemberChosenListener listener) {
        super(activity);
        this.listener = listener;
        if (accounts != null && !accounts.isEmpty()) {
            this.excludeAccounts.addAll(accounts);
        }
        this.anchor = NERtcVoiceRoom.sharedInstance(activity).getAnchor();
    }

    @Override
    protected void renderTopView(FrameLayout parent) {
        TextView titleView = new TextView(getContext());
        titleView.setText("选择成员");
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);
        titleView.setGravity(Gravity.CENTER);
        titleView.setTextColor(Color.parseColor("#ff333333"));
        FrameLayout.LayoutParams titleLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(titleView, titleLayoutParams);

        ImageView cancelView = new ImageView(getContext());
        cancelView.setImageResource(R.drawable.icon_room_memeber_back_arrow);
        cancelView.setPadding(ScreenUtil.dip2px(getContext(), 20), 0, 0, 0);
        FrameLayout.LayoutParams cancelLayoutParams = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        parent.addView(cancelView, cancelLayoutParams);

        cancelView.setOnClickListener(v -> dismiss());
    }

    @Override
    protected void renderBottomView(FrameLayout parent) {
        RecyclerView rvMemberList = new RecyclerView(getContext());
        rvMemberList.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
        int height = (int) (ScreenUtil.getScreenHeight(getContext()) * 0.8) - ScreenUtil.dip2px(getContext(), 48);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, height);
        rvMemberList.setLayoutManager(new LinearLayoutManager(getContext()));
        adapter = new MemberListAdapter(getContext());
        rvMemberList.setAdapter(adapter);
        parent.addView(rvMemberList, layoutParams);

        fetchRoomMembers(excludeAccounts);

    }

    private void fetchRoomMembers(List<String> excludeAccounts) {
        RequestCallback<List<VoiceRoomUser>> callback = new RequestCallback<List<VoiceRoomUser>>() {
            @Override
            public void onSuccess(List<VoiceRoomUser> members) {
                adapter.updateDataSource(members);
                adapter.setOnItemClickListener(item -> {
                    VoiceRoomUser member = members.get(item);
                    if (listener != null) {
                        listener.onMemberChosen(member);
                    }
                    dismiss();
                });
            }

            @Override
            public void onFailed(int i) {
                ToastHelper.showToast("获取用户失败code" + i);
            }

            @Override
            public void onException(Throwable throwable) {
                ToastHelper.showToast("获取用户失败Exception" + throwable.getMessage());
            }
        };
        if (!excludeAccounts.isEmpty()) {
            anchor.getRoomQuery().fetchMembersByAccount(excludeAccounts, false, callback);
        } else {
            anchor.getRoomQuery().fetchMembersByMuted(false, callback);
        }
    }

    public interface OnMemberChosenListener {
        void onMemberChosen(VoiceRoomUser member);
    }
}

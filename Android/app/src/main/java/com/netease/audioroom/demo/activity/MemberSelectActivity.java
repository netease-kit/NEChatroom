package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MemberListAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.EmptyChatRoomListCallback;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 * 选择成员
 */
public class MemberSelectActivity extends BaseActivity {
    private static final String EXTRA_VOICE_ROOM_INFO = "extra_voice_room_info";
    private static String EXTRA_EXCLUDE_ACCOUNTS = "exclude_accounts";
    public static final String RESULT_MEMBER = "member";

    public static void selectWithExcludeMuted(Activity activity, VoiceRoomInfo voiceRoomInfo, int requestCode) {
        Intent intent = new Intent(activity, MemberSelectActivity.class);
        intent.putExtra(EXTRA_VOICE_ROOM_INFO, voiceRoomInfo);
        activity.startActivityForResult(intent, requestCode);
    }

    public static void selectWithExcludeAccounts(Activity activity,
                                                 VoiceRoomInfo voiceRoomInfo,
                                                 List<String> accounts,
                                                 int requestCode) {
        Intent intent = new Intent(activity, MemberSelectActivity.class);
        intent.putExtra(EXTRA_VOICE_ROOM_INFO, voiceRoomInfo);
        intent.putStringArrayListExtra(EXTRA_EXCLUDE_ACCOUNTS, accounts != null ? new ArrayList<>(accounts) : new ArrayList<>());
        activity.startActivityForResult(intent, requestCode);
    }

    private RecyclerView recyclerView;
    private MemberListAdapter adapter;

    private Anchor anchor;

    @Override
    protected int getContentViewID() {
        return R.layout.activity_member;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        VoiceRoomInfo voiceRoomInfo = (VoiceRoomInfo) getIntent().getSerializableExtra(EXTRA_VOICE_ROOM_INFO);
        if (voiceRoomInfo == null) {
            ToastHelper.showToast("聊天室信息不能为空");
            finish();
            return;
        }

        NERtcVoiceRoom voiceRoom = NERtcVoiceRoom.sharedInstance(this);
        voiceRoom.initRoom(voiceRoomInfo, createUser());
        anchor = voiceRoom.getAnchor();

        initViews();

        fetchRoomMembers(getIntent().getStringArrayListExtra(EXTRA_EXCLUDE_ACCOUNTS));
    }

    protected void initViews() {
        View toolbar = findViewById(R.id.toolsbar);
        TextView title = toolbar.findViewById(R.id.title);
        title.setText("选择成员");
        toolbar.findViewById(R.id.icon).setOnClickListener((v) -> finish());

        recyclerView = findViewById(R.id.member_recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.addItemDecoration(new VerticalItemDecoration(Color.GRAY, ScreenUtil.dip2px(this, 1)));

        adapter = new MemberListAdapter(null, this);
        recyclerView.setAdapter(adapter);
    }

    private void fetchRoomMembers(List<String> excludeAccounts) {
        RequestCallback<List<VoiceRoomUser>> callback = new RequestCallback<List<VoiceRoomUser>>() {
            @Override
            public void onSuccess(List<VoiceRoomUser> members) {
                loadSuccess();
                if (members.size() != 0) {
                    adapter = new MemberListAdapter(members, MemberSelectActivity.this);
                    recyclerView.setLayoutManager(new LinearLayoutManager(MemberSelectActivity.this));
                    recyclerView.setAdapter(adapter);
//                    adapter.setItemClickListener((m, p) -> {
//                        VoiceRoomUser member = members.get(p);
//                        Intent intent = new Intent();
//                        intent.putExtra(RESULT_MEMBER, member);
//                        setResult(RESULT_OK, intent);
//                        finish();
//                    });
                } else {
                    loadShowCallback(EmptyChatRoomListCallback.class);
                    setLoadCallBack(EmptyChatRoomListCallback.class, (context, view) -> {
                        ((TextView) (view.findViewById(R.id.toolsbar).findViewById(R.id.title))).setText("选择成员");
                        view.findViewById(R.id.toolsbar).findViewById(R.id.icon).setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                finish();
                            }
                        });
                    });
                }
            }

            @Override
            public void onFailed(int i) {
                showError();
            }

            @Override
            public void onException(Throwable throwable) {
                showError();
            }
        };
        if (excludeAccounts != null) {
            anchor.getRoomQuery().fetchMembersByAccount(excludeAccounts, false, callback);
        } else {
            anchor.getRoomQuery().fetchMembersByMuted(false, callback);
        }
    }
}

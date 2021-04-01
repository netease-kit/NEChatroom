package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MuteMemberListAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.MuteMemberDialog;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
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
 * 禁言成员页面（可侧滑）
 */
public class MuteMembersActivity extends BaseActivity {
    private static final int CODE_SELECT_MEMBER = 10001;
    public static final String EXTRA_VOICE_ROOM_INFO = "extra_voice_room_info";

    private TextView muteAllMember;
    private TextView title;
    private LinearLayout empty_view;
    private RecyclerView recyclerView;
    private MuteMemberListAdapter adapter;

    boolean isAllMute;
    private List<VoiceRoomUser> muteList = new ArrayList<>();

    private VoiceRoomInfo voiceRoomInfo;

    private Anchor anchor;

    public static void start(Activity context, VoiceRoomInfo voiceRoomInfo) {
//        Intent intent = new Intent(context, MuteMembersActivity.class);
//        intent.putExtra(EXTRA_VOICE_ROOM_INFO, voiceRoomInfo);
//        context.startActivity(intent);

        new MuteMemberDialog(context,voiceRoomInfo).show();
    }

    @Override
    protected int getContentViewID() {
        return R.layout.activity_mute_member;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        voiceRoomInfo = (VoiceRoomInfo) getIntent().getSerializableExtra(EXTRA_VOICE_ROOM_INFO);
        if (voiceRoomInfo == null) {
            ToastHelper.showToast("聊天室信息不能为空");
            finish();
            return;
        }

        NERtcVoiceRoom voiceRoom = NERtcVoiceRoom.sharedInstance(this);
        voiceRoom.initRoom(voiceRoomInfo, createUser());
        anchor = voiceRoom.getAnchor();

        initViews();

        fetchRoomMute();
        fetchMutedRoomMembers();
    }

    private void initViews() {
        TextView addMuteMember = findViewById(R.id.addMuteMember);
        muteAllMember = findViewById(R.id.muteAllMember);
        recyclerView = findViewById(R.id.member_recyclerView);
        empty_view = findViewById(R.id.empty_view);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.addItemDecoration(new VerticalItemDecoration(Color.WHITE, 1));

        addMuteMember.setOnClickListener(v -> addMuteMember());
        TextView icon = findViewById(R.id.toolsbar).findViewById(R.id.icon);
        title = findViewById(R.id.toolsbar).findViewById(R.id.title);
        icon.setOnClickListener(v -> finish());
        muteAllMember.setOnClickListener((v) -> muteAllMember(!isAllMute));
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == CODE_SELECT_MEMBER) {
            if (resultCode == RESULT_OK) {
                VoiceRoomUser member = (VoiceRoomUser) data.getSerializableExtra(MemberSelectActivity.RESULT_MEMBER);
                if (member == null) {
                    return;
                }

                muteList.add(0, member);
                if (muteList.size() == 0) {
                    recyclerView.setVisibility(View.GONE);
                    empty_view.setVisibility(View.VISIBLE);
                } else {
                    empty_view.setVisibility(View.GONE);
                    recyclerView.setVisibility(View.VISIBLE);
                    anchor.getRoomQuery().muteMember(member, true, new RequestCallback<Void>() {
                                @Override
                                public void onSuccess(Void param) {
                                    String nick = member.getNick();
                                    ToastHelper.showToast(nick + "已被禁言");

                                    ArrayList<String> accountList = new ArrayList<>();
                                    for (String account : accountList) {
                                        accountList.add(0, account);
                                    }
                                    adapter = new MuteMemberListAdapter(MuteMembersActivity.this);
                                    adapter.updateDataSource(muteList);
                                    recyclerView.setAdapter(adapter);
                                    title.setText("禁言成员 (" + muteList.size() + ")");
                                    adapter.setRemoveMute((p) -> {
                                        if (isAllMute) {
                                            ToastHelper.showToast("全员禁言中,不能解禁");
                                        } else {
                                            removeMuteMember(p, muteList.get(p));
                                        }
                                    });
                                }

                                @Override
                                public void onFailed(int code) {
                                    // 失败
                                    ToastHelper.showToast("禁言失败" + code);
                                }

                                @Override
                                public void onException(Throwable exception) {
                                    // 错误
                                    ToastHelper.showToast("禁言异常" + exception.getMessage());
                                }
                            });
                }

            }
        }
    }

    private void fetchRoomMute() {
        anchor.getRoomQuery().fetchRoomMute(new RequestCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean isMute) {
                loadSuccess();
                if (isMute) {
                    isAllMute = true;
                    muteAllMember.setText("取消全部禁言");
                } else {
                    isAllMute = false;
                    muteAllMember.setText("全部禁言");
                }
            }

            @Override
            public void onFailed(int code) {
                loadSuccess();
                ToastHelper.showToast("禁言失败code" + code);
            }

            @Override
            public void onException(Throwable exception) {
                loadSuccess();
                ToastHelper.showToast("禁言失败exception" + exception.getMessage());
            }
        });
    }

    private void fetchMutedRoomMembers() {
        anchor.getRoomQuery().fetchMembersByMuted(true, new RequestCallback<List<VoiceRoomUser>>() {
            @Override
            public void onSuccess(List<VoiceRoomUser> members) {
                loadSuccess();
                muteList.clear();
                muteList.addAll(members);

                if (muteList.size() != 0) {
                    empty_view.setVisibility(View.GONE);
                    adapter = new MuteMemberListAdapter(MuteMembersActivity.this);
                    adapter.updateDataSource(muteList);
                    recyclerView.setAdapter(adapter);
                    title.setText("禁言成员 (" + muteList.size() + ")");
                    adapter.setRemoveMute((p) -> {
                        if (isAllMute) {
                            ToastHelper.showToast("全员禁言中,不能解禁");
                        } else {
                            removeMuteMember(p, muteList.get(p));
                        }
                    });
                } else {
                    recyclerView.setVisibility(View.GONE);
                    empty_view.setVisibility(View.VISIBLE);
                    title.setText("禁言成员");
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
        });
    }

    private void addMuteMember() {
        MemberSelectActivity.selectWithExcludeMuted(this, voiceRoomInfo, CODE_SELECT_MEMBER);
    }

    private void muteAllMember(boolean mute) {
        ChatRoomHttpClient.getInstance().muteAll(DemoCache.getAccountId(), voiceRoomInfo.getRoomId(), mute, true, false,
                new ChatRoomHttpClient.ChatRoomHttpCallback() {
                    @Override
                    public void onSuccess(Object o) {
                        if (!isAllMute) {
                            muteAllMember.setText("取消全部禁麦");
                            ToastHelper.showToast("已全部禁麦");
                        } else {
                            muteAllMember.setText("全部禁言");
                            ToastHelper.showToast("取消全部禁麦");
                        }
                        isAllMute = mute;
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        ToastHelper.showToast("全部禁麦失败+" + errorMsg);
                    }
                });
    }

    private void removeMuteMember(int p, VoiceRoomUser member) {
        anchor.getRoomQuery().muteMember(member, false, new RequestCallback<Void>() {
                    @Override
                    public void onSuccess(Void param) {
                        ToastHelper.showToast(member.getNick() + "已被解除禁言");
                            muteList.remove(p);
                        if (muteList.size() == 0) {
                            adapter.notifyDataSetChanged();
                            empty_view.setVisibility(View.VISIBLE);
                            title.setText("禁言成员");
                        } else {
                            title.setText("禁言成员 (" + muteList.size() + ")");
                            adapter.notifyDataSetChanged();
                        }
                    }

                    @Override
                    public void onFailed(int code) {
                        ToastHelper.showToast("解禁失败" + code);
                    }

                    @Override
                    public void onException(Throwable exception) {
                        ToastHelper.showToast("解禁异常" + exception.getMessage());
                    }
                });
    }
}

package com.netease.audioroom.demo.activity;

import android.os.Bundle;
import android.view.View;

import com.gyf.immersionbar.ImmersionBar;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.FunctionAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.base.LoginManager;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.NetworkChange;
import com.netease.nimlib.sdk.StatusCode;

import java.util.Arrays;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;


public class MainActivity extends BaseActivity {

    @Override
    protected int getContentViewID() {
        return R.layout.activity_main;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            finish();
            return;
        }
        setupStatusBar();
        initViews();
        showLoading();
        watchNetWork();

    }

    private void watchNetWork() {
        NetworkChange.getInstance().getNetworkLiveData().observe(this, network -> {
            if (network != null && network.isConnected()) {
                MainActivity.this.onNetwork();
            } else {
                showNetError();
            }
        });
    }

    private void setupStatusBar() {
        ImmersionBar.with(this).statusBarDarkFont(true).init();
        View root = findViewById(R.id.cl_root_group);
        int barHeight = ImmersionBar.getStatusBarHeight(this);
        root.setPadding(root.getPaddingLeft(), root.getPaddingTop() + barHeight, root.getPaddingRight(),
                root.getPaddingBottom());
    }

    // not need every time login. im auto login when network change
    private void onNetwork() {
        LoginManager loginManager = LoginManager.getInstance();
        loginManager.tryLogin();
        loginManager.setCallback(new LoginManager.Callback() {

            @Override
            public void onSuccess(AccountInfo accountInfo) {
                loadSuccess();
                requestLivePermission();
            }

            @Override
            public void onFailed(int code, String errorMsg) {
                showError();
            }
        });
    }

    protected void initViews() {
        // 功能列表初始化
        RecyclerView rvFunctionList = findViewById(R.id.rv_function_list);
        rvFunctionList.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        rvFunctionList.setAdapter(new FunctionAdapter(this, Arrays.asList(
                new FunctionAdapter.FunctionItem(FunctionAdapter.TYPE_VIEW_TITLE, getString(R.string.funciton_title)),
                // 每个业务功能入口均在此处生成 item
                new FunctionAdapter.FunctionItem(R.drawable.icon_function_chat_room, getString(R.string.voice_chat),
                        getString(R.string.function_desc), () -> {
                    RoomListActivity.start(MainActivity.this, ChatRoomNetConstants.ROOM_TYPE_CHAT);
                }), new FunctionAdapter.FunctionItem(R.drawable.icon_funcation_ktv, getString(R.string.ktv),
                        getString(R.string.function_desc), () -> {
                    RoomListActivity.start(MainActivity.this, ChatRoomNetConstants.ROOM_TYPE_KTV);
                }))));
        View toCreate = findViewById(R.id.iv_new_live);
        toCreate.setOnClickListener(v -> {
            CreateRoomActivity.start(MainActivity.this, ChatRoomNetConstants.ROOM_TYPE_CHAT);
        });
    }


    @Override
    protected void onResume() {
        super.onResume();
    }


    @Override
    public void onBackPressed() {
        super.onBackPressed();
    }

    @Override
    protected void onLoginEvent(StatusCode statusCode) {
    }

}

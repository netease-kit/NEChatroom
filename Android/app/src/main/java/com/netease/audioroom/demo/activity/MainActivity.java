package com.netease.audioroom.demo.activity;

import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.ChatRoomListAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.base.LoginManager;
import com.netease.audioroom.demo.base.action.INetworkReconnection;
import com.netease.audioroom.demo.base.adapter.BaseAdapter;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.CreateRoomNameDialog;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.HeadImageView;
import com.netease.audioroom.demo.widget.VerticalItemDecoration;
import com.netease.audioroom.demo.widget.pullloadmorerecyclerview.PullLoadMoreRecyclerView;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.ErrorCallback;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.LoadingCallback;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.NetErrCallback;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef;

import java.util.ArrayList;


public class MainActivity extends BaseActivity implements BaseAdapter.ItemClickListener<VoiceRoomInfo>,
        PullLoadMoreRecyclerView.PullLoadMoreListener,
        View.OnClickListener,
        CompoundButton.OnCheckedChangeListener {

    private HeadImageView ivAvatar;
    private TextView tvNick;
    private ChatRoomListAdapter chatRoomListAdapter;
    private StatusCode loginStatus = StatusCode.UNLOGIN;
    private PullLoadMoreRecyclerView mPullLoadMoreRecyclerView;
    RecyclerView mRecyclerView;
    ArrayList<VoiceRoomInfo> mRoomList;

    private int limitPage = 50;
    private int addPage = 20;

    private LinearLayout llSelectAudioQualityContainer;
    private ArrayList<CheckBox> checkBoxes = new ArrayList<>();


    @Override
    protected int getContentViewID() {
        return R.layout.activity_main;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        initViews();
    }

    protected void initViews() {
        mRoomList = new ArrayList<>();
        ivAvatar = findViewById(R.id.iv_self_avatar);
        tvNick = findViewById(R.id.tv_self_nick);
        llSelectAudioQualityContainer = findViewById(R.id.ll_select_audio_quality);

        //顺序很重要
        checkBoxes.add(findViewById(R.id.cb_normal_audio));
        checkBoxes.add(findViewById(R.id.cb_high_audio));
        checkBoxes.add(findViewById(R.id.cb_music_audio));

        int audioQuality = NERtcVoiceRoomDef.RoomAudioQuality.DEFAULT_QUALITY;
        for (CheckBox checkBox : checkBoxes) {
            checkBox.setOnCheckedChangeListener(this);
            checkBox.setTag(audioQuality);
            audioQuality++;
        }


        findViewById(R.id.iv_create_chat_room).setOnClickListener(this);
        findViewById(R.id.tv_create_room).setOnClickListener(this);
        findViewById(R.id.close_select_audio).setOnClickListener(this);

        chatRoomListAdapter = new ChatRoomListAdapter(mRoomList, this);
        // 每个item 16dp 的间隔
        chatRoomListAdapter.setItemClickListener(this);
        mPullLoadMoreRecyclerView = findViewById(R.id.pull_load_more_rv);
        //获取mRecyclerView对象
        mRecyclerView = mPullLoadMoreRecyclerView.getRecyclerView();
        mRecyclerView.addItemDecoration(new VerticalItemDecoration(Color.TRANSPARENT, ScreenUtil.dip2px(this, 8)));
        mRecyclerView.setVerticalScrollBarEnabled(true);
        mPullLoadMoreRecyclerView.setRefreshing(true);
        mPullLoadMoreRecyclerView.setFooterViewText("加载中");
        mPullLoadMoreRecyclerView.setLinearLayout();
        mPullLoadMoreRecyclerView.setOnPullLoadMoreListener(this);
        mPullLoadMoreRecyclerView.setAdapter(chatRoomListAdapter);

        if (Network.getInstance().isConnected()) {
            onNetWork();
        } else {
            netErrCallback();
        }
    }


    @Override
    protected void onResume() {
        super.onResume();
        loadService.showCallback(LoadingCallback.class);
        onRefresh();
        setNetworkReconnection(new INetworkReconnection() {
            @Override
            public void onNetworkReconnection() {
                loadService.showCallback(LoadingCallback.class);
                onNetWork();
            }

            @Override
            public void onNetworkInterrupt() {
                netErrCallback();
            }
        });
    }


    private void onNetWork() {
        LoginManager loginManager = LoginManager.getInstance();
        loginManager.tryLogin();
        loginManager.setCallback(new LoginManager.Callback() {
            @Override
            public void onSuccess(AccountInfo accountInfo) {
                fetchChatRoomList();
                ivAvatar.loadAvatar(accountInfo.avatar);
                tvNick.setText(accountInfo.nick);
                requestLivePermission();
            }

            @Override
            public void onFailed(int code, String errorMsg) {
                loadService.showCallback(ErrorCallback.class);
            }
        });

    }


    private void fetchChatRoomList() {
        int limit;
        if (mRoomList.size() == 0) {
            chatRoomListAdapter.clearAll();
            limit = limitPage;
        } else {
            limit = addPage;
        }
        ChatRoomHttpClient.getInstance().fetchChatRoomList(mRoomList.size(), limit
                , new ChatRoomHttpClient.ChatRoomHttpCallback<ArrayList<VoiceRoomInfo>>() {
                    @Override
                    public void onSuccess(ArrayList<VoiceRoomInfo> roomList) {
                        loadService.showSuccess();
                        if (roomList.size() > 0) {
                            mRoomList.addAll(roomList);
                            chatRoomListAdapter.refrshList(mRoomList);
                        }
                        mPullLoadMoreRecyclerView.setPullLoadMoreCompleted();

                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        mPullLoadMoreRecyclerView.setPullLoadMoreCompleted();
                        loadService.showCallback(ErrorCallback.class);
                    }
                });
    }

    @Override
    public void onRefresh() {
        mRoomList.clear();
        if (Network.getInstance().isConnected()) {
            fetchChatRoomList();
        } else {
            netErrCallback();
        }
    }


    @Override
    public void onLoadMore() {
        if (Network.getInstance().isConnected())
            fetchChatRoomList();
        else
            netErrCallback();
    }

    @Override
    public void onItemClick(VoiceRoomInfo model, int position) {
        if (loginStatus != StatusCode.LOGINED) {
            ToastHelper.showToast("登录失败，请杀掉APP重新登录");
            return;
        }
        //当前帐号创建的房间
        if (TextUtils.equals(DemoCache.getAccountId(), model.getCreatorAccount())) {
//            closeRoom(model.getRoomId());
            AnchorActivity.start(this, model);
        } else {
            AudienceActivity.start(this, model);
        }
    }

    private void closeRoom(String roomId) {
        mPullLoadMoreRecyclerView.setRefreshing(true);
        //关闭应用服务器聊天室
        ChatRoomHttpClient.getInstance().closeRoom(DemoCache.getAccountId(),
                roomId, new ChatRoomHttpClient.ChatRoomHttpCallback() {
                    @Override
                    public void onSuccess(Object o) {
                        ToastHelper.showToast("房间不存在");
                        onRefresh();
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        mPullLoadMoreRecyclerView.setPullLoadMoreCompleted();
                        loadService.showSuccess();
                        ToastHelper.showToast("房间异常" + errorMsg);
                    }
                });
    }

    @Override
    public void onBackPressed() {
        if (llSelectAudioQualityContainer.getVisibility() == View.VISIBLE) {
            llSelectAudioQualityContainer.setVisibility(View.GONE);
            return;
        }
        super.onBackPressed();
    }

    @Override
    protected void onLoginEvent(StatusCode statusCode) {
        loginStatus = statusCode;
    }

    private void netErrCallback() {
        loadService.showCallback(NetErrCallback.class);
        loadService.setCallBack(NetErrCallback.class, (context, view) -> {
            view.setOnClickListener((v) -> {
                loadService.showCallback(LoadingCallback.class);
                if (Network.getInstance().isConnected()) {
                    new Handler().postDelayed(() -> onNetWork(), 10 * 1000); // 延时10秒
                } else {
                    new Handler().postDelayed(() -> {
                        loadService.showCallback(NetErrCallback.class);
                        loadService.setCallBack(NetErrCallback.class, (c, view1) -> netErrCallback()
                        );
                    }, 10 * 1000);
                }
            });
        });
    }


    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.iv_create_chat_room) {
//            llSelectAudioQualityContainer.setVisibility(View.VISIBLE);
            int audioQuality = NERtcVoiceRoomDef.RoomAudioQuality.MUSIC_QUALITY;
            CreateRoomNameDialog dialog = CreateRoomNameDialog.newInstance(audioQuality);
            dialog.show(getSupportFragmentManager(), dialog.TAG);
        } else if (id == R.id.tv_create_room) {
            int audioQuality = findQuality();
            CreateRoomNameDialog dialog = CreateRoomNameDialog.newInstance(audioQuality);
            dialog.show(getSupportFragmentManager(), dialog.TAG);
            llSelectAudioQualityContainer.setVisibility(View.GONE);
        } else if (id == R.id.close_select_audio) {
            llSelectAudioQualityContainer.setVisibility(View.GONE);
        }

    }

    private int findQuality() {
        for (CheckBox checkBox : checkBoxes) {
            if (checkBox.isChecked()) {
                return (int) checkBox.getTag();
            }
        }
        return NERtcVoiceRoomDef.RoomAudioQuality.DEFAULT_QUALITY;
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {

        if (!isChecked) {
            return;
        }

        for (CheckBox checkBox : checkBoxes) {
            if (checkBox != buttonView) {
                checkBox.setChecked(false);
            }
        }

    }
}

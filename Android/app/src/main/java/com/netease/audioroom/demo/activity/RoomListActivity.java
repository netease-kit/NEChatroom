package com.netease.audioroom.demo.activity;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import com.google.android.material.tabs.TabLayout;
import com.gyf.immersionbar.ImmersionBar;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MainPagerAdapter;
import com.netease.audioroom.demo.base.BaseActivity;
import com.netease.audioroom.demo.constant.Extras;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;

import androidx.annotation.Nullable;
import androidx.viewpager.widget.ViewPager;

public class RoomListActivity extends BaseActivity {
    private MainPagerAdapter adapter;

    public static void start(Context context, int type) {
        Intent intent = new Intent(context, RoomListActivity.class);
        intent.putExtra(Extras.ROOM_TYPE, type);
        context.startActivity(intent);
    }

    private int currentPosition;

    @Override
    protected int getContentViewID() {
        return R.layout.activity_room_list;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupStatusBar();
        getIntentData();
        initViews();
    }

    private void setupStatusBar() {
        ImmersionBar.with(this).statusBarDarkFont(true).init();
        View root = findViewById(R.id.rv_root);
        int barHeight = ImmersionBar.getStatusBarHeight(this);
        root.setPadding(root.getPaddingLeft(), root.getPaddingTop() + barHeight, root.getPaddingRight(),
                root.getPaddingBottom());
    }

    private void getIntentData() {
        int type = getIntent().getIntExtra(Extras.ROOM_TYPE, ChatRoomNetConstants.ROOM_TYPE_CHAT);
        currentPosition = type == ChatRoomNetConstants.ROOM_TYPE_CHAT ? 0 : 1;
    }

    protected void initViews() {
        View ivBack = findViewById(R.id.iv_back);
        ivBack.setOnClickListener(v -> finish());
        ViewPager mainPager = findViewById(R.id.vp_fragment);
        adapter = new MainPagerAdapter(this, getSupportFragmentManager());
        mainPager.setAdapter(adapter);
        mainPager.setOffscreenPageLimit(2);
        TabLayout tabLayout = findViewById(R.id.tl_tab);
        tabLayout.setupWithViewPager(mainPager);
        mainPager.addOnPageChangeListener(new TabLayout.TabLayoutOnPageChangeListener(tabLayout) {

            @Override
            public void onPageSelected(int position) {
                currentPosition = position;
                TabLayout.Tab item = tabLayout.getTabAt(position);
                if (item != null) {
                    item.select();
                }
                super.onPageSelected(position);
            }
        });
        mainPager.setCurrentItem(currentPosition, false);
        View toCreate = findViewById(R.id.iv_new_live);
        toCreate.setOnClickListener(v -> CreateRoomActivity.start(RoomListActivity.this, getType(currentPosition)));
        loadSuccess();
    }

    private int getType(int position) {
        int type = ChatRoomNetConstants.ROOM_TYPE_CHAT;
        if (position == 0) {
            type = ChatRoomNetConstants.ROOM_TYPE_CHAT;
        } else if (position == 1) {
            type = ChatRoomNetConstants.ROOM_TYPE_KTV;
        }
        return type;
    }


    @Override
    protected void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.refresh();
        }
    }
}
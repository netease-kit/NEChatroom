package com.netease.audioroom.demo.adapter;

import android.content.Context;
import android.util.SparseArray;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.activity.RoomListFragment;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

public class MainPagerAdapter extends FragmentPagerAdapter {

    private Context context;

    public MainPagerAdapter(Context context, @NonNull FragmentManager fm) {
        super(fm, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        this.context = context;
    }

    @NonNull
    @Override
    public Fragment getItem(int position) {
        return getFragmentByPosition(position);
    }

    @Override
    public int getCount() {
        return 2;
    }

    /**
     * fragment 缓存
     */
    private final SparseArray<RoomListFragment> fragmentCache = new SparseArray<>(2);

    /**
     * 获取对应位置 fragment
     *
     * @param position 位置
     * @return fragment
     */
    private Fragment getFragmentByPosition(int position) {
        RoomListFragment fragment = fragmentCache.get(position);
        if (fragment != null) {
            return fragment;
        }
        if (position == 0) {
            fragment = RoomListFragment.newInstance(ChatRoomNetConstants.ROOM_TYPE_CHAT);
        } else if (position == 1) {
            fragment = RoomListFragment.newInstance(ChatRoomNetConstants.ROOM_TYPE_KTV);
        }
        fragmentCache.put(position, fragment);
        return fragment;
    }

    @Nullable
    @Override
    public CharSequence getPageTitle(int position) {
        switch (position) {
            case 0:
                return context.getString(R.string.room_chat);
            case 1:
                return context.getString(R.string.room_ktv);
        }
        return "";
    }

    public void refresh() {
        int size = fragmentCache.size();

        for (int i = 0; i < size; i++) {
            RoomListFragment fragment = fragmentCache.valueAt(i);
            if (fragment != null) {
                fragment.refresh();
            }
        }
    }
}

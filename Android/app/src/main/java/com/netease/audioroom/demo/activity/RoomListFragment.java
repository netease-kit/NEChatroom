package com.netease.audioroom.demo.activity;

import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;

import com.netease.yunxin.kit.alog.ALog;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.ChatRoomListAdapter;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.constant.Extras;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.http.ChatRoomNetConstants;
import com.netease.audioroom.demo.util.IconFontUtil;
import com.netease.audioroom.demo.util.NetworkUtils;
import com.netease.audioroom.demo.util.ScreenUtil;
import com.netease.audioroom.demo.widget.pullloadmorerecyclerview.PullLoadMoreRecyclerView;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;

import java.util.ArrayList;

import static com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomAudioQuality.DEFAULT_QUALITY;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomAudioQuality.MUSIC_QUALITY;

public class RoomListFragment extends Fragment {

    private static final int PAGE_SIZE = 20;

    private final ArrayList<VoiceRoomInfo> dataSource = new ArrayList<>();

    private ChatRoomListAdapter chatRoomListAdapter;

    private int currentType = ChatRoomNetConstants.ROOM_TYPE_CHAT;

    public RoomListFragment() {
    }

    private View emptyView;

    private TextView emptyViewIcon;

    private PullLoadMoreRecyclerView pullLoadMoreRecyclerView;

    public static RoomListFragment newInstance(int type) {
        RoomListFragment fragment = new RoomListFragment();
        Bundle bundle = new Bundle();
        bundle.putInt(Extras.ROOM_TYPE, type);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            this.currentType = getArguments().getInt(Extras.ROOM_TYPE, ChatRoomNetConstants.ROOM_TYPE_CHAT);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_room_list, container, false);
        findViews(rootView);
        initViews(rootView);
        return rootView;
    }

    private void findViews(View rootView) {
        emptyView = rootView.findViewById(R.id.empty_view);
        emptyViewIcon = rootView.findViewById(R.id.room_list_empty_icon);
    }

    private void initViews(View rootView) {
        setupEmptyFont();
        // 每个item 16dp 的间隔
        chatRoomListAdapter = new ChatRoomListAdapter(getContext());
        chatRoomListAdapter.setItemClickListener((model, position) -> {
            //当前帐号创建的房间
            if (model.getRoomType() == ChatRoomNetConstants.ROOM_TYPE_CHAT) {
                model.setAudioQuality(DEFAULT_QUALITY);
            } else if (model.getRoomType() == ChatRoomNetConstants.ROOM_TYPE_KTV) {
                model.setAudioQuality(MUSIC_QUALITY);
            }
            if (TextUtils.equals(DemoCache.getAccountId(), model.getCreatorAccount())) {
                AnchorActivity.start(getActivity(), model);
            } else {
                AudienceActivity.start(getActivity(), model);
            }
        });
        pullLoadMoreRecyclerView = rootView.findViewById(R.id.rv_room_list);
        //获取mRecyclerView对象
        RecyclerView recyclerView = pullLoadMoreRecyclerView.getRecyclerView();
        recyclerView.setOverScrollMode(RecyclerView.OVER_SCROLL_NEVER);
        recyclerView.addItemDecoration(getDecor(ScreenUtil.dip2px(getContext(), 8)));
        recyclerView.setVerticalScrollBarEnabled(true);
        pullLoadMoreRecyclerView.setRefreshing(true);
        pullLoadMoreRecyclerView.setFooterViewText("加载中");
        pullLoadMoreRecyclerView.setGridLayout(2);
        pullLoadMoreRecyclerView.setOnPullLoadMoreListener(new PullLoadMoreRecyclerView.PullLoadMoreListener() {

            @Override
            public void onRefresh() {
                fetchRoomList(pullLoadMoreRecyclerView, true);
            }

            @Override
            public void onLoadMore() {
                fetchRoomList(pullLoadMoreRecyclerView, false);
            }
        });
        pullLoadMoreRecyclerView.setAdapter(chatRoomListAdapter);
        fetchRoomList(pullLoadMoreRecyclerView, true);
    }

    private void setupEmptyFont() {
        IconFontUtil.getInstance().setFontText(emptyViewIcon, IconFontUtil.ROOM_LIST_EMPTY);
    }

    private RecyclerView.ItemDecoration getDecor(int padding) {
        return new RecyclerView.ItemDecoration() {

            @Override
            public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent,
                                       @NonNull RecyclerView.State state) {
                int position = parent.getChildAdapterPosition(view);
                int left;
                int right;
                if (position % 2 == 0) {
                    left = padding;
                    right = padding / 2;
                } else {
                    right = padding;
                    left = padding / 2;
                }
                outRect.set(left, padding, right, 0);
            }
        };
    }

    private void fetchRoomList(PullLoadMoreRecyclerView pull, boolean refresh) {
        if (refresh) {
            dataSource.clear();
            if (!NetworkUtils.isNetworkConnected(getContext())){
                chatRoomListAdapter.refreshList(dataSource);
                pull.setPullLoadMoreCompleted();
                showEmptyView();
                return;
            }
        }
        ChatRoomHttpClient client = ChatRoomHttpClient.getInstance();
        client.fetchChatRoomList(dataSource.size(), PAGE_SIZE, currentType,
                new ChatRoomHttpClient.ChatRoomHttpCallback<ArrayList<VoiceRoomInfo>>() {
                    @Override
                    public void onSuccess(
                            ArrayList<VoiceRoomInfo> voiceRoomInfos) {
                        if (refresh) {
                            dataSource.clear();
                        }
                        dataSource.addAll(voiceRoomInfos);
                        chatRoomListAdapter.refreshList(dataSource);
                        pull.setPullLoadMoreCompleted();
                        showEmptyView();
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        pull.setPullLoadMoreCompleted();
                        if (dataSource.isEmpty()) {
                            showEmptyView();
                        }
                        ALog.e("FetchRoomList", "errorMsg is " + errorMsg +
                                ", errorCode is " + code);
                    }
                });
    }

    private void showEmptyView() {
        if (dataSource.isEmpty()) {
            emptyView.setVisibility(View.VISIBLE);
        } else {
            emptyView.setVisibility(View.GONE);
        }
    }

    public void refresh() {
        fetchRoomList(pullLoadMoreRecyclerView, true);
    }
}
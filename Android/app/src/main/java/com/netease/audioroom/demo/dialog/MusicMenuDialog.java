package com.netease.audioroom.demo.dialog;

import android.graphics.Color;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ScreenUtils;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MusicMenuAdapter;
import com.netease.audioroom.demo.http.ChatRoomHttpClient;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.pullloadmorerecyclerview.PullLoadMoreRecyclerView;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Music;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicChangeListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.ArrayList;
import java.util.List;

/**
 * 点歌dialog
 */
public class MusicMenuDialog extends BaseBottomDialogFragment{

    /**
     * 已点歌曲数量
     */
    private TextView tvMusicNum;

    /**
     * 右侧箭头
     */
    private ImageView ivRightArrow;

    /**
     * 歌单列表
     */
    private PullLoadMoreRecyclerView rcvMusicOrder;

    private MusicMenuAdapter musicMenuAdapter;

    private List<Music> musicList = new ArrayList<>();

    private MusicChangeListener musicChangeListener;

    private OrderedMusicDialog orderedMusicDialog;

    private VoiceRoomUser user;

    private final int limit = 20;

    private int offset;

    @Override
    protected int getResourceLayout() {
        return R.layout.dialog_order_music_layout;
    }

    @Override
    protected void initView(View rootView) {
        tvMusicNum = rootView.findViewById(R.id.tv_ordered_num);
        ivRightArrow = rootView.findViewById(R.id.iv_right_icon);
        tvMusicNum.setOnClickListener(v -> goToOrderedMusicList());
        ivRightArrow.setOnClickListener(v -> goToOrderedMusicList());

        rcvMusicOrder = rootView.findViewById(R.id.rcv_music);

    }

    @Override
    protected void initData() {
        offset = 0;
        RecyclerView recyclerView = rcvMusicOrder.getRecyclerView();
        recyclerView.setVerticalScrollBarEnabled(true);
        rcvMusicOrder.setPullRefreshEnable(true);
        rcvMusicOrder.setLinearLayout();
        rcvMusicOrder.setFooterViewText("加载更多");
        rcvMusicOrder.setOnPullLoadMoreListener(new PullLoadMoreRecyclerView.PullLoadMoreListener() {
            @Override
            public void onRefresh() {
                offset = 0;
                getMusicMenu();
            }

            @Override
            public void onLoadMore() {
                getMusicMenu();
            }
        });
        musicMenuAdapter = new MusicMenuAdapter(musicList, getContext());
        rcvMusicOrder.setAdapter(musicMenuAdapter);

        getMusicMenu();
        initMusicListener();
    }

    public void getMusicMenu() {
        ChatRoomHttpClient.getInstance().getMusicList(new ChatRoomHttpClient.ChatRoomHttpCallback<List<Music>>() {
            @Override
            public void onSuccess(List<Music> music) {
                if (offset > 0) {
                    musicMenuAdapter.appendItems(music);
                } else {
                    musicMenuAdapter.setItems(music);
                }
                if (music != null && music.size() > 0) {
                    offset = offset + 20;
                    rcvMusicOrder.setHasMore(music.size() >= limit);
                } else {
                    rcvMusicOrder.setHasMore(false);
                }
                rcvMusicOrder.setPullLoadMoreCompleted();
            }

            @Override
            public void onFailed(int code, String errorMsg) {
                ToastHelper.showToast(errorMsg);
                rcvMusicOrder.setPullLoadMoreCompleted();
            }
        }, limit, offset);
    }

    private void initMusicListener() {
        musicChangeListener = new MusicChangeListener() {
            @Override
            public void onListChange(List<MusicOrderedItem> musicList, boolean isInit) {
                int musicSize = musicList.size();
                SpannableString sb = new SpannableString("已点" + musicSize + "首歌");
                ForegroundColorSpan span = new ForegroundColorSpan(Color.parseColor("#337EFF"));
                sb.setSpan(span, 2, sb.length() - 2, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                tvMusicNum.setText(sb);
            }

            @Override
            public void onSongChange(MusicOrderedItem music, boolean isMy, boolean isInit) {

            }

            @Override
            public void onError(String msg) {

            }
        };
        MusicSing.shareInstance().addMusicChangeListener(musicChangeListener);
    }

    @Override
    protected void initParams() {
        Window window = getDialog().getWindow();
        if (window != null) {
            window.setBackgroundDrawableResource(R.drawable.shape_utils_dialog_bg);

            WindowManager.LayoutParams params = window.getAttributes();
            params.gravity = Gravity.BOTTOM;
            // 使用ViewGroup.LayoutParams，以便Dialog 宽度充满整个屏幕
            params.width = ViewGroup.LayoutParams.MATCH_PARENT;
            params.height = ScreenUtils.getScreenHeight() *3/4;
            window.setAttributes(params);

        }
        setCancelable(true);//设置点击外部是否消失
    }


    /**
     * 跳转到已点歌曲
     */
    private void goToOrderedMusicList() {
        if (orderedMusicDialog == null) {
            orderedMusicDialog = new OrderedMusicDialog();
        }
        orderedMusicDialog.setUser(user);
        orderedMusicDialog.show(getChildFragmentManager(), orderedMusicDialog.TAG);
    }

    public void setUser(VoiceRoomUser user) {
        this.user = user;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        MusicSing.shareInstance().removeMusicChangeListener(musicChangeListener);
    }
}

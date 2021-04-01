package com.netease.audioroom.demo.dialog;

import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.blankj.utilcode.util.ScreenUtils;
import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.adapter.MusicOrderedAdapter;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicChangeListener;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicOrderedItem;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;

import java.util.ArrayList;
import java.util.List;

/**
 * 已点歌单dialog
 */
public class OrderedMusicDialog extends BaseBottomDialogFragment{

    /**
     * 已点歌曲数量
     */
    private TextView tvMusicNum;

    /**
     * 右侧箭头
     */
    private ImageView ivLeftArrow;

    /**
     * 歌单列表
     */
    private RecyclerView rcvMusicOrder;

    private MusicOrderedAdapter musicOrderedAdapter;

    private VoiceRoomUser user;

    private MusicChangeListener musicChangeListener;

    @Override
    protected int getResourceLayout() {
        return R.layout.dialog_ordered_music_layout;
    }

    @Override
    protected void initView(View rootView) {
        tvMusicNum = rootView.findViewById(R.id.tv_ordered_num);
        ivLeftArrow = rootView.findViewById(R.id.iv_left_icon);
        rcvMusicOrder = rootView.findViewById(R.id.rcv_music);
        ivLeftArrow.setOnClickListener(v -> goBack());
    }

    @Override
    protected void initData() {
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getContext());
        rcvMusicOrder.setLayoutManager(linearLayoutManager);
        musicOrderedAdapter = new MusicOrderedAdapter(new ArrayList<>(), getContext(), user);
        rcvMusicOrder.setAdapter(musicOrderedAdapter);

        musicChangeListener = new MusicChangeListener() {
            @Override
            public void onListChange(List<MusicOrderedItem> musicList, boolean isInit) {
                if (musicList != null) {
                    musicOrderedAdapter.setItems(musicList);
                    tvMusicNum.setText("已点歌曲(" + musicList.size() + ")");
                }
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

    public void setUser(VoiceRoomUser user) {
        this.user = user;
    }

    /**
     * 跳转到已点歌曲
     */
    private void goBack() {
        dismiss();
    }

    @Override
    public void onDestroy() {
        MusicSing.shareInstance().removeMusicChangeListener(musicChangeListener);
        super.onDestroy();
    }
}

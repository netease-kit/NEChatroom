package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.ChatRoomMoreDialog;
import com.netease.audioroom.demo.dialog.ListItemDialog;
import com.netease.audioroom.demo.dialog.NotificationDialog;
import com.netease.audioroom.demo.dialog.TopTipsDialog;
import com.netease.audioroom.demo.util.Network;
import com.netease.audioroom.demo.util.NetworkChange;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudiencePlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.disposables.Disposable;
import io.reactivex.subjects.PublishSubject;

/**
 * 观众页
 */
public class AudienceActivity extends VoiceRoomBaseActivity implements Audience.Callback {
    private static final List<ChatRoomMoreDialog.MoreItem> MORE_ITEMS = Arrays.asList(
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_MICRO_PHONE, R.drawable.selector_more_micro_phone_status, "麦克风"),
//            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_SPEAKER, R.drawable.selector_more_speaker_status, "扬声器"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_EAR_BACK, R.drawable.selector_more_ear_back_status, "耳返"),
            new ChatRoomMoreDialog.MoreItem(MORE_ITEM_MIXER, R.drawable.icon_room_more_mixer, "调音台")
    );

    private TopTipsDialog topTipsDialog;
    private ImageView ivLeaveSeat;
    private Audience audience;

    private final PublishSubject<VoiceRoomSeat> seatSource = PublishSubject.create();

    private Disposable disposable;

    private ListItemDialog cancelApplyDialog;

    public static void start(Context context, VoiceRoomInfo model) {
        Intent intent = new Intent(context, AudienceActivity.class);
        intent.putExtra(EXTRA_VOICE_ROOM_INFO, model);
        context.startActivity(intent);
        if (context instanceof Activity) {
            ((Activity) context).overridePendingTransition(R.anim.in_from_right, R.anim.out_from_left);
        }
    }

    @Override
    protected int getContentViewID() {
        return R.layout.activity_audience;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        enterRoom(false);
        watchNetWork();

        disposable = seatSource.serialize().throttleFirst(1, TimeUnit.SECONDS)
                .subscribe(this::doOnSeatItemClick, Throwable::printStackTrace);
    }

    private void watchNetWork() {
        NetworkChange.getInstance().getNetworkLiveData().observeInitAware(this, network -> {
            if (network != null && network.isConnected()) {
                if (topTipsDialog != null) {
                    topTipsDialog.dismiss();
                }
                loadSuccess();
                if (audience != null) {
                    audience.restartAudioOrNot();
                    audience.refreshSeat();
                }
                /// not need, because im auto try login, observe online status
//                LoginManager loginManager = LoginManager.getInstance();
//                loginManager.tryLogin();
//                loginManager.setCallback(new LoginManager.Callback() {
//
//                    @Override
//                    public void onSuccess(AccountInfo accountInfo) {
//                        //                        enterChatRoom(voiceRoomInfo.getRoomId());
//                    }
//
//                    @Override
//                    public void onFailed(int code, String errorMsg) {
//                        showError();
//                    }
//                });
            } else {
                Bundle bundle = new Bundle();
                topTipsDialog = new TopTipsDialog();
                TopTipsDialog.Style style = topTipsDialog.new Style("网络断开", 0, R.drawable.neterrricon, 0);
                bundle.putParcelable(topTipsDialog.TAG, style);
                topTipsDialog.setArguments(bundle);
                if (!topTipsDialog.isVisible()) {
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                }
                showNetError();
            }
        });
    }

    @Override
    protected void setupBaseView() {
        singView.setAnchor(false);
        ivLeaveSeat = findViewById(R.id.iv_leave_seat);
        ivLeaveSeat.setOnClickListener(view -> promptLeaveSeat());
        more.setVisibility(View.GONE);
        updateAudioSwitchVisible(false);
    }

    @Override
    protected void doLeaveRoom() {
        if (!voiceRoomInfo.isSupportCDN()) {
            super.doLeaveRoom();
            return;
        }
        VoiceRoomSeat seat = audience.getSeat();
        boolean isInChannel = seat != null && seat.isOn();
        super.doLeaveRoom();
        if (isInChannel) {
            return;
        }
        finish();
    }

    @Override
    protected synchronized void onSeatItemClick(VoiceRoomSeat seat, int position) {
        seatSource.onNext(seat);
    }

    private void doOnSeatItemClick(VoiceRoomSeat seat) {
        switch (seat.getStatus()) {
            case Status.INIT:
            case Status.FORBID:
                if (checkMySeat()) {
                    applySeat(seat);
                }
                break;
            case Status.APPLY:
                ToastHelper.showToast("该麦位正在被申请,\n请尝试申请其他麦位");
                break;
            case Status.ON:
            case Status.AUDIO_MUTED:
            case Status.AUDIO_CLOSED:
            case Status.AUDIO_CLOSED_AND_MUTED:
                if (seat.isSameAccount(DemoCache.getAccountId())) {
                    promptLeaveSeat();
                } else {
                    ToastHelper.showToast("当前麦位有人");
                }
                break;
            case Status.CLOSED:
                ToastHelper.showToast("该麦位已被关闭");
                break;
        }
    }

    @Override
    protected boolean onSeatItemLongClick(VoiceRoomSeat model, int position) {
        return false;
    }

    private boolean checkMySeat() {
        VoiceRoomSeat seat = audience.getSeat();
        if (seat != null) {
            if (seat.getStatus() == Status.CLOSED) {
                ToastHelper.showToast("麦位已关闭");
            } else if (seat.isOn()) {
                ToastHelper.showToast("您已在麦上");
            } else {
                return true;
            }
            return false;
        }
        return true;
    }

    public void applySeat(VoiceRoomSeat seat) {
        audience.applySeat(seat, new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                onApplySeatSuccess();
            }

            @Override
            public void onFailed(int i) {
                ToastHelper.showToast("请求连麦失败 ， code = " + i);
            }

            @Override
            public void onException(Throwable throwable) {
                ToastHelper.showToast("请求连麦异常 ， e = " + throwable);
            }
        });
    }

    private boolean canShowTip = false;
    private void onApplySeatSuccess() {
        Bundle bundle = new Bundle();
        topTipsDialog = new TopTipsDialog();
        TopTipsDialog.Style style = topTipsDialog.new Style("已申请上麦，等待通过...  <font color=\"#0888ff\">取消</color>", 0, 0,
                                                            0);
        bundle.putParcelable(topTipsDialog.TAG, style);
        topTipsDialog.setArguments(bundle);
        topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
        canShowTip = true;
        topTipsDialog.setClickListener(() -> {
            topTipsDialog.dismiss();
            if (cancelApplyDialog!=null&&cancelApplyDialog.isShowing()){
                cancelApplyDialog.dismiss();
            }
            cancelApplyDialog = new ListItemDialog(AudienceActivity.this).setOnItemClickListener(item -> {
                if ("确认取消申请上麦".equals(item)) {
                    cancelSeatApply();
                    canShowTip = false;
                }
            });
            cancelApplyDialog.setOnDismissListener(dialog1 -> {
                if (canShowTip){
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                }
            });
            cancelApplyDialog.show(Arrays.asList("确认取消申请上麦", "取消"));
        });
    }

    public void cancelSeatApply() {
        audience.cancelSeatApply(new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                ToastHelper.showToast("已取消申请上麦");
            }

            @Override
            public void onFailed(int i) {
                ToastHelper.showToast("操作失败");
            }

            @Override
            public void onException(Throwable throwable) {
                ToastHelper.showToast("操作失败");
            }
        });
    }

    private void leaveSeat() {
        audience.leaveSeat(new SuccessCallback<Void>() {
            @Override
            public void onSuccess(Void aVoid) {
                ToastHelper.showToast("您已下麦");
            }
        });

    }

    public void hintSeatState(VoiceRoomSeat seat, boolean on) {
        if (on) {
            Bundle bundle = new Bundle();
            switch (seat.getReason()) {
                case Reason.ANCHOR_INVITE: {
                    int position = seat.getIndex() + 1;
                    new NotificationDialog(AudienceActivity.this)
                            .setTitle("通知")
                            .setContent("您已被主播抱上“麦位”" + position + "\n" +
                                    "现在可以进行语音互动啦\n" +
                                    "如需下麦，可点击自己的头像或下麦按钮")
                            .setPositive("知道了", v -> {
                                canShowTip = false;
                                if (cancelApplyDialog != null && cancelApplyDialog.isShowing()) {
                                    cancelApplyDialog.dismiss();
                                }
                                if (topTipsDialog != null) {
                                    topTipsDialog.dismiss();
                                }
                            })
                            .show();
                    break;
                }
                //主播同意上麦
                case Reason.ANCHOR_APPROVE_APPLY: {
                    canShowTip = false;
                    if (cancelApplyDialog != null && cancelApplyDialog.isShowing()) {
                        cancelApplyDialog.dismiss();
                    }
                    if (topTipsDialog != null) {
                        topTipsDialog.dismiss();
                    }
                    TopTipsDialog topTipsDialog = new TopTipsDialog();
                    TopTipsDialog.Style style = topTipsDialog.new Style("申请通过!",
                            R.color.color_00000000,
                            R.drawable.right,
                            R.color.color_000000);
                    bundle.putParcelable(topTipsDialog.TAG, style);
                    topTipsDialog.setArguments(bundle);
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                    new Handler(Looper.getMainLooper()).postDelayed(topTipsDialog::dismiss, 2000); // 延时2秒
                    break;
                }
                case Reason.CANCEL_MUTED: {
                    new NotificationDialog(this)
                            .setTitle("通知")
                            .setContent( "该麦位被主播“解除语音屏蔽”\n" +
                                    "现在您可以再次进行语音互动了")
                            .setPositive("知道了",null)
                            .show();
                    break;
                }
                default:{
                }
            }
            if (topTipsDialog != null) {
                topTipsDialog.dismiss();
            }
        } else {
            if (topTipsDialog != null) {
                topTipsDialog.dismiss();
            }

            if (seat.getReason() == Reason.ANCHOR_KICK) {
                new NotificationDialog(this)
                        .setTitle("通知")
                        .setContent("您已被主播请下麦位")
                        .setPositive("知道了",null)
                        .show();
            }
        }
    }

    private void promptLeaveSeat() {
        if (audience.getSeat() == null) {
            return;
        }
        new ListItemDialog(AudienceActivity.this)
                .setOnItemClickListener(item -> {
                    if ("下麦".equals(item)) {
                        leaveSeat();
                    }
                }).show(Arrays.asList("下麦", "取消"));
    }

    private void updateAudioSwitchVisible(boolean visible) {
        ivSettingSwitch.setVisibility(visible ? View.VISIBLE : View.GONE);
        ivLocalAudioSwitch.setVisibility(visible ? View.VISIBLE : View.GONE);
        ivLeaveSeat.setVisibility(visible ? View.VISIBLE : View.GONE);
        more.setVisibility(visible ? View.VISIBLE : View.GONE);
        MORE_ITEMS.get(MORE_ITEM_MICRO_PHONE).setVisible(visible);
        MORE_ITEMS.get(MORE_ITEM_EAR_BACK).setVisible(visible);
        MORE_ITEMS.get(MORE_ITEM_MIXER).setVisible(visible);
    }

    @NonNull
    @Override
    protected List<ChatRoomMoreDialog.MoreItem> getMoreItems() {
        MORE_ITEMS.get(MORE_ITEM_MICRO_PHONE).setEnable(!voiceRoom.isLocalAudioMute());
        MORE_ITEMS.get(MORE_ITEM_EAR_BACK).setEnable(!voiceRoom.isEarBackEnable());
//        MORE_ITEMS.get(MORE_ITEM_SPEAKER).setEnable(!voiceRoom.isRoomAudioMute());
        return MORE_ITEMS;
    }

    @Override
    protected ChatRoomMoreDialog.OnItemClickListener getMoreItemClickListener() {
        return onMoreItemClickListener;
    }

    @Override
    protected void initVoiceRoom() {
        super.initVoiceRoom();
        audience = voiceRoom.getAudience();
        audience.setCallback(this);
        audience.getAudiencePlay().registerNotify(new AudiencePlay.PlayerNotify() {
            @Override
            public void onPreparing() {
            }

            @Override
            public void onPlaying() {
            }

            @Override
            public void onError() {
                if (Network.getInstance().isConnected()) {
                    ToastHelper.showToastLong("主播网络好像出了问题");
                }
            }
        });
    }

    //
    // Audience callback
    //

    @Override
    public void onSeatApplyDenied(boolean otherOn) {
        if (otherOn) {
            ToastHelper.showToast("申请麦位已被拒绝");
            if (topTipsDialog != null) {
                topTipsDialog.dismiss();
            }
        } else {

            new NotificationDialog(this)
                    .setTitle("通知")
                    .setContent("您的申请已被拒绝")
                    .setPositive("知道了", v -> {
                        canShowTip = false;
                        if (cancelApplyDialog != null && cancelApplyDialog.isShowing()) {
                            cancelApplyDialog.dismiss();
                        }
                        if (topTipsDialog != null && getSupportFragmentManager() != null) {
                            topTipsDialog.dismiss();
                        }
                    })
                    .show();
        }
    }

    @Override
    public void onEnterSeat(VoiceRoomSeat seat, boolean last) {
        updateAudioSwitchVisible(true);
        if (!last) {
            hintSeatState(seat, true);
        }
    }

    @Override
    public void onLeaveSeat(VoiceRoomSeat seat, boolean bySelf) {
        updateAudioSwitchVisible(false);

        if (!bySelf) {
            hintSeatState(seat, false);
        }
    }

    @Override
    public void onSeatMuted() {
        if (topTipsDialog != null) {
            topTipsDialog.dismiss();
        }
        new NotificationDialog(this)
                .setTitle("通知")
                .setContent("该麦位被主播“屏蔽语音”\n 现在您已无法进行语音互动")
                .setPositive("知道了",null)
                .show();
    }

    @Override
    public void onSeatClosed() {
        if (topTipsDialog != null) {
            topTipsDialog.dismiss();
        }
    }

    @Override
    public void onTextMuted(boolean muted) {
        tvInput.setEnabled(!muted);
        if (muted) {
            tvInput.setHint("您已被禁言");
            tvInput.setFocusable(false);
            ToastHelper.showToast("您已被禁言");
        } else {
            tvInput.setHint("一起聊聊吧~");
            tvInput.requestFocus();
            ToastHelper.showToast("您的禁言被解除");
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (disposable != null && !disposable.isDisposed()) {
            disposable.dispose();
        }
    }
}

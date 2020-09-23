package com.netease.audioroom.demo.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.ImageView;

import androidx.annotation.Nullable;

import com.netease.audioroom.demo.R;
import com.netease.audioroom.demo.base.LoginManager;
import com.netease.audioroom.demo.base.action.INetworkReconnection;
import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.dialog.BottomMenuDialog;
import com.netease.audioroom.demo.dialog.TipsDialog;
import com.netease.audioroom.demo.dialog.TopTipsDialog;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.ToastHelper;
import com.netease.audioroom.demo.widget.unitepage.loadsir.callback.ErrorCallback;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.util.ArrayList;

import static com.netease.audioroom.demo.dialog.BottomMenuDialog.BOTTOMMENUS;

/**
 * 观众页
 */
public class AudienceActivity extends VoiceRoomBaseActivity implements Audience.Callback {
    private TopTipsDialog topTipsDialog;
    private BottomMenuDialog bottomMenuDialog;

    private ImageView ivLeaveSeat;

    private Audience audience;

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
    }

    @Override
    protected void onResume() {
        super.onResume();
        setNetworkReconnection(new INetworkReconnection() {
            @Override
            public void onNetworkReconnection() {
                if (topTipsDialog != null) {
                    topTipsDialog.dismiss();
                }
                LoginManager loginManager = LoginManager.getInstance();
                loginManager.tryLogin();
                loginManager.setCallback(new LoginManager.Callback() {
                    @Override
                    public void onSuccess(AccountInfo accountInfo) {
//                        enterChatRoom(voiceRoomInfo.getRoomId());
                    }

                    @Override
                    public void onFailed(int code, String errorMsg) {
                        loadService.showCallback(ErrorCallback.class);

                    }
                });

            }

            @Override
            public void onNetworkInterrupt() {
                Bundle bundle = new Bundle();
                topTipsDialog = new TopTipsDialog();
                TopTipsDialog.Style style = topTipsDialog.new Style(
                        "网络断开",
                        0,
                        R.drawable.neterrricon,
                        0);
                bundle.putParcelable(topTipsDialog.TAG, style);
                topTipsDialog.setArguments(bundle);
                if (!topTipsDialog.isVisible()) {
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                }

            }
        });
    }

    @Override
    protected void setupBaseView() {
        ivLeaveSeat = findViewById(R.id.iv_leave_seat);
        ivLeaveSeat.setOnClickListener(view -> promptLeaveSeat());
        updateAudioSwitchVisible(false);
    }

    @Override
    protected void onSeatItemClick(VoiceRoomSeat seat, int position) {
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
            } else {
                ToastHelper.showToast("您已在麦上");
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

    private void onApplySeatSuccess() {
        Bundle bundle = new Bundle();
        topTipsDialog = new TopTipsDialog();
        TopTipsDialog.Style style = topTipsDialog.new Style(
                "已申请上麦，等待通过...  <font color=\"#0888ff\">取消</color>",
                0,
                0,
                0);
                    bundle.putParcelable(topTipsDialog.TAG, style);
                    topTipsDialog.setArguments(bundle);
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                    topTipsDialog.setClickListener(() -> {
            topTipsDialog.dismiss();
            bottomMenuDialog = new BottomMenuDialog();
            Bundle bundle1 = new Bundle();
            ArrayList<String> mune = new ArrayList<>();
            mune.add("<font color=\"#ff4f4f\">确认取消申请上麦</color>");
            mune.add("取消");
            bundle1.putStringArrayList(BOTTOMMENUS, mune);
            bottomMenuDialog.setArguments(bundle1);
            bottomMenuDialog.show(getSupportFragmentManager(), bottomMenuDialog.TAG);
            bottomMenuDialog.setItemClickListener((d, p) -> {
                switch (d.get(p)) {
                    case "<font color=\"#ff4f4f\">确认取消申请上麦</color>":
                        cancelSeatApply();
                        if (bottomMenuDialog.isVisible()) {
                            bottomMenuDialog.dismiss();
                        }
                        break;
                    case "取消":
                        if (bottomMenuDialog.isVisible()) {
                            bottomMenuDialog.dismiss();
                        }
                        VoiceRoomSeat seat = audience.getSeat();
                        if (seat != null && seat.getStatus() == Status.APPLY) {
                            topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                        }
                        break;
                }
            });
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
                    TipsDialog tipsDialog = new TipsDialog();
                    bundle.putString(tipsDialog.TAG,
                            "您已被主播抱上“麦位”" + position + "\n" +
                                    "现在可以进行语音互动啦\n" +
                                    "如需下麦，可点击自己的头像或下麦按钮");
                    tipsDialog.setArguments(bundle);
                    tipsDialog.show(getSupportFragmentManager(), tipsDialog.TAG);
                    tipsDialog.setClickListener(() -> {
                        tipsDialog.dismiss();
                        if (topTipsDialog != null) {
                            topTipsDialog.dismiss();
                        }
                    });
                    break;
                }
                //主播同意上麦
                case Reason.ANCHOR_APPROVE_APPLY: {
                    TopTipsDialog topTipsDialog = new TopTipsDialog();
                    TopTipsDialog.Style style = topTipsDialog.new Style("申请通过!",
                            R.color.color_0888ff,
                            R.drawable.right,
                            R.color.color_ffffff);
                    bundle.putParcelable(topTipsDialog.TAG, style);
                    topTipsDialog.setArguments(bundle);
                    topTipsDialog.show(getSupportFragmentManager(), topTipsDialog.TAG);
                    new Handler().postDelayed(() -> topTipsDialog.dismiss(), 2000); // 延时2秒
                    break;
                }
                case Reason.CANCEL_MUTED: {
                    TipsDialog tipsDialog = new TipsDialog();
                    bundle.putString(tipsDialog.TAG,
                            "该麦位被主播“解除语音屏蔽”\n" +
                                    "现在您可以再次进行语音互动了");
                    tipsDialog.setArguments(bundle);
                    tipsDialog.show(getSupportFragmentManager(), tipsDialog.TAG);
                    tipsDialog.setClickListener(() -> tipsDialog.dismiss());
                    break;
                }
                default:;
            }
            if (topTipsDialog != null) {
                topTipsDialog.dismiss();
            }
            if (bottomMenuDialog != null) {
                bottomMenuDialog.dismiss();
            }
        } else {
            if (topTipsDialog != null) {
                topTipsDialog.dismiss();
            }

            if (seat.getReason() == Reason.ANCHOR_KICK) {
                TipsDialog tipsDialog = new TipsDialog();
                Bundle bundle = new Bundle();
                bundle.putString(tipsDialog.TAG, "您已被主播请下麦位");
                tipsDialog.setArguments(bundle);
                tipsDialog.show(getSupportFragmentManager(), tipsDialog.TAG);
                tipsDialog.setClickListener(() -> tipsDialog.dismiss());
            }
        }
    }

    private void promptLeaveSeat() {
        if (audience.getSeat() == null) {
            return;
        }
        BottomMenuDialog bottomMenuDialog = new BottomMenuDialog();
        Bundle bundle = new Bundle();
        ArrayList<String> items = new ArrayList<>();
        items.add("<font color=\"#ff4f4f\">下麦</color>");
        items.add("取消");
        bundle.putStringArrayList(BOTTOMMENUS, items);
        bottomMenuDialog.setArguments(bundle);
        bottomMenuDialog.show(getSupportFragmentManager(), bottomMenuDialog.TAG);
        bottomMenuDialog.setItemClickListener((d, p) -> {
            switch (d.get(p)) {
                case "<font color=\"#ff4f4f\">下麦</color>":
                    leaveSeat();
                    if (bottomMenuDialog.isVisible()) {
                        bottomMenuDialog.dismiss();
                    }
                    break;
                case "取消":
                    if (bottomMenuDialog.isVisible()) {
                        bottomMenuDialog.dismiss();
                    }
                    break;
            }
        });
    }

    private void updateAudioSwitchVisible(boolean enable) {
        ivLocalAudioSwitch.setVisibility(enable ? View.VISIBLE : View.GONE);
        ivLeaveSeat.setVisibility(enable ? View.VISIBLE : View.GONE);
    }

    @Override
    protected void initVoiceRoom() {
        super.initVoiceRoom();
        audience = voiceRoom.getAudience();
        audience.setCallback(this);
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
            if (bottomMenuDialog != null) {
                bottomMenuDialog.dismiss();
            }
        } else {
            TipsDialog tipsDialog = new TipsDialog();
            Bundle bundle = new Bundle();
            bundle.putString(tipsDialog.TAG, "您的申请已被拒绝");
            tipsDialog.setArguments(bundle);
            tipsDialog.show(getSupportFragmentManager(), "TipsDialog");
            tipsDialog.setClickListener(() -> {
                tipsDialog.dismiss();
                if (topTipsDialog != null && getSupportFragmentManager() != null) {
                    topTipsDialog.dismiss();
                }
            });
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
        TipsDialog tipsDialog = new TipsDialog();
        Bundle bundle = new Bundle();
        bundle.putString(tipsDialog.TAG,
                "该麦位被主播“屏蔽语音”\n 现在您已无法进行语音互动");
        tipsDialog.setArguments(bundle);
        tipsDialog.show(getSupportFragmentManager(), tipsDialog.TAG);
        tipsDialog.setClickListener(() -> tipsDialog.dismiss());
    }

    @Override
    public void onSeatClosed() {
        if (topTipsDialog != null) {
            topTipsDialog.dismiss();
        }
    }

    @Override
    public void onTextMuted(boolean muted) {
        if (muted) {
            edtInput.setHint("您已被禁言");
            edtInput.setFocusable(false);
            edtInput.setFocusableInTouchMode(false);
            sendButton.setClickable(false);
            ToastHelper.showToast("您已被禁言");
        } else {
            edtInput.setHint("唠两句~");
            edtInput.setFocusableInTouchMode(true);
            edtInput.setFocusable(true);
            edtInput.requestFocus();
            sendButton.setClickable(true);
            ToastHelper.showToast("您的禁言被解除");
        }
    }
}

package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import androidx.annotation.NonNull;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMember;
import com.netease.nimlib.sdk.chatroom.model.EnterChatRoomResultData;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.model.CustomNotification;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Reason;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.util.DoneCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.util.RequestCallbackEx;

import java.util.List;

class AudienceImpl implements Audience {
    private final NERtcVoiceRoomInner voiceRoom;

    /**
     * 消息服务
     */
    private final MsgService msgService;

    /**
     * 房间信息
     */
    private VoiceRoomInfo voiceRoomInfo;

    /**
     * 资料信息
     */
    private VoiceRoomUser user;

    /**
     * 当前麦位
     */
    private VoiceRoomSeat mySeat;

    /**
     * 观众回调
     */
    private Callback callback;

    AudienceImpl(NERtcVoiceRoomImpl voiceRoom) {
        this.voiceRoom = voiceRoom;
        this.msgService = NIMClient.getService(MsgService.class);
    }

    @Override
    public void setCallback(Callback callback) {
        this.callback = callback;
    }

    @Override
    public void applySeat(VoiceRoomSeat seat, final RequestCallback<Void> callback) {
        mySeat = seat;

        sendNotification(SeatCommands.applySeat(voiceRoomInfo, user, seat), new RequestCallback<Void>() {
            @Override
            public void onSuccess(Void param) {
                if (mySeat == null) {
                    return;
                }

                VoiceRoomSeat q = voiceRoom.getSeat(mySeat.getIndex());
                if (q.getStatus() == Status.CLOSED) {
                    mySeat.setStatus(Status.CLOSED);
                    voiceRoom.updateSeat(mySeat);
                    return;
                }
                mySeat.setStatus(Status.APPLY);

                if (callback != null) {
                    callback.onSuccess(param);
                }
            }

            @Override
            public void onFailed(int code) {
                if (callback != null) {
                    callback.onFailed(code);
                }
            }

            @Override
            public void onException(Throwable exception) {
                if (callback != null) {
                    callback.onException(exception);
                }
            }
        });
    }

    @Override
    public void cancelSeatApply(RequestCallback<Void> callback) {
        VoiceRoomSeat seat = mySeat;
        if (seat.getStatus() == Status.CLOSED) {
            return;
        }
        seat.setReason(Reason.CANCEL_APPLY);
        sendNotification(SeatCommands.cancelSeatApply(voiceRoomInfo, user, mySeat), new RequestCallbackEx<Void>(callback) {
            @Override
            public void onSuccess(Void param) {
                mySeat = null;

                super.onSuccess(param);
            }
        });
    }

    @Override
    public void leaveSeat(RequestCallback<Void> callback) {
        if (mySeat == null) {
            return;
        }
        mySeat.setReason(Reason.LEAVE);
        sendNotification(SeatCommands.leaveSeat(voiceRoomInfo, user, mySeat), new RequestCallbackEx<Void>(callback) {
            @Override
            public void onSuccess(Void param) {
                onLeaveSeat(mySeat, true);
                mySeat = null;

                super.onSuccess(param);
            }
        });
    }

    @Override
    public VoiceRoomSeat getSeat() {
        return mySeat != null ? voiceRoom.getSeat(mySeat.getIndex()) : null;
    }

    void enterRoom(VoiceRoomInfo voiceRoomInfo,
                   VoiceRoomUser user,
                   EnterChatRoomResultData result) {
        this.voiceRoomInfo = voiceRoomInfo;
        this.user = user;
        clearSeats();
        ChatRoomMember member = result.getMember();
        ChatRoomInfo roomInfo = result.getRoomInfo();
        if (roomInfo.isMute() ||
                member.isTempMuted() || member.isMuted()) {
            muteText(true);
        }
    }

    boolean leaveRoom(Runnable runnable) {
        if (mySeat == null) {
            return false;
        }
        leaveSeat(new DoneCallback<Void>(runnable));
        return true;
    }

    void updateRoomInfo(ChatRoomInfo roomInfo) {
        if (roomInfo.isMute()) {
            muteText(true);
        }
    }

    void updateMemberInfo(@NonNull ChatRoomMember member) {
        if (!member.isTempMuted() && !member.isMuted()) {
            muteText(false);
        }
    }

    void initSeats(@NonNull List<VoiceRoomSeat> seats) {
        VoiceRoomSeat seat = VoiceRoomSeat.find(seats, user.account);
        if (seat != null && seat.isOn()) {
            mySeat = seat;
            onEnterSeat(seat, true);
        }
    }

    void clearSeats() {
        mySeat = null;
    }

    void seatChange(VoiceRoomSeat seat){
        // my seat is 'STATUS_CLOSE'
        if (seat.getStatus() == Status.CLOSED
                && mySeat != null && mySeat.isSameIndex(seat)) {
            mySeat = null;
            if (callback != null) {
                callback.onSeatClosed();
            }
            return;
        }

        // others
        if (!seat.isSameAccount(user.account)) {
            // my seat is 'STATUS_NORMAL' by other
            if (seat.getStatus() == Status.ON
                    && mySeat != null && mySeat.isSameIndex(seat)) {
                mySeat = null;
                if (callback != null) {
                    callback.onSeatApplyDenied(true);
                }
            }
        } else {
            switch (seat.getStatus()) {
                case Status.ON:
                    mySeat = seat;
                    onEnterSeat(seat, false);
                    break;
                case Status.AUDIO_MUTED:
                    mySeat = seat;
                    muteSeat();
                    break;
                case Status.INIT:
                case Status.FORBID:
                    if (seat.getReason() == Reason.ANCHOR_DENY_APPLY) {
                        if (callback != null) {
                            callback.onSeatApplyDenied(false);
                        }
                    } else if (seat.getReason() == Reason.ANCHOR_KICK) {
                        onLeaveSeat(seat, false);
                    }
                    mySeat = null;
                    break;
                case Status.CLOSED:
                    if (mySeat != null && mySeat.getStatus() == Status.APPLY) {
                        if (callback != null) {
                            callback.onSeatApplyDenied(false);
                        }
                    } else {
                        if (seat.getReason() == Reason.ANCHOR_KICK) {
                            onLeaveSeat(seat, false);
                        }
                    }
                    mySeat = null;
                    break;
                case Status.AUDIO_CLOSED:
                case Status.AUDIO_CLOSED_AND_MUTED:
                    mySeat = seat;
                    break;
            }
        }
    }

    void muteLocalAudio(boolean muted) {
        if (mySeat == null) {
            return;
        }
        mySeat.muteSelf();
        voiceRoom.sendSeatUpdate(mySeat, null);
    }

    void muteText(boolean mute) {
        if (callback != null) {
            callback.onTextMuted(mute);
        }
    }

    private void onEnterSeat(VoiceRoomSeat seat, boolean last) {
        voiceRoom.startLocalAudio();
        if (voiceRoom.isLocalAudioMute()) {
            voiceRoom.muteLocalAudio(false);
        }
        if (callback != null) {
            callback.onEnterSeat(seat, last);
        }
    }

    private void onLeaveSeat(VoiceRoomSeat seat, boolean bySelf) {
        voiceRoom.stopLocalAudio();
        if (callback != null) {
            callback.onLeaveSeat(seat, bySelf);
        }
    }

    private void muteSeat() {
        voiceRoom.stopLocalAudio();
        if (callback != null) {
            callback.onSeatMuted();
        }
    }

    private void sendNotification(CustomNotification notification, RequestCallback<Void> callback) {
        if (notification == null) {
            if (callback != null) {
                callback.onException(null);
            }
            return;
        }
        notification.setSendToOnlineUserOnly(false);
        msgService.sendCustomNotification(notification).setCallback(callback);
    }
}

package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.chatroom.ChatRoomService;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomUpdateInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.util.RequestCallbackEx;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

class AnchorImpl implements Anchor {
    private static final int MUTE_DURATION = 30/*day*/
            * 24/*hour*/ * 60/*minute*/ * 60/*second*/;

    private final NERtcVoiceRoomInner voiceRoom;

    /**
     * 聊天室服务
     */
    private final ChatRoomService chatRoomService;

    /**
     * 房间信息
     */
    private VoiceRoomInfo voiceRoomInfo;

    private RoomQuery roomQuery;

    /**
     * 主播回调
     */
    private Callback callback;

    /**
     * 麦位申请
     */
    private final ConcurrentLinkedQueue<VoiceRoomSeat> applySeats = new ConcurrentLinkedQueue<>();

    /**
     * 麦位信息
     */
    private final Map<String, VoiceRoomSeat> seats = new ConcurrentHashMap<>();

    AnchorImpl(NERtcVoiceRoomInner voiceRoom) {
        this.voiceRoom = voiceRoom;
        this.chatRoomService = NIMClient.getService(ChatRoomService.class);
    }

    @Override
    public void setCallback(Callback callback) {
        this.callback = callback;
    }

    @Override
    public boolean approveSeatApply(final VoiceRoomSeat seat, RequestCallback<Void> callback0) {
        if (!seat.approveApply()) {
            return false;
        }
        voiceRoom.sendSeatUpdate(seat, new RequestCallbackEx<Void>(callback0) {
            @Override
            public void onSuccess(Void param) {
                voiceRoom.sendSeatEvent(seat, true);
                removeApplySeat(seat);
                super.onSuccess(param);
            }
        });
        return true;
    }

    @Override
    public void denySeatApply(final VoiceRoomSeat seat, RequestCallback<Void> callback) {
        if (!seat.denyApply()) {
            return;
        }
        voiceRoom.sendSeatUpdate(seat, new RequestCallbackEx<Void>(callback) {
            @Override
            public void onSuccess(Void param) {
                removeApplySeat(seat);

                super.onSuccess(param);
            }
        });
    }

    @Override
    public void openSeat(VoiceRoomSeat seat, RequestCallback<Void> callback) {
        seat.open();
        voiceRoom.sendSeatUpdate(seat, callback);
    }

    @Override
    public void closeSeat(final VoiceRoomSeat seat, RequestCallback<Void> callback) {
        seat.close();
        voiceRoom.sendSeatUpdate(seat, new RequestCallbackEx<Void>(callback) {
            @Override
            public void onSuccess(Void param) {
                removeApplySeat(seat);

                super.onSuccess(param);
            }
        });
    }

    @Override
    public void muteSeat(VoiceRoomSeat seat, RequestCallback<Void> callback) {
        seat.mute();
        voiceRoom.sendSeatUpdate(seat, callback);
    }

    @Override
    public boolean inviteSeat(final VoiceRoomSeat seat, RequestCallback<Void> callback0) {
        if (!seat.invite()) {
            return false;
        }
        voiceRoom.sendSeatUpdate(seat, new RequestCallbackEx<Void>(callback0) {
            @Override
            public void onSuccess(Void param) {
                voiceRoom.sendSeatEvent(seat, true);
                removeApplySeat(seat);
                super.onSuccess(param);
            }
        });
        return true;
    }

    @Override
    public void kickSeat(final VoiceRoomSeat seat, RequestCallback<Void> callback0) {
        seat.kick();
        voiceRoom.sendSeatUpdate(seat, new RequestCallbackEx<Void>(callback0) {
            @Override
            public void onSuccess(Void aVoid) {
                voiceRoom.sendSeatEvent(seat, false);
                super.onSuccess(aVoid);
            }
        });
    }

    @Override
    public void fetchSeats(final RequestCallback<List<VoiceRoomSeat>> callback) {
        voiceRoom.fetchSeats(callback);
    }

    @Override
    public VoiceRoomSeat getSeat(int index) {
        return voiceRoom.getSeat(index);
    }

    @Override
    public List<VoiceRoomSeat> getApplySeats() {
        return new ArrayList<>(applySeats);
    }

    @Override
    public RoomQuery getRoomQuery() {
        return roomQuery;
    }

    void initRoom(VoiceRoomInfo voiceRoomInfo) {
        this.voiceRoomInfo = voiceRoomInfo;
        this.roomQuery = new RoomQuery(voiceRoomInfo, chatRoomService);
    }

    void enterRoom() {
        clearSeats();
        sendMute(false);
        sendRoomMute(false);
    }

    void command(int command, final VoiceRoomSeat seat) {
        switch (command) {
            case SeatCommandDef.APPLY_SEAT: {
                VoiceRoomSeat local = seats.get(seat.getKey());
                if (local != null) {
                    local.setUser(seat.getUser());
                } else {
                    local = seat;
                }
                local.apply();
                if (voiceRoom.getSeat(local.getIndex()).getStatus() == Status.CLOSED) {
                    return;
                }
                voiceRoom.sendSeatUpdate(local, null);
                addApplySeat(seat);
                break;
            }
            case SeatCommandDef.CANCEL_SEAT_APPLY: {
                VoiceRoomSeat local = seats.get(seat.getKey());
                if (local == null) {
                    local = seat;
                }
                local.cancelApply();
                final VoiceRoomSeat tmp = local;
                voiceRoom.sendSeatUpdate(local, new SuccessCallback<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        removeApplySeat(tmp);
                    }
                });
                break;
            }
            case SeatCommandDef.LEAVE_SEAT: {
                final VoiceRoomSeat local = seats.get(seat.getKey());
                if (local != null) {
                    local.leave();
                    voiceRoom.sendSeatUpdate(local, new SuccessCallback<Void>() {
                        @Override
                        public void onSuccess(Void param) {
                            voiceRoom.sendSeatEvent(local, false);
                        }
                    });
                }
                break;
            }
        }
    }

    void memberExit(String account) {
        removeApplySeat(account);

        fetchSeat(account, new SuccessCallback<VoiceRoomSeat>() {
            @Override
            public void onSuccess(VoiceRoomSeat seat) {
                if (seat != null) {
                    if (seat.isOn()) {
                        kickSeat(seat, null);
                    }
                    if (seat.getStatus() == Status.APPLY) {
                        denySeatApply(seat, null);
                    }
                }
            }
        });
    }

    void initSeats(@NonNull List<VoiceRoomSeat> seats) {
        for (VoiceRoomSeat seat : seats) {
            if (!TextUtils.isEmpty(seat.getAccount())) {
                this.seats.put(seat.getKey(), seat);
            }
            if (seat.getStatus() == Status.APPLY) {
                addApplySeat(seat);
            }
        }
    }

    void clearSeats() {
        seats.clear();
        applySeats.clear();
    }

    boolean seatChange(VoiceRoomSeat seat) {
        if (seat.getIndex() != -1) {
            seats.put(seat.getKey(), seat);
        }

        // local STATUS_CLOSE and remote STATUS_LOAD ???
        if (voiceRoom.getSeat(seat.getIndex()).getStatus() == Status.CLOSED
                && seat.getStatus() == Status.APPLY) {
            return false;
        }
        return true;
    }

    void muteLocalAudio(boolean muted) {
        sendMute(muted);
    }

    void muteRoomAudio(boolean muted) {
        sendRoomMute(muted);
    }

    private void sendMute(boolean mute) {
        Map<String, Object> extension = new HashMap<>();
        extension.put(ChatRoomInfoExtKey.ANCHOR_MUTE, mute ? 1 : 0);
        ChatRoomUpdateInfo updateInfo = new ChatRoomUpdateInfo();
        updateInfo.setExtension(extension);
        chatRoomService.updateRoomInfo(voiceRoomInfo.getRoomId(), updateInfo,
                true, extension);
    }

    private void sendRoomMute(boolean mute) {
        Map<String, Object> extension = new HashMap<>();
        extension.put(ChatRoomInfoExtKey.ROOM_VOICE_OPEN, !mute);
        ChatRoomUpdateInfo updateInfo = new ChatRoomUpdateInfo();
        updateInfo.setExtension(extension);
        chatRoomService.updateRoomInfo(voiceRoomInfo.getRoomId(), updateInfo,
                false, null);
    }

    private void fetchSeat(final String account, final RequestCallback<VoiceRoomSeat> callback) {
        voiceRoom.fetchSeats(new RequestCallback<List<VoiceRoomSeat>>() {
            @Override
            public void onSuccess(List<VoiceRoomSeat> seats) {
                if (callback != null) {
                    callback.onSuccess(VoiceRoomSeat.find(seats, account));
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

    private void addApplySeat(VoiceRoomSeat seat) {
        applySeats.add(seat);
        if (callback != null) {
            callback.onApplySeats(new ArrayList<>(applySeats));
        }
    }

    private void removeApplySeat(VoiceRoomSeat seat) {
        if (VoiceRoomSeat.remove(applySeats, seat)) {
            if (callback != null) {
                callback.onApplySeats(new ArrayList<>(applySeats));
            }
        }
    }

    private void removeApplySeat(String account) {
        if (VoiceRoomSeat.remove(applySeats, account)) {
            if (callback != null) {
                callback.onApplySeats(new ArrayList<>(applySeats));
            }
        }
    }
}

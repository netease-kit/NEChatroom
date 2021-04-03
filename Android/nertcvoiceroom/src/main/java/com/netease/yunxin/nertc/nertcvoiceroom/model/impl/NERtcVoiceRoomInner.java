package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;

import java.util.List;

abstract class NERtcVoiceRoomInner extends NERtcVoiceRoom {
    abstract void updateSeat(VoiceRoomSeat seat);

    abstract VoiceRoomSeat getSeat(int index);

    abstract void sendSeatEvent(VoiceRoomSeat seat, boolean enter);

    abstract void sendSeatUpdate(VoiceRoomSeat seat, RequestCallback<Void> callback);

    abstract void fetchSeats(final RequestCallback<List<VoiceRoomSeat>> callback);

    abstract void refreshSeats();

    abstract boolean isInitial();
}

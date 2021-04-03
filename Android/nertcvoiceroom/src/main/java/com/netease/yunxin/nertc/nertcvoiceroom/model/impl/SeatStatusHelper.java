package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import com.netease.nimlib.sdk.RequestCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;

import java.util.List;
import java.util.Objects;

import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.APPLY;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.AUDIO_CLOSED;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.AUDIO_CLOSED_AND_MUTED;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.AUDIO_MUTED;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.CLOSED;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.FORBID;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.INIT;
import static com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status.ON;

/**
 * Created by luc on 2/24/21.
 */
public final class SeatStatusHelper {
    private final NERtcVoiceRoomInner voiceRoomInner;

    public SeatStatusHelper(NERtcVoiceRoomInner voiceRoomInner) {
        this.voiceRoomInner = voiceRoomInner;
    }

    /**
     * 更新麦位动作，true 更新成功，false 更新失败
     * 失败规则：
     * 1. 针对同一麦位
     *
     * @param seat 对应麦位，包含对应麦位用户,麦位状态；
     * @return 是否更新成功
     */
    public void updateSeat(final VoiceRoomSeat seat, final ExecuteAction action) {
        if (seat == null || action == null) {
            return;
        }

        voiceRoomInner.fetchSeats(new RequestCallback<List<VoiceRoomSeat>>() {

            @Override
            public void onSuccess(List<VoiceRoomSeat> param) {
                if (checkSeat(param, seat)) {
                    action.onSuccess();
                } else {
                    action.onFail();
                }
            }

            @Override
            public void onFailed(int code) {
                action.onFail();
            }

            @Override
            public void onException(Throwable exception) {
                action.onFail();
            }
        });
    }

    public boolean checkSeat(List<VoiceRoomSeat> seats, VoiceRoomSeat seat) {
        if (seats == null) {
            return false;
        }
        int destStatus = seat.getStatus();
        boolean result = true;
        for (VoiceRoomSeat item : seats) {
            if (item == null) {
                continue;
            }
            int status = item.getStatus();
            if (item.getUser() != null
                    && !Objects.equals(item.getUser(), seat.getUser())
                    && item.getIndex() == seat.getIndex()
                    && !(status == INIT || status == CLOSED || status == FORBID)) {
                result = false;
                break;
            } else if (Objects.equals(item.getUser(), seat.getUser())
                    && item.getIndex() == seat.getIndex()
                    && !statusCheck(status, destStatus)) {
                result = false;
                break;
            } else if (Objects.equals(item.getUser(), seat.getUser())
                    && item.getIndex() != seat.getIndex()
                    && !(status == INIT || status == CLOSED || status == FORBID)) {
                result = false;
                break;
            }
        }
        return result;
    }

    private boolean statusCheck(int source, int dest) {
        if (source == INIT || dest == INIT) {
            return true;
        }
        if (source == APPLY && (dest == ON || dest == CLOSED || dest == FORBID)) {
            return true;
        }

        if (source == ON && (dest == AUDIO_MUTED || dest == AUDIO_CLOSED || dest == AUDIO_CLOSED_AND_MUTED)) {
            return true;
        }

        if (source == FORBID && (dest == APPLY || dest == ON || dest == AUDIO_MUTED || dest == AUDIO_CLOSED || dest == AUDIO_CLOSED_AND_MUTED)) {
            return true;
        }

        if (source == AUDIO_MUTED && (dest == ON || dest == AUDIO_CLOSED || dest == AUDIO_CLOSED_AND_MUTED || dest == FORBID)) {
            return true;
        }

        if (source == AUDIO_CLOSED && (dest == ON || dest == AUDIO_MUTED || dest == AUDIO_CLOSED_AND_MUTED)) {
            return true;
        }

        if (source == AUDIO_CLOSED_AND_MUTED && (dest == ON || dest == AUDIO_MUTED || dest == AUDIO_CLOSED || dest == FORBID)) {
            return true;
        }

        return false;
    }

    public interface ExecuteAction {
        void onSuccess();

        void onFail();
    }
}

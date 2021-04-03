package com.netease.yunxin.nertc.nertcvoiceroom.model;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.netease.yunxin.nertc.nertcvoiceroom.util.JsonUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

/**
 * 麦位信息
 */
public class VoiceRoomSeat implements Serializable, Parcelable {

    /**
     * 麦位容量
     */
    public static final int SEAT_COUNT = 8;

    public interface Status {
        /**
         * 麦位初始化状态（没人）
         */
        int INIT = 0;
        /**
         * 正在申请（没人）
         */
        int APPLY = 1;
        /**
         * 麦位上有人，且能正常发言（有人）
         */
        int ON = 2;
        /**
         * 麦位关闭（没人）
         */
        int CLOSED = 3;
        /**
         * 麦位上没人，但是被主播屏蔽（没人）
         */
        int FORBID = 4;
        /**
         * 麦位上有人，但是语音被屏蔽（有人）
         */
        int AUDIO_MUTED = 5;
        /**
         * 麦位上有人，但是他关闭了自己的语音（有人）(没有被屏蔽)
         */
        int AUDIO_CLOSED = 6;
        /**
         * 麦位上有人，但是他关闭了自己的语音且主播屏蔽了他
         */
        int AUDIO_CLOSED_AND_MUTED = 7;
    }

    public interface Reason {
        /**
         * 初始
         */
        int INIT = 0;

        /**
         * 主播同意上麦
         */
        int ANCHOR_APPROVE_APPLY = 1;

        /**
         * 主播抱上麦
         */
        int ANCHOR_INVITE = 2;

        /**
         * 主播踢下麦
         */
        int ANCHOR_KICK = 3;

        /**
         * 下麦
         */
        int LEAVE = 4;

        /**
         * 取消申请
         */
        int CANCEL_APPLY = 5;

        /**
         * 主播拒绝申请
         */
        int ANCHOR_DENY_APPLY = 6;

        /**
         * 麦位在屏蔽状态中被申请
         */
        int APPLY_MUTED = 7;

        /**
         * 麦位取消屏蔽状态
         */
        int CANCEL_MUTED = 8;
    }

    private int index = -1;
    private int status = Status.INIT;
    private int reason = Reason.INIT;
    private VoiceRoomUser user;

    public VoiceRoomSeat(int index) {
        this(index, Status.INIT, Reason.INIT, null);
    }

    public VoiceRoomSeat(int index, int status, int reason, VoiceRoomUser user) {
        this.index = index;
        this.status = status;
        this.reason = reason;
        this.user = user;
    }

    private static final String INDEX_PREFIX = "queue_";

    private static String getKeyByIndex(int index) {
        return INDEX_PREFIX + index;
    }

    public static boolean isValidKey(String key) {
        return !TextUtils.isEmpty(key) && key.startsWith(INDEX_PREFIX);
    }

    private static final String KEY_INDEX = "index";
    private static final String KEY_STATUS = "status";
    private static final String KEY_REASON = "reason";
    private static final String KEY_MEMBER = "member";

    public static VoiceRoomSeat fromJson(String json) {
        JSONObject jsonObject = JsonUtil.parse(json);
        if (jsonObject == null) {
            return null;
        }

        int index = jsonObject.optInt(KEY_INDEX, -1);
        int status = jsonObject.optInt(KEY_STATUS, Status.INIT);
        int reason = jsonObject.optInt(KEY_REASON, Reason.INIT);
        VoiceRoomUser user = null;

        {
            jsonObject = jsonObject.optJSONObject(KEY_MEMBER);
            if (jsonObject != null) {
                user = new VoiceRoomUser(jsonObject);
            }
        }

        return new VoiceRoomSeat(index, status, reason, user);
    }

    public JSONObject toJson() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put(KEY_STATUS, status);
            jsonObject.put(KEY_INDEX, index);
            jsonObject.put(KEY_REASON, reason);
            if (user != null) {
                jsonObject.put(KEY_MEMBER, user.toJson());
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject;
    }

    public String toJsonString() {
        return toJson().toString();
    }

    public int getIndex() {
        return index;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public int getReason() {
        return reason;
    }

    public void setReason(int reason) {
        this.reason = reason;
    }

    @Nullable
    public VoiceRoomUser getUser() {
        return user;
    }

    public void setUser(VoiceRoomUser user) {
        this.user = user;
    }

    public String getKey() {
        return getKeyByIndex(index);
    }

    public String getAccount() {
        return user != null ? user.getAccount() : null;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.index);
        dest.writeInt(this.status);
        dest.writeInt(this.reason);
        dest.writeSerializable(this.user);
    }

    protected VoiceRoomSeat(Parcel in) {
        this.index = in.readInt();
        this.status = in.readInt();
        this.reason = in.readInt();
        this.user = (VoiceRoomUser) in.readSerializable();
    }

    public static final Creator<VoiceRoomSeat> CREATOR = new Creator<VoiceRoomSeat>() {
        @Override
        public VoiceRoomSeat createFromParcel(Parcel source) {
            return new VoiceRoomSeat(source);
        }

        @Override
        public VoiceRoomSeat[] newArray(int size) {
            return new VoiceRoomSeat[size];
        }
    };

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        VoiceRoomSeat other = (VoiceRoomSeat) o;
        return index == (other.index);
    }

    @Override
    public int hashCode() {
        return index;
    }

    public final boolean isOn() {
        return status == Status.ON
                || status == Status.AUDIO_MUTED
                || status == Status.AUDIO_CLOSED
                || status == Status.AUDIO_CLOSED_AND_MUTED;
    }

    public void apply() {
        if (status == Status.CLOSED) {
            return;
        }
        if (status == Status.FORBID) {
            reason = Reason.APPLY_MUTED;
        } else {
            reason = Reason.INIT;
        }
        status = Status.APPLY;
    }

    public void muteSelf(boolean muted) {
        switch (status) {
            case Status.AUDIO_CLOSED:
                status = Status.ON;
                reason = Reason.INIT;
                break;
            case Status.AUDIO_CLOSED_AND_MUTED:
                status = Status.AUDIO_MUTED;
                break;
            case Status.AUDIO_MUTED:
                status = Status.AUDIO_CLOSED_AND_MUTED;
                break;
            default:
                if (muted) {
                    status = Status.AUDIO_CLOSED;
                }
                break;
        }
    }

    public void mute() {
        switch (status) {
            case Status.AUDIO_CLOSED:
                status = Status.AUDIO_CLOSED_AND_MUTED;
                break;
            case Status.AUDIO_CLOSED_AND_MUTED:
                status = Status.AUDIO_CLOSED;
                break;
            default:
                if (isOn()) {
                    status = Status.AUDIO_MUTED;
                } else {
                    status = Status.FORBID;
                    reason = Reason.INIT;
                }
                break;
        }
    }

    public void open() {
        switch (status) {
            case Status.CLOSED:
            case Status.FORBID:
                status = Status.INIT;
                break;
            case Status.AUDIO_MUTED:
                status = Status.ON;
                reason = Reason.CANCEL_MUTED;
                break;
            case Status.AUDIO_CLOSED_AND_MUTED:
                status = Status.AUDIO_CLOSED;
                break;
            case Status.AUDIO_CLOSED:
                status = Status.AUDIO_CLOSED_AND_MUTED;
                break;
        }
    }

    public void close() {
        status = Status.CLOSED;
        reason = Reason.INIT;
    }

    public boolean denyApply() {
        if (!isOn() && status != Status.APPLY) {
            return false;
        }
        if (reason == Reason.APPLY_MUTED) {
            status = Status.FORBID;
        } else {
            status = Status.INIT;
        }
        reason = Reason.ANCHOR_DENY_APPLY;
        return true;
    }

    public void cancelApply() {
        if (reason == Reason.APPLY_MUTED) {
            status = Status.FORBID;
        } else {
            status = Status.INIT;
        }
        reason = Reason.CANCEL_APPLY;
    }

    public boolean approveApply() {
        if (status == Status.CLOSED) {
            return false;
        }
        if (isOn()) {
            return false;
        }
        if (reason == Reason.APPLY_MUTED) {
            status = Status.AUDIO_MUTED;
        } else {
            status = Status.ON;
        }
        reason = Reason.ANCHOR_APPROVE_APPLY;
        return true;
    }

    public void kick() {
        if (status == Status.AUDIO_CLOSED_AND_MUTED
                || status == Status.AUDIO_MUTED) {
            status = Status.FORBID;
        } else {
            status = Status.INIT;
        }
        reason = Reason.ANCHOR_KICK;
    }

    public void leave() {
        if (status == Status.AUDIO_MUTED
                || status == Status.AUDIO_CLOSED_AND_MUTED) {
            status = Status.FORBID;
        } else {
            status = Status.INIT;
        }
        reason = Reason.LEAVE;
    }

    public boolean invite() {
        if (status == Status.APPLY) {
            return false;
        }

        if (status == Status.FORBID) {
            status = Status.AUDIO_MUTED;
        } else {
            status = Status.ON;
        }
        reason = Reason.ANCHOR_INVITE;
        return true;
    }

    public boolean isSameIndex(VoiceRoomSeat seat) {
        return seat != null && seat.index == index;
    }

    public boolean isSameAccount(String account) {
        return !TextUtils.isEmpty(account)
                && user != null
                && account.equals(user.getAccount());
    }

    @NonNull
    public static List<VoiceRoomSeat> find(List<VoiceRoomSeat> seats, String account) {
        if (seats == null || seats.isEmpty()) {
            return Collections.emptyList();
        }
        List<VoiceRoomSeat> results = new ArrayList<>(seats.size());
        for (VoiceRoomSeat seat : seats) {
            if (seat.isSameAccount(account)) {
                results.add(seat);
            }
        }
        return results;
    }

    @Nullable
    public static VoiceRoomSeat findByStatus(List<VoiceRoomSeat> seats, String account, int status) {
        List<VoiceRoomSeat> userSeats = find(seats, account);
        if (userSeats.isEmpty()) {
            return null;
        }
        VoiceRoomSeat result = null;
        for (VoiceRoomSeat seat : userSeats) {
            if (seat != null && seat.getStatus() == status) {
                result = seat;
                break;
            }
        }
        return result;
    }

    public static boolean remove(Collection<VoiceRoomSeat> seats, String account) {
        boolean removed = false;
        Iterator<VoiceRoomSeat> it = seats.iterator();
        while (it.hasNext()) {
            VoiceRoomSeat seat = it.next();
            if (seat.isSameAccount(account)) {
                it.remove();
                removed = true;
            }
        }
        return removed;
    }

    public static boolean remove(Collection<VoiceRoomSeat> seats, VoiceRoomSeat seat) {
        return seats.remove(seat);
    }

    public VoiceRoomSeat getBackup() {
        return new VoiceRoomSeat(index, status, reason, user);
    }
}

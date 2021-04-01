package com.netease.yunxin.nertc.nertcvoiceroom.model;

import androidx.annotation.NonNull;

public class VoiceRoomMessage {
    /**
     * 消息类型
     */
    public interface Type {
        /**
         * 普通文本消息
         */
        int TEXT = 1;

        /**
         * 事件消息
         */
        int EVENT = 2;
    }

    public final int type;
    public final String content;
    public final String nick;

    public VoiceRoomMessage(int type, String content, String nick) {
        this.type = type;
        this.content = content;
        this.nick = nick;
    }

    public static VoiceRoomMessage createEventMessage(String content) {
        return new VoiceRoomMessage(Type.EVENT, content, "");
    }

    public static VoiceRoomMessage createTextMessage(String nick, String content) {
        return new VoiceRoomMessage(Type.TEXT, content, nick);
    }

    /**
     * 消息文本构建
     */
    public interface MessageTextBuilder {
        /**
         * 房间事件
         *
         * @param nick 昵称
         * @param enter 进入或退出房间
         * @return text
         */
        String roomEvent(String nick, boolean enter);

        /**
         * 麦位事件
         *
         * @param seat  {@link VoiceRoomSeat 麦位}
         * @param enter 进入或退出麦位
         * @return text
         */
        String seatEvent(VoiceRoomSeat seat, boolean enter);

        /**
         * 音乐控制信息
         *
         * @param nick
         * @param isPause 是否暂停，不暂停就是恢复
         * @return
         */
        String musicEvent(String nick, boolean isPause);
    }

    private static final MessageTextBuilder defaultMessageTextBuilder = new DefaultMessageTextBuilder();

    public static MessageTextBuilder getDefaultMessageTextBuilder() {
        return defaultMessageTextBuilder;
    }

    private static final class DefaultMessageTextBuilder implements MessageTextBuilder {
        @Override
        public String roomEvent(String nick, boolean enter) {
            return (enter ? "enter" : "leave") + " room";
        }

        @Override
        public String seatEvent(@NonNull VoiceRoomSeat seat, boolean enter) {
            return (enter ? "enter" : "leave") + " seat " + (seat.getIndex() + 1);
        }

        @Override
        public String musicEvent(String nick, boolean isPause) {
            return isPause ? "pause" : "resume";
        }
    }
}

package com.netease.audioroom.demo.util;

import android.content.Context;
import android.graphics.Typeface;
import android.widget.TextView;

/**
 * Created by hzsunyj on 2/2/21.
 */
public class IconFontUtil {

    // 房间列表为空
    public static final String ROOM_LIST_EMPTY = "\ue7ed";

    // 下一首
    public static final String NEXT = "\ue7e8";

    // 播放
    public static final String PLAY = "\ue7e9";

    // 暂停
    public static final String PAUSE = "\ue7ea";

    // 音量
    public static final String VOLUME = "\ue7eb";

    // 无数据
    public static final String NO_DATA = "\ue7ec";

    // 耳返开
    public static final String ON_EAR = "\ue7df";

    // 扬声器关
    public static final String LOUDSPEAKER_OFF = "\ue7e0";

    // 笑脸
    public static final String SMILE_FACE = "\ue7e1";

    // 麦克风开
    public static final String MICROPHONE_ON = "\ue7e2";

    // 扬声器开
    public static final String LOUDSPEAKER_ON = "\ue7e3";

    // 调音
    public static final String ADJUST_VOLUME = "\ue7e4";

    // 耳返关
    public static final String OFF_EAR = "\ue7e5";

    // 麦克风关
    public static final String MICROPHONE_OFF = "\ue7e6";

    // 鼓掌
    public static final String HANDCLAP = "\ue7e7";

    // 切换
    public static final String SWITCH = "\ue7dd";

    // 结束
    public static final String FINISH = "\ue7de";

    // 屏蔽
    public static final String FORBIDDEN = "\ue7d5";

    // 锁定
    public static final String LOCK = "\ue7d6";

    // 加号
    public static final String PLUS = "\ue7d7";

    // 更多
    public static final String MOPE = "\ue7d8";

    // 聊天
    public static final String CHAT = "\ue7d9";

    // 禁言
    public static final String MUTE_CHAT = "\ue7da";

    // 麦克风关
    public static final String MICROPHONE_OFF_1 = "\ue7db";

    // 麦克风开
    public static final String MICROPHONE_ON_1 = "\ue7dc";

    // 屏蔽语音
    public static final String MUTE_VOICE = "\ue7d1";

    // 开麦
    public static final String ON_MICROPHONE = "\ue7d2";

    // 关麦
    public static final String OFF_MICROPHONE = "\ue7d3";

    // 演唱中
    public static final String SING = "\ue7d4";

    // 语聊
    public static final String VOICE_CHAT = "\ue7ce";

    // ktv
    public static final String KTV = "\ue7cf";

    // 随机
    public static final String RANDOM = "\ue7d0";

    // 箭头上
    public static final String ARROW_TOP = "\ue7c4";

    // 箭头左
    public static final String ARROW_LEFT = "\ue7c5";

    // 箭头右
    public static final String ARROW_RIGH = "\ue7c6";

    // 音乐
    public static final String MUSIC = "\ue7c7";

    // 公告
    public static final String NOTICE = "\ue7c8";

    // 箭头下
    public static final String ARROW_DOWN = "\ue7c9";

    // 叉号
    public static final String CLOSE = "\ue7ca";

    // 开始直播
    public static final String START_LIVE = "\ue7cb";

    // cdn
    public static final String CDN = "\ue7cc";

    // rtc
    public static final String RTC = "\ue7cd";

    private static IconFontUtil instance;

    public static IconFontUtil getInstance() {
        if (instance == null) {
            instance = new IconFontUtil();
        }
        return instance;
    }

    private Typeface typeface;

    public void init(Context context) {
        typeface = Typeface.createFromAsset(context.getAssets(), "fonts/iconfont.ttf");
    }

    private IconFontUtil() {
    }

    public void setFontText(TextView textView, String fontCode) {
        textView.setTypeface(typeface);
        textView.setText(fontCode);
    }

    public void setFontText(TextView textView, String fontCode, String suffix) {
        textView.setTypeface(typeface);
        textView.setText(fontCode + suffix);
    }
}

package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.blankj.utilcode.util.GsonUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.lava.nertc.sdk.NERtcConstants;
import com.netease.lava.nertc.sdk.NERtcEx;
import com.netease.lava.nertc.sdk.NERtcOption;
import com.netease.lava.nertc.sdk.NERtcParameters;
import com.netease.lava.nertc.sdk.stats.NERtcAudioVolumeInfo;
import com.netease.lava.nertc.sdk.video.NERtcRemoteVideoStreamType;
import com.netease.nimlib.sdk.InvocationFuture;
import com.netease.nimlib.sdk.NIMClient;
import com.netease.nimlib.sdk.Observer;
import com.netease.nimlib.sdk.RequestCallback;
import com.netease.nimlib.sdk.StatusCode;
import com.netease.nimlib.sdk.chatroom.ChatRoomMessageBuilder;
import com.netease.nimlib.sdk.chatroom.ChatRoomService;
import com.netease.nimlib.sdk.chatroom.ChatRoomServiceObserver;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomInfo;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomKickOutEvent;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMember;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomMessage;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomNotificationAttachment;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomQueueChangeAttachment;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomStatusChangeData;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomTempMuteAddAttachment;
import com.netease.nimlib.sdk.chatroom.model.ChatRoomTempMuteRemoveAttachment;
import com.netease.nimlib.sdk.chatroom.model.EnterChatRoomData;
import com.netease.nimlib.sdk.chatroom.model.EnterChatRoomResultData;
import com.netease.nimlib.sdk.msg.MsgService;
import com.netease.nimlib.sdk.msg.MsgServiceObserve;
import com.netease.nimlib.sdk.msg.attachment.MsgAttachment;
import com.netease.nimlib.sdk.msg.constant.ChatRoomQueueChangeType;
import com.netease.nimlib.sdk.msg.constant.MsgTypeEnum;
import com.netease.nimlib.sdk.msg.constant.SessionTypeEnum;
import com.netease.nimlib.sdk.msg.model.CustomNotification;
import com.netease.nimlib.sdk.util.Entry;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Anchor;
import com.netease.yunxin.nertc.nertcvoiceroom.model.Audience;
import com.netease.yunxin.nertc.nertcvoiceroom.model.AudioPlay;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoom;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.AccountMapper;
import com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomCallback;
import com.netease.yunxin.nertc.nertcvoiceroom.model.PushTypeSwitcher;
import com.netease.yunxin.nertc.nertcvoiceroom.model.StreamTaskControl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomMessage;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomSeat.Status;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomUser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CloseRoomAttach;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CustomAttachParser;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.CustomAttachmentType;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.MusicControl;
import com.netease.yunxin.nertc.nertcvoiceroom.model.custom.StreamRestarted;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.MusicSing;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.SEI;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.impl.MusicSingImpl;
import com.netease.yunxin.nertc.nertcvoiceroom.util.SuccessCallback;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.netease.yunxin.nertc.nertcvoiceroom.model.NERtcVoiceRoomDef.RoomAudioQuality;

public class NERtcVoiceRoomImpl extends NERtcVoiceRoomInner {
    private static final String LOG_TAG = NERtcVoiceRoomImpl.class.getSimpleName();

    private static NERtcVoiceRoomImpl sInstance;

    public static synchronized NERtcVoiceRoom sharedInstance(Context context) {
        if (sInstance == null) {
            sInstance = new NERtcVoiceRoomImpl(context.getApplicationContext());
        }
        return sInstance;
    }

    public static synchronized void destroySharedInstance() {
        if (sInstance != null) {
            sInstance.destroy();
            sInstance = null;
        }
    }

    private final Context context;

    /**
     * 音视频引擎
     */
    private NERtcEx engine;

    /**
     * 聊天室服务
     */
    private ChatRoomService chatRoomService;

    /**
     * 房间信息
     */
    private VoiceRoomInfo voiceRoomInfo;

    private RoomQuery roomQuery;

    /**
     * 用户信息
     */
    private VoiceRoomUser user;

    /**
     * 点歌服务
     */
    private MusicSing musicSing;

    /**
     * 主播模式
     */
    private boolean anchorMode;

    /**
     * 房间静音状态
     */
    private boolean muteRoomAudio;

    /**
     * 耳返状态
     */
    private boolean enableEarBack;

    /**
     * 采集音量，默认100
     */
    private int audioCaptureVolume = 100;

    /**
     * 房间状态回调
     */
    private RoomCallback roomCallback;

    private final List<VoiceRoomSeat> seats = new ArrayList<>();

    private boolean initial = false;

    /**
     * 音视频引擎回调
     */
    private final NERtcCallbackExImpl callback = new NERtcCallbackExImpl() {
        @Override
        public void onJoinChannel(int result, long channelId, long elapsed) {
            if (anchorMode && voiceRoomInfo.isSupportCDN()) {
                getStreamTaskControl().addStreamTask(accountToVoiceUid(user.account), voiceRoomInfo.getStreamConfig().pushUrl);
            }
            ALog.e("NERtcVoiceRoomImpl", "join channel result code is " + result);
            onEnterRoom(result == NERtcConstants.ErrorCode.OK || result == NERtcConstants.ErrorCode.ENGINE_ERROR_ROOM_ALREADY_JOINED);
            //设置之前保存的采集音量
            engine.adjustRecordingSignalVolume(audioCaptureVolume);
        }

        /**
         * CDN 模式下添加对应用户的混流设置
         * @param uid 用户id
         */
        @Override
        public void onUserJoined(long uid) {
            if (!voiceRoomInfo.isSupportCDN()) {
                return;
            }
            if (anchorMode) {
                getStreamTaskControl().addMixStreamUser(uid);
            }
        }

        /**
         * CDN 模式下 移除对应用户的混流设置
         * @param uid 用户id
         * @param reason 该用户离开原因{@link com.netease.lava.nertc.sdk.NERtcConstants.ErrorCode}
         */
        @Override
        public void onUserLeave(long uid, int reason) {
            if (!voiceRoomInfo.isSupportCDN()) {
                return;
            }
            if (anchorMode) {
                getStreamTaskControl().removeMixStreamUser(uid);
            }
        }

        @Override
        public void onLeaveChannel(int result) {
            ALog.e("NERtcVoiceRoomImpl", "leave channel result code is " + result);
            if (anchorMode || !initial || !voiceRoomInfo.isSupportCDN()) {
                onLeaveRoom();
            }
        }

        /**
         * 通知混音状态
         * 0 播放完成
         * 1 播放出错
         */
        @Override
        public void onAudioMixingStateChanged(int reason) {
            if (audioPlay != null) {
                audioPlay.onAudioMixingStateChanged(reason);
            }
        }

        @Override
        public void onAudioMixingTimestampUpdate(long timestampMs) {
            musicSing.receiveSEIMsg(timestampMs);
            String seiString = GsonUtils.toJson(new SEI(timestampMs));
            engine.sendSEIMsg(seiString);
        }

        @Override
        public void onRecvSEIMsg(long l, String s) {
            SEI sei = GsonUtils.fromJson(s, SEI.class);
            musicSing.receiveSEIMsg(sei.audio_mixing_pos);
        }

        /**
         * 通知音效播放完成
         */
        @Override
        public void onAudioEffectFinished(int effectId) {
            if (audioPlay != null) {
                audioPlay.onAudioEffectFinished(effectId);
            }
        }

        @Override
        public void onUserVideoStart(long uid, int maxProfile) {
            super.onUserVideoStart(uid, maxProfile);
            engine.subscribeRemoteVideoStream(uid, NERtcRemoteVideoStreamType.kNERtcRemoteVideoStreamTypeHigh, true);
        }

        /**
         * 通知房间内用户语音音量，可以知道，“谁”正在说话
         */
        @Override
        public void onRemoteAudioVolumeIndication(NERtcAudioVolumeInfo[] volumeArray, int totalVolume) {
            Map<Long, Integer> volumes = new HashMap<>();
            for (NERtcAudioVolumeInfo volumeInfo : volumeArray) {
                volumes.put(volumeInfo.uid, volumeInfo.volume);
            }
            updateVolumes(volumes);
        }

        @Override
        public void onDisconnect(int reason) {
            ALog.e("NERtcVoiceRoomImpl", "disconnected from RTC room.  reason is " + reason);
            leaveRoom();
            onLeaveRoom();
        }
    };

    private final AnchorImpl anchor = new AnchorImpl(this);

    private final AudienceImpl audience = new AudienceImpl(this);

    private AudioPlayImpl audioPlay;

    private StreamTaskControl streamTaskControl;

    private PushTypeSwitcher switcher;

    private final Observer<List<ChatRoomMessage>> messageObserver = new Observer<List<ChatRoomMessage>>() {
        @Override
        public void onEvent(List<ChatRoomMessage> chatRoomMessages) {
            if (chatRoomMessages == null || chatRoomMessages.isEmpty()) {
                return;
            }
            if (voiceRoomInfo == null) {
                return;
            }
            final String roomId = voiceRoomInfo.getRoomId();
            for (ChatRoomMessage message : chatRoomMessages) {
                if (message.getSessionType() != SessionTypeEnum.ChatRoom ||
                        !message.getSessionId().equals(roomId)) {
                    continue;
                }
                MsgAttachment attachment = message.getAttachment();
                if (attachment instanceof ChatRoomNotificationAttachment) {
                    onNotification((ChatRoomNotificationAttachment) attachment);
                    continue;
                }
                if (message.getMsgType() == MsgTypeEnum.text) {
                    onTextMessage(message);
                    continue;
                }
                if (attachment instanceof CloseRoomAttach) {
                    if (roomCallback != null) {
                        roomCallback.onRoomDismiss();
                    }
                    return;
                }

                if (attachment instanceof StreamRestarted) {
                    audience.restartAudioOrNot();
                    return;
                }

                if (attachment instanceof MusicControl) {
                    MusicControl musicControl = (MusicControl) attachment;
                    int type = musicControl.getType();
                    if (roomCallback != null) {
                        VoiceRoomMessage msg = VoiceRoomMessage.createEventMessage(
                                getMessageTextBuilder().musicEvent(musicControl.operator, type == CustomAttachmentType.MUSIC_PAUSE));
                        roomCallback.onVoiceRoomMessage(msg);
                        roomCallback.onMusicStateChange(type);
                    }
                }
            }
        }
    };

    private final Observer<ChatRoomKickOutEvent> kickOutObserver = new Observer<ChatRoomKickOutEvent>() {
        @Override
        public void onEvent(ChatRoomKickOutEvent event) {
            if (voiceRoomInfo == null) {
                return;
            }
            final String roomId = voiceRoomInfo.getRoomId();
            if (!roomId.equals(event.getRoomId())) {
                return;
            }

            if (roomCallback != null) {
                roomCallback.onRoomDismiss();
            }
        }
    };

    private final Observer<CustomNotification> customNotification = new Observer<CustomNotification>() {
        @Override
        public void onEvent(CustomNotification notification) {
            int command = SeatCommands.commandFrom(notification);
            VoiceRoomSeat seat = SeatCommands.seatFrom(notification);
            if (seat == null) {
                return;
            }
            anchor.command(command, seat);
        }
    };

    Observer<ChatRoomStatusChangeData> onlineStatusObserver = new Observer<ChatRoomStatusChangeData>() {
        @Override
        public void onEvent(ChatRoomStatusChangeData change) {
            String roomId = voiceRoomInfo != null ? voiceRoomInfo.getRoomId() : "";
            if (!roomId.equals(change.roomId)) {
                return;
            }
            if (change.status == StatusCode.LOGINED && musicSing != null) {
                musicSing.update();
            }
            if (change.status.wontAutoLogin()) {
                //
            }
        }
    };

    private static final int MSG_MEMBER_EXIT = 500;

    private static final Handler delayHandler = new Handler(Looper.getMainLooper()) {

        @Override
        public void handleMessage(@NonNull Message msg) {
            removeMessages(msg.what);
            if (msg.obj instanceof Runnable) {
                ((Runnable) msg.obj).run();
            }
        }
    };

    private NERtcVoiceRoomImpl(Context context) {
        this.context = context;

        NIMClient.getService(MsgService.class).registerCustomAttachmentParser(new CustomAttachParser());
        chatRoomService = NIMClient.getService(ChatRoomService.class);

        engine = NERtcEx.getInstance();
    }

    private void destroy() {
        if (engine != null) {
            engine.release();
        }
    }

    /**
     * 恢复单例中非 长期有效对象内容为默认
     */
    private void restoreInstanceInfo() {
        muteRoomAudio = false;
        user = null;
        voiceRoomInfo = null;
        anchorMode = false;
        audioCaptureVolume = 100;
    }

    @Override
    public void init(String appKey, RoomCallback callback) {
        roomCallback = callback;
        NERtcOption option = new NERtcOption();
        musicSing = MusicSing.shareInstance();
        option.logLevel = NERtcConstants.LogLevel.DEBUG;
        try {
            engine.init(context, appKey, this.callback, option);
        } catch (Exception e) {
            e.printStackTrace();
        }
        initial = true;
    }

    @Override
    public void setAudioQuality(int quality) {
        int scenario = NERtcConstants.AudioScenario.CHATROOM;
        int profile = NERtcConstants.AudioProfile.HIGH_QUALITY;
        if (quality == RoomAudioQuality.MUSIC_QUALITY) {
            scenario = NERtcConstants.AudioScenario.MUSIC;
            profile = NERtcConstants.AudioProfile.HIGH_QUALITY_STEREO;
        }
        engine.setAudioProfile(profile, scenario);
    }

    @Override
    public void initRoom(VoiceRoomInfo voiceRoomInfo, VoiceRoomUser user) {
        this.voiceRoomInfo = voiceRoomInfo;
        this.user = user;
        this.roomQuery = new RoomQuery(voiceRoomInfo, chatRoomService);

        anchor.initRoom(voiceRoomInfo);


    }

    @Override
    public void enterRoom(final boolean anchorMode) {
        this.anchorMode = anchorMode;
        EnterChatRoomData roomData = new EnterChatRoomData(voiceRoomInfo.getRoomId());
        roomData.setNick(user.nick);
        roomData.setAvatar(user.avatar);
        InvocationFuture<EnterChatRoomResultData> future = anchorMode ? chatRoomService.enterChatRoom(
                roomData) : chatRoomService.enterChatRoomEx(roomData, 1);
        future.setCallback(new RequestCallback<EnterChatRoomResultData>() {
            @Override
            public void onSuccess(EnterChatRoomResultData param) {
                ALog.e("====>", "enter room success.");
                if (roomCallback != null) {
                    roomCallback.onOnlineUserCount(param.getRoomInfo().getOnlineUserCount());
                }

                if (!anchorMode) {
                    audience.enterRoom(voiceRoomInfo, user, param);
                } else {
                    anchor.enterRoom();
                }

                Boolean mute = isAnchorMute(param.getRoomInfo());
                if (mute != null) {
                    if (roomCallback != null) {
                        roomCallback.onAnchorMute(mute);
                    }
                }

                if (anchorMode || !voiceRoomInfo.isSupportCDN()) {
                    joinChannel();
                } else {
                    audience.getAudiencePlay().play(voiceRoomInfo.getStreamConfig().rtmpPullUrl);
                    onEnterRoom(true);
                }

                initSeats();
                initAnchorInfo();
                initKtv();
            }

            @Override
            public void onFailed(int code) {
                ALog.e("====>", "enter room fail.");
                if (roomCallback != null) {
                    roomCallback.onEnterRoom(false);
                }
                destroy();// must destroy engine
                restoreInstanceInfo();
            }

            @Override
            public void onException(Throwable exception) {
                ALog.e("====>", "enter room exception.");
                if (roomCallback != null) {
                    roomCallback.onEnterRoom(false);
                }
                destroy();// must destroy engine
                restoreInstanceInfo();
            }
        });
    }

    @Override
    public void leaveRoom() {
        initial = false;
        delayHandler.removeMessages(MSG_MEMBER_EXIT);
        listen(false);
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if (voiceRoomInfo != null) {
                    ALog.e("====>", "leave room.");
                    chatRoomService.exitChatRoom(voiceRoomInfo.getRoomId());
                }
                if (anchorMode && voiceRoomInfo.isSupportCDN()) {
                    getStreamTaskControl().removeStreamTask();
                }
                int resultCode = engine.leaveChannel();
                ALog.e("====>", "level channel code is " + resultCode);
            }
        };
        if (anchorMode || !audience.leaveRoom(runnable)) {
            runnable.run();
        }
    }

    @Override
    public void startLocalAudio() {
        engine.enableLocalAudio(true);
    }

    @Override
    public void stopLocalAudio() {
        engine.enableLocalAudio(false);
    }

    @Override
    public boolean muteLocalAudio(boolean mute) {
        engine.setRecordDeviceMute(mute);
        boolean muted = isLocalAudioMute();

        if (anchorMode) {
            anchor.muteLocalAudio(muted);
        } else {
            audience.muteLocalAudio(muted);
        }

        if (roomCallback != null) {
            roomCallback.onMute(muted);
        }

        return muted;
    }

    @Override
    public boolean isLocalAudioMute() {
        return engine.isRecordDeviceMute();
    }

    @Override
    public void setSpeaker(boolean useSpeaker) {
        engine.setSpeakerphoneOn(useSpeaker);
    }

    @Override
    public void setAudioCaptureVolume(int volume) {
        audioCaptureVolume = volume;
        engine.adjustRecordingSignalVolume(volume);
    }

    @Override
    public int getAudioCaptureVolume() {
        return audioCaptureVolume;
    }


    @Override
    public boolean muteRoomAudio(boolean mute) {
        muteRoomAudio = mute;
        engine.setPlayoutDeviceMute(mute);
        if (anchorMode) {
            anchor.muteRoomAudio(mute);
        } else if (voiceRoomInfo.isSupportCDN()) {
            audience.getAudiencePlay().setVolume(mute ? 0f : 1f);
        }
        return mute;
    }

    @Override
    public boolean isRoomAudioMute() {
        return muteRoomAudio;
    }

    @Override
    public boolean isEarBackEnable() {
        return enableEarBack;
    }

    @Override
    public void enableEarback(boolean enable) {
        this.enableEarBack = enable;
        engine.enableEarback(enable, 100);
    }

    @Override
    public void sendTextMessage(String text) {
        sendMessage(text, false);
    }

    @Override
    public AudioPlay getAudioPlay() {
        if (audioPlay == null) {
            audioPlay = new AudioPlayImpl(engine);
        }
        return audioPlay;
    }

    @Override
    public PushTypeSwitcher getPushTypeSwitcher() {
        if (switcher == null) {
            switcher = new PushTypeSwitcherImpl(context, engine, audience.getAudiencePlay());
        }
        return switcher;
    }

    public StreamTaskControl getStreamTaskControl() {
        if (streamTaskControl == null) {
            streamTaskControl = new StreamTaskControlImpl(anchor, engine);
        }
        return streamTaskControl;
    }

    @Override
    public Anchor getAnchor() {
        return anchor;
    }

    @Override
    public Audience getAudience() {
        return audience;
    }

    @Override
    void updateSeat(VoiceRoomSeat seat) {
        this.seats.set(seat.getIndex(), seat);
        if (roomCallback != null) {
            roomCallback.updateSeat(seat);
        }
        if (!seat.isOn() &&(seat.getReason() == VoiceRoomSeat.Reason.ANCHOR_KICK || seat.getReason() == VoiceRoomSeat.Reason.LEAVE)&& anchorMode) {
            musicSing.leaveSet(seat.getUser(), false);
        }
    }

    @Override
    synchronized VoiceRoomSeat getSeat(int index) {
        return seats.get(index);
    }

    @Override
    void sendSeatEvent(VoiceRoomSeat seat, boolean enter) {
        sendMessage(getMessageTextBuilder().seatEvent(seat, enter), true);
    }

    @Override
    void sendSeatUpdate(VoiceRoomSeat seat, RequestCallback<Void> callback) {
        chatRoomService.updateQueue(voiceRoomInfo.getRoomId(),
                seat.getKey(),
                seat.toJsonString()).setCallback(callback);
    }

    @Override
    void fetchSeats(final RequestCallback<List<VoiceRoomSeat>> callback) {
        chatRoomService.fetchQueue(voiceRoomInfo.getRoomId()).setCallback(new RequestCallback<List<Entry<String, String>>>() {
            @Override
            public void onSuccess(List<Entry<String, String>> param) {
                if (callback != null) {
                    List<VoiceRoomSeat> seats = createSeats();
                    if (param != null) {
                        fillSeats(param, seats);
                    }
                    callback.onSuccess(seats);
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
    boolean isInitial() {
        return initial;
    }

    private void listen(boolean on) {
        NIMClient.getService(MsgServiceObserve.class).observeCustomNotification(customNotification, on);
        NIMClient.getService(ChatRoomServiceObserver.class).observeReceiveMessage(messageObserver, on);
        NIMClient.getService(ChatRoomServiceObserver.class).observeKickOutEvent(kickOutObserver, on);
        NIMClient.getService(ChatRoomServiceObserver.class).observeOnlineStatus(onlineStatusObserver, on);
    }

    private void onEnterRoom(boolean success) {
        if (success) {
            listen(true);

            // 打开扬声器
            setSpeaker(true);
            // 打开耳返
            enableEarback(false);
            // 设置音量汇报间隔 500ms
            engine.enableAudioVolumeIndication(true, 500);
            if (!anchorMode) {
                musicSing.update();
            }
        }

        if (roomCallback != null) {
            roomCallback.onEnterRoom(success);
        }
    }

    private void onLeaveRoom() {
        if (audioPlay!=null){
            audioPlay.reset();
        }
        engine.release();
        restoreInstanceInfo();

        if (roomCallback != null) {
            roomCallback.onLeaveRoom();
        }
    }

    private void joinChannel() {
        setAudioQuality(voiceRoomInfo.getAudioQuality());
        setupParameters();
        if (anchorMode) {
            startLocalAudio();
        } else {
            stopLocalAudio();
        }
        int result = engine.joinChannel(null, voiceRoomInfo.getRoomId(), accountToVoiceUid(user.account));
        ALog.e("====>", "join channel code is " + result);
        if (result != 0) {
            if (roomCallback != null) {
                roomCallback.onEnterRoom(false);
            }
        }
    }

    private void setupParameters() {
        NERtcParameters parameters = new NERtcParameters();
        parameters.setBoolean(NERtcParameters.KEY_AUTO_SUBSCRIBE_AUDIO, true);
        if (voiceRoomInfo.isSupportCDN()) {
            parameters.set(NERtcParameters.KEY_PUBLISH_SELF_STREAM, true);
        }
        NERtcEx.getInstance().setParameters(parameters);
    }

    private void updateRoomInfo() {
        chatRoomService.fetchRoomInfo(voiceRoomInfo.getRoomId()).setCallback(new SuccessCallback<ChatRoomInfo>() {
            @Override
            public void onSuccess(ChatRoomInfo param) {
                if (!anchorMode) {
                    audience.updateRoomInfo(param);
                }
                if (roomCallback != null) {
                    roomCallback.onOnlineUserCount(param.getOnlineUserCount());
                }

                Boolean mute = isAnchorMute(param);
                if (mute != null) {
                    if (roomCallback != null) {
                        roomCallback.onAnchorMute(mute);
                    }
                }
            }
        });
    }

    private void initAnchorInfo() {
        if (anchorMode) {
            initAnchorInfo(user);
            return;
        }
        roomQuery.fetchMember(voiceRoomInfo.getCreatorAccount(), new SuccessCallback<ChatRoomMember>() {
            @Override
            public void onSuccess(ChatRoomMember chatRoomMember) {
                if (chatRoomMember != null) {
                    initAnchorInfo(new VoiceRoomUser(chatRoomMember));
                }
            }
        });
    }

    private void initKtv() {
        musicSing.initRoom(chatRoomService, user, voiceRoomInfo.getRoomId());
        musicSing.setAudienceInfo(anchorMode, audience);
        musicSing.setRoomCallback(roomCallback);
    }

    private void initAnchorInfo(VoiceRoomUser user) {
        if (roomCallback != null) {
            roomCallback.onAnchorInfo(user);
        }
    }

    private void initSeats() {
        if (anchorMode) {
            updateSeats(createSeats());
//            return;
        }
        fetchSeats(new SuccessCallback<List<VoiceRoomSeat>>() {
            @Override
            public void onSuccess(List<VoiceRoomSeat> seats) {
                if (!anchorMode) {
                    audience.initSeats(seats);
                } else {
                    anchor.initSeats(seats);
                }
                updateSeats(seats);
            }
        });
    }

    @Override
    public void refreshSeats() {
        initSeats();
    }

    private void onNotification(final ChatRoomNotificationAttachment notification) {
        switch (notification.getType()) {
            case ChatRoomQueueChange: {
                ChatRoomQueueChangeAttachment queueChange = (ChatRoomQueueChangeAttachment) notification;
                onQueueChange(queueChange);
                break;
            }
            case ChatRoomMemberIn: {
                delayHandler.removeMessages(MSG_MEMBER_EXIT);
                updateRoomInfo();
                sendRoomEvent(notification.getTargetNicks(), true);
                break;
            }
            case ChatRoomMemberExit: {
                delayHandler.sendMessageDelayed(delayHandler.obtainMessage(MSG_MEMBER_EXIT, new Runnable() {
                    @Override
                    public void run() {
                        updateRoomInfo();

                        if (anchorMode) {
                            anchor.memberExit(notification.getOperator());
                        }
                        sendRoomEvent(notification.getTargetNicks(), false);
                    }
                }), 500);
                break;
            }
            case ChatRoomRoomMuted: {
                if (!anchorMode) {
                    audience.muteText(true);
                }
                break;
            }
            case ChatRoomRoomDeMuted: {
                if (!anchorMode) {
                    roomQuery.fetchMember(user.account, new SuccessCallback<ChatRoomMember>() {
                        @Override
                        public void onSuccess(ChatRoomMember member) {
                            if (member != null) {
                                audience.updateMemberInfo(member);
                            }
                        }
                    });
                }
                break;
            }
            case ChatRoomMemberTempMuteAdd: {
                ChatRoomTempMuteAddAttachment muteAdd = (ChatRoomTempMuteAddAttachment) notification;
                if (!anchorMode) {
                    if (muteAdd.getTargets().contains(user.account)) {
                        audience.muteText(true);
                    }
                }
                break;
            }
            case ChatRoomMemberTempMuteRemove: {
                ChatRoomTempMuteRemoveAttachment muteRemove = (ChatRoomTempMuteRemoveAttachment) notification;
                if (!anchorMode) {
                    if (muteRemove.getTargets().contains(user.account)) {
                        audience.muteText(false);
                    }
                }
                break;
            }
            case ChatRoomInfoUpdated: {
                Boolean mute = isAnchorMute(notification);
                if (mute != null) {
                    if (roomCallback != null) {
                        roomCallback.onAnchorMute(mute);
                    }
                }
                break;
            }
        }
    }

    private void onTextMessage(ChatRoomMessage message) {
        String content = message.getContent();
        String nick = message.getChatRoomMessageExtension().getSenderNick();
        VoiceRoomMessage msg = isEventMessage(message)
                ? VoiceRoomMessage.createEventMessage(content)
                : VoiceRoomMessage.createTextMessage(nick, content);
        if (roomCallback != null) {
            roomCallback.onVoiceRoomMessage(msg);
        }
    }

    private void onQueueChange(ChatRoomQueueChangeAttachment queueChange) {
        ALog.i(LOG_TAG, "onQueueChange: type = " + queueChange.getChatRoomQueueChangeType() +
                " key = " + queueChange.getKey() + " content = " + queueChange.getContent());
        ChatRoomQueueChangeType type = queueChange.getChatRoomQueueChangeType();
        if (type == ChatRoomQueueChangeType.DROP) {
            if (anchorMode) {
                anchor.clearSeats();
            } else {
                audience.clearSeats();
            }
            updateSeats(createSeats());
            return;
        }

        if (type == ChatRoomQueueChangeType.OFFER || type == ChatRoomQueueChangeType.POLL) {
            String content = queueChange.getContent();
            String key = queueChange.getKey();
            if (TextUtils.isEmpty(content)) {
                return;
            }
            if (MusicSingImpl.isMusicKey(key)) {
                if (type == ChatRoomQueueChangeType.OFFER) {
                    musicSing.addSongFromQueue(content);
                } else {
                    musicSing.removeSongFromQueue(content);
                }
            } else if (type == ChatRoomQueueChangeType.OFFER) {
                VoiceRoomSeat seat = VoiceRoomSeat.fromJson(content);
                if (seat == null) {
                    return;
                }
                VoiceRoomSeat currentSeat = getSeat(seat.getIndex());
                if (currentSeat != null && currentSeat.isOn() && seat.getStatus() == Status.INIT && seat.getReason() == VoiceRoomSeat.Reason.CANCEL_APPLY) {
                    if (!anchorMode){
                        audience.initSeats(seats);
                    }
                    return;
                }
                if (anchorMode) {
                    if (anchor.seatChange(seat)) {
                        updateSeat(seat);
                    }
                } else {
                    updateSeat(seat);
                    audience.seatChange(seat);
                }
            }
        }
    }

    private void sendRoomEvent(List<String> nicks, boolean enter) {
        if (nicks == null || nicks.isEmpty()) {
            return;
        }
        for (String nick : nicks) {
            VoiceRoomMessage message = VoiceRoomMessage.createEventMessage(
                    getMessageTextBuilder().roomEvent(nick, enter));
            if (roomCallback != null) {
                roomCallback.onVoiceRoomMessage(message);
            }
        }
    }

    private void updateSeats(@NonNull List<VoiceRoomSeat> seats) {
        this.seats.clear();
        this.seats.addAll(seats);
        if (roomCallback != null) {
            roomCallback.updateSeats(this.seats);
        }
    }

    private void updateVolumes(Map<Long, Integer> volumes) {
        if (roomCallback != null) {
            boolean enable = !isLocalAudioMute() && !isRoomAudioMute();
            roomCallback.onAnchorVolume(enable
                    ? getVolume(volumes, voiceRoomInfo.getCreatorAccount())
                    : 0);
            for (VoiceRoomSeat seat : seats) {
                roomCallback.onSeatVolume(seat,
                        enable && seat.getStatus() == Status.ON
                                ? getVolume(volumes, seat.getAccount())
                                : 0);
            }
        }
    }

    private void sendMessage(String text, boolean event) {
        if (voiceRoomInfo == null) {
            return;
        }
        ChatRoomMessage message = ChatRoomMessageBuilder.createChatRoomTextMessage(
                voiceRoomInfo.getRoomId(),
                text);

        if (event) {
            Map<String, Object> remoteExtension = new HashMap<>();
            remoteExtension.put(ChatRoomMsgExtKey.KEY_TYPE, ChatRoomMsgExtKey.TYPE_EVENT);
            message.setRemoteExtension(remoteExtension);
        }

        chatRoomService.sendMessage(message, false);

        if (roomCallback != null) {
            VoiceRoomMessage msg = event
                    ? VoiceRoomMessage.createEventMessage(text)
                    : VoiceRoomMessage.createTextMessage(user.nick, text);
            roomCallback.onVoiceRoomMessage(msg);
        }
    }

    private static int getVolume(Map<Long, Integer> volumes, String account) {
        long uid = accountToVoiceUid(account);
        if (uid <= 0) {
            return 0;
        }
        Integer volume = volumes.get(uid);
        return volume != null ? volume : 0;
    }

    public static Boolean isAnchorMute(ChatRoomInfo chatRoomInfo) {
        Map<String, Object> extension = chatRoomInfo.getExtension();
        Object value = extension != null ? extension.get(ChatRoomInfoExtKey.ANCHOR_MUTE) : null;
        return value instanceof Integer ? (Integer) value == 1 : null;
    }

    public static Boolean isAnchorMute(ChatRoomNotificationAttachment attachment) {
        Map<String, Object> extension = attachment.getExtension();
        Object value = extension != null ? extension.get(ChatRoomInfoExtKey.ANCHOR_MUTE) : null;
        return value instanceof Integer ? (Integer) value == 1 : null;
    }

    public static boolean isEventMessage(ChatRoomMessage message) {
        if (message.getMsgType() != MsgTypeEnum.text) {
            return false;
        }
        Map<String, Object> remoteExtension = message.getRemoteExtension();
        Object value = remoteExtension != null ? remoteExtension.get(ChatRoomMsgExtKey.KEY_TYPE) : null;
        return value instanceof Integer && (Integer) value == ChatRoomMsgExtKey.TYPE_EVENT;
    }


    private static List<VoiceRoomSeat> createSeats() {
        int size = VoiceRoomSeat.SEAT_COUNT;
        List<VoiceRoomSeat> seats = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            seats.add(new VoiceRoomSeat(i));
        }
        return seats;
    }

    private static void fillSeats(@NonNull List<Entry<String, String>> entries,
                                  @NonNull List<VoiceRoomSeat> seats) {
        for (Entry<String, String> entry : entries) {
            if (!VoiceRoomSeat.isValidKey(entry.key)) {
                continue;
            }
            if (TextUtils.isEmpty(entry.value)) {
                continue;
            }
            VoiceRoomSeat seat = VoiceRoomSeat.fromJson(entry.value);
            if (seat == null) {
                continue;
            }
            int index = seat.getIndex();
            if (index >= 0 && index < seats.size()) {
                seats.set(seat.getIndex(), seat);
            }
        }
    }

    private static AccountMapper accountMapper;

    private static long accountToVoiceUid(String account) {
        return accountMapper != null ? accountMapper.accountToVoiceUid(account) : -1;
    }

    public static void setAccountMapper(AccountMapper mapper) {
        accountMapper = mapper;
    }

    private static VoiceRoomMessage.MessageTextBuilder messageTextBuilder;

    public static VoiceRoomMessage.MessageTextBuilder getMessageTextBuilder() {
        if (messageTextBuilder != null) {
            return messageTextBuilder;
        }
        return VoiceRoomMessage.getDefaultMessageTextBuilder();
    }

    public static void setMessageTextBuilder(VoiceRoomMessage.MessageTextBuilder messageTextBuilder) {
        NERtcVoiceRoomImpl.messageTextBuilder = messageTextBuilder;
    }
}
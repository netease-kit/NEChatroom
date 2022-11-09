// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(value) => "已拒绝${value}的申请";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "accompaniment": MessageLookupByLibrary.simpleMessage("伴奏"),
        "alreadyLeaveSeat": MessageLookupByLibrary.simpleMessage("您已下麦"),
        "alreadyOnSeat": MessageLookupByLibrary.simpleMessage("您已在麦上"),
        "alreadySeat": MessageLookupByLibrary.simpleMessage("已上麦"),
        "announcementContent": MessageLookupByLibrary.simpleMessage(
            "本应用为示例产品，请勿商用，单场直播最长10分钟，最多10人次。\n感谢网易MMORPG游戏《新倩女幽魂》提供伴奏歌曲。"),
        "announcementTitle": MessageLookupByLibrary.simpleMessage("公告"),
        "appVersion": MessageLookupByLibrary.simpleMessage("应用版本"),
        "applause": MessageLookupByLibrary.simpleMessage("鼓掌声"),
        "apply": MessageLookupByLibrary.simpleMessage("的申请"),
        "applyCanceled": MessageLookupByLibrary.simpleMessage("已取消申请上麦"),
        "applyMicroHasArrow": MessageLookupByLibrary.simpleMessage("申请上麦"),
        "applySeat": MessageLookupByLibrary.simpleMessage("麦位申请"),
        "applyingNow": MessageLookupByLibrary.simpleMessage("正在申请"),
        "audioAndVideoSdkVersion":
            MessageLookupByLibrary.simpleMessage("音视频SDK版本"),
        "avatar": MessageLookupByLibrary.simpleMessage("头像"),
        "backgroundMusic": MessageLookupByLibrary.simpleMessage("背景音乐"),
        "biz_live_authorization_failed":
            MessageLookupByLibrary.simpleMessage("认证失败"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "closeRoomTips": MessageLookupByLibrary.simpleMessage("该房间已被主播解散"),
        "closeSeat": MessageLookupByLibrary.simpleMessage("关闭麦位"),
        "closeSeatTip": MessageLookupByLibrary.simpleMessage("已关闭"),
        "confirmToCancel": MessageLookupByLibrary.simpleMessage("确认取消申请上麦"),
        "dataCenterCN": MessageLookupByLibrary.simpleMessage("中国"),
        "dataCenterOverSea": MessageLookupByLibrary.simpleMessage("海外地区"),
        "dataCenterSwitchConfirmMessage":
            MessageLookupByLibrary.simpleMessage("确定切换数据中心吗？应用需要重新启动和登录。"),
        "dataCenterTitle": MessageLookupByLibrary.simpleMessage("数据中心"),
        "disclaimer": MessageLookupByLibrary.simpleMessage("免责声明"),
        "downSeat": MessageLookupByLibrary.simpleMessage("已下麦"),
        "earback": MessageLookupByLibrary.simpleMessage("耳返"),
        "earbackDesc": MessageLookupByLibrary.simpleMessage("插入耳机后可使用耳返功能"),
        "emptyLive": MessageLookupByLibrary.simpleMessage("暂无直播"),
        "emptyMember": MessageLookupByLibrary.simpleMessage("暂无成员"),
        "endLive": MessageLookupByLibrary.simpleMessage("结束直播"),
        "endRoomSuccess": MessageLookupByLibrary.simpleMessage("房间解散成功"),
        "finish": MessageLookupByLibrary.simpleMessage("结束"),
        "freeForTest": MessageLookupByLibrary.simpleMessage("免费申请试用"),
        "hasConfirm": MessageLookupByLibrary.simpleMessage("已通过"),
        "homeListViewDetailText1": MessageLookupByLibrary.simpleMessage("语聊房"),
        "homeListViewDetailText2": MessageLookupByLibrary.simpleMessage(
            "6-8人语聊房，玩家可自由发言，实现线上兴趣/话题式语聊互动场景"),
        "iKnow": MessageLookupByLibrary.simpleMessage("我知道了"),
        "imVersion": MessageLookupByLibrary.simpleMessage("IM 版本"),
        "inputChatMessageHint": MessageLookupByLibrary.simpleMessage("一起聊聊吧～"),
        "joinRoom": MessageLookupByLibrary.simpleMessage("加入房间"),
        "kickSeat": MessageLookupByLibrary.simpleMessage("将TA踢下麦位"),
        "kickoutSeatByHost": MessageLookupByLibrary.simpleMessage("已被主播请下麦位"),
        "kickoutSeatSuccessTip1": MessageLookupByLibrary.simpleMessage("已将"),
        "kickoutSeatSuccessTip2": MessageLookupByLibrary.simpleMessage("踢下麦位"),
        "kickoutSeatSure": MessageLookupByLibrary.simpleMessage("确定踢下麦位"),
        "laughter": MessageLookupByLibrary.simpleMessage("笑声"),
        "leaveRoom": MessageLookupByLibrary.simpleMessage("离开房间"),
        "leaveSeat": MessageLookupByLibrary.simpleMessage("下麦"),
        "loadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
        "loaded": MessageLookupByLibrary.simpleMessage("加载完成"),
        "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
        "logoutEn": MessageLookupByLibrary.simpleMessage("登出"),
        "micOff": MessageLookupByLibrary.simpleMessage("话筒已关闭"),
        "micOn": MessageLookupByLibrary.simpleMessage("话筒已打开"),
        "microphone": MessageLookupByLibrary.simpleMessage("麦克风"),
        "mixer": MessageLookupByLibrary.simpleMessage("调音台"),
        "more": MessageLookupByLibrary.simpleMessage("更多"),
        "moveMemberOnSeat": MessageLookupByLibrary.simpleMessage("将成员抱上麦位"),
        "moveOnSeat": MessageLookupByLibrary.simpleMessage("抱上麦位"),
        "music": MessageLookupByLibrary.simpleMessage("伴音"),
        "muteSeat": MessageLookupByLibrary.simpleMessage("屏蔽麦位"),
        "muteSeatFail": MessageLookupByLibrary.simpleMessage("该麦位语音屏蔽失败"),
        "nickName": MessageLookupByLibrary.simpleMessage("昵称"),
        "no": MessageLookupByLibrary.simpleMessage("否"),
        "noMore": MessageLookupByLibrary.simpleMessage("没有更多啦"),
        "notify": MessageLookupByLibrary.simpleMessage("通知"),
        "onSeatedTips": MessageLookupByLibrary.simpleMessage("您已被主播抱上麦位"),
        "onSeatedTips2": MessageLookupByLibrary.simpleMessage(
            "\n现在可以进行语音互动啦 \n如需下麦，可点击自己的头像或下麦按钮"),
        "online": MessageLookupByLibrary.simpleMessage("在线"),
        "onlineNumber": MessageLookupByLibrary.simpleMessage("人"),
        "openSeat": MessageLookupByLibrary.simpleMessage("打开麦位"),
        "openSeatFail": MessageLookupByLibrary.simpleMessage("打开失败"),
        "openSeatSuccess": MessageLookupByLibrary.simpleMessage("已打开"),
        "operateFail": MessageLookupByLibrary.simpleMessage("操作失败"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私协议"),
        "pullToRefresh": MessageLookupByLibrary.simpleMessage("下拉刷新"),
        "pushToLoad": MessageLookupByLibrary.simpleMessage("下拉加载"),
        "putAway": MessageLookupByLibrary.simpleMessage("收起"),
        "refreshCompleted": MessageLookupByLibrary.simpleMessage("刷新完成"),
        "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
        "refreshing": MessageLookupByLibrary.simpleMessage("刷新中"),
        "rejectSeatRequestTips": m0,
        "releaseToLoad": MessageLookupByLibrary.simpleMessage("松开加载"),
        "releaseToRefresh": MessageLookupByLibrary.simpleMessage("松开刷新"),
        "requestRejected": MessageLookupByLibrary.simpleMessage("申请麦位已被拒绝"),
        "roomName": MessageLookupByLibrary.simpleMessage("房间名称"),
        "seatAlreadyClosed": MessageLookupByLibrary.simpleMessage("该麦位已被关闭"),
        "seatAlreadyTaken": MessageLookupByLibrary.simpleMessage("当前麦位有人"),
        "seatApplied":
            MessageLookupByLibrary.simpleMessage("该麦位正在被申请,请尝试申请其他麦位"),
        "seatApplying": MessageLookupByLibrary.simpleMessage("已申请上麦，等待通过..."),
        "seatBigPrefix": MessageLookupByLibrary.simpleMessage("麦位"),
        "seatEn": MessageLookupByLibrary.simpleMessage("麦位"),
        "seatMuteTips": MessageLookupByLibrary.simpleMessage("该麦位语音已被屏蔽，无法发言"),
        "seatMuted":
            MessageLookupByLibrary.simpleMessage("该麦位被主播屏蔽语音\n现在您已无法进行语音互动"),
        "selectMember": MessageLookupByLibrary.simpleMessage("选择成员"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "settingTitle": MessageLookupByLibrary.simpleMessage("个人信息"),
        "space": MessageLookupByLibrary.simpleMessage(" "),
        "startLive": MessageLookupByLibrary.simpleMessage("开播"),
        "startLiveFailed": MessageLookupByLibrary.simpleMessage("创建房间失败"),
        "sure": MessageLookupByLibrary.simpleMessage("确定"),
        "sureEndLive": MessageLookupByLibrary.simpleMessage("确定结束直播"),
        "termsOfService": MessageLookupByLibrary.simpleMessage("用户协议"),
        "tip": MessageLookupByLibrary.simpleMessage("提示"),
        "toSetUp": MessageLookupByLibrary.simpleMessage("设置"),
        "topAndCoverEmptyHint":
            MessageLookupByLibrary.simpleMessage("主题和封面不能为空"),
        "unKnowVersion": MessageLookupByLibrary.simpleMessage("未知版本"),
        "unmuteSeat": MessageLookupByLibrary.simpleMessage("解除语音屏蔽"),
        "unmuteSeatFail": MessageLookupByLibrary.simpleMessage("该麦位解除语音屏蔽失败"),
        "unmuteSeatSuccess": MessageLookupByLibrary.simpleMessage("该麦位已解除语音屏蔽"),
        "unmuteSeatTips": MessageLookupByLibrary.simpleMessage(
            "该麦位被主播解除语音屏蔽 \n 现在您可以再次进行语音互动了"),
        "updateAt": MessageLookupByLibrary.simpleMessage("刷新于 %T"),
        "vocals": MessageLookupByLibrary.simpleMessage("人声"),
        "voiceChatRoom": MessageLookupByLibrary.simpleMessage("语音聊天室"),
        "voiceRoomLive": MessageLookupByLibrary.simpleMessage("语聊房"),
        "yes": MessageLookupByLibrary.simpleMessage("是")
      };
}

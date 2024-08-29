// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `User Profile`
  String get settingTitle {
    return Intl.message(
      'User Profile',
      name: 'settingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Audio Room`
  String get homeListViewDetailText1 {
    return Intl.message(
      'Audio Room',
      name: 'homeListViewDetailText1',
      desc: '',
      args: [],
    );
  }

  /// `Voice chat room with 6-8 participants. Users can speak freely and talk about interesting topics.`
  String get homeListViewDetailText2 {
    return Intl.message(
      'Voice chat room with 6-8 participants. Users can speak freely and talk about interesting topics.',
      name: 'homeListViewDetailText2',
      desc: '',
      args: [],
    );
  }

  /// `No live broadcast for now`
  String get emptyLive {
    return Intl.message(
      'No live broadcast for now',
      name: 'emptyLive',
      desc: '',
      args: [],
    );
  }

  /// `End the live`
  String get endLive {
    return Intl.message(
      'End the live',
      name: 'endLive',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed to end the live`
  String get sureEndLive {
    return Intl.message(
      'Confirmed to end the live',
      name: 'sureEndLive',
      desc: '',
      args: [],
    );
  }

  /// `Have a chat～`
  String get inputChatMessageHint {
    return Intl.message(
      'Have a chat～',
      name: 'inputChatMessageHint',
      desc: '',
      args: [],
    );
  }

  /// `Microphone`
  String get microphone {
    return Intl.message(
      'Microphone',
      name: 'microphone',
      desc: '',
      args: [],
    );
  }

  /// `In-ear monitor`
  String get earback {
    return Intl.message(
      'In-ear monitor',
      name: 'earback',
      desc: '',
      args: [],
    );
  }

  /// `Plug in the earphones and you can use the in-ear monitor`
  String get earbackDesc {
    return Intl.message(
      'Plug in the earphones and you can use the in-ear monitor',
      name: 'earbackDesc',
      desc: '',
      args: [],
    );
  }

  /// `Mixer`
  String get mixer {
    return Intl.message(
      'Mixer',
      name: 'mixer',
      desc: '',
      args: [],
    );
  }

  /// `Voice`
  String get vocals {
    return Intl.message(
      'Voice',
      name: 'vocals',
      desc: '',
      args: [],
    );
  }

  /// `Backing`
  String get accompaniment {
    return Intl.message(
      'Backing',
      name: 'accompaniment',
      desc: '',
      args: [],
    );
  }

  /// `Background music`
  String get backgroundMusic {
    return Intl.message(
      'Background music',
      name: 'backgroundMusic',
      desc: '',
      args: [],
    );
  }

  /// `Applause`
  String get applause {
    return Intl.message(
      'Applause',
      name: 'applause',
      desc: '',
      args: [],
    );
  }

  /// `laughter`
  String get laughter {
    return Intl.message(
      'laughter',
      name: 'laughter',
      desc: '',
      args: [],
    );
  }

  /// `Mixing`
  String get music {
    return Intl.message(
      'Mixing',
      name: 'music',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get finish {
    return Intl.message(
      'End',
      name: 'finish',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Disclaimer`
  String get disclaimer {
    return Intl.message(
      'Disclaimer',
      name: 'disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Start Live`
  String get startLive {
    return Intl.message(
      'Start Live',
      name: 'startLive',
      desc: '',
      args: [],
    );
  }

  /// `Authorization failed`
  String get biz_live_authorization_failed {
    return Intl.message(
      'Authorization failed',
      name: 'biz_live_authorization_failed',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nickName {
    return Intl.message(
      'Nickname',
      name: 'nickName',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logoutEn {
    return Intl.message(
      'Log out',
      name: 'logoutEn',
      desc: '',
      args: [],
    );
  }

  /// `Data Center`
  String get dataCenterTitle {
    return Intl.message(
      'Data Center',
      name: 'dataCenterTitle',
      desc: '',
      args: [],
    );
  }

  /// `China`
  String get dataCenterCN {
    return Intl.message(
      'China',
      name: 'dataCenterCN',
      desc: '',
      args: [],
    );
  }

  /// `Out of China`
  String get dataCenterOverSea {
    return Intl.message(
      'Out of China',
      name: 'dataCenterOverSea',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to switch the data center? The app is required to restart to take effect.`
  String get dataCenterSwitchConfirmMessage {
    return Intl.message(
      'Are you sure you want to switch the data center? The app is required to restart to take effect.',
      name: 'dataCenterSwitchConfirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Request Free Trial`
  String get freeForTest {
    return Intl.message(
      'Request Free Trial',
      name: 'freeForTest',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get tip {
    return Intl.message(
      'Tips',
      name: 'tip',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get sure {
    return Intl.message(
      'Confirmed',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  /// `I got it`
  String get iKnow {
    return Intl.message(
      'I got it',
      name: 'iKnow',
      desc: '',
      args: [],
    );
  }

  /// `seat`
  String get seatEn {
    return Intl.message(
      'seat',
      name: 'seatEn',
      desc: '',
      args: [],
    );
  }

  /// `Seat`
  String get seatBigPrefix {
    return Intl.message(
      'Seat',
      name: 'seatBigPrefix',
      desc: '',
      args: [],
    );
  }

  /// `Request to speak`
  String get applyMicroHasArrow {
    return Intl.message(
      'Request to speak',
      name: 'applyMicroHasArrow',
      desc: '',
      args: [],
    );
  }

  /// `You have taken a seat`
  String get alreadySeat {
    return Intl.message(
      'You have taken a seat',
      name: 'alreadySeat',
      desc: '',
      args: [],
    );
  }

  /// `Request to speak was cancelled`
  String get applyCanceled {
    return Intl.message(
      'Request to speak was cancelled',
      name: 'applyCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Your request was rejected`
  String get requestRejected {
    return Intl.message(
      'Your request was rejected',
      name: 'requestRejected',
      desc: '',
      args: [],
    );
  }

  /// `Decline to go on mic.`
  String get rejectInviteSeat {
    return Intl.message(
      'Decline to go on mic.',
      name: 'rejectInviteSeat',
      desc: '',
      args: [],
    );
  }

  /// `You have left a seat`
  String get downSeat {
    return Intl.message(
      'You have left a seat',
      name: 'downSeat',
      desc: '',
      args: [],
    );
  }

  /// `removed from the seat`
  String get kickoutSeatByHost {
    return Intl.message(
      'removed from the seat',
      name: 'kickoutSeatByHost',
      desc: '',
      args: [],
    );
  }

  /// `Seat Request`
  String get applySeat {
    return Intl.message(
      'Seat Request',
      name: 'applySeat',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notify {
    return Intl.message(
      'Notification',
      name: 'notify',
      desc: '',
      args: [],
    );
  }

  /// `Moved to Seat`
  String get onSeatedTips {
    return Intl.message(
      'Moved to Seat',
      name: 'onSeatedTips',
      desc: '',
      args: [],
    );
  }

  /// `You can speak now \n To leave the seat, click your avatar or the Leave button`
  String get onSeatedTips2 {
    return Intl.message(
      'You can speak now \n To leave the seat, click your avatar or the Leave button',
      name: 'onSeatedTips2',
      desc: '',
      args: [],
    );
  }

  /// `The seat is muted, Unable to speak`
  String get seatMuted {
    return Intl.message(
      'The seat is muted, Unable to speak',
      name: 'seatMuted',
      desc: '',
      args: [],
    );
  }

  /// `Voice chat room`
  String get voiceChatRoom {
    return Intl.message(
      'Voice chat room',
      name: 'voiceChatRoom',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get announcementTitle {
    return Intl.message(
      'Notice',
      name: 'announcementTitle',
      desc: '',
      args: [],
    );
  }

  /// `The app is used for demo purpose only. Commercial use is not allowed. A live stream can last 10 minutes with 10 participants.\n Grateful for the backing track provided by NetEase MMORPG A Chinese Ghost Story Online`
  String get announcementContent {
    return Intl.message(
      'The app is used for demo purpose only. Commercial use is not allowed. A live stream can last 10 minutes with 10 participants.\n Grateful for the backing track provided by NetEase MMORPG A Chinese Ghost Story Online',
      name: 'announcementContent',
      desc: '',
      args: [],
    );
  }

  /// `Room Name`
  String get roomName {
    return Intl.message(
      'Room Name',
      name: 'roomName',
      desc: '',
      args: [],
    );
  }

  /// ``
  String get online {
    return Intl.message(
      '',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// ` people`
  String get onlineNumber {
    return Intl.message(
      ' people',
      name: 'onlineNumber',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get putAway {
    return Intl.message(
      'Hide',
      name: 'putAway',
      desc: '',
      args: [],
    );
  }

  /// `Select Member`
  String get selectMember {
    return Intl.message(
      'Select Member',
      name: 'selectMember',
      desc: '',
      args: [],
    );
  }

  /// `No Members`
  String get emptyMember {
    return Intl.message(
      'No Members',
      name: 'emptyMember',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get toSetUp {
    return Intl.message(
      'Settings',
      name: 'toSetUp',
      desc: '',
      args: [],
    );
  }

  /// `Move a member to speaker`
  String get moveMemberOnSeat {
    return Intl.message(
      'Move a member to speaker',
      name: 'moveMemberOnSeat',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeSeat {
    return Intl.message(
      'Close',
      name: 'closeSeat',
      desc: '',
      args: [],
    );
  }

  /// `Move TA to audience`
  String get kickSeat {
    return Intl.message(
      'Move TA to audience',
      name: 'kickSeat',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get unmuteSeat {
    return Intl.message(
      'Mute',
      name: 'unmuteSeat',
      desc: '',
      args: [],
    );
  }

  /// `Unmute`
  String get muteSeat {
    return Intl.message(
      'Unmute',
      name: 'muteSeat',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get openSeat {
    return Intl.message(
      'Open',
      name: 'openSeat',
      desc: '',
      args: [],
    );
  }

  /// `The seat is closed`
  String get seatAlreadyClosed {
    return Intl.message(
      'The seat is closed',
      name: 'seatAlreadyClosed',
      desc: '',
      args: [],
    );
  }

  /// `You are already a speaker`
  String get alreadyOnSeat {
    return Intl.message(
      'You are already a speaker',
      name: 'alreadyOnSeat',
      desc: '',
      args: [],
    );
  }

  /// `The seat is being requested. Try to request for another seat.`
  String get seatApplied {
    return Intl.message(
      'The seat is being requested. Try to request for another seat.',
      name: 'seatApplied',
      desc: '',
      args: [],
    );
  }

  /// `Seat is already taken`
  String get seatAlreadyTaken {
    return Intl.message(
      'Seat is already taken',
      name: 'seatAlreadyTaken',
      desc: '',
      args: [],
    );
  }

  /// `You are moved to audience`
  String get alreadyLeaveSeat {
    return Intl.message(
      'You are moved to audience',
      name: 'alreadyLeaveSeat',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get kickoutSeatSure {
    return Intl.message(
      'Remove',
      name: 'kickoutSeatSure',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to go on mic?`
  String get onSeatSure {
    return Intl.message(
      'Confirm to go on mic?',
      name: 'onSeatSure',
      desc: '',
      args: [],
    );
  }

  /// `is closed`
  String get closeSeatTip {
    return Intl.message(
      'is closed',
      name: 'closeSeatTip',
      desc: '',
      args: [],
    );
  }

  /// `Move`
  String get kickoutSeatSuccessTip1 {
    return Intl.message(
      'Move',
      name: 'kickoutSeatSuccessTip1',
      desc: '',
      args: [],
    );
  }

  /// `to audience`
  String get kickoutSeatSuccessTip2 {
    return Intl.message(
      'to audience',
      name: 'kickoutSeatSuccessTip2',
      desc: '',
      args: [],
    );
  }

  /// `The seat is muted, Unable to speak`
  String get seatMuteTips {
    return Intl.message(
      'The seat is muted, Unable to speak',
      name: 'seatMuteTips',
      desc: '',
      args: [],
    );
  }

  /// `The seat was unmuted`
  String get unmuteSeatSuccess {
    return Intl.message(
      'The seat was unmuted',
      name: 'unmuteSeatSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to unmute`
  String get unmuteSeatFail {
    return Intl.message(
      'Failed to unmute',
      name: 'unmuteSeatFail',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mute`
  String get muteSeatFail {
    return Intl.message(
      'Failed to mute',
      name: 'muteSeatFail',
      desc: '',
      args: [],
    );
  }

  /// `is opened`
  String get openSeatSuccess {
    return Intl.message(
      'is opened',
      name: 'openSeatSuccess',
      desc: '',
      args: [],
    );
  }

  /// `is opened fail`
  String get openSeatFail {
    return Intl.message(
      'is opened fail',
      name: 'openSeatFail',
      desc: '',
      args: [],
    );
  }

  /// `requesting the seat`
  String get applyingNow {
    return Intl.message(
      'requesting the seat',
      name: 'applyingNow',
      desc: '',
      args: [],
    );
  }

  /// `Move to audience`
  String get leaveSeat {
    return Intl.message(
      'Move to audience',
      name: 'leaveSeat',
      desc: '',
      args: [],
    );
  }

  /// `Request to speak is submitted. Please wait...`
  String get seatApplying {
    return Intl.message(
      'Request to speak is submitted. Please wait...',
      name: 'seatApplying',
      desc: '',
      args: [],
    );
  }

  /// `Operation failed`
  String get operateFail {
    return Intl.message(
      'Operation failed',
      name: 'operateFail',
      desc: '',
      args: [],
    );
  }

  /// `Microphone Off`
  String get micOff {
    return Intl.message(
      'Microphone Off',
      name: 'micOff',
      desc: '',
      args: [],
    );
  }

  /// `Microphone On`
  String get micOn {
    return Intl.message(
      'Microphone On',
      name: 'micOn',
      desc: '',
      args: [],
    );
  }

  /// `Confirm to cancel the request to speak`
  String get confirmToCancel {
    return Intl.message(
      'Confirm to cancel the request to speak',
      name: 'confirmToCancel',
      desc: '',
      args: [],
    );
  }

  /// `The seat is unmuted \n You can speak now`
  String get unmuteSeatTips {
    return Intl.message(
      'The seat is unmuted \n You can speak now',
      name: 'unmuteSeatTips',
      desc: '',
      args: [],
    );
  }

  /// `Passed`
  String get hasConfirm {
    return Intl.message(
      'Passed',
      name: 'hasConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Request`
  String get apply {
    return Intl.message(
      'Request',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// ` `
  String get space {
    return Intl.message(
      ' ',
      name: 'space',
      desc: '',
      args: [],
    );
  }

  /// `Move a member to speaker`
  String get moveOnSeat {
    return Intl.message(
      'Move a member to speaker',
      name: 'moveOnSeat',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '' key

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `{value} request was rejected`
  String rejectSeatRequestTips(Object value) {
    return Intl.message(
      '$value request was rejected',
      name: 'rejectSeatRequestTips',
      desc: '',
      args: [value],
    );
  }

  /// `The room is dismissed`
  String get closeRoomTips {
    return Intl.message(
      'The room is dismissed',
      name: 'closeRoomTips',
      desc: '',
      args: [],
    );
  }

  /// `Room was dismissed`
  String get endRoomSuccess {
    return Intl.message(
      'Room was dismissed',
      name: 'endRoomSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Pull to refresh`
  String get pullToRefresh {
    return Intl.message(
      'Pull to refresh',
      name: 'pullToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Release to refresh`
  String get releaseToRefresh {
    return Intl.message(
      'Release to refresh',
      name: 'releaseToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Refreshing...`
  String get refreshing {
    return Intl.message(
      'Refreshing...',
      name: 'refreshing',
      desc: '',
      args: [],
    );
  }

  /// `Refresh completed`
  String get refreshCompleted {
    return Intl.message(
      'Refresh completed',
      name: 'refreshCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Refresh failed`
  String get refreshFailed {
    return Intl.message(
      'Refresh failed',
      name: 'refreshFailed',
      desc: '',
      args: [],
    );
  }

  /// `No more`
  String get noMore {
    return Intl.message(
      'No more',
      name: 'noMore',
      desc: '',
      args: [],
    );
  }

  /// `Update at %T`
  String get updateAt {
    return Intl.message(
      'Update at %T',
      name: 'updateAt',
      desc: '',
      args: [],
    );
  }

  /// `Push to load`
  String get pushToLoad {
    return Intl.message(
      'Push to load',
      name: 'pushToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Release to load`
  String get releaseToLoad {
    return Intl.message(
      'Release to load',
      name: 'releaseToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Loaded`
  String get loaded {
    return Intl.message(
      'Loaded',
      name: 'loaded',
      desc: '',
      args: [],
    );
  }

  /// `Load failed`
  String get loadFailed {
    return Intl.message(
      'Load failed',
      name: 'loadFailed',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get appVersion {
    return Intl.message(
      'App version',
      name: 'appVersion',
      desc: '',
      args: [],
    );
  }

  /// `IM version`
  String get imVersion {
    return Intl.message(
      'IM version',
      name: 'imVersion',
      desc: '',
      args: [],
    );
  }

  /// `unKnowVersion`
  String get unKnowVersion {
    return Intl.message(
      'unKnowVersion',
      name: 'unKnowVersion',
      desc: '',
      args: [],
    );
  }

  /// `Audio & Video SDK version`
  String get audioAndVideoSdkVersion {
    return Intl.message(
      'Audio & Video SDK version',
      name: 'audioAndVideoSdkVersion',
      desc: '',
      args: [],
    );
  }

  /// `Join room`
  String get joinRoom {
    return Intl.message(
      'Join room',
      name: 'joinRoom',
      desc: '',
      args: [],
    );
  }

  /// `Leave room`
  String get leaveRoom {
    return Intl.message(
      'Leave room',
      name: 'leaveRoom',
      desc: '',
      args: [],
    );
  }

  /// `VoiceRoom Live`
  String get voiceRoomLive {
    return Intl.message(
      'VoiceRoom Live',
      name: 'voiceRoomLive',
      desc: '',
      args: [],
    );
  }

  /// `topic and cover should not be empty`
  String get topAndCoverEmptyHint {
    return Intl.message(
      'topic and cover should not be empty',
      name: 'topAndCoverEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `start live failed`
  String get startLiveFailed {
    return Intl.message(
      'start live failed',
      name: 'startLiveFailed',
      desc: '',
      args: [],
    );
  }

  /// `No internet`
  String get noInternet {
    return Intl.message(
      'No internet',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

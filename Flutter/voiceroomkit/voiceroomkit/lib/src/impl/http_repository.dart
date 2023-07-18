// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class _NEVoiceRoomHttpRepository {
  static var manager = _HttpExecutor();

  static late String appKey;

  static String _path(String subPath, String module, String version) {
    return '/scene/apps/$appKey/$module/$version/$subPath';
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/list HTTP/1.1
  static Future<NEResult<NEVoiceRoomList>> fetchLiveList(
      int pageNum, int pageSize, NEVoiceRoomLiveState liveStatus) async {
    var body = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'live': liveStatus.index,
      'liveType': 2,
    };
    var ret = await manager._post('/nemo/entertainmentLive/live/list', body);
    var response = NEVoiceRoomList.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/getDefaultLiveInfo HTTP/1.1
  static Future<NEResult<NEVoiceCreateRoomDefaultInfo>>
      getCreateRoomDefaultInfo() async {
    var ret =
        await manager._get('/nemo/entertainmentLive/live/getDefaultLiveInfo');
    var response = NEVoiceCreateRoomDefaultInfo.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/info HTTP/1.1
  static Future<NEResult<NEVoiceRoomInfo>> getRoomInfo(int liveRecordId) async {
    var body = {
      'liveRecordId': liveRecordId,
    };
    var ret = await manager._post('/nemo/entertainmentLive/live/info', body);
    var response = NEVoiceRoomInfo.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/createLive HTTP/1.1
  static Future<NEResult<NEVoiceRoomInfo>> startVoiceRoom(
      String? liveTopic,
      String? cover,
      int liveType,
      int configId,
      String? roomName,
      int seatCount,
      int seatApplyMode,
      int seatInviteMode) async {
    var body = {
      "liveTopic": liveTopic,
      "cover": cover,
      "liveType": liveType,
      "configId": configId,
      "roomName": roomName,
      "seatCount": seatCount,
      "seatApplyMode": seatApplyMode,
      "seatInviteMode": seatInviteMode
    };
    var ret =
        await manager._post('/nemo/entertainmentLive/live/createLive', body);
    var response = NEVoiceRoomInfo.fromJson(ret.data);
    return NEResult(code: ret.code, msg: ret.msg, data: response);
  }

  /// POST http://{host}/scene/apps/{appKey}/ent/live/v1/destroyLive HTTP/1.1
  static Future<NEResult<Void>> stopVoiceRoom(int liveRecordId) async {
    var body = {
      'liveRecordId': liveRecordId,
    };
    var ret =
        await manager._post('/nemo/entertainmentLive/live/destroyLive', body);
    return NEResult(code: ret.code, msg: ret.msg);
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 房间列表
/// @property pageNum 当前页码
/// @property hasNextPage 是否有下一页
/// @property list 直播房间列表
/// @constructor
class NEVoiceRoomList {
  int? pageNum;
  bool? hasNextPage;
  List<NEVoiceRoomInfo>? list;

  NEVoiceRoomList(this.pageNum, this.hasNextPage, this.list);

  NEVoiceRoomList.fromJson(Map? json) {
    pageNum = json?['pageNum'] as int?;
    hasNextPage = json?['hasNextPage'] as bool?;
    list = (json?['list'] as List<dynamic>?)
        ?.map((e) => NEVoiceRoomInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> toJson() =>
      {'pageNum': pageNum, 'hasNextPage': hasNextPage, 'list': list};

  @override
  String toString() {
    return 'NEVoiceRoomList{pageNum: $pageNum, hasNextPage: $hasNextPage, list: $list}';
  }
}

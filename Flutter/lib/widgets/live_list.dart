// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

typedef LoadDataCallback = void Function(
    List<NEVoiceRoomInfo> liveInfoList, bool isRefresh, int value);

mixin LiveListDataMixin {
  List<NEVoiceRoomInfo> liveList = [];
  static const int pageSize = 20;
  int nextPageNum = 1;
  bool haveMore = false;

  void setDataList(List<NEVoiceRoomInfo> liveInfoList, bool isRefresh) {
    if (isRefresh) {
      liveList.clear();
    }
    if (liveInfoList.isNotEmpty && liveInfoList.length > 0) {
      liveList.addAll(liveInfoList);
    }
  }

  void getLiveLists(bool isRefresh, LoadDataCallback callback) {
    if (isRefresh) {
      nextPageNum = 1;
    }
    NEVoiceRoomKit.instance
        .getRoomList(NEVoiceRoomLiveState.live, nextPageNum, pageSize)
        .then((value) {
      print('fetchLiveList  ====> ${value.toString()} ');
      if (value.code == 0) {
        nextPageNum++;
        NEVoiceRoomList? liveList = value.data;
        if (liveList?.hasNextPage != null) {
          haveMore = liveList!.hasNextPage!;
        }
        if (liveList?.list != null) {
          callback(liveList!.list!, isRefresh, 0);
        }
      } else {
        callback([], isRefresh, value.code);
      }
    });
  }
}

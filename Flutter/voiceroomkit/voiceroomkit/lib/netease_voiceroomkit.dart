// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 网易云信语聊房组件
library netease_voiceroomkit;

import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart' as http;
import 'package:netease_common/netease_common.dart';
import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';
import 'package:netease_voiceroomkit/src/impl/model/voiceroom_member_impl.dart';
import 'package:uuid/uuid.dart';

part 'src/api/constants.dart';
part 'src/api/model/nevoiceroom_Info.dart';
part 'src/api/model/nevoiceroom_anchor.dart';
part 'src/api/model/nevoiceroom_chat_text_message.dart';
part 'src/api/model/nevoiceroom_create_audio_effect_option.dart';
part 'src/api/model/nevoiceroom_create_audio_mixing_option.dart';
part 'src/api/model/nevoiceroom_createroom_default_info.dart';
part 'src/api/model/nevoiceroom_list.dart';
part 'src/api/model/nevoiceroom_live_model.dart';
part 'src/api/model/nevoiceroom_member.dart';
part 'src/api/model/nevoiceroom_seatItem.dart';
part 'src/api/model/nevoiceroom_seatItem_status.dart';
part 'src/api/model/nevoiceroom_seat_info.dart';
part 'src/api/model/nevoiceroom_seat_request_item.dart';
part 'src/api/nevoiceroom_listener.dart';
part 'src/api/nevoiceroomkit.dart';
part 'src/executor/http_executor.dart';
part 'src/executor/server_config.dart';
part 'src/impl/constants/member_property_constants.dart';
part 'src/impl/constants/nevoiceroom_im_private_constants.dart';
part 'src/impl/http_repository.dart';
part 'src/impl/room_event.dart';
part 'src/impl/voiceroomkit_impl.dart';
part 'src/utils/logger.dart';
part 'src/utils/model_convert_util.dart';
part 'src/utils/text_utils.dart';

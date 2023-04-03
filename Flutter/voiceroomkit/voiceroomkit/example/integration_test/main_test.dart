// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';

import 'case/media_case.dart';
import 'case/login_case.dart';
import 'package:permission_handler/permission_handler.dart';

import 'case/seat_case.dart';
import 'case/voice_room_case.dart';

const success = 'success';
const fail = 'fail';

List<HandleBaseCase> caseList = [
  HandleCompleteCase(),
  HandleVoiceRoomCase(),
  HandleMediaCase(),
  HandleSeatCase(),
  HandleLoginCase(),
];

/// [Permission.values]
final permissions = [
  Permission.location,
  Permission.storage,
  Permission.camera,
  Permission.photos,
  Permission.phone,
  Permission.microphone,
];

/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/main_test.dart  --keep-app-running  登陆之后使用
/// flutter test  integration_test/main_test.dart  --keep-app-running -d xxx
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('api test', () {
    testWidgets('voiceroom flutter test', (WidgetTester tester) async {
      await IntegratedPermissionHelper.requestPermissions(permissions);
      await IntegratedManager.instance.init(
          applicationName: 'VoiceRoom',
          version: '1.0.0',
          widgetTester: tester,
          packageId: 'com.netease.yunxin.voiceroom',
          caseList: caseList);
    }, timeout: const Timeout(Duration(minutes: 30)));
  });
}

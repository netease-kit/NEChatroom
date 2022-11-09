// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_state.dart';
import 'state_lifecycle.dart';

abstract class LifecycleBaseState<T extends StatefulWidget>
    extends BaseState<T> {
  StateLifecycleExecutor? _executor;

  @override
  @mustCallSuper
  void dispose() {
    _executor?.cancel();
    super.dispose();
  }

  void prepareExecutor() {
    _executor ??= StateLifecycleExecutor();
  }

  Future<T?> lifecycleExecute<T>(Future<T> future) {
    prepareExecutor();
    return _executor!.exec(future);
  }

  Future<T?> lifecycleExecuteUI<T>(Future<T> future) {
    prepareExecutor();
    return _executor!.execUi(future);
  }

  UniqueKey? lifecycleListen<T>(Stream<T> stream, void onData(T event)) {
    prepareExecutor();
    return _executor!.listen(stream, onData);
  }

  void lifecycleUnListen(UniqueKey key) {
    _executor?.unListen(key);
  }

  void delayTask(void callback(),
      {int days = 0,
      int hours = 0,
      int minutes = 0,
      int seconds = 0,
      int milliseconds = 0,
      int microseconds = 0}) {
    Timer(
        Duration(
            days: days,
            hours: hours,
            minutes: minutes,
            milliseconds: milliseconds,
            microseconds: microseconds),
        callback);
  }
}

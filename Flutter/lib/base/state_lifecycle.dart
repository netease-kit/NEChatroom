// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:voiceroomkit_ui/constants/consts.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

import '../utils/loading.dart';

class StateLifecycleExecutor {
  static const _tag = 'StateLifecycleExecutor';
  final Map<UniqueKey, CancelableOperation> _futures = {};

  final Map<UniqueKey, StreamSubscription> _subscriptions = {};

  bool _enable = true;

  Future<T?> execUi<T>(Future<T> future) {
    LoadingUtil.showLoading();
    return exec(future).whenComplete(() {
      LoadingUtil.hideLoading();
    });
  }

  Future<T?> exec<T>(Future<T> future) {
    if (!_enable) {
      return Future<T>.error('This Executor is disable');
    }

    UniqueKey key = UniqueKey();
    CancelableOperation<T> operation =
        CancelableOperation.fromFuture(future, onCancel: () {
      if (_enable) {
        _futures.remove(key);
      }
    });
    _futures.putIfAbsent(key, () => operation);

    operation.value.whenComplete(() {
      if (_enable) {
        _futures.remove(key);
      }
    });
    return operation.valueOrCancellation();
  }

  UniqueKey? listen<T>(Stream<T> stream, void Function(T event) onData) {
    if (!_enable) {
      return null;
    }

    UniqueKey key = UniqueKey();
    _subscriptions.putIfAbsent(key, () => stream.listen(onData));
    return key;
  }

  void unListen(UniqueKey key) {
    StreamSubscription? subscription = _subscriptions.remove(key);
    if (_enable) {
      subscription?.cancel();
    }
  }

  void cancel() {
    _disable();

    var iterable = _futures.values;
    for (var element in iterable) {
      element.cancel();
      Alog.d(
          tag: _tag, moduleName: moduleName, content: 'drop future: $element');
    }
    _futures.clear();
    for (var element in _subscriptions.values) {
      element.cancel();
      Alog.d(
          tag: _tag,
          moduleName: moduleName,
          content: 'drop subscriptions: $element');
    }
    _subscriptions.clear();
  }

  void _disable() {
    _enable = false;
  }
}

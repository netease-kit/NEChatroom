// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ToastUtils {
  static var style = const TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.w400);

  static var decoration = const ShapeDecoration(
      color: Color(0xBF1E1E1E),
      shape: RoundedRectangleBorder(
          /**side: BorderSide(color: Color(0xBF1E1E1E)),*/ borderRadius:
              BorderRadius.all(Radius.circular(4))));

  static var edgeInsets =
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0);

  static final _requests = ListQueue<_ToastRequest>();
  static bool _scheduled = false;

  static void showToast(
    BuildContext context,
    String? text, {
    Duration duration = const Duration(seconds: 2),
    bool dissmissOthers = false,
    bool atFrontOfQueue = false,
    Key? key,
  }) {
    if (text == null) return;

    if (dissmissOthers) {
      _requests.clear();
    }
    if (atFrontOfQueue) {
      _requests.addFirst(_ToastRequest(key, context, text, duration));
    } else {
      _requests.addLast(_ToastRequest(key, context, text, duration));
    }

    if (!_scheduled) {
      _scheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showNextToast();
      });
      SchedulerBinding.instance.ensureVisualUpdate();
    }
  }

  static void _showNextToast() {
    _scheduled = false;
    if (_requests.isEmpty) {
      return;
    }
    final request = _requests.removeFirst();
    final key = request.key;
    final context = request.context;
    final text = request.text;
    final duration = request.duration;
    _showToast(key, context, text, duration);
  }

  static void _showToast(
      Key? key, BuildContext context, String text, Duration duration) async {
    final overlayState = Overlay.of(context);
    if (overlayState != null && overlayState.mounted) {
      final entry = OverlayEntry(
        builder: (_) => Center(
          child: Container(
            padding: edgeInsets,
            decoration: decoration,
            child: Text(
              text,
              key: key,
              style: style,
            ),
          ),
        ),
      );
      overlayState.insert(entry);
      await Future.delayed(duration);
      entry.remove();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showNextToast();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }
}

class _ToastRequest {
  Key? key;

  BuildContext context;

  final String text;

  final Duration duration;

  _ToastRequest(this.key, this.context, this.text, this.duration);
}

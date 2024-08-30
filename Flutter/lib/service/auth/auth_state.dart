// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

/// auth state
class AuthState {
  static const int init = 0;

  static const int unauth = 1;

  static const int authed = 2;

  static const int logout = 3;

  static const int tokenIllegal = 4;

  static final AuthState _singleton = AuthState._internal();

  factory AuthState() => _singleton;

  int state = init;

  StreamController<AuthEvent> broadcast = StreamController.broadcast();

  AuthState._internal();

  Stream<AuthEvent> authState() {
    return broadcast.stream;
  }

  void updateState({required int state, String errorTip = ''}) {
    this.state = state;
    broadcast.add(AuthEvent(state, errorTip));
  }
}

class AuthEvent {
  final int state;
  final String errorTip;

  AuthEvent(this.state, this.errorTip);

  @override
  String toString() {
    return 'state=$state,errorTip=$errorTip';
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:bot_toast/bot_toast.dart';

class LoadingUtil {
  static void showLoading() {
    BotToast.showLoading();
  }

  static void hideLoading() {
    BotToast.closeAllLoading();
  }
}

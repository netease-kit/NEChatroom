// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';

import '../constants/colors.dart';

class DialogUtils {
  static Future showCommonDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String? cancelText,
      String? acceptText,
      bool canBack = true,
      bool isContentCenter = true}) {
    acceptText ??= S.of(context).sure;
    cancelText ??= S.of(context).cancel;
    return showDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return WillPopScope(
            child: CupertinoAlertDialog(
              title: TextUtils.isEmpty(title) ? null : Text(title),
              content: Text(content,
                  textAlign:
                      isContentCenter ? TextAlign.center : TextAlign.left),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(cancelText!),
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    cancelCallback();
                  },
                  textStyle: const TextStyle(color: AppColors.color_666666),
                ),
                CupertinoDialogAction(
                  child: Text(acceptText!),
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    acceptCallback();
                  },
                  textStyle: const TextStyle(color: AppColors.color_337eff),
                ),
              ],
            ),
            onWillPop: () async {
              return canBack;
            },
          );
        });
  }

  static void showEndLiveDialog(
    BuildContext context,
    String userName,
    VoidCallback cancelCallback,
    VoidCallback acceptCallback,
  ) {
    DialogUtils.showCommonDialog(
        context, S.of(context).endLive, S.of(context).sureEndLive, () {
      cancelCallback();
    }, () {
      acceptCallback();
    },
        cancelText: S.current.cancel,
        acceptText: S.current.sure,
        canBack: true,
        isContentCenter: true);
  }

  static Future<T?> showChildNavigatorDialog<T extends Object>(
      BuildContext context, Widget widgetPage) {
    return showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }

  static Future<T?> showChildNavigatorPopup<T extends Object>(
      BuildContext context, Widget widgetPage) {
    return showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (BuildContext context) {
          return widgetPage;
        });
  }

  static commonShowCupertinoDialog(BuildContext context, String title,
      String content, VoidCallback cancelCallback, VoidCallback acceptCallback,
      {String? sure, String? cancel, bool visi = true}) {
    sure ??= S.of(context).sure;
    cancel ??= S.of(context).cancel;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return Visibility(
            visible: visi,
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text(cancel!),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    cancelCallback();
                  },
                ),
                TextButton(
                  child: Text(sure!),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acceptCallback();
                  },
                ),
              ],
            ),
          );
        });
  }

  static commonShowOneChooseCupertinoDialog(BuildContext context, String title,
      String content, VoidCallback acceptCallback,
      {String? sure, bool visi = true}) {
    sure ??= S.of(context).sure;
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return Visibility(
            visible: visi,
            child: CupertinoAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text(sure!),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    acceptCallback();
                  },
                ),
              ],
            ),
          );
        });
  }
}

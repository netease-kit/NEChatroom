// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class TextUtils {
  static final regexLetterOrDigital = RegExp(r'^[0-9a-zA-Z]*$');
  static final regexLetter = RegExp(r'^[a-zA-Z]*$');
  static final regexDigital = RegExp(r'^[0-9]*$');

  static bool isEmpty(String? text) => text == null || text.isEmpty;

  static bool isNotEmpty(String? text) => text != null && text.isNotEmpty;

  static bool nonEmptyEquals(String? text1, String? text2) =>
      isNotEmpty(text1) && isNotEmpty(text2) && text1 == text2;

  static bool isLetter(String? text) =>
      isNotEmpty(text) && regexLetter.hasMatch(text!);

  static bool isDigital(String? text) =>
      isNotEmpty(text) && regexDigital.hasMatch(text!);

  static bool isLetterOrDigital(String? text) =>
      isNotEmpty(text) && regexLetterOrDigital.hasMatch(text!);
}

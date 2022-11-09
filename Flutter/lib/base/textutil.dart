// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:math';

class TextUtil {
  static bool isEmpty(String? text) {
    return text == null || text.isEmpty;
  }

  static bool equals(String text1, String text2) {
    if (isEmpty(text1) || isEmpty(text2)) {
      return false;
    }
    return Comparable.compare(text1, text2) == 0;
  }

  static String formatDigitPattern(String text,
      {int digit = 4, String pattern = ' '}) {
    text = text.replaceAllMapped(RegExp("(.{$digit})"), (Match match) {
      return "${match.group(0)}$pattern";
    });
    if (text.endsWith(pattern)) {
      text = text.substring(0, min(0, text.length - 1));
    }
    return text;
  }

  static String formatDigitPatternEnd(String text,
      {int digit = 4, String pattern = ' '}) {
    String temp = reverse(text);
    temp = formatDigitPattern(temp, digit: 3, pattern: ',');
    temp = reverse(temp);
    return temp;
  }

  static String formatSpace4(String text) {
    return formatDigitPattern(text);
  }

  static String formatComma3(Object num) {
    return formatDigitPatternEnd(num.toString(), digit: 3, pattern: ',');
  }

  static String hideNumber(String phoneNo,
      {int start = 3, int end = 7, String replacement = '****'}) {
    return phoneNo.replaceRange(start, end, replacement);
  }

  static String replace(String text, Pattern from, String replace) {
    return text.replaceAll(from, replace);
  }

  static List<String> split(String text, Pattern pattern) {
    return text.split(pattern);
  }

  static String reverse(String text) {
    if (isEmpty(text)) return '';
    StringBuffer sb = StringBuffer();
    for (int i = text.length - 1; i >= 0; i--) {
      sb.writeCharCode(text.codeUnitAt(i));
    }
    return sb.toString();
  }

  static String replaceAllBlank(String text) {
    if (isEmpty(text)) return '';
    return text.replaceAll(RegExp(r"\s+\b|\b\s"), "");
  }

  static String applyMask(String value, String mask) {
    String result = '';
    Map<String, RegExp> translator = getDefaultTranslator();
    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      var maskChar = mask[maskCharIndex];
      var valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar]!.hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return {
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  static String encodeBase64(String data) {
    var content = utf8.encode(data);
    var digest = base64Encode(content);
    return digest;
  }

  static String decodeBase64(String data) {
    return utf8.decode(base64Decode(data));
  }
}

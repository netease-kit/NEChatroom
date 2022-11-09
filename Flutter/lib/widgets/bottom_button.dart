// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class RoomBottomButton extends StatelessWidget {
  final String _icon;

  const RoomBottomButton(this._icon, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.6),
        border:
            Border.all(color: const Color.fromRGBO(0, 0, 0, 0.6), width: 0.5),
        shape: BoxShape.circle,
      ),
      child: Image(
        image: AssetImage(_icon),
        width: 36,
        height: 36,
      ),
    );
  }
}

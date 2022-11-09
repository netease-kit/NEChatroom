// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class LiveCircleButton extends StatelessWidget {
  final String _icon;
  final String _text;

  LiveCircleButton(this._icon, this._text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 0, 0, 0.6),
        border:
            Border.all(color: const Color.fromRGBO(0, 0, 0, 0.6), width: 0.5),
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 64,
        height: 40,
        child: Column(
          children: [
            Image(
              image: AssetImage(_icon),
              width: 64,
              height: 20,
            ),
            Text(
              _text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class FilterButton extends StatelessWidget {
  final String _icon;
  final String _text;
  final VoidCallback _onPress;
  final bool _isSelected;

  FilterButton(this._icon, this._text, this._onPress, this._isSelected);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: _onPress,
            child: Container(
              width: 30,
              height: 30,
              decoration: _isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(),
                    )
                  : const BoxDecoration(),
              child: ClipOval(
                child: Image(
                  image: AssetImage(_icon),
                  width: 30,
                  height: 30,
                ),
              ),
            )),
        Text(
          _text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10.0,
          ),
        ),
      ],
    );
  }
}

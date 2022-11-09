// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BottomSheetDialogCommon extends StatefulWidget {
  final Widget title;
  final Widget body;

  const BottomSheetDialogCommon(
      {Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  State<BottomSheetDialogCommon> createState() {
    return _BottomSheetDialogCommonState();
  }
}

class _BottomSheetDialogCommonState extends State<BottomSheetDialogCommon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildBottomToolViewMore(),
    );
  }

  Widget buildBottomToolViewMore() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final itemSpace = (width - 4 * 60 - 60) / 3;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: 48,
            child: widget.title,
          ),
          Container(
            color: AppColors.color_e6e7eb,
            height: 1,
          ),
          widget.body,
        ],
      ),
    );
  }
}

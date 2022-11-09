// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../base/lifecycle_base_state.dart';
import '../constants/colors.dart';

class AudienceTotalCount extends StatefulWidget {
  final int memberNum;
  const AudienceTotalCount({Key? key, required this.memberNum})
      : super(key: key);

  @override
  State<AudienceTotalCount> createState() {
    return _AudienceTotalCountState();
  }
}

class _AudienceTotalCountState extends LifecycleBaseState<AudienceTotalCount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      alignment: Alignment.bottomRight,
      decoration: BoxDecoration(
        color: AppColors.color_ff0C0C0D,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Text(
          widget.memberNum.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.white, fontSize: 12),
        ),
      ),
    );
  }
}

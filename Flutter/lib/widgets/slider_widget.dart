// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

import 'package:voiceroomkit_ui/constants/colors.dart';
import 'package:voiceroomkit_ui/widgets/round_slider_trackshape.dart';

class SliderWidget extends StatefulWidget {
  final String? title;
  final Function(int value) onChange;
  int level;
  final bool? isShowClose;
  final String? path;

  SliderWidget(
      {Key? key,
      this.title,
      required this.onChange,
      required this.level,
      this.isShowClose,
      this.path})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SliderDemo();
}

class _SliderDemo extends State<SliderWidget> {
  bool isOpenBeauty = false;

  Widget _buildTitle() {
    if (TextUtils.isNotEmpty(widget.title)) {
      return Text(widget.title!,
          style: const TextStyle(
              color: AppColors.black_222222,
              fontSize: 14,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500));
    } else if (TextUtils.isNotEmpty(widget.path)) {
      return Image(
          image: AssetImage(widget.path!),
          color: AppColors.color_222222,
          width: 16,
          height: 16);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      const SizedBox(
        width: 20,
      ),
      _buildTitle(),
      const SizedBox(
        width: 10,
      ),
      Expanded(
        child: SliderTheme(
            //自定义风格
            data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xff337EFF),
                inactiveTrackColor: const Color(0xffF0F0F2),
                trackShape: const RoundSliderTrackShape(radius: 5),
                thumbColor: Colors.white,
                overlayColor: const Color.fromRGBO(51, 126, 255, 0.70),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 12,
                ),
                thumbShape: const RoundSliderThumbShape(
                  disabledThumbRadius: 10,
                  enabledThumbRadius: 10,
                ),
                inactiveTickMarkColor: Colors.black,
                tickMarkShape: const RoundSliderTickMarkShape(
                  tickMarkRadius: 2.0,
                ),
                showValueIndicator: ShowValueIndicator.onlyForDiscrete,
                valueIndicatorColor: Colors.red,
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                trackHeight: 4),
            child: Slider(
              // key: MeetingCoreValueKey.beautyLevelSlider,
              value: widget.level.toDouble(),
              min: 0,
              max: 100,
              label: '${widget.level}',
              onChanged: (double newValue) {
                setState(() {
                  widget.level = newValue.round();
                  isOpenBeauty = widget.level != 0;
                });
                widget.onChange(widget.level);
              },
            )),
      ),
      const SizedBox(
        width: 20,
      ),
    ]);
  }

  Widget line() {
    return Container(
      color: Colors.white,
      child: Container(
        color: AppColors.color_ffe8e9eb,
        height: 0.5,
      ),
    );
  }
}

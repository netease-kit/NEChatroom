// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../generated/l10n.dart';
import '../constants/colors.dart';

class LiveListFooter extends Footer {
  /// Key
  final Key? key;
  final AlignmentGeometry? alignment;
  final String? loadText;

  final String? loadReadyText;

  final String? loadingText;

  final String? loadedText;

  final String? loadFailedText;

  final String? noMoreText;

  final bool showInfo;

  final String? infoText;

  final Color bgColor;

  final Color textColor;

  final Color darkTextColor;

  final Color infoColor;

  final bool isLight;

  LiveListFooter(
      {double extent = 60.0,
      double triggerDistance = 70.0,
      bool float = false,
      Duration? completeDuration = const Duration(seconds: 1),
      bool enableInfiniteLoad = true,
      bool enableHapticFeedback = true,
      bool overScroll = false,
      bool safeArea = true,
      EdgeInsets? padding,
      this.key,
      this.alignment,
      this.loadText,
      this.loadReadyText,
      this.loadingText,
      this.loadedText,
      this.loadFailedText,
      this.noMoreText,
      this.showInfo: true,
      this.infoText,
      this.bgColor: Colors.transparent,
      this.textColor: AppColors.white_50_ffffff,
      this.darkTextColor = AppColors.black_50_000000,
      this.infoColor: Colors.teal,
      this.isLight = true})
      : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: completeDuration,
          enableInfiniteLoad: enableInfiniteLoad,
          enableHapticFeedback: enableHapticFeedback,
          overScroll: overScroll,
          safeArea: safeArea,
          padding: padding,
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      LoadMode loadState,
      double pulledExtent,
      double loadTriggerPullDistance,
      double loadIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteLoad,
      bool success,
      bool noMore) {
    return LiveFooterWidget(
      key: key,
      classicalFooter: this,
      loadState: loadState,
      pulledExtent: pulledExtent,
      loadTriggerPullDistance: loadTriggerPullDistance,
      loadIndicatorExtent: loadIndicatorExtent,
      axisDirection: axisDirection,
      float: float,
      completeDuration: completeDuration,
      enableInfiniteLoad: enableInfiniteLoad,
      success: success,
      noMore: noMore,
    );
  }
}

class LiveFooterWidget extends StatefulWidget {
  final LiveListFooter classicalFooter;
  final LoadMode loadState;
  final double pulledExtent;
  final double loadTriggerPullDistance;
  final double loadIndicatorExtent;
  final AxisDirection axisDirection;
  final bool float;
  final Duration? completeDuration;
  final bool enableInfiniteLoad;
  final bool success;
  final bool noMore;

  LiveFooterWidget(
      {Key? key,
      required this.loadState,
      required this.classicalFooter,
      required this.pulledExtent,
      required this.loadTriggerPullDistance,
      required this.loadIndicatorExtent,
      required this.axisDirection,
      required this.float,
      this.completeDuration,
      required this.enableInfiniteLoad,
      required this.success,
      required this.noMore})
      : super(key: key);

  @override
  LiveFooterWidgetState createState() => LiveFooterWidgetState();
}

class LiveFooterWidgetState extends State<LiveFooterWidget>
    with TickerProviderStateMixin<LiveFooterWidget> {
  bool _overTriggerDistance = false;

  bool get overTriggerDistance => _overTriggerDistance;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance
          ? _readyController.forward()
          : _restoreController.forward();
    }
    _overTriggerDistance = over;
  }

  String get _loadText {
    return widget.classicalFooter.loadText ?? S.of(context).pushToLoad;
  }

  String get _loadReadyText {
    return widget.classicalFooter.loadReadyText ?? S.of(context).releaseToLoad;
  }

  String get _loadingText {
    return widget.classicalFooter.loadingText ?? S.of(context).loading;
  }

  String get _loadedText {
    return widget.classicalFooter.loadedText ?? S.of(context).loaded;
  }

  String get _loadFailedText {
    return widget.classicalFooter.loadFailedText ?? S.of(context).loadFailed;
  }

  String get _noMoreText {
    return widget.classicalFooter.noMoreText ?? S.of(context).noMore;
  }

  late AnimationController _readyController;
  late Animation<double> _readyAnimation;
  late AnimationController _restoreController;
  late Animation<double> _restoreAnimation;

  String get _showText {
    if (widget.noMore) return _noMoreText;
    if (widget.enableInfiniteLoad) {
      if (widget.loadState == LoadMode.loaded ||
          widget.loadState == LoadMode.inactive ||
          widget.loadState == LoadMode.drag) {
        return _finishedText;
      } else {
        return _loadingText;
      }
    }
    switch (widget.loadState) {
      case LoadMode.load:
        return _loadingText;
      case LoadMode.armed:
        return _loadingText;
      case LoadMode.loaded:
        return _finishedText;
      case LoadMode.done:
        return _finishedText;
      default:
        if (overTriggerDistance) {
          return _loadReadyText;
        } else {
          return _loadText;
        }
    }
  }

  String get _finishedText {
    if (!widget.success) return _loadFailedText;
    if (widget.noMore) return _noMoreText;
    return _loadedText;
  }

  @override
  void initState() {
    super.initState();
    _readyController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _restoreController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  void dispose() {
    _readyController.dispose();
    _restoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVertical = widget.axisDirection == AxisDirection.down ||
        widget.axisDirection == AxisDirection.up;
    bool isReverse = widget.axisDirection == AxisDirection.up ||
        widget.axisDirection == AxisDirection.left;
    overTriggerDistance = widget.loadState != LoadMode.inactive &&
        widget.pulledExtent >= widget.loadTriggerPullDistance;
    return Stack(
      children: <Widget>[
        Positioned(
          top: !isVertical
              ? 0.0
              : !isReverse
                  ? 0.0
                  : null,
          bottom: !isVertical
              ? 0.0
              : isReverse
                  ? 0.0
                  : null,
          left: isVertical
              ? 0.0
              : !isReverse
                  ? 0.0
                  : null,
          right: isVertical
              ? 0.0
              : isReverse
                  ? 0.0
                  : null,
          child: Container(
            alignment: widget.classicalFooter.alignment ??
                (isVertical
                    ? !isReverse
                        ? Alignment.topCenter
                        : Alignment.bottomCenter
                    : isReverse
                        ? Alignment.centerRight
                        : Alignment.centerLeft),
            width: !isVertical
                ? widget.loadIndicatorExtent > widget.pulledExtent
                    ? widget.loadIndicatorExtent
                    : widget.pulledExtent
                : double.infinity,
            height: isVertical
                ? widget.loadIndicatorExtent > widget.pulledExtent
                    ? widget.loadIndicatorExtent
                    : widget.pulledExtent
                : double.infinity,
            color: widget.classicalFooter.bgColor,
            child: SizedBox(
              height: isVertical ? widget.loadIndicatorExtent : double.infinity,
              width: !isVertical ? widget.loadIndicatorExtent : double.infinity,
              child: isVertical
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContent(bool isVertical, bool isReverse) {
    return isVertical
        ? <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _showText,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: widget.classicalFooter.isLight
                          ? widget.classicalFooter.textColor
                          : widget.classicalFooter.darkTextColor,
                    ),
                  )
                ],
              ),
            ),
          ]
        : <Widget>[];
  }
}

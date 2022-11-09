// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../generated/l10n.dart';
import '../constants/asset_name.dart';
import '../constants/colors.dart';

class LiveListHeader extends Header {
  final Key? key;

  final AlignmentGeometry? alignment;

  final String? refreshText;

  final String? refreshReadyText;

  final String? refreshingText;

  final String? refreshedText;

  final String? refreshFailedText;

  final String? noMoreText;

  /// Display additional information (default time)
  final bool showInfo;

  /// For more information
  final String? infoText;

  final Color bgColor;

  final Color textColor;

  final Color darkTextColor;

  /// Text color for more information
  final Color infoColor;

  final bool isLight;

  LiveListHeader(
      {double extent = 60.0,
      double triggerDistance = 70.0,
      bool float = false,
      Duration? completeDuration = const Duration(seconds: 1),
      bool enableInfiniteRefresh = false,
      bool enableHapticFeedback = true,
      bool overScroll = true,
      this.key,
      this.alignment,
      this.refreshText,
      this.refreshReadyText,
      this.refreshingText,
      this.refreshedText,
      this.refreshFailedText,
      this.noMoreText,
      this.showInfo = true,
      this.infoText,
      this.bgColor = Colors.transparent,
      this.textColor = AppColors.white_50_ffffff,
      this.darkTextColor = AppColors.black_50_000000,
      this.infoColor = Colors.teal,
      this.isLight = true})
      : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: float
              ? completeDuration == null
                  ? const Duration(
                      milliseconds: 400,
                    )
                  : completeDuration +
                      const Duration(
                        milliseconds: 400,
                      )
              : completeDuration,
          enableInfiniteRefresh: enableInfiniteRefresh,
          enableHapticFeedback: enableHapticFeedback,
          overScroll: overScroll,
        );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    return ClassicalHeaderWidget(
      key: key,
      classicalHeader: this,
      refreshState: refreshState,
      pulledExtent: pulledExtent,
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      axisDirection: axisDirection,
      float: float,
      completeDuration: completeDuration,
      enableInfiniteRefresh: enableInfiniteRefresh,
      success: success,
      noMore: noMore,
    );
  }
}

class ClassicalHeaderWidget extends StatefulWidget {
  final LiveListHeader classicalHeader;
  final RefreshMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final AxisDirection axisDirection;
  final bool float;
  final Duration? completeDuration;
  final bool enableInfiniteRefresh;
  final bool success;
  final bool noMore;

  ClassicalHeaderWidget(
      {Key? key,
      required this.refreshState,
      required this.classicalHeader,
      required this.pulledExtent,
      required this.refreshTriggerPullDistance,
      required this.refreshIndicatorExtent,
      required this.axisDirection,
      required this.float,
      required this.completeDuration,
      required this.enableInfiniteRefresh,
      required this.success,
      required this.noMore})
      : super(key: key);

  @override
  ClassicalHeaderWidgetState createState() => ClassicalHeaderWidgetState();
}

class ClassicalHeaderWidgetState extends State<ClassicalHeaderWidget>
    with TickerProviderStateMixin<ClassicalHeaderWidget> {
  // Whether the trigger refresh distance is reached
  bool _overTriggerDistance = false;

  bool get overTriggerDistance => _overTriggerDistance;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance
          ? _readyController.forward()
          : _restoreController.forward();
      _overTriggerDistance = over;
    }
  }

  String get _refreshText {
    return widget.classicalHeader.refreshText ?? S.of(context).pullToRefresh;
  }

  String get _refreshReadyText {
    return widget.classicalHeader.refreshReadyText ??
        S.of(context).releaseToRefresh;
  }

  String get _refreshingText {
    return widget.classicalHeader.refreshingText ?? S.of(context).refreshing;
  }

  String get _refreshedText {
    return widget.classicalHeader.refreshedText ??
        S.of(context).refreshCompleted;
  }

  String get _refreshFailedText {
    return widget.classicalHeader.refreshFailedText ??
        S.of(context).refreshFailed;
  }

  String get _noMoreText {
    return widget.classicalHeader.noMoreText ?? S.of(context).noMore;
  }

  String get _infoText {
    return widget.classicalHeader.infoText ?? S.of(context).updateAt;
  }

  // Is refresh complete
  bool _refreshFinish = false;

  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish && widget.float) {
        Future.delayed(
            widget.completeDuration! - const Duration(milliseconds: 400), () {
          if (mounted) {
            _floatBackController.forward();
          }
        });
        Future.delayed(widget.completeDuration!, () {
          _floatBackDistance = null;
          _refreshFinish = false;
        });
      }
      _refreshFinish = finish;
    }
  }

  // Animation
  late AnimationController _readyController;
  late Animation<double> _readyAnimation;
  late AnimationController _restoreController;
  late Animation<double> _restoreAnimation;
  late AnimationController _floatBackController;
  late Animation<double> _floatBackAnimation;

  // Icon rotation value
  double _iconRotationValue = 1.0;

  // When floating, fold up distance
  double? _floatBackDistance;

  String get _showText {
    if (widget.noMore) return _noMoreText;
    if (widget.enableInfiniteRefresh) {
      if (widget.refreshState == RefreshMode.refreshed ||
          widget.refreshState == RefreshMode.inactive ||
          widget.refreshState == RefreshMode.drag) {
        return _finishedText;
      } else {
        return _refreshingText;
      }
    }
    switch (widget.refreshState) {
      case RefreshMode.refresh:
        return _refreshingText;
      case RefreshMode.armed:
        return _refreshingText;
      case RefreshMode.refreshed:
        return _finishedText;
      case RefreshMode.done:
        return _finishedText;
      default:
        if (overTriggerDistance) {
          return _refreshReadyText;
        } else {
          return _refreshText;
        }
    }
  }

  String get _finishedText {
    if (!widget.success) return _refreshFailedText;
    if (widget.noMore) return _noMoreText;
    return _refreshedText;
  }

  IconData get _finishedIcon {
    if (!widget.success) return Icons.error_outline;
    if (widget.noMore) return Icons.hourglass_empty;
    return Icons.done;
  }

  late DateTime _dateTime;

  String get _infoTextStr {
    if (widget.refreshState == RefreshMode.refreshed) {
      _dateTime = DateTime.now();
    }
    String fillChar = _dateTime.minute < 10 ? "0" : "";
    return _infoText.replaceAll(
        "%T", "${_dateTime.hour}:$fillChar${_dateTime.minute}");
  }

  @override
  void initState() {
    super.initState();
    // Initialization time
    _dateTime = DateTime.now();
    // Prepare the animation
    _readyController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _readyAnimation = Tween(begin: 0.5, end: 1.0).animate(_readyController)
      ..addListener(() {
        setState(() {
          if (_readyAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _readyAnimation.value;
          }
        });
      });
    _readyAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _readyController.reset();
      }
    });
    // Restore the animation
    _restoreController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _restoreAnimation = Tween(begin: 1.0, end: 0.5).animate(_restoreController)
      ..addListener(() {
        setState(() {
          if (_restoreAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _restoreAnimation.value;
          }
        });
      });
    _restoreAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _restoreController.reset();
      }
    });
    // Float collapse animation
    _floatBackController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _floatBackAnimation = Tween(begin: widget.refreshIndicatorExtent, end: 0.0)
        .animate(_floatBackController)
      ..addListener(() {
        setState(() {
          if (_floatBackAnimation.status != AnimationStatus.dismissed) {
            _floatBackDistance = _floatBackAnimation.value;
          }
        });
      });
    _floatBackAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _floatBackController.reset();
      }
    });
  }

  @override
  void dispose() {
    _readyController.dispose();
    _restoreController.dispose();
    _floatBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isVertical = widget.axisDirection == AxisDirection.down ||
        widget.axisDirection == AxisDirection.up;
    bool isReverse = widget.axisDirection == AxisDirection.up ||
        widget.axisDirection == AxisDirection.left;
    // Whether the trigger refresh distance is reached
    overTriggerDistance = widget.refreshState != RefreshMode.inactive &&
        widget.pulledExtent >= widget.refreshTriggerPullDistance;
    if (widget.refreshState == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: !isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          bottom: !isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          left: isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          right: isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          child: Container(
            alignment: widget.classicalHeader.alignment ??
                (isVertical
                    ? isReverse
                        ? Alignment.topCenter
                        : Alignment.bottomCenter
                    : !isReverse
                        ? Alignment.centerRight
                        : Alignment.centerLeft),
            width: isVertical
                ? double.infinity
                : _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent
                        ? widget.refreshIndicatorExtent
                        : widget.pulledExtent)
                    : widget.refreshIndicatorExtent,
            height: isVertical
                ? _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent
                        ? widget.refreshIndicatorExtent
                        : widget.pulledExtent)
                    : widget.refreshIndicatorExtent
                : double.infinity,
            color: widget.classicalHeader.bgColor,
            child: SizedBox(
              height:
                  isVertical ? widget.refreshIndicatorExtent : double.infinity,
              width:
                  !isVertical ? widget.refreshIndicatorExtent : double.infinity,
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

  // Building display content
  List<Widget> _buildContent(bool isVertical, bool isReverse) {
    return isVertical
        ? <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(
                  right: 0.0,
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(AssetName.iconLoading),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _showText,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: widget.classicalHeader.isLight
                          ? widget.classicalHeader.textColor
                          : widget.classicalHeader.darkTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ]
        : <Widget>[
            Container(
              child: widget.refreshState == RefreshMode.refresh ||
                      widget.refreshState == RefreshMode.armed
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation(
                          widget.classicalHeader.textColor,
                        ),
                      ),
                    )
                  : widget.refreshState == RefreshMode.refreshed ||
                          widget.refreshState == RefreshMode.done ||
                          (widget.enableInfiniteRefresh &&
                              widget.refreshState != RefreshMode.refreshed) ||
                          widget.noMore
                      ? Icon(
                          _finishedIcon,
                          color: widget.classicalHeader.textColor,
                        )
                      : Transform.rotate(
                          child: Icon(
                            isReverse ? Icons.arrow_back : Icons.arrow_forward,
                            color: widget.classicalHeader.textColor,
                          ),
                          angle: 2 * pi * _iconRotationValue,
                        ),
            )
          ];
  }
}

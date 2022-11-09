// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:voiceroomkit_ui/generated/l10n.dart';
import 'package:voiceroomkit_ui/constants/asset_name.dart';
import 'package:voiceroomkit_ui/constants/colors.dart';
import 'package:voiceroomkit_ui/widgets/bottom_sheet_dialog_common.dart';
import 'package:voiceroomkit_ui/widgets/slider_widget.dart';
import 'package:voiceroomkit_ui/viewmodel/background_music_viewmodel.dart';

class BottomSheetDialogMusic extends StatefulWidget {
  final AudioMaxing audioMaxing;

  const BottomSheetDialogMusic({Key? key, required this.audioMaxing})
      : super(key: key);

  @override
  State<BottomSheetDialogMusic> createState() {
    return _BottomSheetDialogMusicState();
  }
}

class _BottomSheetDialogMusicState extends State<BottomSheetDialogMusic> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) {
      var viewModel = BackgroundMusicViewModel();
      viewModel.audioMaxing = widget.audioMaxing;
      return viewModel;
    }, builder: (context, child) {
      return buildBottomToolViewMore(context.watch<BackgroundMusicViewModel>());
    });
  }

  Widget buildBottomToolViewMore(BackgroundMusicViewModel viewModel) {
    return BottomSheetDialogCommon(
        title: Text(
          S.of(context).backgroundMusic,
          style: TextStyle(fontSize: 16, color: AppColors.black_333333),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 20, top: 12, right: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: _effectButton(
                          AssetName.applauseIcon, S.of(context).applause, () {
                    viewModel.playEffect(0);
                  })),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _effectButton(
                          AssetName.laughterIcon, S.of(context).laughter, () {
                    viewModel.playEffect(1);
                  })),
                ],
              ),
            ),
            Container(
              color: AppColors.color_e6e7eb,
              height: 1,
            ),
            Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                        itemCount: viewModel.musicItem.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return _getMusicItem(i, viewModel, () {
                            viewModel.playAudioMixing(i);
                          });
                        }),
                    const SizedBox(height: 12),
                    _buildFooter(viewModel),
                    const SizedBox(height: 12),
                  ],
                )),
          ],
        ));
  }

  Widget _getMusicItem(
      int index, BackgroundMusicViewModel viewModel, Function callback) {
    var isSelected = viewModel.audioMaxing.musicSelectedIndex == index;
    return InkWell(
      onTap: () => callback(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: _getMusicHeaderState(index, viewModel),
                ),
                Text(viewModel.musicItem[index].name,
                    style: TextStyle(
                        color: isSelected ? AppColors.blue_337eff : null)),
              ],
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: Text(
                viewModel.musicItem[index].singer,
                style: const TextStyle(color: AppColors.color_999999),
              ),
              padding: const EdgeInsets.only(left: 30, bottom: 8)),
          Container(
            color: AppColors.color_e6e7eb,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _getMusicHeaderState(int index, BackgroundMusicViewModel viewModel) {
    String text = '0${index + 1}';
    if (viewModel.audioMaxing.musicSelectedIndex != index) {
      return Text(text, style: const TextStyle(color: AppColors.color_999999));
    } else if (viewModel.isMusicPlaying()) {
      return Lottie.asset(AssetName.musicPlaying, width: 24, height: 18);
    } else {
      return Text(text, style: const TextStyle(color: AppColors.blue_337eff));
    }
  }

  Widget _effectButton(String iconPath, String content, Function onPress) {
    return Container(
        padding: const EdgeInsets.only(top: 7, bottom: 7),
        decoration: const BoxDecoration(
            color: AppColors.color_f2f3f5,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: GestureDetector(
          onTap: () => onPress(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(width: 20, height: 20, image: AssetImage(iconPath)),
              const SizedBox(width: 3),
              Text(content),
            ],
          ),
        ));
  }

  Widget _buildFooter(BackgroundMusicViewModel viewModel) {
    return Row(
      children: [
        Expanded(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
          _getMusicButton(
              viewModel.isMusicPlaying()
                  ? AssetName.iconBottomMoreMusicPause
                  : AssetName.iconBottomMoreMusicPlay, () {
            if (viewModel.isMusicPlaying()) {
              viewModel.pauseAudioMixing();
            } else if (viewModel.isMusicPaused()) {
              viewModel.resumeAudioMixing();
            } else {
              viewModel.playAudioMixing(0);
            }
          }),
          const SizedBox(width: 12),
          _getMusicButton(
              AssetName.iconBottomMoreMusicNext, () => viewModel.nextSong()),
        ])),
        Expanded(
            child: SliderWidget(
          onChange: (value) {
            viewModel.setVolume(value);
          },
          level: viewModel.audioMaxing.volume,
          path: AssetName.iconBottomMoreMusicVolume,
        ))
      ],
    );
  }

  Widget _getMusicButton(String path, Function onPress) {
    return Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(),
        decoration: const BoxDecoration(
          color: AppColors.global_bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconButton(
            onPressed: () => onPress(),
            icon: Image.asset(path),
          ),
        ));
  }
}

// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../constants/asset_name.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 20),
        child: SafeArea(
          child: Container(
            height: 80,
            alignment: Alignment.center,
            child: Image(
              width: 250,
              height: 35,
              image: AssetImage(AppConfig().isZh
                  ? AssetName.iconHomePageLogoZH
                  : AssetName.iconHomePageLogoEN),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

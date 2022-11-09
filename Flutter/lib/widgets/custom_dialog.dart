// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class CustomDialog extends Dialog {
  final String title;
  final String content;

  const CustomDialog(this.title, this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Center(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                height: 300,
                width: 300,
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                this.title,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              )),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: Icon(Icons.close),
                              onTap: () => {Navigator.pop(context)},
                            ),
                          )
                        ],
                      )),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    width: double.infinity,
                    child: Text(
                      '${this.content}',
                      textAlign: TextAlign.left,
                    ),
                  )
                ]))));
  }
}

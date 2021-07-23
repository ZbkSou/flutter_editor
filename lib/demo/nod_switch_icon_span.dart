import 'dart:ui';

import 'package:flutter/material.dart';

import '../special_text_span_builder.dart';

///
///  nod_switch_icon_span
///  @author: DreamilyAI
///  @description:
///  Created by zhao on2021/7/21 .


class NodSwitchIconSpan extends SpecialText {
  NodSwitchIconSpan(TextStyle textStyle, this.count,{SpecialTextGestureTapCallback? onTap}) : super(textStyle,onTap:onTap);


  final int? count ;
  bool isCheck = false;


  @override
  InlineSpan finishText() {

    return WidgetSpan(
        child:InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            isCheck = !isCheck;
          },
          child: Container(
            width: 20,
            height: 20,
            child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: isCheck ? 1 : 0.3,
                      child: Image.asset(
                        "images/icon_平行世界_续写气泡.png",
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "${count}",
                      style: new TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                ]),
          ),
        ));

  }
}
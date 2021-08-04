import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/painting/inline_span.dart';
import 'package:flutter/src/painting/text_style.dart';

import '../special_text_span.dart';
import '../special_text_span_builder.dart';

///
///  red_text
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/7/15 .


class RedText   extends SpecialText {
  RedText(TextStyle textStyle,{SpecialTextGestureTapCallback? onTap}) : super(textStyle,onTap:onTap);


  @override
  InlineSpan finishText() {
    final String text = getContent();

    return SpecialTextSpan(
        text: text,
        style: textStyle.copyWith(color:Colors.red),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap!(toString());
            }
          });
  }


}
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_editor/special_inline_span_base.dart';

///
///  special_text_span
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/8/3 .


class SpecialTextSpan  extends TextSpan with SpecialInlineSpanBase {
  SpecialTextSpan({
    TextStyle? style,
    required String text,
    String? actualText,
    GestureRecognizer? recognizer,
    List<InlineSpan>? children,
    String? semanticsLabel,
    MouseCursor? mouseCursor,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
  })  :

        actualText = actualText ?? text,

        super(
        style: style,
        text: text,
        recognizer: recognizer,
        children: children,
        semanticsLabel: semanticsLabel,
        mouseCursor: mouseCursor,
        onEnter: onEnter,
        onExit: onExit,
      );

  @override
  final String actualText;



  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (super != other) {
      return false;
    }
    return other is SpecialInlineSpanBase && equal(other);
  }


  @override
  RenderComparison compareTo(InlineSpan other) {
    RenderComparison comparison = super.compareTo(other);
    if (comparison == RenderComparison.identical) {
      comparison = baseCompareTo(other as SpecialInlineSpanBase);
    }
    return comparison;
  }
}
import 'package:flutter/material.dart';

///
///  special_inline_span_base
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/8/3 .


abstract class SpecialInlineSpanBase {
  /// actual text
  String get actualText;

  bool equal(SpecialInlineSpanBase other) {
    return
        other.actualText == actualText;
  }

  RenderComparison baseCompareTo(SpecialInlineSpanBase other) {
    if (other.actualText != actualText) {
      return RenderComparison.paint;
    }
    return RenderComparison.identical;
  }




}
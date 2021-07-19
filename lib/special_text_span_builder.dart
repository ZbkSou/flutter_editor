import 'package:flutter/widgets.dart';

import 'special_text_content.dart';

///
///  special_text_span_builder
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/7/2 .

typedef SpecialTextGestureTapCallback = void Function(dynamic parameter);
abstract class SpecialTextSpanBuilder {

  TextSpan build(
      {SpecialTextContentList ? specialTextContentList,TextStyle? textStyle, SpecialTextGestureTapCallback? onTap}) {
    final List<InlineSpan> inlineList = <InlineSpan>[];

    return TextSpan(children: inlineList, style: textStyle);
  }


  VoidCallback? rebuildCallback;

  /// start with SpecialText
  bool isStart(String value, String startFlag) {
    return value.endsWith(startFlag);
  }
}


///appendContent 增加内容
///finishText 获得InlineSpan
abstract class SpecialText {
  SpecialText(this.textStyle, {this.onTap})
      : _content = StringBuffer();
  final StringBuffer _content;


  /// TextStyle of SpecialText
  final TextStyle textStyle;

  /// tap call back of SpecialText
  final SpecialTextGestureTapCallback? onTap;

  /// finish SpecialText
  InlineSpan finishText();


  /// append text of SpecialText
  void appendContent(String value) {
    _content.write(value);
  }

  /// get content of SpecialText(not include startFlag and endFlag)
  /// https://github.com/fluttercandies/extended_text/issues/76
  String getContent() {
    String content = _content.toString();
    return content;
  }


}


import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_editor/demo/red_text.dart';
import '../special_text_content.dart';
import '../special_text_span_builder.dart';
import 'nod_switch_icon_span.dart';

///
///  my_special_text_span_builder
///  @author: flutter_editor
///  @description:
///  Created by zhao on2021/7/15 .


class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {

  @override
  TextSpan build({SpecialTextContentList? specialTextContentList,
      TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap}) {
    final List<InlineSpan> inlineList = <InlineSpan>[];
    SpecialText? specialText;

    if(specialTextContentList==null){
      return TextSpan(children: inlineList, style: textStyle);
    }

    for(SpecialTextContent content in specialTextContentList.list){

      switch(content.type){
        case 0:
          inlineList.add(TextSpan(text: content.text, style: textStyle));
          break;
        case 1:
          specialText = RedText(textStyle!, onTap:onTap);
          specialText.appendContent(content.text);
          inlineList.add(specialText.finishText());
          specialText = null;
          break;
          case 2:
        specialText = NodSwitchIconSpan(textStyle!,int.parse(content.hint??"0"));
        inlineList.add(specialText.finishText());
        specialText = null;
        break;
      }

    }
    return TextSpan(children: inlineList, style: textStyle);
  }
}
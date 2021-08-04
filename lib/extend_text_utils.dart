import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_editor/special_inline_span_base.dart';

import 'special_text_span_builder.dart';


const String zeroWidthSpace = '\u{200B}';

TextPosition convertTextInputPostionToTextPainterPostion(
    InlineSpan text, TextPosition textPosition) {
  int caretOffset = textPosition.offset;
  int textOffset = 0;
  text.visitChildren((InlineSpan ts) {
    if (ts is SpecialInlineSpanBase) {
      final int length = (ts as SpecialInlineSpanBase).actualText.length;
      caretOffset -= length - getInlineOffset(ts);
      textOffset += length;
    } else {
      textOffset += getInlineOffset(ts);
    }
    if (textOffset >= textPosition.offset) {
      return false;
    }
    return true;
  });
  if (caretOffset != textPosition.offset) {
    return TextPosition(
        offset: max(0, caretOffset), affinity: textPosition.affinity);
  }

  return textPosition;
}

TextSelection convertTextInputSelectionToTextPainterSelection(
    InlineSpan text, TextSelection selection) {
  if (selection.isValid) {
    if (selection.isCollapsed) {
      final TextPosition extent =
          convertTextInputPostionToTextPainterPostion(text, selection.extent);
      if (selection.extent != extent) {
        selection = selection.copyWith(
            baseOffset: extent.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    } else {
      final TextPosition extent =
          convertTextInputPostionToTextPainterPostion(text, selection.extent);

      final TextPosition base =
          convertTextInputPostionToTextPainterPostion(text, selection.base);

      if (selection.extent != extent || selection.base != base) {
        selection = selection.copyWith(
            baseOffset: base.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    }
  }

  return selection;
}


bool hasSpecialText(InlineSpan textSpan) {
  return hasT<SpecialInlineSpanBase>(textSpan);
}

bool hasT<T>(InlineSpan? textSpan) {
  if (textSpan == null) {
    return false;
  }
  if (textSpan is T) {
    return true;
  }
  if (textSpan is TextSpan && textSpan.children != null) {
    for (final InlineSpan ts in textSpan.children!) {
      final bool has = hasT<T>(ts);
      if (has) {
        return true;
      }
    }
  }
  return false;
}

TextPosition? convertTextPainterPostionToTextInputPostion(
    InlineSpan text, TextPosition? textPosition,
    {bool? end}) {
  if (textPosition != null) {
    int caretOffset = textPosition.offset;
    if (caretOffset <= 0) {
      return textPosition;
    }
    int textOffset = 0;
    text.visitChildren((InlineSpan ts) {
      if (ts is SpecialInlineSpanBase) {
        final SpecialInlineSpanBase specialTs = ts as SpecialInlineSpanBase;
        final int length = specialTs.actualText.length;
        caretOffset += length - getInlineOffset(ts);


      }
      textOffset += getInlineOffset(ts);
      if (textOffset >= textPosition.offset) {
        return false;
      }
      return true;
    });

    if (caretOffset != textPosition.offset) {
      return TextPosition(offset: caretOffset, affinity: textPosition.affinity);
    }
  }
  return textPosition;
}

TextSelection convertTextPainterSelectionToTextInputSelection(
    InlineSpan text, TextSelection selection,
    {bool selectWord = false}) {
  if (selection.isValid) {
    if (selection.isCollapsed) {
      final TextPosition? extent =
      convertTextPainterPostionToTextInputPostion(text, selection.extent);
      if (selection.extent != extent) {
        selection = selection.copyWith(
            baseOffset: extent!.offset,
            extentOffset: extent.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    } else {
      final TextPosition? extent = convertTextPainterPostionToTextInputPostion(
          text, selection.extent,
          end: selectWord ? true : null);

      final TextPosition? base = convertTextPainterPostionToTextInputPostion(
          text, selection.base,
          end: selectWord ? false : null);

      if (selection.extent != extent || selection.base != base) {
        selection = selection.copyWith(
            baseOffset: base!.offset,
            extentOffset: extent!.offset,
            affinity: selection.affinity,
            isDirectional: selection.isDirectional);
        return selection;
      }
    }
  }

  return selection;
}


int getInlineOffset(InlineSpan inlineSpan) {
  if (inlineSpan is TextSpan && inlineSpan.text != null) {
    return inlineSpan.text!.length;
  }
  if (inlineSpan is PlaceholderSpan) {
    return 1;
  }
  return 0;
}


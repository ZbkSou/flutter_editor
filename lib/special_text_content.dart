import 'package:flutter/cupertino.dart';

///
///  special_text_content
///  @author: flutter_editor
///  @description: 编辑器
///  Created by zhao on2021/7/5 .

class SpecialTextContentListNotifier extends ValueNotifier<SpecialTextContentList> {

  SpecialTextContentListNotifier(SpecialTextContentList specialTextContentList): super(specialTextContentList);

  void add( SpecialTextContent content ) {

    value.list.add(content);
    notifyListeners();
  }

}

class SpecialTextContentList {
  late List<SpecialTextContent> list;

  SpecialTextContentList(this.list);

  SpecialTextContentList substring(int start, [int? end]) {
    List<SpecialTextContent> resultList = [];
    int textCount = 0;
    for (SpecialTextContent content in resultList) {
      textCount += content.text.length;
      String tmpText = "";
      //处理开头
      if (textCount >= start && resultList.length == 0) {
        tmpText =
            content.text.substring(content.text.length - textCount + start);
        SpecialTextContent tmpContent = SpecialTextContent();
        tmpContent.text = tmpText;
        tmpContent.type = content.type;
        resultList.add(tmpContent);
        continue;
      }
      //处理结尾
      if (textCount > (end ?? content.text.length)) {
        tmpText = content.text.substring(
            content.text.length - textCount + (end ?? content.text.length));
        SpecialTextContent tmpContent = SpecialTextContent();
        tmpContent.text = tmpText;
        tmpContent.type = content.type;
        resultList.add(tmpContent);
        break;
      }

      if (resultList.length > 0) {
        resultList.add(content);
      }
    }

    return SpecialTextContentList(resultList);
  }

  /// 删除
  bool deleteTextContent(int index, String text) {
    int length = text.length;
    int tmp = 0;
    for (int j = 0; j < list.length; j++) {
      SpecialTextContent specialTextContent = list[j];

      String str = (specialTextContent.text as String);
      tmp += str.length;

      if (index <= tmp) {
        int realIndex = str.length - tmp + index;
        if (str.length - realIndex > length) {
          String str1 = str.substring(0, realIndex);
          String str2 = str.substring(realIndex + length, str.length);
          str = str1 + str2;
          specialTextContent.text = str;
          return true;
        } else {
          /// 不够删
          /// 从头都删掉
          if (realIndex == 0) {
            length -= str.length;
            tmp -= str.length;
            if (specialTextContent.text.length == 0) {
              list.removeAt(j);
              j -= 1;
            }
            continue;
          }

          /// 删掉本values  index后面所有
          String str1 = str.substring(0, realIndex);
          specialTextContent.text = str1;
          length -= (str.length - realIndex);
          tmp -= (str.length - realIndex);
        }
      }
    }
    return false;
  }

  /// 手动添加
  bool addTextContent(int index, String content) {
    int tmp = 0;
    if (list.length == 0) {
      SpecialTextContent specialTextContent = SpecialTextContent();
      specialTextContent.text = content;
      specialTextContent.type = 0;
      list.add(specialTextContent);
      return true;
    }
    for (int i =0 ;i< list.length;i++) {
      {

        SpecialTextContent specialTextContent = list[i];
        if(specialTextContent.text.length==0){
          continue;
        }
        String str = (specialTextContent.text as String);
        tmp += str.length;
        if (index <= tmp) {
          if (specialTextContent.type == 0) {
            ///继续手动输入
            int realIndex = str.length - tmp + index;
            String str1 = str.substring(0, realIndex);
            String str2 = str.substring(realIndex);
            str = str1 + content + str2;
            specialTextContent.text = str;
          } else {
            ///在model后输入
            ///单独保存手动输入的内容
            SpecialTextContent specialTextContent = SpecialTextContent();
            specialTextContent.text = content;
            specialTextContent.type = 0;
            if (index == tmp) {
              list.insert(i + 1, specialTextContent);
              i+=1;
            } else {
              int realIndex = str.length - tmp + index;
              String str1 = str.substring(0, realIndex);
              String str2 = str.substring(realIndex);
              SpecialTextContent specialTextContent1 = SpecialTextContent();
              specialTextContent1.text = str1;

              SpecialTextContent specialTextContent2 = SpecialTextContent();
              specialTextContent2.text = str2;

              list[i] = specialTextContent1;

              list.insert(i + 1, specialTextContent);
              list.insert(i + 2, specialTextContent2);
            }
          }
          return true;
        }
      }
    }
    return false;
  }


  String getContent(){
    StringBuffer stringBuffer = StringBuffer();
    for (SpecialTextContent content in list) {
      stringBuffer.write(content.text);
    }
    return stringBuffer.toString();
  }


}

class SpecialTextContent {
  //文字内容
  String text = "";

  //样式类型 0为默认模型没有样式
  int type = 0;

  //hit
  String? hint;
}

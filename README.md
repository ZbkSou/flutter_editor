# flutter_editor

富文本编辑框

支持自定义多种样式的编辑框，可以手动修改内容，通过方法增减带样式文本，
# 使用

```
  ExtendTextField(
                //文字内容改变监听
                onChangeListen: (diff, selection) {
                  print(diff);
                  return "";
                },
    //样式显示控制
                specialTextSpanBuilder: MySpecialTextSpanBuilder(),

// 样式数据控制
                specialTextContentDataController:specialTextContentDataController,
                decoration: InputDecoration(
                  hintMaxLines: 100,
                  hintText: "富文本编辑框",
                  border: InputBorder.none,
                ))
```

1. 需要定义 MySpecialTextSpanBuilder  显示样式文件

```
class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {

  @override
  TextSpan build({SpecialTextContentList? specialTextContentList,TextStyle? textStyle,SpecialTextGestureTapCallback? onTap}) {
    final List<InlineSpan> inlineList = <InlineSpan>[];
    SpecialText? specialText;

    if(specialTextContentList==null){
      return TextSpan(children: inlineList, style: textStyle);
    }

    for(SpecialTextContent content in specialTextContentList.list){

// 在这里根据type选择不同的样式显示，此处默认手动输入的文字样式type = 0 
      switch(content.type){
        case 0:
          inlineList.add(TextSpan(text: content.text, style: textStyle));
          break;
        case 1:
// RedText 将会返回TextSpan 的列表 ，其他样式需要自定义
          specialText = RedText(textStyle!, onTap:onTap);
          specialText.appendContent(content.text);
          inlineList.add(specialText.finishText());
          specialText = null;
          break;
      }

    }
    return TextSpan(children: inlineList, style: textStyle);
  }
}
```

1. 设置样式内容控制器

```
 @override
  void initState() {
    List<SpecialTextContent> list = [];
    SpecialTextContentList specialTextContentList =
    new SpecialTextContentList(list);
    specialTextContentDataController =
    new SpecialTextContentListNotifier(specialTextContentList);
    specialTextContentDataController.addListener(() {
      specialTextContentList = specialTextContentDataController.value;
      print("样式改变："+specialTextContentList.getContent());
    });
  }
```

1. 通过代码控制样式文本

```
          FloatingActionButton(
            child: Icon(Icons.add), 
            onPressed: () {
              SpecialTextContent content = new SpecialTextContent();
              content.text = "11111";
              content.type = 1;
              specialTextContentDataController.add(content);
          }),
```
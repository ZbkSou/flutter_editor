import 'package:flutter/material.dart';
import 'package:flutter_editor/special_text_content.dart';

import 'demo/my_special_text_span_builder.dart';
import 'extend_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late SpecialTextContentListNotifier specialTextContentDataController;



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

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          padding: EdgeInsets.only(bottom: 150),
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 500,
                      ),
                      child: ExtendTextField(
                          onChangeListen: (diff, selection) {
                            print(diff);
                            return "";
                          },
                          enableSuggestions: false,
                          autocorrect: false,
                          specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                          specialTextContentDataController:
                          specialTextContentDataController,
                          decoration: InputDecoration(
                            hintMaxLines: 100,
                            hintText: "富文本编辑框",
                            border: InputBorder.none,
                          ),
                          maxLines: null),

                    ),
                  ],
                ),
            ),
          ]),
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: () {

            SpecialTextContent content = new SpecialTextContent();
            content.text = "323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的"+
                "323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的的"+"323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的"+
                "323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的的"+"323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的"+
                "323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的323234243243243数量的开发计划事件的看法就开始了的的";
            content.type = 1;
            specialTextContentDataController.add(content);
            SpecialTextContent content2 = new SpecialTextContent();
           content2.hint ="2";
            content2.type = 2;
            specialTextContentDataController.add(content2);
            specialTextContentDataController.add(content);
          }),
    );
  }
}

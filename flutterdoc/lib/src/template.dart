const template = {
  'pubspec.yaml': '''name: gallery
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.1.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.2
  flutter_highlight: ^0.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
''',
  'lib/main.dart': '''import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'examples.dart';
import 'payloads.dart';

void main() => runApp(MyApp());

const title = 'Flutter Gallery';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: MyHomePage(title: title),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
            children: payloads.map((item) {
          final fileName = item['name'] as String;
          final description = item['description'] as String;
          final items = item['items'] as List;

          return InkWell(
            child: ListTile(title: Text(fileName), subtitle: Text(description)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(fileName)),
                  body: Column(
                    children: items.map((item) {
                      final source = item['source'] as String;
                      final widgetName = item['name'] as String;
                      final widgetBuilder =
                          examples['\$fileName.\$widgetName'] as Function;

                      return Column(
                        children: <Widget>[
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: widgetBuilder(),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: HighlightView(
                              source,
                              language: 'dart',
                              theme: githubTheme,
                              textStyle: TextStyle(
                                  fontFamily:
                                      'SFMono-Regular,Consolas,Liberation Mono,Menlo,monospace'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ));
            },
          );
        }).toList()),
      ),
    );
  }
}
''',
  'lib/examples.dart': '''const examples = {};
''',
  'lib/payloads.dart': '''const payloads = [];
''',
};

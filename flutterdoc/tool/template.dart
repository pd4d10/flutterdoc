import 'dart:io';
import 'package:dart_style/dart_style.dart';

main(List<String> args) async {
  var code = 'const template = {';
  ['pubspec.yaml', 'lib/main.dart', 'lib/examples.dart', 'lib/payloads.dart']
      .forEach((name) {
    var content =
        File('gallery/$name').readAsStringSync().replaceAll(r'$', r'\$');
    code += "'$name': '''$content''',";
  });
  code += '};';
  File('flutterdoc/lib/src/template.dart')
      .writeAsStringSync(DartFormatter().format(code));
}

import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutterdoc/src/template.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:yaml/yaml.dart';
import 'package:flutterdoc/src/utils.dart';
import 'package:flutterdoc/src/model.dart';

const _dirname = 'flutterdoc';
final _formatter = DartFormatter();

void _generate() async {
  var exampleExists = await Directory('example').exists();
  if (!exampleExists) {
    print('example not exists');
    return;
  }

  // Clean up
  try {
    await Directory(_dirname).delete(recursive: true);
  } finally {}

  // Flutter create
  var result = await Process.run('flutter', ['create', _dirname]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // Remove test folder
  await Directory(path.join(_dirname, 'test')).delete(recursive: true);

  // Copy templates
  template.forEach((k, v) {
    File(path.join(_dirname, k)).writeAsStringSync(v);
  });

  // Add dependency
  var libName = loadYaml(await File('pubspec.yaml').readAsString())['name'];
  var pubspec = await File('$_dirname/pubspec.yaml').readAsString();

  // Run pub get after dependencies change
  // result =
  //     await Process.run('flutter', ['pub', 'get'], workingDirectory: _dirname);
  // stdout.write(result.stdout);
  // stderr.write(result.stderr);

  await File('$_dirname/pubspec.yaml').writeAsString(
    pubspec.replaceFirst('dependencies:', '''
dependencies:
  $libName:
    path: ../
'''),
  );

  // Create example folder soft link
  var docExampleLink = Link(path.join(_dirname, 'lib/example'));
  if (!(await docExampleLink.exists())) {
    await docExampleLink.create('../../example');
  }

  // Get meta data from code
  List<DocPayload> payloads = [];
  var entities = Directory('example').listSync(); // TODO: recursive

  for (var entity in entities) {
    var payload = DocPayload(
        path.basenameWithoutExtension(entity.path), '', []); // TODO: desc
    payloads.add(payload);

    var result = parseFile(
        path: entity.path, featureSet: FeatureSet.fromEnableFlags([]));

    result.unit.declarations.forEach((decl) {
      if (decl is ClassDeclaration) {
        var item = DocItemPayload(
          decl.name.toString(),
          stripComments(decl.documentationComment.tokens.join('\n')),
          _formatter.format(decl.toSource()),
        );
        payload.items.add(item);
      }
    });
  }

  // Generate examples file
  var examplesContent = 'final examples = {';
  for (var payload in payloads) {
    for (var item in payload.items) {
      var fileName = payload.name;
      var widgetName = item.name;

      examplesContent =
          'import "example/$fileName.dart" as $fileName;\n' + examplesContent;
      examplesContent +=
          '"$fileName.$widgetName": () => $fileName.$widgetName(),';
    }
  }
  examplesContent += '};';

  await File(path.join(_dirname, 'lib/examples.dart'))
      .writeAsString(examplesContent);

  // Generate payloads file
  var payloadsContent = 'const payloads = ' +
      json.encode(payloads.map((p) => p.toJson()).toList()) +
      ';';
  await File(path.join(_dirname, 'lib/payloads.dart'))
      .writeAsString(payloadsContent);
}

void serve() async {
  await _generate();

  var process = await Process.start('flutter', ['run', '-d', 'chrome'],
      workingDirectory: _dirname);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
}

void build() async {
  await _generate();

  // Read config
  var configFile = File('flutterdoc.yaml');
  if (await configFile.exists()) {
    var config = loadYaml(await configFile.readAsString());

    if (config['ga_id'] != null) {
      // Add GA script
      var file = File(path.join(_dirname, 'web/index.html'));
      var content = await file.readAsString();
      content = content.replaceFirst(
          '</body>', getGaScript(config['ga_id']) + '</body>');
      await file.writeAsString(content);
    }
  }

  var result = await Process.run('flutter', ['build', 'web'],
      workingDirectory: _dirname);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}

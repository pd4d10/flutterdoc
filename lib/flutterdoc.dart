import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:flutterdoc/utils.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:yaml/yaml.dart';
import 'model.dart';

const dirname = 'flutterdoc';

void _generate() async {
  var exampleExists = await Directory('example').exists();
  if (!exampleExists) {
    print('example not exists');
    return;
  }

  // Copy template
  await Directory(dirname).create();
  await copyDirectory(
    Directory(
        path.normalize(path.join(Platform.script.path, '../../lib/template'))),
    Directory(dirname),
  );

  // Add dependency
  var libName = loadYaml(await File('pubspec.yaml').readAsString())['name'];
  var pubspec = await File('$dirname/pubspec.yaml').readAsString();

  await File('$dirname/pubspec.yaml').writeAsString(
    pubspec.replaceFirst(
        'dependencies:', 'dependencies:\n  $libName:\n    path: ../\n'),
  );

  // Create example folder soft link
  var docExampleLink = Link(path.join(dirname, 'lib/example'));
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
          decl.toSource(),
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

  await File(path.join(dirname, 'lib/examples.dart'))
      .writeAsString(examplesContent);

  // Generate payloads file
  var payloadsContent = 'const payloads = ' +
      json.encode(payloads.map((p) => p.toJson()).toList()) +
      ';';
  await File(path.join(dirname, 'lib/payloads.dart'))
      .writeAsString(payloadsContent);
}

void serve() async {
  _generate();

  var process = await Process.start('flutter', ['run', '-d', 'chrome'],
      workingDirectory: dirname);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
}

void build() async {
  _generate();

  var result =
      await Process.run('flutter', ['build', 'web'], workingDirectory: dirname);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}

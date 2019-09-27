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

const configFileName = 'flutterdoc.yaml';
final _formatter = DartFormatter();

Future<DocConfig> _readConfig() async {
  // Read config
  final configFile = File(configFileName);
  Map<String, dynamic> data = {};
  if (await configFile.exists()) {
    final _yamlMap = loadYaml(await configFile.readAsString());
    data = {
      'input': _yamlMap['input'],
      'output': _yamlMap['output'],
      'ga_id': _yamlMap['ga_id'],
    };
  }
  return DocConfig.fromJson(data);
}

void _generate(DocConfig config) async {
  var inputExists = await Directory(config.input).exists();
  if (!inputExists) {
    print('Input folder not exists: ${config.input}');
    return;
  }

  final inputDir = config.input;
  final outputDir = config.output;

  // Clean up
  if (await Directory(outputDir).exists()) {
    await Directory(outputDir).delete(recursive: true);
  }

  // Flutter create
  var result = await Process.run('flutter', ['create', outputDir]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);

  // Remove test folder
  await Directory(path.join(outputDir, 'test')).delete(recursive: true);

  // Copy templates
  template.forEach((k, v) {
    File(path.join(outputDir, k)).writeAsStringSync(v);
  });

  // Add dependency
  var libName = loadYaml(await File('pubspec.yaml').readAsString())['name'];
  var pubspec = await File('$outputDir/pubspec.yaml').readAsString();

  // Run pub get after dependencies change
  // result =
  //     await Process.run('flutter', ['pub', 'get'], workingDirectory: _dirname);
  // stdout.write(result.stdout);
  // stderr.write(result.stderr);

  await File('$outputDir/pubspec.yaml').writeAsString(
    pubspec.replaceFirst('dependencies:', '''
dependencies:
  $libName:
    path: ../
'''),
  );

  // Create example folder soft link
  var inputLink = Link(path.join(outputDir, 'lib/$inputDir'));
  if (!(await inputLink.exists())) {
    await inputLink.create('../../$inputDir');
  }

  // Get meta data from code
  List<DocPayload> payloads = [];
  var entities = Directory(inputDir).listSync(); // TODO: recursive

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
          'import "$inputDir/$fileName.dart" as $fileName;\n' + examplesContent;
      examplesContent +=
          '"$fileName.$widgetName": () => $fileName.$widgetName(),';
    }
  }
  examplesContent += '};';

  await File(path.join(outputDir, 'lib/examples.dart'))
      .writeAsString(examplesContent);

  // Generate payloads file
  var payloadsContent = 'const payloads = ' +
      json.encode(payloads.map((p) => p.toJson()).toList()) +
      ';';
  await File(path.join(outputDir, 'lib/payloads.dart'))
      .writeAsString(payloadsContent);
}

void serve() async {
  final config = await _readConfig();
  await _generate(config);

  var process = await Process.start('flutter', ['run', '-d', 'chrome'],
      workingDirectory: config.output);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
}

void build() async {
  final config = await _readConfig();
  await _generate(config);

  if (config.ga_id != null) {
    // Add GA script
    var file = File(path.join(config.output, 'web/index.html'));
    var content = await file.readAsString();
    content =
        content.replaceFirst('</body>', getGaScript(config.ga_id) + '</body>');
    await file.writeAsString(content);
  }

  var result = await Process.run('flutter', ['build', 'web'],
      workingDirectory: config.output);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
}

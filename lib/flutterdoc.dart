import 'dart:io';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:flutterdoc/utils.dart';
import 'package:path/path.dart' as path;
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:dartdoc/src/utils.dart';

class DocPayload {
  String name;
  String description;
  List<DocItemPayload> items;
  DocPayload(this.name, this.description, this.items);
}

class DocItemPayload {
  String name;
  String description;
  String source;
  DocItemPayload(this.name, this.description, this.source);
}

void build() async {
  var exampleExists = await Directory('example').exists();
  if (!exampleExists) {
    print('example not exists');
    return;
  }

  const dirname = 'flutterdoc';

  await Directory(dirname).create();
  await copyDirectory(
    Directory(
        path.normalize(path.join(Platform.script.path, '../../lib/template'))),
    Directory(dirname),
  );

  var docExampleLink = Link(path.join(dirname, 'lib/example'));
  if (!(await docExampleLink.exists())) {
    await docExampleLink.create('../../example');
  }

  List<DocPayload> payloads = [];
  var entities = Directory('example').listSync(); // TODO: recursive

  for (var entity in entities) {
    var payload = DocPayload(
      path.basename(entity.path),
      '', // TODO:
      [],
    );
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

  var res =
      await Process.run('flutter', ['build', 'web'], workingDirectory: dirname);
  print(res.stderr);
  print(res.stdout);
}

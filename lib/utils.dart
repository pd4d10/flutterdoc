import 'dart:io';
import 'package:path/path.dart' as p;

// https://gist.github.com/thosakwe/681056e86673e73c4710cfbdfd2523a8
Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    if (entity is Directory) {
      var newDirectory =
          Directory(p.join(destination.absolute.path, p.basename(entity.path)));
      await newDirectory.create();
      await copyDirectory(entity.absolute, newDirectory);
    } else if (entity is File) {
      await entity.copy(p.join(destination.path, p.basename(entity.path)));
    }
  }
}

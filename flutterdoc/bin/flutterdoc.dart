import 'package:args/command_runner.dart';
import 'package:flutterdoc/flutterdoc.dart' as flutterdoc;

class ServeCommand extends Command {
  @override
  String get name => 'serve';
  @override
  String get description => 'Serve';

  run() {
    flutterdoc.serve();
  }
}

class BuildCommand extends Command {
  @override
  String get name => 'build';
  @override
  String get description => 'Build';

  run() {
    flutterdoc.build();
  }
}

main(List<String> arguments) {
  var runner = CommandRunner('flutterdoc', 'Generate gallery for your widgets')
    ..addCommand(ServeCommand())
    ..addCommand(BuildCommand());

  runner.run(arguments);
}

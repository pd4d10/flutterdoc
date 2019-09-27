import 'package:args/command_runner.dart';
import 'package:flutterdoc/flutterdoc.dart' as flutterdoc;

class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Create flutterdoc.yaml config template';

  run() => flutterdoc.init();
}

class ServeCommand extends Command {
  @override
  String get name => 'serve';
  @override
  String get description => 'Serve';

  run() => flutterdoc.serve();
}

class BuildCommand extends Command {
  @override
  String get name => 'build';
  @override
  String get description => 'Build';

  run() => flutterdoc.build();
}

main(List<String> arguments) {
  var runner = CommandRunner('flutterdoc', 'Generate gallery for your widgets')
    ..addCommand(InitCommand())
    ..addCommand(ServeCommand())
    ..addCommand(BuildCommand());

  runner.run(arguments);
}

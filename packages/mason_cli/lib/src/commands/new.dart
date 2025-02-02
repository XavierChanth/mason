import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:mason_cli/src/command.dart';
import 'package:mason_cli/src/yaml_encode.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:universal_io/io.dart';

/// {@template new_command}
/// `mason new` command which creates a new brick.
/// {@endtemplate}
class NewCommand extends MasonCommand {
  /// {@macro new_command}
  NewCommand({Logger? logger}) : super(logger: logger) {
    argParser.addOption(
      'desc',
      abbr: 'd',
      help: 'Description of the new brick template',
      defaultsTo: 'A new brick created with the Mason CLI.',
    );
  }

  @override
  final String description = 'Creates a new brick template.';

  @override
  final String name = 'new';

  @override
  Future<int> run() async {
    if (results.rest.isEmpty) {
      throw UsageException('Name of the new brick is required.', usage);
    }
    final bricksJson = localBricksJson;
    if (bricksJson == null) throw const MasonYamlNotFoundException();
    final name = results.rest.first.snakeCase;
    final description = results['desc'] as String;
    final directory = Directory(p.join(entryPoint.path, 'bricks'));
    final brickYaml = File(p.join(directory.path, name, BrickYaml.file));

    if (brickYaml.existsSync()) {
      logger.err('Existing brick: $name at ${brickYaml.path}');
      return ExitCode.usage.code;
    }

    final done = logger.progress('Creating new brick: $name.');
    final target = DirectoryGeneratorTarget(directory, logger);
    final generator = _BrickGenerator(name, description);
    final newBrick = Brick(
      path: p.normalize(
        p.relative(
          brickYaml.parent.path,
          from: entryPoint.path,
        ),
      ),
    );
    final bricks = Map.of(masonYaml.bricks)..addAll({name: newBrick});

    try {
      await Future.wait([
        generator.generate(target, vars: <String, dynamic>{'name': '{{name}}'}),
        if (!masonYaml.bricks.containsKey(name))
          masonYamlFile.writeAsString(Yaml.encode(MasonYaml(bricks).toJson())),
      ]);
      await bricksJson.add(newBrick);
      await bricksJson.flush();

      done('Created new brick: $name');
      logger
        ..info(
          '''${lightGreen.wrap('✓')} Generated ${generator.files.length} file(s):''',
        )
        ..flush(logger.detail);
      return ExitCode.success.code;
    } catch (_) {
      done();
      rethrow;
    }
  }
}

class _BrickGenerator extends MasonGenerator {
  _BrickGenerator(this.brickName, this.brickDescription)
      : super(
          '__new_brick__',
          'Creates a new brick.',
          files: [
            TemplateFile(
              p.join(brickName, BrickYaml.file),
              _content(brickName, brickDescription),
            ),
            TemplateFile(
              p.join(brickName, BrickYaml.dir, 'hello.md'),
              'Hello {{name}}!',
            ),
          ],
        );

  static String _content(String name, String description) => '''
name: $name
description: $description
version: 1.0.0
vars:
  - name
''';

  final String brickName;
  final String brickDescription;
}

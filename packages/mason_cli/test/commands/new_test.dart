import 'package:mason/mason.dart';
import 'package:mason_cli/src/command.dart';
import 'package:mason_cli/src/command_runner.dart';
import 'package:mason_cli/src/version.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:pub_updater/pub_updater.dart';
import 'package:test/test.dart';
import 'package:universal_io/io.dart';

import '../helpers/helpers.dart';

class MockLogger extends Mock implements Logger {}

class MockPubUpdater extends Mock implements PubUpdater {}

void main() {
  final cwd = Directory.current;

  group('mason new', () {
    late Logger logger;
    late PubUpdater pubUpdater;
    late MasonCommandRunner commandRunner;

    setUp(() {
      logger = MockLogger();
      pubUpdater = MockPubUpdater();

      when(() => logger.progress(any())).thenReturn(([String? _]) {});
      when(
        () => pubUpdater.getLatestVersion(any()),
      ).thenAnswer((_) async => packageVersion);

      commandRunner = MasonCommandRunner(
        logger: logger,
        pubUpdater: pubUpdater,
      );
      setUpTestingEnvironment(cwd, suffix: '.new');
    });

    tearDown(() {
      Directory.current = cwd;
    });

    test('exits with code 64 when mason.yaml does not exist', () async {
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.usage.code));
      verify(
        () => logger.err(const MasonYamlNotFoundException().message),
      ).called(1);
    });

    test(
        'exits with code 64 when '
        'exception occurs during generation', () async {
      when(() => logger.progress(any())).thenReturn(([update]) {
        if (update?.startsWith('Created new brick:') == true) {
          throw const MasonException('oops');
        }
      });
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err('oops')).called(1);
    });

    test('creates a new brick when it does not exist', () async {
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.new')),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'new')),
      );
      expect(
        directoriesDeepEqual(actual, expected, ignore: ['bricks.json']),
        isTrue,
      );
      verify(() => logger.flush(logger.detail)).called(1);
    });

    test('exits with code 64 when name is missing', () async {
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new']);
      expect(result, equals(ExitCode.usage.code));
      verify(() => logger.err('Name of the new brick is required.')).called(1);
    });

    test('exits with code 64 when brick already exists', () async {
      File(path.join(Directory.current.path, 'mason.yaml'))
          .writeAsStringSync('bricks:\n');
      final result = await commandRunner.run(['new', 'hello world']);
      expect(result, equals(ExitCode.success.code));
      final actual = Directory(
        path.join(testFixturesPath(cwd, suffix: '.new')),
      );
      final expected = Directory(
        path.join(testFixturesPath(cwd, suffix: 'new')),
      );
      expect(
        directoriesDeepEqual(actual, expected, ignore: ['bricks.json']),
        isTrue,
      );

      final secondResult = await commandRunner.run(['new', 'hello world']);
      expect(secondResult, equals(ExitCode.usage.code));
      final expectedBrickYamlPath = path.join(
        Directory.current.path,
        'bricks',
        'hello_world',
        'brick.yaml',
      );
      verify(
        () => logger.err(
          'Existing brick: hello_world at $expectedBrickYamlPath',
        ),
      ).called(1);
    });
  });
}

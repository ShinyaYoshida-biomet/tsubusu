import 'dart:io';

const _normalTargets = <String>[
  'build',
  'coverage',
  '.dart_tool',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
];

const _fullOnlyTargets = <String>[
  'macos/Flutter/ephemeral',
  'macos/Pods',
  'windows/flutter/ephemeral',
];

void main(List<String> arguments) {
  final flags = arguments.toSet();
  const validFlags = {'--normal', '--full', '--dry-run', '--help'};
  if (flags.length != arguments.length || !flags.every(validFlags.contains)) {
    _usage(exitCode: 64);
  }

  if (flags.contains('--help') ||
      (!flags.contains('--normal') && !flags.contains('--full'))) {
    _usage(exitCode: flags.contains('--help') ? 0 : 64);
  }

  if (flags.contains('--normal') && flags.contains('--full')) {
    stderr.writeln('Choose either --normal or --full.');
    exitCode = 64;
    return;
  }

  final repositoryRoot = File.fromUri(Platform.script).parent.parent;
  final targets = [
    ..._normalTargets,
    if (flags.contains('--full')) ..._fullOnlyTargets,
  ];
  final dryRun = flags.contains('--dry-run');

  for (final relativePath in targets) {
    final targetPath = '${repositoryRoot.path}/$relativePath';
    final type = FileSystemEntity.typeSync(targetPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      stdout.writeln('Already absent: $relativePath');
      continue;
    }

    if (type == FileSystemEntityType.link) {
      stderr.writeln('Refusing to remove symlink: $relativePath');
      exitCode = 1;
      continue;
    }

    if (dryRun) {
      stdout.writeln('Would remove: $relativePath');
      continue;
    }

    if (type == FileSystemEntityType.directory) {
      Directory(targetPath).deleteSync(recursive: true);
    } else if (type == FileSystemEntityType.file) {
      File(targetPath).deleteSync();
    } else {
      stderr.writeln('Refusing unexpected filesystem entry: $relativePath');
      exitCode = 1;
      continue;
    }
    stdout.writeln('Removed: $relativePath');
  }
}

void _usage({required int exitCode}) {
  final output = exitCode == 0 ? stdout : stderr;
  output.writeln('''Usage: dart run tool/clean_generated.dart <mode> [--dry-run]

Modes:
  --normal  Remove Flutter build and Dart/Pub generated state.
  --full    Also remove regenerated macOS CocoaPods and platform ephemeral state.

The command only removes the explicitly listed generated paths. It never
removes source, lockfiles, signing configuration, credentials, or user data.''');
  if (exitCode != 0) {
    exit(exitCode);
  }
}

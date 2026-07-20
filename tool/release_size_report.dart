import 'dart:io';

/// Reports the size of a release archive and the uncompressed files it contains.
///
/// This intentionally has no package dependencies so it can run in each release
/// job immediately after `flutter pub get`.
void main(List<String> arguments) {
  final options = _parseArguments(arguments);
  final artifactPath = _requiredOption(options, 'artifact');
  final payloadPath = _requiredOption(options, 'payload');
  final platform = _requiredOption(options, 'platform');
  final budgetMb = double.tryParse(_requiredOption(options, 'budget-mb'));

  if (budgetMb == null || budgetMb <= 0) {
    _fail('--budget-mb must be a positive number.');
  }

  final artifact = File(artifactPath);
  final payload = Directory(payloadPath);
  if (!artifact.existsSync()) {
    _fail('Release artifact does not exist: $artifactPath');
  }
  if (!payload.existsSync()) {
    _fail('Release payload does not exist: $payloadPath');
  }

  final artifactBytes = artifact.lengthSync();
  final payloadBytes = _directorySize(payload);
  final budgetBytes = (budgetMb * 1000 * 1000).round();
  final components = _componentSizes(payload, platform);
  final report = _markdownReport(
    platform: platform,
    artifactPath: artifactPath,
    artifactBytes: artifactBytes,
    payloadPath: payloadPath,
    payloadBytes: payloadBytes,
    budgetBytes: budgetBytes,
    components: components,
  );

  stdout.write(report);
  final summaryPath = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (summaryPath != null && summaryPath.isNotEmpty) {
    File(summaryPath).writeAsStringSync(report, mode: FileMode.append);
  }

  if (artifactBytes > budgetBytes) {
    _fail(
      '$platform release artifact is ${_megabytes(artifactBytes)} MB; '
      'the budget is ${_megabytes(budgetBytes)} MB.',
    );
  }
}

Map<String, String> _parseArguments(List<String> arguments) {
  final options = <String, String>{};
  for (var index = 0; index < arguments.length; index += 2) {
    final flag = arguments[index];
    if (!flag.startsWith('--') || index + 1 >= arguments.length) {
      _fail(
        'Usage: dart run tool/release_size_report.dart '
        '--platform <name> --artifact <file> --payload <directory> '
        '--budget-mb <decimal MB>',
      );
    }
    options[flag.substring(2)] = arguments[index + 1];
  }
  return options;
}

String _requiredOption(Map<String, String> options, String name) {
  final value = options[name];
  if (value == null || value.isEmpty) {
    _fail('Missing required --$name option.');
  }
  return value;
}

Never _fail(String message) => throw ArgumentError(message);

int _directorySize(Directory directory) {
  var total = 0;
  for (final entity in directory.listSync(recursive: true, followLinks: false)) {
    if (entity is File) {
      total += entity.lengthSync();
    }
  }
  return total;
}

List<MapEntry<String, int>> _componentSizes(Directory payload, String platform) {
  var componentRoot = payload;
  var prefix = '';
  if (platform == 'macos') {
    final contents = Directory('${payload.path}${Platform.pathSeparator}Contents');
    if (contents.existsSync()) {
      componentRoot = contents;
      prefix = 'Contents/';
    }
  }

  final components = <MapEntry<String, int>>[];
  for (final entity in componentRoot.listSync(followLinks: false)) {
    final name = entity.path.split(Platform.pathSeparator).last;
    final size = switch (entity) {
      File file => file.lengthSync(),
      Directory directory => _directorySize(directory),
      _ => 0,
    };
    components.add(MapEntry('$prefix$name', size));
  }
  components.sort((a, b) => b.value.compareTo(a.value));
  return components;
}

String _markdownReport({
  required String platform,
  required String artifactPath,
  required int artifactBytes,
  required String payloadPath,
  required int payloadBytes,
  required int budgetBytes,
  required List<MapEntry<String, int>> components,
}) {
  final status = artifactBytes <= budgetBytes ? 'PASS' : 'FAIL';
  final buffer = StringBuffer()
    ..writeln('## ${platform[0].toUpperCase()}${platform.substring(1)} release size')
    ..writeln()
    ..writeln('| Measure | Size |')
    ..writeln('| --- | ---: |')
    ..writeln('| Archive (`$artifactPath`) | ${_megabytes(artifactBytes)} MB |')
    ..writeln('| Budget | ${_megabytes(budgetBytes)} MB |')
    ..writeln('| Uncompressed payload (`$payloadPath`) | ${_megabytes(payloadBytes)} MB |')
    ..writeln('| Budget check | **$status** |')
    ..writeln()
    ..writeln('### Uncompressed payload breakdown')
    ..writeln()
    ..writeln('| Component | Size |')
    ..writeln('| --- | ---: |');

  for (final component in components) {
    buffer.writeln('| `${component.key}` | ${_megabytes(component.value)} MB |');
  }
  buffer.writeln();
  buffer.writeln(
    'Archive size is the distributed download. Payload sizes are uncompressed '
    'and are provided to identify Flutter runtime, app binary, assets, plugins, '
    'symbols, and packaging contributors.',
  );
  buffer.writeln();
  return buffer.toString();
}

String _megabytes(int bytes) => (bytes / 1000 / 1000).toStringAsFixed(2);

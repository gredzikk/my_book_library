#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart scripts/bump_version.dart [major|minor|patch]');
    print('Example: dart scripts/bump_version.dart patch');
    exit(1);
  }

  final type = args[0].toLowerCase();
  if (!['major', 'minor', 'patch'].contains(type)) {
    print('Invalid type. Use: major, minor, or patch');
    exit(1);
  }

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('Error: pubspec.yaml not found');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*(\d+)\.(\d+)\.(\d+)(\+(\d+))?');
  final match = versionRegex.firstMatch(content);

  if (match == null) {
    print('Error: Could not find version in pubspec.yaml');
    exit(1);
  }

  var major = int.parse(match.group(1)!);
  var minor = int.parse(match.group(2)!);
  var patch = int.parse(match.group(3)!);
  var buildNumber = match.group(5) != null ? int.parse(match.group(5)!) : 0;

  // Increment based on type
  switch (type) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
      break;
    case 'minor':
      minor++;
      patch = 0;
      break;
    case 'patch':
      patch++;
      break;
  }

  // Always increment build number
  buildNumber++;

  final newVersion = '$major.$minor.$patch+$buildNumber';
  final oldVersion = match.group(0)!;
  final newContent = content.replaceFirst(versionRegex, 'version: $newVersion');

  pubspecFile.writeAsStringSync(newContent);

  print(
    '✓ Version updated: ${match.group(1)}.${match.group(2)}.${match.group(3)}+${match.group(5) ?? '0'} → $newVersion',
  );
}

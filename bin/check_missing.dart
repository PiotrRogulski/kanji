import 'package:collection/collection.dart';
import 'package:file/file.dart';
import 'package:kanji/utils.dart';

final imageNameRegex = RegExp(r'^\d+\.png$');
final yamlRegex = RegExp(r'^\d+\.yaml$');

void main(List<String> args) {
  final basePath =
      args.singleOrNull ?? error('Usage: check_missing.dart <directory>');

  final baseDir = fs.directory(basePath);

  final files = baseDir.listSync(recursive: true).whereType<File>();

  final imageMap = {
    for (final image in files.where((f) => imageNameRegex.hasMatch(f.basename)))
      image.nameWithoutExtension: image,
  };
  final yamlMap = {
    for (final yaml in files.where((f) => yamlRegex.hasMatch(f.basename)))
      yaml.nameWithoutExtension: yaml,
  };

  final missingYamls = {
    for (final MapEntry(:key, :value) in imageMap.entries)
      if (!yamlMap.containsKey(key)) value,
  };

  if (missingYamls.isEmpty) {
    print('All images have corresponding YAML files.');
  } else {
    print('Missing YAML files for the following images:');
    print(
      missingYamls
          .map((e) => e.nameWithoutExtension)
          .sortedBy(int.parse)
          .join(', '),
    );
  }
}

extension on File {
  String get nameWithoutExtension => switch (basename.split('.')) {
    [] || [_] => basename,
    [...final nameParts, _] => nameParts.join('.'),
  };
}

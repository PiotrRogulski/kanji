import 'dart:io';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:kanji/model.dart';
import 'package:mime/mime.dart';
import 'package:yaml/yaml.dart';

const fs = LocalFileSystem();

void main(List<String> args) async {
  final apiKey =
      Platform.environment['GEMINI_API_KEY'] ??
      error(r'No $GEMINI_API_KEY environment variable');

  final imagePath = args.singleOrNull ?? error('Usage: kanji.dart <directory>');
  final imageDir = fs.directory(imagePath);

  if (!imageDir.existsSync()) {
    error('Directory does not exist: $imagePath');
  }

  final yamlDir = imageDir.childDirectory('res')..createSync();
  final rawOutputFile = yamlDir.childFile('raw.txt');
  if (rawOutputFile.existsSync()) {
    final content = rawOutputFile.readAsStringSync();
    writeFiles(yamlDir, content);
    return;
  }

  final model = createModel(apiKey: apiKey);

  final images = imageDir
      .listSync()
      .whereType<File>()
      .map((file) {
        final bytes = file.readAsBytesSync();
        final mime = lookupMimeType(
          file.path,
          headerBytes: Uint8List.sublistView(
            bytes,
            0,
            defaultMagicNumbersMaxLength,
          ),
        );
        return (mime, bytes);
      })
      .whereType<(String, Uint8List)>()
      .where((e) => e.$1.startsWith('image/'))
      .map((e) => Content.data(e.$1, e.$2));

  final response = await model.generateContent(images);
  final result = response.text;

  if (result == null) {
    error('Failed to generate content');
  }

  rawOutputFile.writeAsStringSync(result);
  writeFiles(yamlDir, result);
}

void writeFiles(Directory targetDir, String content) {
  final cleanedContent = content.replaceAll(RegExp('```(?:yaml)?\n?'), '');

  for (final yaml in loadYamlDocuments(cleanedContent)) {
    final contents = yaml.contents as YamlMap;
    final id = contents['id'];
    targetDir.childFile('$id.yaml').writeAsStringSync(contents.span.text);
  }
}

Never error(String message) {
  stderr.writeln(message);
  exit(1);
}

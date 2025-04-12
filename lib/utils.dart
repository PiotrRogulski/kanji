import 'dart:io';

import 'package:file/local.dart';

const fs = LocalFileSystem();

Never error(String message) {
  stderr.writeln(message);
  exit(1);
}

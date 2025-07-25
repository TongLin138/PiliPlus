import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

final _loggerFactory = PiliLogger();

PiliLogger getLogger<T>() {
  return _loggerFactory;
}

class PiliLogger extends Logger {
  PiliLogger() : super();

  @override
  Future<void> log(
    Level level,
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) async {
    if (level == Level.error || level == Level.fatal) {
      // 添加至文件末尾
      File logFile = await getLogsPath();
      logFile.writeAsString(
        "**${DateTime.now()}** \n $message \n $stackTrace",
        mode: FileMode.writeOnlyAppend,
      );
    }
    super.log(level, "$message", error: error, stackTrace: stackTrace);
  }
}

Future<File> getLogsPath() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  final String filename = p.join(dir, ".pili_logs");
  final File file = File(filename);
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }
  return file;
}

Future<bool> clearLogs() async {
  final File file = await getLogsPath();
  try {
    await file.writeAsString('');
  } catch (e) {
    if (kDebugMode) debugPrint('Error clearing file: $e');
    return false;
  }
  return true;
}

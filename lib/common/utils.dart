import 'package:flutter/foundation.dart';

import '../controller/app_state.dart';
import 'dart:io';

void openFolder(path) async {
  if (Platform.isWindows) {
    Process.runSync('explorer', [path]);
  } else if (Platform.isMacOS) {
    Process.runSync('open', [path]);
  }
}

Future<void> killall() async {
  late Future<ProcessResult> processResult;

  if (Platform.isWindows) {
    processResult = Process.run(
      'taskkill',
      ['/f', '/im', AppState.to.frpcExecutableFilename],
    );
  } else if (Platform.isMacOS) {
    processResult = Process.run(
      'killall',
      [AppState.to.frpcExecutableFilename],
    );
  }

  await processResult.then((result) {
    debugPrint('[killall] result.stderr: ${result.stderr}');
    debugPrint('[killall] result.stdout: ${result.stdout}');
    debugPrint('[killall] exitCode: ${result.exitCode}');
  });
}

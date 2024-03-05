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

void killall() async {
  late ProcessResult processResult;

  if (Platform.isWindows) {
    processResult = Process.runSync(
      'taskkill',
      ['/f', '/im', AppState.to.frpcExecutableFilename],
    );
  } else if (Platform.isMacOS) {
    processResult = Process.runSync(
      'killall',
      [AppState.to.frpcExecutableFilename],
    );
  }

  debugPrint('[killall] processResult.stderr: ${processResult.stderr}');
  debugPrint('[killall] processResult.stdout: ${processResult.stdout}');
  debugPrint('[killall] exitCode: ${processResult.exitCode}');
}

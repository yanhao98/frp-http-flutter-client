import 'dart:io';

void openFolder(path) async {
  if (Platform.isWindows) {
    Process.runSync('explorer', [path]);
  } else if (Platform.isMacOS) {
    Process.runSync('open', [path]);
  }
}

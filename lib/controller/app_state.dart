import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppState extends GetxController {
  static AppState get to => Get.find();

  RxString frpsServer = 'fro.oo1.dev'.obs;
  late String systemArch = '';
  late String subdomainPrefix;
  late String workingDirectory;
  RxString frpcVersion = ''.obs;

  @override
  Future<void> onInit() async {
    await initFrpcInfo();
    debugPrint('[AppState] init complete');
    debugPrint('[AppState] workingDirectory: $workingDirectory');
    super.onInit();
  }

  initFrpcInfo() async {
    var deviceInfo = await _getDeviceInfo();
    systemArch = deviceInfo.arch;
    subdomainPrefix = deviceInfo.systemId;
    _setWorkingDirectory();

    // final directory = await getTemporaryDirectory();
    // debugPrint('directory.path: ${directory.path}');
    // late String filePath;
    // late String filename;
    // if (Platform.isMacOS) {
    //   filename = 'frpc_darwin_$systemArch';
    // } else if (Platform.isWindows) {
    //   filename = 'frpc_windows_$systemArch.exe';
    // }
    // filePath = path.join(directory.path, 'frp-http-client', filename);
    // debugPrint('filePath: $filePath');
    // final file = File(filePath);
    // if (!file.existsSync()) {
    //   // https://dl.19980901.xyz/frpc_darwin_arm64
    //   debugPrint('文件不存在，开始下载');
    //   await file.create(recursive: true);
    //   final url = 'https://dl.19980901.xyz/frpc_darwin_$systemArch';
    //   final request = await HttpClient().getUrl(Uri.parse(url));
    //   final response = await request.close();
    //   await response.pipe(file.openWrite());
    // }
    // if (Platform.isMacOS) {
    //   await Process.run('chmod', ['+x', filePath]);
    // }

    // final result = await Process.run(filePath, ['-v']);
    // debugPrint('result: ${result.stdout}');
    // // executableFilePath.value = filePath;
    // frpcVersion.value = result.stdout.toString().trim();
  }

  Future<void> _setWorkingDirectory() async {
    if (Platform.isMacOS) {
      final directory = await getTemporaryDirectory();
      workingDirectory = path.join(directory.path, 'frp-http-client');
    } else if (Platform.isWindows) {
      final dir = path.dirname(Platform.resolvedExecutable);
      workingDirectory = path.join(dir, 'frp-http-client');
    }
  }
}

class _DeviceInfo {
  final String arch;
  final String systemId;

  _DeviceInfo({
    required this.arch,
    required this.systemId,
  });
}

Future<_DeviceInfo> _getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isMacOS) {
    final macOsInfo = await deviceInfo.macOsInfo;
    return _DeviceInfo(
      arch: macOsInfo.arch,
      systemId: macOsInfo.systemGUID!,
    );
  } else if (Platform.isWindows) {
    final windowsInfo = await deviceInfo.windowsInfo;

    return _DeviceInfo(
      arch: windowsInfo.buildLabEx.toLowerCase().contains('arm64')
          ? 'arm64'
          : 'amd64',
      systemId: windowsInfo.deviceId,
    );
  } else {
    throw UnimplementedError('Unsupported platform');
  }
}

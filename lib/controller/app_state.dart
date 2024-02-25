import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


class AppState extends GetxController {
  static AppState get to => Get.find();

  var frpsServer = 'fro.oo1.dev'.obs;
  var systemArch = ''.obs;
  var executableFilePath = ''.obs;
  var subdomainPrefix = ''.obs;
  var frpcVersion = ''.obs;

  @override
  Future<void> onInit() async {
    await initDeviceInfo();
    initFrpcInfo();
    super.onInit();
  }

  initFrpcInfo() async {
    final arch = systemArch.value;
    final directory = await getTemporaryDirectory();
    debugPrint('directory.path: ${directory.path}');
    late String filePath;
    late String filename;
    if (Platform.isMacOS) {
      filename = 'frpc_darwin_$arch';
    } else if (Platform.isWindows) {
      filename = 'frpc_windows_$arch.exe';
    }
    filePath = path.join(directory.path, 'frp-http-client', filename);
    debugPrint('filePath: $filePath');
    final file = File(filePath);
    if (!file.existsSync()) {
      // https://dl.19980901.xyz/frpc_darwin_arm64
      debugPrint('文件不存在，开始下载');
      await file.create(recursive: true);
      final url = 'https://dl.19980901.xyz/frpc_darwin_$arch';
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
    }
    if (Platform.isMacOS) {
      await Process.run('chmod', ['+x', filePath]);
    }

    final result = await Process.run(filePath, ['-v']);
    debugPrint('result: ${result.stdout}');
    executableFilePath.value = filePath;
    frpcVersion.value = result.stdout.toString().trim();
  }

  Future<void> initDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String? arch;
    String? systemId;
    if (Platform.isMacOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      arch = macOsInfo.arch;
      systemId = macOsInfo.systemGUID;
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      if (windowsInfo.buildLabEx.toLowerCase().contains('arm64')) {
        arch = 'arm64';
      } else {
        arch = 'amd64';
      }
      systemId = windowsInfo.deviceId;
    }

    systemArch.value = arch!;
    subdomainPrefix.value = systemId!;
  }
}

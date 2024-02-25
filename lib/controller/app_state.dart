import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:frp_http_client/model/frpc_info.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../model/device_info.dart';

class AppState extends GetxController {
  static AppState get to => Get.find();

  var frpsServer = ''.obs;
  final Rx<DeviceInfo> deviceInfo = DeviceInfo().obs;
  final Rx<FrpcInfo> frpcInfo = FrpcInfo().obs;

  @override
  Future<void> onInit() async {
    frpsServer.value = 'fro.oo1.dev';
    await initDeviceInfo();
    initFrpcInfo();
    super.onInit();
  }

  initFrpcInfo() async {
    final directory = await getTemporaryDirectory();
    debugPrint('directory.path: ${directory.path}');
    late String filePath;
    late String filename;
    if (Platform.isMacOS) {
      filename = 'frpc_darwin_${deviceInfo.value.arch}';
    } else if (Platform.isWindows) {
      filename = 'frpc_windows_${deviceInfo.value.arch}.exe';
    }
    filePath = path.join(directory.path, 'frp.oo1.dev', filename);
    debugPrint('filePath: $filePath');
    final file = File(filePath);
    if (!file.existsSync()) {
      // https://dl.19980901.xyz/frpc_darwin_arm64
      debugPrint('文件不存在，开始下载');
      await file.create(recursive: true);
      final url =
          'https://dl.19980901.xyz/frpc_darwin_${deviceInfo.value.arch}';
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      await response.pipe(file.openWrite());
    }
    if (Platform.isMacOS) {
      await Process.run('chmod', ['+x', filePath]);
    }

    final result = await Process.run(filePath, ['-v']);
    debugPrint('result: ${result.stdout}');
    frpcInfo.update((val) {
      val!.executableFilePath = filePath;
      val.version = result.stdout.toString().trim();
    });
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
      arch = getWIndowsArch();
      final windowsInfo = await deviceInfo.windowsInfo;
      systemId = windowsInfo.deviceId;
    }

    this.deviceInfo.update((val) {
      val!.arch = arch;
      val.subdomainPrefix = systemId;
    });
  }
}

String getWIndowsArch() {
  final result =
      Process.runSync('cmd', ['/c', 'echo %PROCESSOR_ARCHITECTURE%']);
  return result.stdout.toString().trim().toLowerCase();
}

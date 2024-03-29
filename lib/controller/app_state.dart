import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppState extends GetxController {
  static AppState get to => Get.find();

  RxBool ready = false.obs;
  // RxString frpsServer = 'nwct.dev'.obs;
  late String systemArch = '';

  /// 默认是系统的唯一标识的前 8 位
  late String domainPrefix;
  late String frpcDirectory;
  Rx<String?> frpcVersion = Rx(null);
  String get frpcExecutableFilename {
    late String filename;
    if (Platform.isMacOS) {
      filename = 'frpc_darwin_$systemArch';
    } else if (Platform.isWindows) {
      filename = 'frpc_windows_$systemArch.exe';
    }
    return filename;
  }

  String get frpcExecutablePath {
    return path.join(frpcDirectory, frpcExecutableFilename);
  }

  @override
  Future<void> onInit() async {
    var deviceInfo = await _getDeviceInfo();
    systemArch = deviceInfo.arch;
    domainPrefix = deviceInfo.systemId
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .substring(0, 8);
    await _setWorkingDirectory();
    await checkFrpc();
    ready.value = true;
    debugPrint('[AppState] init complete');
    super.onInit();
  }

  Future<void> checkFrpc() async {
    debugPrint('frpcExecutablePath: $frpcExecutablePath');

    final file = File(frpcExecutablePath);
    if (file.existsSync()) {
      final result = await Process.run(frpcExecutablePath, ['-v']);
      debugPrint('result: ${result.stdout}');
      frpcVersion.value = '${result.stdout}'.trim();
    }
  }

  Future<void> downloadFrpc() async {
    late String url;
    if (Platform.isMacOS) {
      url = 'https://dl.19980901.xyz/frpc_darwin_$systemArch';
    } else if (Platform.isWindows) {
      url = 'https://dl.19980901.xyz/frpc_windows_$systemArch.exe';
    }
    // TODO: 还需要处理：下载到一半退出了。
    await Dio().download(
      url,
      frpcExecutablePath,
      options: Options(
        sendTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 60),
      ),
    );

    if (Platform.isMacOS) {
      await Process.run('chmod', ['+x', frpcExecutablePath]);
    }
  }

  Future<void> _setWorkingDirectory() async {
    if (Platform.isMacOS) {
      final directory = await getTemporaryDirectory();
      frpcDirectory = path.join(directory.path, 'frp-http-client');
    } else if (Platform.isWindows) {
      final dir = path.dirname(Platform.resolvedExecutable);
      frpcDirectory = path.join(dir, 'frpc');
    }
    Directory(frpcDirectory).createSync(recursive: true);

    /* if (kDebugMode) {
      final file = File(frpcExecutablePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } */
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

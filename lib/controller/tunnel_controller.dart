import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/network_tunnel.dart';
import './app_state.dart';

class TunnelController extends GetxController {
  static TunnelController get to => Get.find();

  // https://github.dev/tadaspetra/getx_examples/tree/master/todo_app
  // https://github.dev/carnevalli/getx_todo_app_tutorial
  // https://github.com/jonataslaw/getx/blob/master/documentation/zh_CN/state_management.md#getbuilder-vs-getx-vs-obx-vs-mixinbuilder
  final tunnels = <NetworkTunnel>[]; // no need for .obs
  late AppLifecycleListener _appLifecycleListener;

  Future<AppExitResponse> _onExitRequested() async {
    await _killall();
    return AppExitResponse.exit;
  }

  Future<void> _killall() async {
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

  @override
  void onInit() {
    // TODO: GetStorage for persistence
    if (kDebugMode) {
      addTunnel(NetworkTunnel(localIp: '127.0.0.1', localPort: 80));
    }

    _killall();
    _appLifecycleListener = AppLifecycleListener(
      onExitRequested: _onExitRequested,
    );
    super.onInit();
  }

  @override
  void onClose() {
    debugPrint('onClose');
    _appLifecycleListener.dispose();
    super.onClose();
  }

  void addTunnel(NetworkTunnel tunnel) {
    tunnels.add(tunnel);
    // GetBuilder only rebuilds on update()
    update();
  }

  void startTunnel(NetworkTunnel tunnel) {
    if (tunnel.status != TunnelStatus.notStarted) {
      return;
    }

    Process.start(AppState.to.frpcExecutablePath, [
      'http',
      '--server-addr=${AppState.to.frpsServerIp}',
      '--server-port=7000',
      '--local-ip=${tunnel.localIp}',
      '--local-port=${tunnel.localPort}',
      '--sd=${tunnel.subdomain}',
      '--proxy-name=${tunnel.subdomain}',
    ]).then((process) async {
      debugPrint('[startTunnel] process.pid: ${process.pid}');

      tunnel.process = process;
      tunnel.status = TunnelStatus.running;
      update();

      // 监听标准输出流
      process.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('标准输出: $data');
      });

      // 监听错误输出流
      process.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('错误输出: $data');
      });

      process.exitCode.then((exitCode) {
        debugPrint('tunnel.localPort: ${tunnel.localPort}');
        debugPrint('exitCode: $exitCode');
        if (tunnels.contains(tunnel)) {
          tunnel.status = TunnelStatus.notStarted;
          update();
        }
      });
    });
  }

  void stopTunnel(NetworkTunnel tunnel) {
    tunnel.process?.kill();
  }

  void stopAllTunnels() {
    for (var tunnel in tunnels) {
      stopTunnel(tunnel);
    }
  }

  void startAllTunnels() {
    for (var tunnel in tunnels) {
      startTunnel(tunnel);
    }
  }

  void removeTunnel(NetworkTunnel tunnel) {
    tunnels.remove(tunnel);
    tunnel.process?.kill();
    update();
  }
}
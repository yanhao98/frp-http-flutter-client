import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frp_http_client/common/constants.dart';
import 'package:frp_http_client/common/utils.dart';
import 'package:frp_http_client/model/frpc_log.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/network_tunnel.dart';
import './app_state.dart';

const _storageKey = 'tunnels';

class TunnelController extends GetxController {
  final _box = GetStorage(kStorageContainer, AppState.to.frpcDirectory);

  static TunnelController get to => Get.find();

  // https://github.dev/tadaspetra/getx_examples/tree/master/todo_app
  // https://github.dev/carnevalli/getx_todo_app_tutorial
  // https://github.com/jonataslaw/getx/blob/master/documentation/zh_CN/state_management.md#getbuilder-vs-getx-vs-obx-vs-mixinbuilder
  final tunnels = <NetworkTunnel>[].obs;
  // final tunnels = Rx<List<NetworkTunnel>>([]);
  late AppLifecycleListener _appLifecycleListener;

  @override
  Future<void> onInit() async {
    await _box.initStorage;
    _appLifecycleListener = AppLifecycleListener(
      onExitRequested: () async {
        killall();
        return AppExitResponse.exit;
      },
    );

    _restoreTunnels();
    debugPrint('[onInit]. tunnels.length: ${tunnels.length}');

    Future.delayed(
      const Duration(seconds: 1),
      () => startAllTunnels(),
    );

    ever(
      tunnels,
      (_) => {
        debugPrint('💾 tunnels changed'),
      },
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
    startTunnel(tunnel);
    _saveTunnels();
  }

  void startTunnel(NetworkTunnel tunnel) {
    debugPrint('[startTunnel] tunnel.subdomainHost: ${tunnel.subdomainHost}');
    if (tunnel.status != TunnelStatus.notStarted) {
      return;
    }
    tunnel.status = TunnelStatus.starting;
    tunnels.refresh();

    Process.start(AppState.to.frpcExecutablePath, [
      'http',
      '--server-addr=${tunnel.frpsServerIp}',
      '--server-port=7000',
      '--local-ip=${tunnel.localIp}',
      '--local-port=${tunnel.localPort}',
      '--sd=${tunnel.subdomain}',
      '--proxy-name=${tunnel.subdomain}',
    ]).then((process) async {
      debugPrint('[startTunnel] process.pid: ${process.pid}');

      tunnel.process = process;
      tunnel.status = TunnelStatus.running;
      tunnels.refresh();

      // 监听标准输出流
      process.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('标准输出: $data');
        // tunnel.logs.addAll(data.split('\n').map((e) => FrpcLogOutput(data: e)));
        tunnel.logs.addAll(data
            .split('\n')
            .where((e) => e.isNotEmpty)
            .map((e) => FrpcLogOutput(data: e)));
      });

      // 监听错误输出流
      process.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('错误输出: $data');
        tunnel.logs.add(FrpcLogError(data: data));
      });

      process.exitCode.then((exitCode) {
        debugPrint('tunnel.localPort: ${tunnel.localPort}');
        debugPrint('exitCode: $exitCode');
        if (tunnels.contains(tunnel)) {
          tunnel.status = TunnelStatus.notStarted;
          tunnels.refresh();
        }
      });
    });
  }

  void stopTunnel(NetworkTunnel tunnel) {
    debugPrint('[stopTunnel] tunnel.process?.pid: ${tunnel.process?.pid}');
    tunnel.process?.kill();
  }

  void stopAllTunnels() {
    debugPrint('[stopAllTunnels] tunnels.length: ${tunnels.length}');
    for (var tunnel in tunnels) {
      stopTunnel(tunnel);
    }
    killall();
  }

  void startAllTunnels() {
    for (var tunnel in tunnels) {
      startTunnel(tunnel);
    }
  }

  void removeTunnel(NetworkTunnel tunnel) {
    tunnels.remove(tunnel);
    tunnel.process?.kill();
    _saveTunnels();
  }

  void _saveTunnels() {
    debugPrint('[saveTunnels] tunnels.length: ${tunnels.length}');
    _box.write(_storageKey, tunnels);
  }

  void _restoreTunnels() {
    debugPrint('_box.read(_storageKey): ${_box.read(_storageKey)}');

    if (_box.hasData(_storageKey)) {
      debugPrint('🤡 _restoreTunnels');
      final List<dynamic> data = _box.read(_storageKey);
      tunnels.addAll(data.map((e) => NetworkTunnel.fromJson(e)));
    }
  }
}

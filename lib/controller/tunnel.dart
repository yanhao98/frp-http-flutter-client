import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../model/network_tunnel.dart';

class TunnelController extends GetxController {
  static TunnelController get to => Get.find();

  // https://github.dev/tadaspetra/getx_examples/tree/master/todo_app
  // https://github.dev/carnevalli/getx_todo_app_tutorial
  final tunnels = <NetworkTunnel>[].obs;

  @override
  void onInit() {
    ever(tunnels, (_) {
      debugPrint('Tunnels changed. ${tunnels.length} tunnels.');
    });
    super.onInit();
  }

  void addTunnel(NetworkTunnel tunnel) {
    tunnels.add(tunnel);
    update();
  }
}

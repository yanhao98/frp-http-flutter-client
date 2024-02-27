import 'dart:io';

import 'package:frp_http_client/controller/app_state.dart';

enum TunnelStatus {
  notStarted('未启动'),
  starting('启动中');

  final String name;
  const TunnelStatus(this.name);
}

class NetworkTunnel {
  String localIp;
  int localPort;
  TunnelStatus status = TunnelStatus.notStarted;
  late Process process;

  String get publicHostname =>
      '$subdomain.${AppState.to.frpsServer}'.toLowerCase();

  String get subdomain => '${AppState.to.subdomainPrefix}-$localPort';

  NetworkTunnel({
    required this.localIp,
    required this.localPort,
  });
}

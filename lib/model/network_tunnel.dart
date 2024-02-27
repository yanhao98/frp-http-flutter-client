import 'dart:io';

import 'package:frp_http_client/controller/app_state.dart';

enum TunnelStatus {
  notStarted('未启动'),
  running('运行中');

  final String name;
  const TunnelStatus(this.name);
}

class NetworkTunnel {
  final String localIp;
  final int localPort;
  TunnelStatus status = TunnelStatus.notStarted;
  Process? process;

  String get publicHostname =>
      '$subdomain.${AppState.to.frpsServer}'.toLowerCase();

  String get subdomain => '${AppState.to.subdomainPrefix}-$localPort';

  factory NetworkTunnel.fromJson(Map<String, dynamic> json) {
    return NetworkTunnel(
      localIp: json['localIp'],
      localPort: json['localPort'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localIp': localIp,
      'localPort': localPort,
    };
  }

  NetworkTunnel({
    required this.localIp,
    required this.localPort,
  });
}

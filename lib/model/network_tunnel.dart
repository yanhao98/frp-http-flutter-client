import 'dart:io';

import 'package:frp_http_client/common/constants.dart';
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

  /// frps服务器域名
  final String subdomainHost;

  TunnelStatus status = TunnelStatus.notStarted;
  Process? process;

  String get subdomain => '${AppState.to.domainPrefix}-$localPort';
  String get publicHostname => '$subdomain.$subdomainHost'.toLowerCase();
  get frpsServerIp => 'server-ip.$subdomainHost';

  factory NetworkTunnel.fromJson(Map<String, dynamic> json) {
    return NetworkTunnel(
      localIp: json['localIp'],
      localPort: json['localPort'],
      subdomainHost: json['subdomainHost'] ?? kDefaultSubdomainHost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localIp': localIp,
      'localPort': localPort,
      'subdomainHost': subdomainHost,
    };
  }

  NetworkTunnel({
    required this.localIp,
    required this.localPort,
    required this.subdomainHost,
  });
}

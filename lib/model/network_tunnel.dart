enum NetworkTunnelStatus {
  notStarted('未启动'),
  starting('启动中');

  final String status;
  const NetworkTunnelStatus(this.status);
}

class NetworkTunnelItem {
  // 内网地址
  String localIp;
  // 内网端口
  int localPort;

  NetworkTunnelItem({
    required this.localIp,
    required this.localPort,
  });
}

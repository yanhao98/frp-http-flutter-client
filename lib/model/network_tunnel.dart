enum TunnelStatus {
  notStarted('未启动'),
  starting('启动中');

  final String status;
  const TunnelStatus(this.status);
}

class NetworkTunnel {
  String localIp;
  int localPort;
  TunnelStatus status = TunnelStatus.notStarted;

  NetworkTunnel({
    required this.localIp,
    required this.localPort,
  });
}

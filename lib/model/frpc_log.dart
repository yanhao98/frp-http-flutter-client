// 2024/03/05 22:20:20 [1;34m[I] [service.go:287] try to connect to server...[0m
class FrpcLogBase {
  /// 原始数据
  final String data;

  String get text =>
      // 去掉末尾的换行符
      (data.endsWith('\n') ? data.substring(0, data.length - 0) : data)
          // 去掉颜色控制符
          .replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '')
          // 去掉 ` [I]/[E]/[W]`
          .replaceAll(RegExp(r' \[[IWE]\]'), '')
          // 去掉 ` [xxx.go:xxx]`
          .replaceAll(RegExp(r' \[[a-zA-Z0-9_\.]+:\d+\]'), '')
      //
      ;

  // Error, Warn, Info, Debug, Trace
  // 匹配 data 中的 [I] [E] [W]
  String get type =>
      RegExp(r'\[([IWE])\]').firstMatch(data)?.group(1) ?? 'Unknown';

  FrpcLogBase({required this.data});

  @override
  toString() => data;
}

class FrpcLogOutput extends FrpcLogBase {
  FrpcLogOutput({required super.data});
}

class FrpcLogError extends FrpcLogBase {
  FrpcLogError({required super.data});
}

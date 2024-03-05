class FrpcLogBase {
  /// 原始数据
  final String data;

  //    2024/03/05 22:20:20 [1;34m[I] [service.go:287] try to connect to server...[0m
  // => 2024/03/05 22:20:20 [I] [service.go:287] try to connect to server...
  String get text =>
      // 去掉末尾的换行符
      (data.endsWith('\n') ? data.substring(0, data.length - 0) : data)
          // 去掉颜色控制符
          .replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '')
      //
      ;

  // 第一个 [ 和 ] 之间的内容
  String get type => text.substring(text.indexOf('[') + 1, text.indexOf(']'));

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

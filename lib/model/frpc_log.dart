class FrpcLogBase {
  final String data;

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

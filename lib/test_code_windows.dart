import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

void _kill() {
  // taskkill /f /im frpc_windows_arm64.exe
  Process.run('taskkill', ['/f', '/im', 'frpc_windows_arm64.exe'])
      .then((result) {
    debugPrint(result.stderr);
    debugPrint(result.stdout);
    debugPrint('Exit code: ${result.exitCode}');
  });
}

Future<void> _testFn() async {
  debugPrint('Downloading...');
  // final directory = await getTemporaryDirectory();
  // https://dl.19980901.xyz/frpc_windows_arm64.exe

  final directory = await getTemporaryDirectory();
  const url = 'https://dl.19980901.xyz/frpc_windows_arm64.exe';
  final response = await http.get(Uri.parse(url));
  final filePath = path.join(directory.path, 'frpc_windows_arm64.exe');
  final file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  debugPrint('Downloaded to $filePath');

  // Execute the command
  final process = await Process.start(
      filePath,
      [
        'http',
        '--server-addr=146.56.128.30',
        '--server-port=7000',
        '--local-ip=127.0.0.1',
        '--local-port=80',
        '--sd=flutter-dev',
        '--proxy-name=flutter-dev'
      ],
      runInShell: true);

  // 监听标准输出流
  process.stdout.transform(utf8.decoder).listen((data) {
    debugPrint('标准输出: $data');
  });

  // 监听错误输出流
  process.stderr.transform(utf8.decoder).listen((data) {
    debugPrint('错误输出: $data');
  });

  final exitCode = await process.exitCode;
  debugPrint('Exit code: $exitCode');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _kill,
                child: Text('Kill frpc_windows_arm64.exe'),
              ),
              ElevatedButton(
                onPressed: _testFn,
                child: Text('Download and Run'),
              ),
            ],
          ),
        ));
  }
}

import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
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

void getWindowsArch() {
  final result =
      Process.runSync('cmd', ['/c', 'echo %PROCESSOR_ARCHITECTURE%']);
  var content = result.stdout.toString().trim().toLowerCase();
  debugPrint('content: $content'); // amd64
}

ElevatedButton clickMe(BuildContext context) {
  return ElevatedButton(
    onPressed: () async {
      String? content;
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isMacOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        debugPrint('macOsInfo: $macOsInfo');
        debugPrint('macOsInfo.arch: ${macOsInfo.arch}');
        // {"arch":"arm64","majorVersion":14,"kernelVersion":"Darwin Kernel Version 23.3.0: Wed Dec 20 21:30:44 PST 2023; root:xnu-10002.81.5~7/RELEASE_ARM64_T6000","osRelease":"Version 14.3 (Build 23D56)","cpuFrequency":0,"activeCPUs":10,"model":"MacBookPro18,2","memorySize":34359738368,"systemGUID":"DF772E83-CFAF-5284-9A05-8F65438A657F","computerName":"严浩的MacBook Pro","patchVersion":0,"minorVersion":3,"hostName":"Darwin"}
        content = jsonEncode(macOsInfo.data.toString());
      }
      if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        debugPrint('windowsInfo: $windowsInfo');
        debugPrint('windowsInfo.computerName: ${windowsInfo.computerName}');
        // "{computerName: 2E76, numberOfCores: 4, systemMemoryInMegabytes: 8192, userName: yanhao, majorVersion: 10, minorVersion: 0, buildNumber: 22000, platformId: 2, csdVersion: , servicePackMajor: 0, servicePackMinor: 0, suitMask: 768, productType: 1, reserved: 0, buildLab: 22000.co_release.210604-1628, buildLabEx: 22000.1.arm64fre.co_release.210604-1628, digitalProductId: [164, 0, 0, 0, 3, 0, 0, 0, 48, 48, 51, 50, 54, 45, 49, 48, 48, 48, 48, 45, 48, 48, 48, 48, 48, 45, 65, 65, 50, 54, 52, 0, 189, 12, 0, 0, 91, 84, 72, 93, 88, 49, 57, 45, 57, 56, 56, 54, 56, 0, 0, 0, 189, 12, 0, 0, 0, 0, 188, 179, 189, 197, 115, 255, 9, 118, 9, 0, 0, 0, 0, 0, 152, 151, 35, 99, 0, 108, 34, 187, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 103, 176, 69, 253], displayVersion: 21H2, editionId: Core, installDate: 2022-09-15 21:23:58.000, productId: 00326-10000-00000-AA264, productName: Windows 11 Home, registeredOwner: 严浩, releaseId: 2009, deviceId: {154EBC95-597F-48AF-8BA9-EA9BBE6D1590}}"
        // "{computerName: DESKTOP-FHQNHGB, numberOfCores: 8, systemMemoryInMegabytes: 16384, userName: DELL, majorVersion: 10, minorVersion: 0, buildNumber: 19045, platformId: 2, csdVersion: , servicePackMajor: 0, servicePackMinor: 0, suitMask: 768, productType: 1, reserved: 0, buildLab: 19041.vb_release.191206-1406, buildLabEx: 19041.1.amd64fre.vb_release.191206-1406, digitalProductId: [164, 0, 0, 0, 3, 0, 0, 0, 48, 48, 51, 50, 54, 45, 49, 48, 48, 48, 48, 45, 48, 48, 48, 48, 48, 45, 65, 65, 56, 54, 48, 0, 189, 12, 0, 0, 91, 84, 72, 93, 88, 49, 57, 45, 57, 56, 56, 54, 56, 0, 0, 0, 189, 12, 0, 0, 0, 0, 188, 179, 189, 197, 115, 255, 9, 118, 9, 0, 0, 0, 0, 0, 98, 49, 166, 97, 76, 88, 240, 151, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 58, 18, 172, 41], displayVersion: 22H2, editionId: Core, installDate: 2021-11-30 14:14:14.000, productId: 00326-10000-00000-AA860, productName: Windows 10 Home, registeredOwner: DELL, releaseId: 2009, deviceId: {161A51D1-8AB5-4472-BBC8-0EF175667D51}}"
        content = jsonEncode(windowsInfo.data.toString());
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('DeviceInfo'),
            content: TextField(
              controller: TextEditingController(text: content),
              maxLines: 10,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
    child: const Text('Click me'),
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:frp_http_client/left_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          const SizedBox(
            width: 256 - 56,
            child: LeftWidget(),
          ),
          Expanded(
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    String? content;
                    final deviceInfo = DeviceInfoPlugin();
                    if (Platform.isMacOS) {
                      final macOsInfo = await deviceInfo.macOsInfo;
                      debugPrint('macOsInfo: $macOsInfo');
                      debugPrint('macOsInfo.arch: ${macOsInfo.arch}');
                      // {"arch":"arm64","majorVersion":14,"kernelVersion":"Darwin Kernel Version 23.3.0: Wed Dec 20 21:30:44 PST 2023; root:xnu-10002.81.5~7/RELEASE_ARM64_T6000","osRelease":"Version 14.3 (Build 23D56)","cpuFrequency":0,"activeCPUs":10,"model":"MacBookPro18,2","memorySize":34359738368,"systemGUID":"DF772E83-CFAF-5284-9A05-8F65438A657F","computerName":"严浩的MacBook Pro","patchVersion":0,"minorVersion":3,"hostName":"Darwin"}
                      content = jsonEncode(macOsInfo.data);
                    }
                    if (Platform.isWindows) {
                      final windowsInfo = await deviceInfo.windowsInfo;
                      debugPrint('windowsInfo: $windowsInfo');
                      debugPrint(
                          'windowsInfo.computerName: ${windowsInfo.computerName}');
                      content = jsonEncode(windowsInfo.data);
                    }

                    if (context.mounted) {
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
                    }
                  },
                  child: const Text('Click me'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:frp_http_client/left_widget.dart';
import 'package:frp_http_client/right_widget.dart';
import 'package:get/get.dart';

import 'controller/app_state.dart';

void main() async {
  // await GetStorage.init(kStorageContainer);
  appWindow.minSize = const Size(1000, 400);
  appWindow.size = const Size(1000, 600);
  runApp(const MyApp());
  GetInstance().put(AppState());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    debugPrint('build MyApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // useMaterial3: false,
          ),
      // home: MoveWindow(child: const MyHomePage()),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          ),
          const Expanded(
            child: Row(
              children: [
                LeftWidget(),
                RightWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(),
        CloseWindowButton(),
      ],
    );
  }
}

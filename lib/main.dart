import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:frp_http_client/left_widget.dart';
import 'package:frp_http_client/right_widget.dart';
import 'package:get/get.dart';

import 'common/utils.dart';
import 'controller/app_state.dart';

void main() async {
  killall();
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
          if (!Platform.isWindows)
            // Windows 用系统自带的标题栏
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  // const WindowButtons()
                ],
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

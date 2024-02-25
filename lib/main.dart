import 'package:flutter/material.dart';
import 'package:frp_http_client/left_widget.dart';
import 'package:frp_http_client/right_widget.dart';
import 'package:get/get.dart';

import 'controller/app_state.dart';

void main() {
  runApp(const MyApp());
  GetInstance().put(AppState());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
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
    return const Scaffold(
      body: Row(
        children: [LeftWidget(), RightWidget()],
      ),
    );
  }
}

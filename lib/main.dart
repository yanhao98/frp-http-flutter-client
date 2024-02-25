import 'package:flutter/material.dart';
import 'package:frp_http_client/left_widget.dart';
import 'package:frp_http_client/right_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
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

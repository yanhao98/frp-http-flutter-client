import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 256,
              child: Text('left side content'),
            ),
          ),
          Expanded(
            child: Card(
              elevation: 0,
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              child: const Center(
                child: Text('right side content'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

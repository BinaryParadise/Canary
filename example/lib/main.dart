
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_canary/flutter_canary.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String _platformVersion = 'Unknown';
  bool connect = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    FlutterCanary.instance().configure('82e439d7968b7c366e24a41d7f53f47d',
        service: 'http://127.0.0.1:9001/api',
        deviceid: 'flutter-canary-example-device-id');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await FlutterCanary.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _testCanary() {
    if (connect) {
      FlutterCanary.instance().stop();
    } else {
      FlutterCanary.instance().start();
    }
    setState(() {
      connect = !connect;
    });
  }

  void log(String msg, {StackTrace? trace}) {
    throw msg;
  }

  @override
  Widget build(BuildContext context) {
    Widget current = Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Running on: $_platformVersion\n'),
          TextButton(
              onPressed: _testCanary, child: Text(connect ? '关闭连接' : '连接测试')),
          TextButton(onPressed: () => log('日志测试'), child: Text('日志测试')),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _testCanary();
          FlutterCanary.instance().showOptions(context);
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
    return current;
  }
}

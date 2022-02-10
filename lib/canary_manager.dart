// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/canary_dio.dart';
import 'package:flutter_canary/canary_logger.dart';
import 'package:flutter_canary/canary_options.dart';
import 'package:flutter_canary/mock_manager.dart';
import 'package:flutter_canary/model/model_user.dart';
import 'package:flutter_canary/websocket/canary_websocket.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:flutter_canary/websocket/websocket_receiver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/model_mock.dart';

enum NetLogMode { AFNetworking, Alamofire }

class FlutterCanary {
  static final FlutterCanary _instance = FlutterCanary._();
  FlutterCanary._();
  static FlutterCanary instance() => _instance;

  static const MethodChannel channel = MethodChannel('flutter_canary');

  static Future<String?> get platformVersion async {
    final String? version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  late String appSecret;
  late String service;
  late String deviceid;
  bool _forwardLog = false;
  bool debug = false;
  bool _mockOn = false;
  bool get mockOn => _mockOn;
  set mockOn(bool on) {
    SharedPreferences.getInstance()
        .then((value) => value.setBool('mockOn', on).then((value) {
              _mockOn = on;
              channel.invokeMethod('enableMock', _mockOn);
            }));
  }

  ValueNotifier<User?> user = ValueNotifier(null);
  Map<String, MockItem> mockMap = {};

  void configure(String appSecret,
      {required String service, required String deviceid, bool debug = false}) {
    this.appSecret = appSecret;
    this.service = service;
    this.deviceid = deviceid;
    this.debug = debug;

    MockManager.instance().update();
    SharedPreferences.getInstance().then((prefs) {
      _mockOn = prefs.getBool('mockOn') ?? false;
      if (_mockOn) {
        channel.invokeMethod('enableMock', _mockOn);
      }
      var map =
          jsonDecode(prefs.getString('user') ?? "{}") as Map<String, dynamic>?;
      if (map != null && map.isNotEmpty) {
        user.value = User.fromJson(map);
      }
    });

    channel.setMethodCallHandler(_callHandler);

    CanaryDio.instance().configure(service);
    CanaryWebSocket.instance().configure(service, deviceid, appSecret);
    setupChannel();
  }

  void setupChannel() async {
    await channel.invokeMethod('configure', {'baseUrl': service});
  }

  void start({NetLogMode mode = NetLogMode.AFNetworking}) async {
    CanaryWebSocket.instance().start();
    await channel
        .invokeMethod('enableNetLog', mode.toString())
        .then((value) => null);
    _forwardLog = true;
    logger.i('开启网络日志');
  }

  void stop() {
    _forwardLog = false;
    CanaryWebSocket.instance().clear();
  }

  void showOptions(BuildContext context) {
    Widget current = const CanaryOptions();
    showDialog(context: context, useSafeArea: false, builder: (ctx) => current);
  }

  Future<dynamic> _callHandler(MethodCall call) {
    if (debug) {
      logger.d('${call.method} ${call.arguments}');
    }
    if (call.method == "forwardLog" && _forwardLog) {
      var msg = WebSocketMessage(MessageAction.log, data: call.arguments);
      CanaryWebSocket.instance().send(msg);
      return Future.value(true);
    } else if (call.method == "checkIntercept") {
      return MockManager.instance().checkIntercept(call);
    }
    return Future.value(false);
  }
}

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
import 'package:flutter_canary/canary_options.dart';
import 'package:flutter_canary/model/model_user.dart';
import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/canary_websocket.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:flutter_canary/websocket/websocket_receiver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterCanary {
  static final FlutterCanary _instance = FlutterCanary._();
  FlutterCanary._();
  static FlutterCanary instance() => _instance;

  static const MethodChannel _channel = MethodChannel('flutter_canary');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  late String appSecret;
  late String service;
  late String deviceid;

  ValueNotifier<User?> user = ValueNotifier(null);

  void configure(String appSecret,
      {required String service, required String deviceid}) {
    this.appSecret = appSecret;
    this.service = service;
    this.deviceid = deviceid;

    SharedPreferences.getInstance().then((prefs) {
      var map =
          jsonDecode(prefs.getString('user') ?? "{}") as Map<String, dynamic>?;
      if (map != null && map.isNotEmpty) {
        user.value = User.fromJson(map);
      }
    });

    _channel.setMethodCallHandler(_callHandler);

    CanaryDio.instance().configure(service);
    CanaryWebSocket.instance().configure(service, deviceid, appSecret);
  }

  void start() {
    CanaryWebSocket.instance().provider = WebSocketReceiver();
    CanaryWebSocket.instance().start();
  }

  void showOptions(BuildContext context) {
    Widget current = const CanaryOptions();
    showDialog(context: context, useSafeArea: false, builder: (ctx) => current);
  }

  Future<dynamic> _callHandler(MethodCall call) {
    if (call.method == "forwardLog") {
      var msg = WebSocketMessage(MessageAction.log, data: call.arguments);
      CanaryWebSocket.instance().send(msg);
      return Future.value(true);
    }
    return Future.value(false);
  }
}

// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/canary_dio.dart';
import 'package:flutter_canary/canary_logger.dart';
import 'package:flutter_canary/canary_options.dart';
import 'package:flutter_canary/config/config_manager.dart';
import 'package:flutter_canary/mock/mock_manager.dart';
import 'package:flutter_canary/model/model_user.dart';
import 'package:flutter_canary/websocket/canary_websocket.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import 'model/model_mock.dart';

enum NetLogMode { afNetworking, alamofire, okHttp }

class FlutterCanary {
  static final FlutterCanary _instance = FlutterCanary._();
  FlutterCanary._();
  factory FlutterCanary() => _instance;
  static FlutterCanary get instance => _instance;

  static MethodChannel channel = const MethodChannel('flutter_canary');

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

  /// 附加信息(例如push token)
  Map<String, dynamic> Function()? extra;

  ValueNotifier<User?> user = ValueNotifier(null);
  Map<String, MockItem> mockMap = {};

  Future<void> configure(String appSecret,
      {required String service,
      required String deviceid,
      bool debug = false}) async {
    this.appSecret = appSecret;
    this.service = service;
    this.deviceid = deviceid;
    this.debug = debug;
    if (debug) {
      Logger.level = Level.debug;
    } else {
      Logger.level = Level.info;
    }

    CanaryDio.instance.configure(service);

    var prefs = await SharedPreferences.getInstance();
    _mockOn = prefs.getBool('mockOn') ?? false;
    if (_mockOn) {
      channel.invokeMethod('enableMock', _mockOn);
    }
    var map =
        jsonDecode(prefs.getString('user') ?? "{}") as Map<String, dynamic>?;
    if (map != null && map.isNotEmpty) {
      user.value = User.fromJson(map);
    }

    MockManager.instance().update();

    channel.setMethodCallHandler(_callHandler);

    CanaryWebSocket.instance.configure(service, deviceid, appSecret);
  }

  void start({NetLogMode mode = NetLogMode.afNetworking}) async {
    mode = Platform.isAndroid ? NetLogMode.okHttp : mode;
    CanaryWebSocket.instance.start();
    await channel
        .invokeMethod('enableNetLog', mode.toString())
        .then((value) => null);
    _forwardLog = true;
    logger.d('开启网络日志');
  }

  void stop() {
    _forwardLog = false;
    CanaryWebSocket.instance.clear();
  }

  void showOptions(BuildContext context) {
    showDialog(
        context: context,
        useSafeArea: false,
        useRootNavigator: false,
        builder: (ctx) => options(),
        routeSettings: const RouteSettings(name: '/canary_root'));
  }

  // 返回原生页面（若是顶层则关闭）, animated仅对iOS生效
  static Future<T?> pop<T>({bool animated = true}) {
    return channel.invokeMethod('navigator.pop', animated);
  }

  Widget options() {
    return const CanaryOptions();
  }

  /// 获取配置的参数值
  String? configValue(String key, {String? def}) {
    return ConfigManager.instance.value(key, def: def);
  }

  void close(BuildContext context) {
    Navigator.of(context).popUntil((route) {
      return route.settings.name == 'canary_root';
    });
  }

  Future<dynamic> _callHandler(MethodCall call) {
    if (debug) {
      logger.d('${call.method} ${call.arguments}');
    }
    if (call.method == "forwardLog" && _forwardLog) {
      var msg = WebSocketMessage(MessageAction.log, data: call.arguments);
      CanaryWebSocket.instance.send(msg);
      return Future.value(true);
    } else if (call.method == "checkIntercept") {
      return MockManager.instance().checkIntercept(call);
    } else if (call.method == "configValue") {
      return Future.value(
          FlutterCanary.instance.configValue(call.arguments as String));
    }
    return Future.value(false);
  }
}

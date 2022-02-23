import 'dart:convert' show Utf8Encoder, jsonEncode;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_canary/canary_logger.dart';
import 'package:flutter_canary/canary_manager.dart';
import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:web_socket_io/web_socket_io.dart';

class CanaryWebSocket implements WebSocketProvider {
  static final CanaryWebSocket _instance = CanaryWebSocket._();
  static CanaryWebSocket get instance => _instance;
  CanaryWebSocket._();
  late WebSocketChannel channel;

  Timer? _timer;
  int _count = 0;

  WebSocketClient? client;
  late String _webSocketUrl;
  String get url {
    return _webSocketUrl;
  }

  String appSecret = '';

  void configure(String url, String deviceid, String appSecret) {
    var uri = Uri.parse(url);
    this.appSecret = appSecret;
    var platform =
        defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '');
    _webSocketUrl =
        '${uri.scheme.toLowerCase() == 'http' ? 'ws' : 'wss'}://${uri.host}:${uri.port}${uri.path}/channel/$platform/$deviceid';
    client = WebSocketClient(_webSocketUrl,
        provider: this, headers: {'Canary-App-Secret': appSecret});
  }

  // 开启服务
  void start() {
    client?.connect();
  }

  Future<bool> _reconnect() async {
    await Future.delayed(const Duration(seconds: 10), () {
      start();
    });
    return Future.value(true);
  }

  void clear() {
    client?.close();
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    var data = const Utf8Encoder().convert(jsonEncode(msg.toJson()));
    client?.sendData(data);
  }

  void register() async {
    var device = await Device.create();
    if (FlutterCanary.instance.extra != null) {
      device.profile = FlutterCanary.instance.extra!();
    }
    var msg = WebSocketMessage(MessageAction.register, data: device.toJson());
    channel.send(OpCode.binary, const Utf8Encoder().convert(jsonEncode(msg)));
  }

  @override
  void onClosed(CloseCode code, WebSocketChannel webSocket) {
    logger.e('连接已关闭, 10秒后重试...$url');
    _reconnect();
    _timer?.cancel();
    _timer = null;
  }

  /// WebSocketProvider
  @override
  void onConnected(WebSocketChannel webSocket) {
    logger.i('设备已连接到: ${CanaryWebSocket.instance.url}');
    channel = webSocket;
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _count++;
      channel.send(OpCode.ping, _count.bytes());
    });
    register();
  }

  @override
  void onMessage(Uint8List message, WebSocketChannel webSocket) {}

  @override
  void onPing(Uint8List data, WebSocketChannel webSocket) {}

  @override
  void onPong(Uint8List data, WebSocketChannel webSocket) {
    register();
  }

  @override
  void onText(String message, WebSocketChannel webSocket) {}
}

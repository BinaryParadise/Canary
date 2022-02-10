import 'dart:async';
import 'dart:convert' show Utf8Decoder, Utf8Encoder, jsonDecode, jsonEncode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:flutter_canary/websocket/websocket_receiver.dart';
import 'package:web_socket_io/web_socket_io.dart';

class CanaryWebSocket {
  static final CanaryWebSocket _instance = CanaryWebSocket._();
  static CanaryWebSocket instance() => _instance;
  CanaryWebSocket._();

  WebSocketClient? client;
  late String _webSocketUrl;
  String get url {
    return _webSocketUrl;
  }

  String appSecret = '';
  Timer? _pingTimer;
  int _pingCount = 0;

  void configure(String url, String deviceid, String appSecret) {
    var uri = Uri.parse(url);
    this.appSecret = appSecret;
    var platform =
        defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '');
    _webSocketUrl =
        '${uri.scheme.toLowerCase() == 'http' ? 'ws' : 'wss'}://${uri.host}:${uri.port}${uri.path}/channel/$platform/$deviceid';
    client = WebSocketClient(_webSocketUrl,
        provider: WebSocketReceiver(),
        headers: {'Canary-App-Secret': appSecret});
  }

  // 开启服务
  void start() {
    client?.connect();
  }

  void clear() {
    client?.close();
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    var data = Utf8Encoder().convert(jsonEncode(msg.toJson()));
    client?.sendData(data);
  }
}

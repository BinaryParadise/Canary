import 'dart:convert' show Utf8Decoder, Utf8Encoder, jsonDecode, jsonEncode;

import 'package:flutter/foundation.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:websocket_io/websocket_io.dart';

class CanaryWebSocket {
  static final CanaryWebSocket _instance = CanaryWebSocket._();
  static CanaryWebSocket instance() => _instance;
  CanaryWebSocket._();

  WebSocketIO? channel;
  late String _webSocketUrl;
  String get url {
    return _webSocketUrl;
  }

  WebSocketProvider? provider;
  String appSecret = '';

  void configure(String url, String deviceid, String appSecret) {
    var uri = Uri.parse(url);
    this.appSecret = appSecret;
    var platform =
        defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '');
    _webSocketUrl =
        '${uri.scheme.toLowerCase() == 'http' ? 'ws' : 'wss'}://${uri.host}:${uri.port}${uri.path}/channel/$platform/$deviceid';
  }

  void _setup() async {
    channel =
        WebSocketIO(_webSocketUrl, headers: {'Canary-App-Secret': appSecret});
    await channel?.connect();
    channel?.onMessage = (frame) {
      switch (frame.opcode) {
        case OpCode.text:
          break;
        case OpCode.binary:
          var data = jsonDecode(const Utf8Decoder().convert(frame.payload))
              as Map<String, dynamic>;
          if (data.isNotEmpty) {
            var r = WebSocketMessage.fromJson(data);
            provider?.onMessage(r, this);
            print(data);
          }
          break;
        case OpCode.close:
          // TODO: Handle this case.
          break;
        case OpCode.ping:
          // TODO: Handle this case.
          break;
        case OpCode.pong:
          // TODO: Handle this case.
          break;
        case OpCode.reserved:
          // TODO: Handle this case.
          break;
      }
    };
    channel?.onClose = (closeCode) {
      provider?.onClosed(closeCode);
    };
  }

  // 开启服务
  void start() {
    _setup();
  }

  void clear() {
    channel?.close();
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    var data = Utf8Encoder().convert(jsonEncode(msg.toJson()));
    channel?.sendBinary(data.toList());
  }
}

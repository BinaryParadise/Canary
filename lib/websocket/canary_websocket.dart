import 'dart:convert' show Utf8Decoder, Utf8Encoder, jsonDecode, jsonEncode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:flutter_canary/websocket/websocket_receiver.dart';
import 'package:web_socket_channel/io.dart';
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
    await channel?.close();
    channel =
        WebSocketIO(_webSocketUrl, headers: {'Canary-App-Secret': appSecret});
    channel?.connect().then((value) => provider?.onConnected(this));
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
      print('$closeCode');
    };
  }

  // 开启服务
  void start() {
    clear().then((value) => _setup());
  }

  Future<bool> clear() async {
    if (channel != null) {
      channel?.close().then((value) => true);
    }
    return Future.value(true);
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    var data = Utf8Encoder().convert(jsonEncode(msg.toJson()));
    print('预备: ${data.length}');
    channel?.sendBinary(data.toList());
  }
}

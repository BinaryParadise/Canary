import 'dart:convert' show Utf8Decoder, jsonDecode, jsonEncode;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:flutter_canary/websocket/websocket_receiver.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CanaryWebSocket {
  static final CanaryWebSocket _instance = CanaryWebSocket._();
  static CanaryWebSocket instance() => _instance;
  CanaryWebSocket._();

  WebSocketChannel? channel;
  late String _webSocketUrl;
  WebSocketProvider? provider;

  void configure(String url, String deviceid, String appSecret) {
    var uri = Uri.parse(url);
    var platform =
        defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '');
    _webSocketUrl =
        '${uri.scheme.toLowerCase() == 'http' ? 'ws' : 'wss'}://${uri.host}:${uri.port}${uri.path}/channel/$platform/$deviceid?app-secret=$appSecret';
  }

  void _setup() {
    channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
    channel?.stream.listen((event) {
      var data = jsonDecode(const Utf8Decoder().convert(event))
          as Map<String, dynamic>;
      if (data.isNotEmpty) {
        var r = WebSocketMessage.fromJson(data);
        provider?.onMessage(r, this);
        print(data);
      }
    }, onError: (e) {
      print('onError');
    }, onDone: () {
      print('onDone');
    });
    channel?.sink.done.then((value) => print(value));
  }

  // 开启服务
  void start() {
    clear().then((value) => _setup());
  }

  Future<bool> clear() async {
    if (channel != null) {
      channel?.sink.close().then((value) => true);
    }
    return Future.value(true);
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    channel?.sink.add(jsonEncode(msg.toJson()).codeUnits);
  }
}

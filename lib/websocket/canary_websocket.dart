import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CanaryWebSocket {
  static final CanaryWebSocket _instance = CanaryWebSocket._();
  static CanaryWebSocket instance() => _instance;
  CanaryWebSocket._();

  late WebSocketChannel channel;
  late String _webSocketUrl;

  void configure(String url, String deviceid, String appSecret) {
    var uri = Uri.parse(url);
    var platform =
        defaultTargetPlatform.toString().replaceAll('TargetPlatform.', '');
    _webSocketUrl =
        '${uri.scheme.toLowerCase() == 'http' ? 'ws' : 'wss'}://${uri.host}:${uri.port}${uri.path}/channel/$platform/$deviceid?app-secret=$appSecret';
  }

  // 开启服务
  void start() {
    channel = WebSocketChannel.connect(Uri.parse(_webSocketUrl));
    channel.stream.listen((event) {
      var data = jsonDecode(const Utf8Decoder().convert(event))
          as Map<String, dynamic>;
      if (data.isNotEmpty) {
        var r = Result.fromJson(data);
        print(data);
      }
    }, onError: (e) {
      print('onError');
    }, onDone: () {
      print('onDone');
    });
  }

  // 发送消息
  void send(WebSocketMessage msg) {
    channel.sink.add(msg.toJson());
  }
}

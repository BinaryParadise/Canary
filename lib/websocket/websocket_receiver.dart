import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';
import 'package:web_socket_io/web_socket_io.dart';

class WebSocketReceiver implements WebSocketProvider {
  late WebSocketChannel channel;

  Timer? _timer;
  int _count = 0;

  void register() async {
    var device = await Device.create();
    var msg = WebSocketMessage(MessageAction.register, data: device.toJson());
    channel.send(OpCode.binary, const Utf8Encoder().convert(jsonEncode(msg)));
  }

  @override
  void onClosed(CloseCode code, WebSocketChannel webSocket) {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void onConnected(WebSocketChannel webSocket) {
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

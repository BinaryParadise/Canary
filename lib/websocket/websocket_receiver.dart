import 'dart:async';

import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/canary_websocket.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';

class WebSocketReceiver implements WebSocketProvider {
  Timer? timer;

  @override
  void onMessage(WebSocketMessage message, CanaryWebSocket webSocket) {
    switch (message.type) {
      case MessageAction.connected:
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 10), (timer) {
          register(webSocket);
        });
        onConnected(webSocket);
        break;
      case MessageAction.update:
        // TODO: Handle this case.
        break;
      case MessageAction.register:
        // TODO: Handle this case.
        break;
      case MessageAction.list:
        // TODO: Handle this case.
        break;
      case MessageAction.log:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void onConnected(CanaryWebSocket webSocket) {
    print('已连接: ${webSocket.url}');
    register(webSocket);
  }

  void register(CanaryWebSocket webSocket) async {
    var device = await Device.create();
    webSocket
        .send(WebSocketMessage(MessageAction.register, data: device.toJson()));
  }
}

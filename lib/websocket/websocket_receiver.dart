import 'dart:async';
import 'dart:ffi';

import 'package:flutter_canary/model/module_device.dart';
import 'package:flutter_canary/websocket/canary_websocket.dart';
import 'package:flutter_canary/websocket/websocket_message.dart';

class WebSocketReceiver implements WebSocketProvider {
  @override
  void onMessage(WebSocketMessage message, CanaryWebSocket webSocket) {
    switch (message.type) {
      case MessageAction.connected:
        Timer.periodic(const Duration(seconds: 10), (timer) {
          register(webSocket);
        });
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

  void register(CanaryWebSocket webSocket) async {
    var device = await Device.create();
    webSocket
        .send(WebSocketMessage(MessageAction.register, data: device.toJson()));
  }
}

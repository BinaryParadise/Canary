import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:websocket_io/websocket_io.dart';

void main() {
  final channel = WebSocketIO(
      'ws://127.0.0.1:9001/api/channel/iOS/canary_device_id',
      headers: {'app-secret': '82e439d7968b7c366e24a41d7f53f47d'});
  test('adds one to input values', () async {
    channel.onMessage = (data) {};
    await channel.connect().then((value) => expect(value, true));
  });

  test('num convert to bytes', () {
    expect(8756982.bytes(bit: BitWidth.byte), Uint8List.fromList([246]));
    expect(8756982.bytes(bit: BitWidth.short), Uint8List.fromList([158, 246]));
    expect(8756982.bytes(bit: BitWidth.int), Uint8List.fromList([0, 133, 158, 246]));
    expect(9007199590416384.bytes(bit: BitWidth.long),
        Uint8List.fromList([0, 32, 0, 0, 20, 02, 0, 0]));
  });
}

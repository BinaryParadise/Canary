import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_canary/flutter_canary.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_canary');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterCanary.platformVersion, '42');
  });

  test('sha', () {
    const secWebSocketKey = 'WucfuUQPB1aZVA7ifVqEdA==';

    var acceptKey = base64.encoder.convert(sha1
        .convert((secWebSocketKey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')
            .codeUnits)
        .bytes);
    expect(acceptKey, 'lx1/mZBv0CojohTRTQA74CGdc+0=');
  });
}

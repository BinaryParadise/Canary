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

  test('regex', () {
    var uri1 = Uri.parse('http://127.0.0.1/mock/data?action=sq');
    expect(
        RegExp('/{p1}/{p2}'.replaceAll(RegExp('({[^{}]+})'), '[^/]+'))
            .hasMatch(uri1.path),
        true);

    var uri2 = Uri.parse(
        'https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp');
    expect(
        RegExp('/{p1}/{p2}.do'.replaceAll(RegExp('({[^{}]+})'), '[^/]+'))
            .hasMatch(uri2.path),
        true);
  });
}

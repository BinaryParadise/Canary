library websocket_io;

export './webscoket_frame.dart';

import 'dart:io';
import 'dart:convert' as convert;
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:websocket_io/webscoket_frame.dart';

const String webSocketGUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';

class WebSocketIO {
  String url;
  Map<String, String>? headers;
  WebSocketIO(this.url, {this.headers, this.onMessage});

  Function(WebSocketFrame frame)? onMessage;
  Function(CloseCode)? onClose;

  bool _handshaked = false;
  Socket? _socket;

  Future<bool> connect() async {
    this.close();
    var uri = Uri.parse(url);
    await Socket.connect(uri.host, uri.port).then((value) {
      _socket = value;

      _socket?.listen((event) {
        if (_handshaked) {
          var frame = WebSocketFrame.create(event);
          if (onMessage != null) {
            if (frame.opcode == OpCode.close) {
              if (onClose != null) {
                onClose!(CloseCodeExtension.parse(frame.payload.uint16));
              }
            } else {
              onMessage!(frame);
            }
          }
        } else {
          var hds = String.fromCharCodes(event.toList()).split('\r\n');
          _handshaked = true;
        }
      }, onError: (error) {
        if (onClose != null) {
          onClose!(CloseCode.error);
        }
      });

      _socket?.writeln('GET ${uri.path} HTTP/1.1');
      _socket?.writeln('Host: ${uri.host}:${uri.port}');
      _socket?.writeln('Upgrade: websocket');
      _socket?.writeln('Connection: Upgrade');
      _socket?.writeln('Sec-WebSocket-Key: ${secKey()}');
      _socket?.writeln('Sec-WebSocket-Version: 13');
      _socket?.writeln(
          'Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits');
      headers?.forEach((key, value) {
        _socket?.writeln('$key: $value');
      });
      _socket?.writeln();
    }).catchError((error) => print(error));
    return true;
  }

  void sendBinary(List<int> data) {
    var frame = WebSocketFrame(OpCode.binary,
        mask: true, payload: Uint8List.fromList(data));
    var raw = frame.rawBytes();
    _socket?.add(raw.toList());
    _socket?.flush().then((value) {
      if (value == null) {}
      return true;
    });
  }

  void close() {
    var frame =
        WebSocketFrame(OpCode.close, payload: 1006.bytes(bit: BitWidth.short));
    _socket?.add(frame.rawBytes());
  }

  String signKey(String key) => convert.base64
      .encode(sha1.convert((key + webSocketGUID).codeUnits).bytes);

  String secKey() {
    List<int> d = List.filled(16, 0);
    var rand = Random();
    for (var i = 0; i < d.length; i++) {
      d[i] = rand.nextInt(255);
    }
    return convert.base64.encode(d);
  }
}

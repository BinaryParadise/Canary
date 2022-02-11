enum MessageAction {
  /// 连接成功
  connected,

  /// 更新
  update,

  /// 注册设备
  register,

  /// 设备列表
  list,

  /// 日志
  log
}

extension MessageActionExtension on MessageAction {
  static const List<int> actions = [1, 2, 10, 11, 30];
  int get value {
    return actions[index];
  }

  static MessageAction parse(int value) {
    return MessageAction.values[actions.indexOf(value)];
  }
}

class WebSocketMessage {
  int code;
  String? msg;
  dynamic data;
  MessageAction type;
  int? timestamp;

  WebSocketMessage(this.type, {this.msg, this.code = 0, this.data});

  WebSocketMessage.fromJson(Map<String, dynamic> json)
      : code = json['code'] as int,
        data = json['data'],
        type = MessageActionExtension.parse(json['type'] as int),
        msg = json['msg'] as String?,
        timestamp = json['timestamp'] as int?;

  Map<String, dynamic> toJson() => {
        'code': code,
        'data': data,
        'timestamp': timestamp,
        'msg': msg,
        'type': type.value
      };
}

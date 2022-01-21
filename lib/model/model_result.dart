class Result {
  int code = 0;
  String? msg;
  dynamic data;
  int? timestamp;

  Result(this.code, this.data, {this.msg});

  Result.fromJson(Map<String, dynamic> json)
      : code = json['code'] as int,
        data = json['data'],
        msg = json['msg'] as String?,
        timestamp = json['timestamp'] as int?;

  Map<String, dynamic> toJson() =>
      {'code': code, 'data': data, 'timestamp': timestamp, 'msg': msg};
}

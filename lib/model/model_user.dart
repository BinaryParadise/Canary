import 'package:json_annotation/json_annotation.dart';

part 'model_user.g.dart';

@JsonSerializable()
class User {
  int id;
  String username;
  String password;
  String name;
  String token;
  int roleid;
  String? rolename;
  int? rolelevel;
  int expire;
// String app: ProtoProject?
  // ignore: non_constant_identifier_names
  int? app_id;

  User(this.id, this.username, this.password, this.name, this.token,
      this.roleid, this.expire);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

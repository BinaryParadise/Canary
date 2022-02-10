import 'package:json_annotation/json_annotation.dart';

part 'model_remote_conf.g.dart';

@JsonSerializable()
class ConfigGroup {
  int type;
  String name;
  List<Config>? items;

  ConfigGroup(this.type, this.name);

  factory ConfigGroup.fromJson(Map<String, dynamic> json) =>
      _$ConfigGroupFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigGroupToJson(this);
}

@JsonSerializable()
class Config {
  int id;
  String name;
  int type;
  int updateTime;
  int? appId;
  String? author;
  String? comment;
  List<ConfigItem>? subItems;
  bool? defaultTag;
  int? copyid;

  Config(this.id, this.name, this.type, this.updateTime);

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@JsonSerializable()
class ConfigItem {
  int id;
  String name;
  String value;
  int envid;
  int updateTime;
  String? comment;
  int? uid;
  String? author;

  /// 0、全部 1、iOS 2、Android
  int platform = 0;

  ConfigItem(this.id, this.name, this.value, this.envid, this.updateTime);

  factory ConfigItem.fromJson(Map<String, dynamic> json) =>
      _$ConfigItemFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigItemToJson(this);
}

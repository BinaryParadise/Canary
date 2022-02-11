import 'package:json_annotation/json_annotation.dart';

part 'model_remote_conf.g.dart';

enum GroupType { dev, test, production }

extension GroupTypeExtension on GroupType {
  int get value => index;
  static GroupType parse(int value) {
    return GroupType.values[value];
  }

  String get decription {
    switch (this) {
      case GroupType.dev:
        return '开发';
      case GroupType.test:
        return '测试';
      case GroupType.production:
        return '生产';
    }
  }
}

@JsonSerializable()
class ConfigGroup {
  int type;
  GroupType get typeEnum => GroupTypeExtension.parse(type);
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
  GroupType get typeEnum => GroupTypeExtension.parse(type);
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_remote_conf.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigGroup _$ConfigGroupFromJson(Map<String, dynamic> json) => ConfigGroup(
      json['type'] as int,
      json['name'] as String,
    )..items = (json['items'] as List<dynamic>?)
        ?.map((e) => Config.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$ConfigGroupToJson(ConfigGroup instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'items': instance.items,
    };

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      json['id'] as int,
      json['name'] as String,
      json['type'] as int,
      json['updateTime'] as int,
    )
      ..appId = json['appId'] as int?
      ..author = json['author'] as String?
      ..comment = json['comment'] as String?
      ..subItems = (json['subItems'] as List<dynamic>?)
          ?.map((e) => ConfigItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..defaultTag = json['defaultTag'] as bool?
      ..copyid = json['copyid'] as int?;

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'updateTime': instance.updateTime,
      'appId': instance.appId,
      'author': instance.author,
      'comment': instance.comment,
      'subItems': instance.subItems,
      'defaultTag': instance.defaultTag,
      'copyid': instance.copyid,
    };

ConfigItem _$ConfigItemFromJson(Map<String, dynamic> json) => ConfigItem(
      json['id'] as int,
      json['name'] as String,
      json['value'] as String,
      json['envid'] as int,
      json['updateTime'] as int,
    )
      ..comment = json['comment'] as String?
      ..uid = json['uid'] as int?
      ..author = json['author'] as String?
      ..platform = json['platform'] as int;

Map<String, dynamic> _$ConfigItemToJson(ConfigItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
      'envid': instance.envid,
      'updateTime': instance.updateTime,
      'comment': instance.comment,
      'uid': instance.uid,
      'author': instance.author,
      'platform': instance.platform,
    };

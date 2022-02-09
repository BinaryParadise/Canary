// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_mock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MockParam _$MockParamFromJson(Map<String, dynamic> json) => MockParam(
      json['name'] as String,
      json['value'] as String,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$MockParamToJson(MockParam instance) => <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'comment': instance.comment,
    };

MockScene _$MockSceneFromJson(Map<String, dynamic> json) => MockScene(
      json['id'] as int,
      json['name'] as String,
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => MockParam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MockSceneToJson(MockScene instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'params': instance.params,
    };

MockItem _$MockItemFromJson(Map<String, dynamic> json) => MockItem(
      json['id'] as int,
      json['name'] as String,
      json['path'] as String,
      json['enabled'] as bool,
      sceneid: json['sceneid'] as int?,
      scenes: (json['scenes'] as List<dynamic>?)
          ?.map((e) => MockScene.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MockItemToJson(MockItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'enabled': instance.enabled,
      'sceneid': instance.sceneid,
      'scenes': instance.scenes,
    };

MockGroup _$MockGroupFromJson(Map<String, dynamic> json) => MockGroup(
      json['id'] as int,
      json['name'] as String,
      mocks: (json['mocks'] as List<dynamic>?)
          ?.map((e) => MockItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MockGroupToJson(MockGroup instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mocks': instance.mocks,
    };

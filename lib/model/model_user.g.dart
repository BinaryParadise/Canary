// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['id'] as int,
      json['username'] as String,
      json['password'] as String,
      json['name'] as String,
      json['token'] as String,
      json['roleid'] as int,
      json['expire'] as int,
    )
      ..rolename = json['rolename'] as String?
      ..rolelevel = json['rolelevel'] as int?
      ..app_id = json['app_id'] as int?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'password': instance.password,
      'name': instance.name,
      'token': instance.token,
      'roleid': instance.roleid,
      'rolename': instance.rolename,
      'rolelevel': instance.rolelevel,
      'expire': instance.expire,
      'app_id': instance.app_id,
    };

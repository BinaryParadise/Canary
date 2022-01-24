// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
      json['simulator'] as bool,
      json['appVersion'] as String,
      json['osName'] as String,
      json['osVersion'] as String,
      json['modelName'] as String,
      json['name'] as String,
      json['deviceId'] as String,
    )
      ..ipAddrs =
          (json['ipAddrs'] as List<dynamic>).map((e) => e as String).toList()
      ..profile = json['profile'] as Map<String, dynamic>?
      ..update = json['update'] as int?;

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
      'ipAddrs': instance.ipAddrs,
      'simulator': instance.simulator,
      'appVersion': instance.appVersion,
      'osName': instance.osName,
      'osVersion': instance.osVersion,
      'modelName': instance.modelName,
      'name': instance.name,
      'profile': instance.profile,
      'deviceId': instance.deviceId,
      'update': instance.update,
    };

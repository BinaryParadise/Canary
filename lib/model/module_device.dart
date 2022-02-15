import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_canary/canary_manager.dart';
import 'package:json_annotation/json_annotation.dart';

part 'module_device.g.dart';

@JsonSerializable()
class Device {
  List<String> ipAddrs = [];
  late bool simulator;
  late String appVersion;
  late String osName;
  late String osVersion;
  late String modelName;
  late String name;
  Map<String, dynamic>? profile;
  late String deviceId;
  int? update;

  Device(this.simulator, this.appVersion, this.osName, this.osVersion,
      this.modelName, this.name, this.deviceId);

  static Future<Device> create() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      var ios = await DeviceInfoPlugin().iosInfo;
      return Device(
          !ios.isPhysicalDevice,
          '1.0.0',
          ios.systemName,
          ios.systemVersion,
          ios.model,
          ios.name,
          FlutterCanary.instance.deviceid);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      throw 'not implement';
    } else {
      throw 'not implement';
    }
  }

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_canary/model/model_remote_conf.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../canary_dio.dart';
import '../canary_manager.dart';
import 'config_info_page.dart';
import 'config_list_page.dart';

class ConfigManager {
  static final ConfigManager _instance = ConfigManager._();
  static ConfigManager get instance => _instance;
  factory ConfigManager() => _instance;

  /// 当前选中的配置
  String? pickedName;
  Map<String, Config> configMap = {};
  List<ConfigGroup> groups = [];
  Config? get pickedConfig {
    return configMap[pickedName ?? ''];
  }

  ConfigManager._() {
    () async {
      var prefs = await SharedPreferences.getInstance();
      var data = jsonDecode(prefs.getString('config_json_data') ?? '[]');
      _transform(data);
      _matchPicked();
      if (pickedName != null) {
        prefs.setString('config_picked_name', pickedName!);
      }
    }()
        .then((value) => update());
  }

  Future<Result> update() async {
    var result = await CanaryDio.instance
        .get('/conf/full?appkey=${FlutterCanary.instance.appSecret}');
    if (result.success) {
      _transform(result.data);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('config_json_data', jsonEncode(result.data));
      await _matchPicked();
    }
    return result;
  }

  Future<dynamic> apply(Config config) async {
    pickedName = config.name;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('config_picked_name', config.name);
    return true;
  }

  String? value(String key, {String? def}) {
    var config = pickedConfig;
    if (config == null) {
      return def;
    } else {
      try {
        return config.subItems
            ?.firstWhere(
              (element) => element.name == key,
            )
            .value;
      } catch (e) {
        return def;
      }
    }
  }

  void _transform(List data) {
    groups.clear();
    for (var element in data) {
      var group = ConfigGroup.fromJson(element as Map<String, dynamic>);
      group.items?.forEach((element) => configMap[element.name] = element);
      groups.add(group);
    }
  }

  Future<void> _matchPicked() async {
    var prefs = await SharedPreferences.getInstance();
    var picked = prefs.getString('config_picked_name');
    if (configMap.isNotEmpty) {
      var def = configMap.values
          .firstWhere(
            (element) => element.defaultTag ?? false,
            orElse: () => configMap.values.first,
          )
          .name;
      if (picked == null) {
        pickedName = def;
      } else {
        if (configMap.values.any((element) => element.name == picked)) {
          pickedName = picked;
        } else {
          pickedName = def;
        }
      }
    }
    return Future.value();
  }

  Route listPageRoute() =>
      CupertinoPageRoute(builder: (context) => const ConfigListPage());

  Route infoPageRoute(Config config) =>
      CupertinoPageRoute(builder: (context) => ConfigInfoPage(config));
}

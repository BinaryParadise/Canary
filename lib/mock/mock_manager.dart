import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_canary/mock/mock_list_page.dart';
import 'package:flutter_canary/model/model_mock.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../canary_dio.dart';
import '../canary_manager.dart';

class MockManager {
  static final MockManager _instance = MockManager._();
  MockManager._() {
    SharedPreferences.getInstance().then((value) {
      var data = value.getString('mockdata');
      if (data != null) {
        _loadData(jsonDecode(data) as List);
      }
    });
  }
  static MockManager instance() => _instance;
  List<MockGroup> groups = [];
  Map<String, MockItem> mockMap = {};

  void _loadData(List data) {
    groups.clear();
    for (var element in data) {
      groups.add(MockGroup.fromJson(element as Map<String, dynamic>));
    }
    mockMap.clear();
    for (var element in groups) {
      element.mocks?.forEach((e) {
        mockMap[e.path] = e;
      });
    }
  }

  /// 更新mock数据
  Future<Result> update() async {
    var value = await CanaryDio.instance.get('/mock/app/whole');
    if (value.success) {
      _loadData(value.data as List);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('mockdata', jsonEncode(value.data));
    }
    return value;
  }

  /// 检测是否需要Mock
  Future<dynamic> checkIntercept(MethodCall call) async {
    var intercept = false;
    String? matchUrl;
    var args = Map<String, dynamic>.from(call.arguments);
    var uri = Uri.parse(args['url'] as String);
    if (args['url'] as String == FlutterCanary.instance.service) {
      // 不拦截金丝雀域名
      return await Future.value({'intercept': intercept});
    }

    //完全匹配
    var matchMock = mockMap[uri.path];
    if (matchMock == null || !matchMock.enabled) {
      for (var element in mockMap.values) {
        if (element.enabled &&
            RegExp(element.path.replaceAll(RegExp('({[^{}]+})'), '[^/]+'))
                .hasMatch(uri.path)) {
          matchMock = element;
          break;
        }
      }
    }

    if (matchMock != null && matchMock.enabled) {
      var sceneid = matchMock.match(
          matchMock.sceneid, Map<String, dynamic>.from(args['params']));
      if (sceneid != null) {
        intercept = true;
        var queryStr = '?$uri.query';
        matchUrl =
            '${FlutterCanary.instance.service}/mock/app/scene/$sceneid$queryStr';
      }
      return Future.value({'intercept': intercept, 'url': matchUrl});
    }
    return Future.value({'intercept': intercept});
  }

  String? matchURLParameter(String path) {
    return null;
  }

  Route pageRoute() =>
      CupertinoPageRoute(builder: (context) => const MockListPage());
}

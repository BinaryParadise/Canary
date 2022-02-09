import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_canary/model/model_mock.dart';
import 'package:flutter_canary/model/model_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'canary_dio.dart';
import 'canary_manager.dart';

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
    data.forEach((element) {
      groups.add(MockGroup.fromJson(element as Map<String, dynamic>));
    });
    mockMap.clear();
    groups.forEach((element) => element.mocks?.forEach((e) {
          mockMap[e.path] = e;
        }));
  }

  Future<Result> update() async {
    var value = await CanaryDio.instance().get('/mock/app/whole');
    if (value.success) {
      _loadData(value.data as List);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('mockdata', jsonEncode(value.data));
    }
    return value;
  }

  Future<dynamic> checkIntercept(MethodCall call) async {
    var intercept = false;
    String? matchUrl;
    var args = Map<String, dynamic>.from(call.arguments);
    var uri = Uri.parse(args['url'] as String);
    if (args['url'] as String == FlutterCanary.instance().service) {
      // 不拦截金丝雀域名
      return await Future.value({'intercept': intercept});
    }

    //完全匹配
    var matchMock = mockMap[uri.path];
    if (matchMock == null) {
      //TODO:正则匹配
      /*matchMock = mockMap.values.first(where: { (item) -> Bool in
                do {
                    let regexStr = matchParameter(path: item.path)
                    let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
                    let count = regex.matches(in: path, options: .reportProgress, range: NSRange(location: 0, length: path.count)).count
                    if count > 0 {
                        return true
                    }
                } catch {
                    print("正则匹配：\(error)")
                }
                return false
            })*/
    } else {
      if (matchMock.enabled) {
        var sceneid = matchMock.match(
            matchMock.sceneid, Map<String, dynamic>.from(args['params']));
        if (sceneid != null) {
          intercept = true;
          var queryStr = '?$uri.query';
          matchUrl =
              '${FlutterCanary.instance().service}/mock/app/scene/$sceneid$queryStr';
        }
      }
      return Future.value({'intercept': intercept, 'url': matchUrl});
    }
    return Future.value({'intercept': intercept});
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'model_mock.g.dart';

@JsonSerializable()
class MockParam {
  String name;
  String value;
  String? comment;
  MockParam(this.name, this.value, {this.comment});

  factory MockParam.fromJson(Map<String, dynamic> json) =>
      _$MockParamFromJson(json);
  Map<String, dynamic> toJson() => _$MockParamToJson(this);
}

@JsonSerializable()
class MockScene {
  int id;
  String name;
  List<MockParam>? params;
  MockScene(this.id, this.name, {this.params});

  factory MockScene.fromJson(Map<String, dynamic> json) =>
      _$MockSceneFromJson(json);
  Map<String, dynamic> toJson() => _$MockSceneToJson(this);
}

@JsonSerializable()
class MockItem {
  int id;
  String name;
  String path;

  /// 激活状态
  bool enabled;
  int? sceneid;
  List<MockScene>? scenes;

  String get sceneMode {
    if (sceneid == null || sceneid == 0) {
      return '自动';
    } else {
      var s = scenes?.firstWhere((element) => element.id == (sceneid ?? 0));
      return s == null ? '自动' : s.name;
    }
  }

  int? match(int? sceneid, Map<String, dynamic> queryParameters) {
    if (sceneid == 0) {
      //自动模式: 通过参数匹配
      for (MockScene item in scenes ?? []) {
        if (item.params?.any((element) =>
                queryParameters[item.name.toLowerCase()] == element.value) ??
            false) {
          return item.id;
        }
      }
    }
    var scene =
        scenes?.firstWhere((element) => element.id == sceneid && sceneid != 0);
    if (scene == null) {
      scene = scenes?.firstWhere((element) => element.id > 0);
    }
    return scene?.id;
  }

  MockItem(this.id, this.name, this.path, this.enabled,
      {this.sceneid, this.scenes});

  factory MockItem.fromJson(Map<String, dynamic> json) =>
      _$MockItemFromJson(json);
  Map<String, dynamic> toJson() => _$MockItemToJson(this);
}

@JsonSerializable()
class MockGroup {
  int id;
  String name;
  List<MockItem>? mocks;

  MockGroup(this.id, this.name, {this.mocks});

  factory MockGroup.fromJson(Map<String, dynamic> json) =>
      _$MockGroupFromJson(json);
  Map<String, dynamic> toJson() => _$MockGroupToJson(this);
}

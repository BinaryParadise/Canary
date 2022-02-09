import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_canary/canary_dio.dart';
import 'package:flutter_canary/mock_manager.dart';
import 'package:flutter_canary/model/model_mock.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CanaryMock extends StatefulWidget {
  const CanaryMock({Key? key}) : super(key: key);

  @override
  State<CanaryMock> createState() => _CanaryMockState();
}

final ValueNotifier<int> doRefresh = ValueNotifier(0);

class _CanaryMockState extends State<CanaryMock> {
  List<MockGroup> groups = [];

  @override
  void initState() {
    queryAll();
    doRefresh.addListener(queryAll);
    super.initState();
  }

  void queryAll() {
    MockManager.instance().update().then((value) {
      if (value.success) {
        setState(() {
          groups = MockManager.instance().groups;
        });
      } else {
        Fluttertoast.showToast(msg: value.msg ?? '未知错误');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    current = ListView.separated(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: groups.length,
      itemBuilder: (ctx, row) {
        return _MockGroupRow(groups[row]);
      },
      separatorBuilder: (ctx, row) {
        return Container(
          child: SizedBox(
            height: 8,
          ),
        );
      },
    );
    current = Scaffold(
      appBar: AppBar(
        title: Text('Mock'),
      ),
      backgroundColor: Color(0xFFF2F4F6),
      body: current,
    );
    return current;
  }

  @override
  void dispose() {
    doRefresh.removeListener(queryAll);
    super.dispose();
  }
}

class _MockGroupRow extends StatelessWidget {
  MockGroup group;
  _MockGroupRow(this.group, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current;
    List<MockItem> mocks = group.mocks ?? [];
    current = ListView.separated(
      itemCount: mocks.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (ctx, row) {
        return _MockItemRow(mocks[row]);
      },
      separatorBuilder: (ctx, row) => const Divider(
        height: 1,
        color: Color(0xFFD8D8D8),
      ),
    );
    current = Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.all(12),
              child: Text(
                group.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Divider(
          indent: 12,
        ),
        current
      ],
    );
    current = Container(
      color: Colors.white,
      child: current,
    );
    return current;
  }
}

class _MockItemRow extends StatelessWidget {
  MockItem item;
  _MockItemRow(this.item, {Key? key}) : super(key: key);

  void setEnabled(MockItem item, bool isOn) {
    CanaryDio.instance().post('/mock/active',
        arguments: {"mockid": item.id, "enabled": isOn}).then((value) {
      if (value.success) {
        doRefresh.value += 1;
      } else {
        Fluttertoast.showToast(msg: value.msg ?? '未知错误');
      }
    });
  }

  void activeScene(MockScene scene) {
    CanaryDio.instance().post('/mock/scene/active', arguments: {
      "sceneid": scene.id,
      "enabled": scene.name != item.sceneMode,
      "mockid": item.id
    }).then((value) {
      if (value.success) {
        doRefresh.value += 1;
      } else {
        Fluttertoast.showToast(msg: value.msg ?? '未知错误');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget current;
    current = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name),
            Text(
              '路径: ${item.path}',
              style: TextStyle(color: Color(0xFF666666)),
            )
          ],
        ),
        Switch(value: item.enabled, onChanged: (on) => setEnabled(item, on))
      ],
    );

    List<MockScene> scenes = item.scenes ?? [];

    Widget scene;
    scene = DropdownButton(
        value: item.sceneMode,
        borderRadius: BorderRadius.circular(6),
        onChanged: (value) {},
        items: scenes
            .map((e) => DropdownMenuItem(
                  child: Text(e.name),
                  value: e.name,
                  onTap: () {
                    var s =
                        scenes.firstWhere((element) => element.name == e.name);
                    if (s != null) {
                      activeScene(s);
                    }
                  },
                ))
            .toList());
    scene = Row(
        children: [Text('场景: ', style: TextStyle(color: Colors.black)), scene]);

    current = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        current,
        scene,
        SizedBox(
          height: 10,
        )
      ],
    );
    current = Container(
      // height: 80,
      // color: Colors.lightGreenAccent[100],
      margin: EdgeInsets.only(left: 12, right: 8),
      child: current,
    );
    return current;
  }
}

class _SceneModeChange extends StatelessWidget {
  MockItem item;
  _SceneModeChange(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

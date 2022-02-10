import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_canary/canary_dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_canary/canary_mock.dart';
import 'package:flutter_canary/canary_remote_conf.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'canary_manager.dart';
import 'model/model_user.dart';

class CanaryOptions extends StatefulWidget {
  const CanaryOptions({Key? key}) : super(key: key);

  @override
  _CanaryOptionsState createState() => _CanaryOptionsState();
}

class _CanaryOptionsState extends State<CanaryOptions> {
  final TextEditingController _editingController1 = TextEditingController();
  final TextEditingController _editingController2 = TextEditingController();
  bool mockOn = FlutterCanary.instance().mockOn;

  @override
  void initState() {
    super.initState();

    _editingController1.addListener(() {});
    _editingController2.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget current;

    current = ValueListenableBuilder(
        valueListenable: FlutterCanary.instance().user,
        builder: (ctx, user, child) {
          if (user == null) {
            return loginWidget(ctx);
          } else {
            return listWidget(ctx);
          }
        });

    current = Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('金丝雀'),
      ),
      body: current,
    );
    return current;
  }

  void onLogin() {
    CanaryDio.instance().post('/user/login', arguments: {
      'username': _editingController1.text,
      'password': md5
          .convert(utf8.encode(_editingController2.text))
          .toString()
          .toLowerCase()
    }).then((value) {
      if (value.code == 0) {
        Fluttertoast.showToast(msg: '登录成功');
        loginSuccess(User.fromJson(value.data as Map<String, dynamic>));
      } else {
        Fluttertoast.showToast(
            msg: value.localizedDescription, gravity: ToastGravity.CENTER);
      }
    });
  }

  void loginSuccess(User user) {
    FlutterCanary.instance().user.value = user;
    SharedPreferences.getInstance()
        .then((value) => value.setString('user', jsonEncode(user)));
  }

  void loginout(BuildContext context) {
    Widget diag = AlertDialog(
      title: const Text('提示'),
      content: const Text('确认退出登录?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'))
      ],
    );
    showDialog<bool>(
        context: context,
        builder: (ctx) {
          return diag;
        }).then((value) {
      if (value!) {
        FlutterCanary.instance().user.value = null;
      }
    });
  }

  Widget listWidget(BuildContext context) {
    Widget current;
    User user = FlutterCanary.instance().user.value!;
    current = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        RichText(
            text: TextSpan(children: [
          const TextSpan(
              text: '昵称: ',
              style:
                  TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          TextSpan(
              text: '${user.name}（${user.rolename ?? '?'}）',
              style: const TextStyle(color: Colors.orange))
        ])),
        TextButton(onPressed: () => loginout(context), child: const Text('退出'))
      ],
    );

    List<Widget> items = [
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(CupertinoPageRoute(builder: (ctx) => CanaryRemoteConf())),
            child: _RowActionElement('远程配置',
                children: [const Icon(Icons.arrow_right)]),
          ),
          _RowActionElement('监控日志',
              children: [Switch(value: false, onChanged: (on) {})]),
          _RowActionElement('网络日志',
              children: [Switch(value: false, onChanged: (on) {})]),
          _RowActionElement(
            'Mock',
            children: [
              Switch(
                  value: mockOn,
                  onChanged: (on) {
                    FlutterCanary.instance().mockOn = on;
                    setState(() {
                      mockOn = on;
                    });
                  })
            ],
          ),
        ] +
        (mockOn
            ? [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        CupertinoPageRoute(builder: (ctx) => CanaryMock()));
                  },
                  child: _RowActionElement('Mock',
                      children: [const Icon(Icons.arrow_right)]),
                )
              ]
            : []);
    Widget list = ListView.separated(
        itemBuilder: (ctx, row) => items[row],
        separatorBuilder: (ctx, row) => SizedBox(
              height: 8,
            ),
        itemCount: items.length);
    current = Column(
      children: [current, Expanded(child: list)],
    );
    return current;
  }

  Widget loginWidget(BuildContext context) {
    Widget current;
    var username = TextField(
      controller: _editingController1,
      decoration: const InputDecoration(
          prefixIcon: Icon(Icons.account_box), hintText: '用户名'),
    );
    var password = TextField(
      controller: _editingController2,
      obscureText: true,
      decoration: const InputDecoration(
          prefixIcon: Icon(Icons.password), hintText: '密码'),
    );
    Widget login = Container(
      padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(8)),
      child: const Text(
        '登录',
        style: TextStyle(color: Colors.white),
      ),
    );

    login = TextButton(onPressed: onLogin, child: login);

    current = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        username,
        password,
        const SizedBox(
          height: 30,
        ),
        login
      ],
    );
    return current;
  }
}

class _RowActionElement extends StatelessWidget {
  String title;
  List<Widget> children;
  _RowActionElement(this.title, {this.children = const []});

  @override
  Widget build(BuildContext context) {
    Widget current;
    current = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[Text(title)] + children,
    );
    current = Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        height: 60,
        color: Colors.white,
        child: current);
    return current;
  }
}

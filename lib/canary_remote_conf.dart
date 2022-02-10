import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_canary/canary_dio.dart';
import 'package:flutter_canary/model/model_remote_conf.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'canary_manager.dart';

class CanaryRemoteConf extends StatefulWidget {
  const CanaryRemoteConf({Key? key}) : super(key: key);

  @override
  _CanaryRemoteConfState createState() => _CanaryRemoteConfState();
}

class _CanaryRemoteConfState extends State<CanaryRemoteConf> {
  List<dynamic> confs = [];
  @override
  void initState() {
    queryAll();
    super.initState();
  }

  void queryAll() async {
    var result = await CanaryDio.instance()
        .get('/conf/full?appkey=${FlutterCanary.instance().appSecret}');
    if (result.success) {
      result.data as List
        ..forEach((element) {
          var group = ConfigGroup.fromJson(element as Map<String, dynamic>);
          confs.add(group);
          confs.addAll(group.items ?? []);
          group.items = null;
        });
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: result.localizedDescription, gravity: ToastGravity.CENTER);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget current;

    Widget list = ListView.separated(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        itemBuilder: (ctx, row) {
          var item = confs[row];
          if (item is ConfigGroup) {
            return _SectionHeader(item);
          } else {
            return _SectionRow(item as Config);
          }
        },
        separatorBuilder: (ctx, row) {
          if (confs[row] is Config &&
              (row + 1 < confs.length && confs[row + 1] is ConfigGroup)) {
            return SizedBox(
              height: 8,
            );
          } else {
            return Divider(
              indent: 12,
              height: 0.5,
            );
          }
        },
        itemCount: confs.length);

    current = Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      appBar: AppBar(
        title: const Text('远程配置'),
      ),
      body: list,
    );
    return current;
  }
}

class _SectionHeader extends StatelessWidget {
  ConfigGroup group;

  _SectionHeader(this.group, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.only(top: 12, left: 12),
      child: Text(
        group.name,
        style: const TextStyle(
            color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  Config config;
  _SectionRow(this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(config.name), const Icon(Icons.chevron_right)],
    );
    current = GestureDetector(
      onTap: () => null,
      child: current,
    );
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: current,
    );
  }
}

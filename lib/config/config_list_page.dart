import 'package:flutter/material.dart';
import 'package:flutter_canary/config/config_manager.dart';
import 'package:flutter_canary/model/model_remote_conf.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfigListPage extends StatefulWidget {
  const ConfigListPage({Key? key}) : super(key: key);

  @override
  _ConfigListPageState createState() => _ConfigListPageState();
}

class _ConfigListPageState extends State<ConfigListPage> {
  List<dynamic> confs = [];
  @override
  void initState() {
    for (var group in ConfigManager.instance.groups) {
      confs.add(group);
      confs.addAll(group.items ?? []);
    }
    queryAll();
    super.initState();
  }

  void queryAll() async {
    var result = await ConfigManager.instance.update();
    if (result.success) {
      confs.clear();
      for (var group in ConfigManager.instance.groups) {
        confs.add(group);
        confs.addAll(group.items ?? []);
      }
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
        padding: const EdgeInsets.only(top: 20, bottom: 20),
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
            return const SizedBox(
              height: 8,
            );
          } else {
            return const Divider(
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
  final ConfigGroup group;

  const _SectionHeader(this.group, {Key? key}) : super(key: key);

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
  final Config config;
  const _SectionRow(this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool picked = config.name == ConfigManager.instance.pickedName;
    var rights = [const Icon(Icons.chevron_right)];
    if (picked) {
      rights.insert(
          0,
          const Icon(
            Icons.check,
            color: Colors.blue,
          ));
    }
    Widget current = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(config.name),
        Row(
          children: rights,
        )
      ],
    );

    current = Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: current,
    );

    current = GestureDetector(
      onTap: () => Navigator.of(context)
          .push(ConfigManager.instance.infoPageRoute(config)),
      child: current,
    );
    return current;
  }
}

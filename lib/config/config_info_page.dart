import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_canary/canary_manager.dart';
import 'package:flutter_canary/config/config_manager.dart';
import 'package:flutter_canary/model/model_remote_conf.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfigInfoPage extends StatelessWidget {
  final Config config;
  const ConfigInfoPage(this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current;
    current = Container(
        height: 50,
        padding: const EdgeInsets.only(left: 12),
        child: Row(
          children: [
            Text('类型: ${config.typeEnum.decription}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ))
          ],
        ));
    List<ConfigItem> subItems = config.subItems ?? [];
    if (subItems.isEmpty) {
      Fluttertoast.showToast(msg: '请在后台添加配置', gravity: ToastGravity.CENTER);
    }
    Widget list = ListView.separated(
        padding: const EdgeInsets.only(bottom: 12),
        itemBuilder: (context, row) => _ConfigItemRow(subItems[row]),
        separatorBuilder: (context, row) => const SizedBox(
              height: 12,
            ),
        itemCount: subItems.length);
    current = Column(
      children: [current, Expanded(child: list)],
    );
    current = Scaffold(
      appBar: AppBar(
        title: Text(config.name),
      ),
      backgroundColor: const Color(0xFFF2F4F6),
      body: current,
      floatingActionButton: FloatingActionButton(
        onPressed: config.name == ConfigManager.instance.pickedName
            ? null
            : () => _confirmChange(context),
        child: Icon(config.name == ConfigManager.instance.pickedName
            ? Icons.not_interested
            : Icons.done),
      ),
    );
    return current;
  }

  void _confirmChange(BuildContext context) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('确认'),
            content: Text('确认将远程配置切换到"${config.name}"?'),
            actions: [
              TextButton(
                  onPressed: () {
                    ConfigManager.instance.apply(config).then((value) {
                      FlutterCanary.pop().then((value) {
                        Navigator.of(context).pushNamed('/');
                      });
                      Fluttertoast.showToast(
                          msg: '切换成功，请重启应用!', gravity: ToastGravity.CENTER);
                    });
                  },
                  child: const Text('确认')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'))
            ],
          );
        });
  }
}

class _ConfigItemRow extends StatelessWidget {
  final ConfigItem item;
  const _ConfigItemRow(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget current;
    current = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 8, bottom: 4, left: 12, right: 12),
          child: RichText(
            text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: '"'),
                  TextSpan(
                      text: item.name,
                      style: const TextStyle(color: Colors.red)),
                  const TextSpan(text: '"'),
                  const TextSpan(
                      text: '  =  ', style: TextStyle(color: Colors.blue)),
                  const TextSpan(text: '"'),
                  TextSpan(
                      text: item.value,
                      style: const TextStyle(color: Colors.purple)),
                  const TextSpan(text: '"'),
                ]),
            maxLines: 9,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Divider(
          indent: 12,
        ),
        Container(
          padding:
              const EdgeInsets.only(top: 2, bottom: 4, left: 12, right: 12),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                    text: '说明: ',
                    style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                TextSpan(
                    text: item.comment,
                    style: const TextStyle(color: Colors.grey, fontSize: 13))
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
    current = Container(
      color: Colors.white,
      child: current,
    );
    return current;
  }
}

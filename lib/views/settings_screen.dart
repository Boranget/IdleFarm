import 'package:flutter/material.dart';
import '../models/ranch.dart';
import '../controllers/player_controller.dart';
import '../controllers/farm_controller.dart';
import '../controllers/ranch_controller.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _developerMode = false;
  TextEditingController _moneyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeveloperMode();
  }

  Future<void> _loadDeveloperMode() async {
    _developerMode = await StorageService.getBool('developerMode', false);
    setState(() {});
  }

  Future<void> _toggleDeveloperMode(bool value) async {
    _developerMode = value;
    await StorageService.setBool('developerMode', value);
    setState(() {});
  }

  void _editMoney() {
    _moneyController.text = PlayerController.player.money.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('编辑金钱'),
          content: TextField(
            controller: _moneyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '金钱数量'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                int money = int.tryParse(_moneyController.text) ?? 0;
                PlayerController.player.money = money;
                PlayerController.save();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('金钱已更新')));
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _unlockRanch() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('开放牧场'),
          content: Text('确定要开放牧场吗？这将直接解锁牧场，无需满足任何条件。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // 直接添加牧场数据，不检查条件
                RanchController.ranch.plots.add(
                  RanchPlot(
                    id: 'ranch_plot_1',
                    type: 'basic',
                    status: 'claimed',
                  ),
                );

                RanchController.ranch.animals.add(
                  Animal(
                    id: 'chicken',
                    name: '鸡',
                    growthTime: 1800,
                    baseYield: 10,
                    basePrice: 5,
                    product: '蛋',
                  ),
                );

                RanchController.ranch.employees.add(
                  RanchEmployee(id: 'ranch_employee_1', type: 'basic'),
                );

                await RanchController.save();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('牧场已开放')));
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetGameData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('重置游戏数据'),
        content: Text('确定要重置所有游戏数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 重置所有数据
              await StorageService.clearAll();

              // 重新初始化游戏
              await PlayerController.initialize();
              await FarmController.initialize();
              await RanchController.initialize();

              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('游戏数据已重置')));
            },
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('设置')),
      body: ListView(
        children: [
          Divider(),
          ListTile(
            title: Text('关于游戏'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('关于IdleFarm'),
                  content: Text(
                    'IdleFarm是一款纯文本的放置类农场游戏，你可以通过种植作物、养殖动物来获取收益，升级你的农场和牧场。\n\n版本: 1.0.0\n\n开发者: IdleFarm Team',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            title: Text('游戏说明'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('游戏说明'),
                  content: Text(
                    '1. 农场：种植作物，收获后获得金钱\n2. 牧场：养殖动物，收获后获得金钱\n3. 商店：购买种子、动物和工具\n4. 升级：提升农场、牧场和员工等级\n5. 离线收益：即使离线也能获得收益',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          Divider(),
          // 开发者模式
          ListTile(
            title: Text('开发者模式'),
            subtitle: Text('开启后可以编辑金钱和开放牧场'),
            trailing: Switch(
              value: _developerMode,
              onChanged: _toggleDeveloperMode,
            ),
          ),
          // 开发者模式功能
          if (_developerMode) ...[
            Divider(),
            ListTile(title: Text('编辑金钱'), onTap: _editMoney),
            ListTile(title: Text('开放牧场'), onTap: _unlockRanch),
          ],
          Divider(),
          ListTile(
            title: Text('重置游戏数据'),
            subtitle: Text('此操作将清除所有游戏进度'),
            onTap: _resetGameData,
          ),
        ],
      ),
    );
  }
}

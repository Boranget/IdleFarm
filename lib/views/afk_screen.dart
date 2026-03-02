import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AfkScreen extends StatefulWidget {
  @override
  _AfkScreenState createState() => _AfkScreenState();
}

class _AfkScreenState extends State<AfkScreen> {
  bool _autoPlant = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _autoPlant = await StorageService.getBool('autoPlant', false);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggleAutoPlant(bool value) async {
    await StorageService.setBool('autoPlant', value);
    setState(() {
      _autoPlant = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 挂机设置卡片
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '挂机设置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('自动种植', style: Theme.of(context).textTheme.bodyMedium),
                        subtitle: Text('当作物收获后自动重新种植（需要雇佣农民）', style: Theme.of(context).textTheme.bodySmall),
                        value: _autoPlant,
                        onChanged: _toggleAutoPlant,
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // 挂机说明卡片
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '挂机说明',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '1. 开启自动种植后，当作物成熟并收获后，系统会自动重新种植相同的作物',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. 挂机时游戏会在后台继续运行，产生离线收益',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. 建议在不需要频繁操作游戏时开启挂机模式',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

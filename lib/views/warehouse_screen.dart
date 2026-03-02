import 'package:flutter/material.dart';
import '../controllers/player_controller.dart';
import '../controllers/farm_controller.dart';

class WarehouseScreen extends StatefulWidget {
  @override
  _WarehouseScreenState createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 确保所有数据都已加载
      await PlayerController.initialize();
      await FarmController.initialize();
    } catch (e) {
      print('Error loading warehouse data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('仓库')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('仓库'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: '种子'),
                Tab(text: '作物'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSeedsTab(),
                  _buildCropsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedsTab() {
    final seeds = PlayerController.player.seeds;
    final farm = FarmController.farm;

    if (seeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('没有种子'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 导航到商店的农作物标签
                Navigator.pop(context);
                // 这里可以添加导航到商店的逻辑
              },
              child: Text('去购买种子'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: seeds.length,
      itemBuilder: (context, index) {
        final seedId = seeds.keys.elementAt(index);
        final amount = seeds[seedId]!;
        final crop = farm.getCropById(seedId);

        if (crop == null || crop.id.isEmpty) {
          return SizedBox();
        }

        return Card(
          child: ListTile(
            title: Text(crop.name),
            subtitle: Text('数量: $amount'),
            trailing: Text('价值: ${crop.basePrice} 金钱/个'),
          ),
        );
      },
    );
  }

  Widget _buildCropsTab() {
    final crops = PlayerController.player.crops;
    final farm = FarmController.farm;

    if (crops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('没有作物'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 导航到农场页面
                Navigator.pop(context);
                // 这里可以添加导航到农场的逻辑
              },
              child: Text('去种植作物'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: crops.length,
      itemBuilder: (context, index) {
        final cropId = crops.keys.elementAt(index);
        final amount = crops[cropId]!;
        final crop = farm.getCropById(cropId);

        if (crop == null || crop.id.isEmpty) {
          return SizedBox();
        }

        return Card(
          child: ListTile(
            title: Text(crop.name),
            subtitle: Text('数量: $amount'),
            trailing: Text('价值: ${crop.basePrice} 金钱/个'),
          ),
        );
      },
    );
  }
}

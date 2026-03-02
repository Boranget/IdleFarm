import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../controllers/shop_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/farm_controller.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Shop? _shop;
  int _playerMoney = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _shop = await ShopController.loadShop();
      final player = await PlayerController.loadPlayer();
      _playerMoney = player.money;
    } catch (e) {
      print('Error loading shop data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _purchaseItem(Item item) async {
    // 显示购买数量对话框
    showDialog(
      context: context,
      builder: (context) {
        int quantity = 1;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('购买 ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('单价: ${item.price} 金钱'),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text('$quantity'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  SizedBox(height: 16),
                  Text('总价: ${item.price * quantity} 金钱'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    bool success = ShopController.purchaseItem(item.id, _playerMoney, quantity: quantity);

                    if (success) {
                      await _loadData();
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('购买成功！')));
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('货币不足！')));
                    }
                  },
                  child: Text('确认购买'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('商店')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('商店'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '农作物'),
            Tab(text: '动物'),
            Tab(text: '工具'),
            Tab(text: '特殊'),
            Tab(text: '收购'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryTab('crops'),
          _buildCategoryTab('animals'),
          _buildCategoryTab('tools'),
          _buildCategoryTab('special'),
          _buildSellTab(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('金钱: $_playerMoney')],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    if (_shop == null) {
      return Center(child: Text('加载失败'));
    }

    final items = _shop!.items
        .where((item) => item.category == category)
        .toList();

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description),
                Text(
                  '价格: ${item.price} 金钱',
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () => _purchaseItem(item),
              child: Text('购买'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSellTab() {
    // 获取玩家的作物库存
    final playerCrops = PlayerController.player.crops;
    final farm = FarmController.farm;

    // 检查是否有作物
    if (playerCrops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('仓库为空，没有可出售的作物'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 切换到农作物标签
                _tabController.animateTo(0);
              },
              child: Text('去购买种子'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 批量出售按钮
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // 执行批量出售
              final result = ShopController.sellAllCrops();
              if (result['totalMoney'] > 0) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('出售成功！获得 ${result['totalMoney']} 金钱')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('没有可出售的作物')),
                );
              }
            },
            child: Text('出售所有作物'),
          ),
        ),
        // 作物列表
        Expanded(
          child: ListView.builder(
            itemCount: playerCrops.length,
            itemBuilder: (context, index) {
              final cropId = playerCrops.keys.elementAt(index);
              final amount = playerCrops[cropId]!;
              final crop = farm.getCropById(cropId);

              if (crop == null || crop.id.isEmpty) {
                return SizedBox();
              }

              return Card(
                child: ListTile(
                  title: Text(crop.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('数量: $amount'),
                      Text('收购价格: ${crop.basePrice} 金钱/个'),
                      Text('总价: ${crop.basePrice * amount} 金钱'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // 出售当前作物
                      bool success = ShopController.sellCrop(cropId, amount);
                      if (success) {
                        _loadData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('出售成功！获得 ${crop.basePrice * amount} 金钱')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('出售失败')),
                        );
                      }
                    },
                    child: Text('出售'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../controllers/farm_controller.dart';
import '../controllers/player_controller.dart';
import '../controllers/shop_controller.dart';
import '../controllers/drop_controller.dart';
import '../models/farm.dart';

class FarmScreen extends StatefulWidget {
  @override
  _FarmScreenState createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
  String _selectedCategory = 'plots';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('农场'),
      ),
      body: Column(
        children: [
          // 分类标签
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'plots';
                    });
                  },
                  child: Text('地皮'),
                  style: _selectedCategory == 'plots' ? ElevatedButton.styleFrom(backgroundColor: Colors.green) : null,
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'crops';
                    });
                  },
                  child: Text('作物'),
                  style: _selectedCategory == 'crops' ? ElevatedButton.styleFrom(backgroundColor: Colors.green) : null,
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'farmers';
                    });
                  },
                  child: Text('农民'),
                  style: _selectedCategory == 'farmers' ? ElevatedButton.styleFrom(backgroundColor: Colors.green) : null,
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'tech';
                    });
                  },
                  child: Text('科技'),
                  style: _selectedCategory == 'tech' ? ElevatedButton.styleFrom(backgroundColor: Colors.green) : null,
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'warehouse';
                    });
                  },
                  child: Text('仓库'),
                  style: _selectedCategory == 'warehouse' ? ElevatedButton.styleFrom(backgroundColor: Colors.green) : null,
                ),
              ),
            ],
          ),
          // 内容区域
          Expanded(
            child: _getCategoryContent(),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryContent() {
    switch (_selectedCategory) {
      case 'plots':
        return _buildPlotsList();
      case 'crops':
        return _buildCropsList();
      case 'farmers':
        return _buildFarmersList();
      case 'tech':
        return _buildTechList();
      case 'warehouse':
        return _buildWarehouseList();
      default:
        return _buildPlotsList();
    }
  }

  Widget _buildPlotsList() {
    return ListView.builder(
      itemCount: FarmController.farm.plots.length,
      itemBuilder: (context, index) {
        Plot plot = FarmController.farm.plots[index];
        return Card(
          child: ListTile(
            title: Text('地皮 ${index + 1} (${plot.type})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('等级: ${plot.level}'),
                Text('状态: ${_getStatusText(plot.status)}'),
                if (plot.cropId != null)
                  Text('作物: ${FarmController.farm.getCropById(plot.cropId!)?.name ?? ''}'),
                if (plot.matureAt != null)
                  Text('成熟时间: ${_formatTime(plot.matureAt!)}'),
              ],
            ),
            trailing: Wrap(
              direction: Axis.vertical,
              spacing: 4,
              children: [
                if (plot.status == 'unclaimed')
                  ElevatedButton(
                    onPressed: () {
                      bool success = FarmController.claimPlot(plot.id);
                      if (success) {
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('货币不足')),
                        );
                      }
                    },
                    child: Text('开垦'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(60, 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                if (plot.status == 'claimed')
                  ElevatedButton(
                    onPressed: () {
                      _showPlantDialog(plot.id);
                    },
                    child: Text('种植'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(60, 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                if (plot.status == 'planted' && plot.isMature())
                  ElevatedButton(
                    onPressed: () {
                      var harvest = FarmController.harvestCrop(plot.id);
                      if (harvest != null) {
                        // 检查稀有掉落
                        var drop = DropController.checkCropDrop(plot.cropId!, plot.id);
                        if (drop != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('恭喜获得稀有种子: ${drop['name']}')),
                          );
                        }
                        setState(() {});
                      }
                    },
                    child: Text('收获'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(60, 24),
                      textStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    bool success = FarmController.upgradePlot(plot.id);
                    if (success) {
                      setState(() {});
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('货币不足或已达到最高等级')),
                      );
                    }
                  },
                  child: Text('升级'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(60, 24),
                    textStyle: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropsList() {
    return ListView.builder(
      itemCount: FarmController.farm.crops.length,
      itemBuilder: (context, index) {
        Crop crop = FarmController.farm.crops[index];
        return Card(
          child: ListTile(
            title: Text(crop.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('生长时间: ${crop.growthTime ~/ 60}分钟'),
                Text('基础产量: ${crop.baseYield}'),
                Text('基础售价: ${crop.basePrice}'),
                Text('解锁等级: ${crop.unlockLevel}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFarmersList() {
    return ListView.builder(
      itemCount: FarmController.farm.farmers.length,
      itemBuilder: (context, index) {
        Farmer farmer = FarmController.farm.farmers[index];
        return Card(
          child: ListTile(
            title: Text('农民 ${index + 1} (${farmer.type})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('等级: ${farmer.level}'),
                Text('状态: ${farmer.status}'),
                Text('技能: ${farmer.skills.join(', ')}'),
                Text('产量加成: ${(farmer.getYieldBonus() * 100).toStringAsFixed(1)}%'),
                Text('生长速度加成: ${(farmer.getGrowthSpeedBonus() * 100).toStringAsFixed(1)}%'),
                Text('损失减少: ${(farmer.getLossReduction() * 100).toStringAsFixed(1)}%'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                bool success = FarmController.upgradeFarmer(farmer.id);
                if (success) {
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('货币不足或已达到最高等级')),
                  );
                }
              },
              child: Text('升级'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechList() {
    Map<String, String> techNames = {
      'planting': '种植科技',
      'harvesting': '收获科技',
      'management': '管理科技',
      'economy': '经济科技',
    };

    Map<String, String> techDescriptions = {
      'planting': '提升作物生长速度和产量',
      'harvesting': '减少收获损失，增加稀有掉落几率',
      'management': '增加地皮和农民上限',
      'economy': '提升作物售价，降低购买成本',
    };

    return ListView.builder(
      itemCount: FarmController.farm.tech.length,
      itemBuilder: (context, index) {
        String techType = FarmController.farm.tech.keys.elementAt(index);
        int level = FarmController.farm.tech[techType]!;
        return Card(
          child: ListTile(
            title: Text('${techNames[techType]} (等级 $level)'),
            subtitle: Text(techDescriptions[techType]!),
            trailing: ElevatedButton(
              onPressed: () {
                bool success = FarmController.upgradeTech(techType);
                if (success) {
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('货币不足')),
                  );
                }
              },
              child: Text('升级'),
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'unclaimed':
        return '未开垦';
      case 'claimed':
        return '已开垦';
      case 'planted':
        return '已种植';
      default:
        return status;
    }
  }

  String _formatTime(DateTime time) {
    Duration duration = time.difference(DateTime.now());
    if (duration.isNegative) {
      return '已成熟';
    }
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '$minutes分$seconds秒';
  }

  Widget _buildWarehouseList() {
    final seeds = PlayerController.player.seeds;
    final crops = PlayerController.player.crops;
    final farm = FarmController.farm;

    return DefaultTabController(
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
                // 种子列表
                seeds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('没有种子'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // 导航到商店
                                Navigator.pop(context);
                                // 这里可以添加导航到商店的逻辑
                              },
                              child: Text('去购买种子'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                      ),
                // 作物列表
                crops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('没有作物'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // 导航到农场地皮标签
                                setState(() {
                                  _selectedCategory = 'plots';
                                });
                              },
                              child: Text('去种植作物'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
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
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // 出售作物
                                  bool success = ShopController.sellCrop(cropId, amount);
                                  if (success) {
                                    setState(() {});
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlantDialog(String plotId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择作物'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FarmController.farm.crops
                .where((crop) => crop.unlockLevel <= PlayerController.player.level)
                .map((crop) {
              // 检查种子数量
              int seedAmount = PlayerController.getSeedAmount(crop.id);
              return ListTile(
                title: Text(crop.name),
                subtitle: Text('生长时间: ${crop.growthTime ~/ 60}分钟, 产量: ${crop.baseYield}, 售价: ${crop.basePrice}, 种子: $seedAmount'),
                onTap: () {
                  bool success = FarmController.plantCrop(plotId, crop.id);
                  if (success) {
                    Navigator.of(context).pop();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('种植失败，可能是种子不足')),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

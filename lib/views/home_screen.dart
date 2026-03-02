import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/player_controller.dart';
import '../controllers/farm_controller.dart';
import '../controllers/ranch_controller.dart';
import '../services/time_service.dart';
import 'farm_screen.dart';
import 'ranch_screen.dart';
import 'shop_screen.dart';
import 'settings_screen.dart';
import 'afk_screen.dart';
import 'warehouse_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // 启动定时器，每秒更新一次页面
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isLoading) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    // 初始化控制器
    await PlayerController.initialize();
    await FarmController.initialize();
    await RanchController.initialize();

    // 处理离线收益
    _processOfflineEarnings();

    setState(() {
      _isLoading = false;
    });
  }

  void _processOfflineEarnings() {
    DateTime lastOnline = PlayerController.player.lastOnline;
    DateTime currentTime = DateTime.now();
    
    // 计算离线收益
    var earnings = TimeService.calculateOfflineEarnings(
      lastOnline,
      currentTime,
      FarmController.farm,
      RanchController.ranch.plots.isNotEmpty ? RanchController.ranch : null,
    );

    // 处理收益
    PlayerController.processOfflineEarnings(earnings);
    PlayerController.updateLastOnline();

    // 收获所有成熟的作物和动物
    FarmController.harvestAllMatureCrops();
    if (RanchController.ranch.plots.isNotEmpty) {
      RanchController.harvestAllMatureAnimals();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return FarmScreen();
      case 2:
        return RanchController.ranch.plots.isEmpty ? _buildRanchLocked() : RanchScreen();
      case 3:
        return ShopScreen();
      case 4:
        return WarehouseScreen();
      case 5:
        return AfkScreen();
      case 6:
        return SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 玩家信息卡片
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IdleFarm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '等级',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${PlayerController.player.level}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '经验',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${PlayerController.player.exp}/${PlayerController.player.level * 100}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 6),
                            Container(
                              height: 4,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: PlayerController.player.exp / (PlayerController.player.level * 100),
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '货币',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${PlayerController.player.money}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // 农场状态卡片
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '农场状态',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '地皮',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${FarmController.farm.plots.length}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '农民',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${FarmController.farm.farmers.length}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '作物',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${FarmController.farm.crops.length}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '作物生长',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(height: 12),
                    ...FarmController.farm.plots.where((plot) => plot.status == 'planted').map((plot) {
                      final crop = FarmController.farm.getCropById(plot.cropId!);
                      final timeLeft = plot.matureAt!.difference(DateTime.now());
                      final minutesLeft = timeLeft.inMinutes;
                      final secondsLeft = timeLeft.inSeconds % 60;
                      
                      // 计算生长进度
                      final totalGrowthTime = plot.matureAt!.difference(plot.plantedAt!).inSeconds;
                      final elapsedTime = DateTime.now().difference(plot.plantedAt!).inSeconds;
                      final growthProgress = elapsedTime / totalGrowthTime;
                      
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  crop?.name ?? '未知',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${minutesLeft}分${secondsLeft}秒',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              height: 4,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: growthProgress > 1 ? 1 : growthProgress,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9E9E9E)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (FarmController.farm.plots.every((plot) => plot.status != 'planted'))
                      Text(
                        '无种植作物',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // 牧场状态卡片
            if (RanchController.ranch.plots.isNotEmpty) 
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '牧场状态',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '地皮',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${RanchController.ranch.plots.length}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '员工',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${RanchController.ranch.employees.length}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '动物',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${RanchController.ranch.animals.length}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 40), // 底部留白
          ],
        ),
      ),
    );
  }

  Widget _buildRanchLocked() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '牧场未解锁',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 20),
                Text(
                  '解锁条件',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('•', style: Theme.of(context).textTheme.bodySmall),
                          SizedBox(width: 12),
                          Text('农场等级达到3级', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('•', style: Theme.of(context).textTheme.bodySmall),
                          SizedBox(width: 12),
                          Text('拥有至少5块农场地皮', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text('•', style: Theme.of(context).textTheme.bodySmall),
                          SizedBox(width: 12),
                          Text('花费5000游戏货币', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (PlayerController.player.level >= 3 && 
                          FarmController.farm.plots.length >= 5) {
                        bool success = RanchController.unlockRanch(PlayerController.player.level);
                        if (success) {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('货币不足')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('未满足解锁条件')),
                        );
                      }
                    },
                    child: Text('解锁牧场'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: '农场',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: '牧场',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '商店',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '仓库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: '挂机',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

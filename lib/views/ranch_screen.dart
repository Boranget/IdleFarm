import 'package:flutter/material.dart';
import '../models/ranch.dart';
import '../controllers/ranch_controller.dart';

class RanchScreen extends StatefulWidget {
  @override
  _RanchScreenState createState() => _RanchScreenState();
}

class _RanchScreenState extends State<RanchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Ranch? _ranch;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadRanchData();
  }

  Future<void> _loadRanchData() async {
    _ranch = await RanchController.loadRanch();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('牧场'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '动物'),
            Tab(text: '员工'),
            Tab(text: '技术'),
            Tab(text: '布局'),
            Tab(text: '仓库'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnimalsTab(),
          _buildEmployeesTab(),
          _buildTechnologyTab(),
          _buildLayoutTab(),
          _buildWarehouseTab(),
        ],
      ),
    );
  }

  Widget _buildAnimalsTab() {
    final ranch = _ranch;
    if (ranch == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: ranch.animals.length,
      itemBuilder: (context, index) {
        final animal = ranch.animals[index];
        return Card(
          child: ListTile(
            title: Text('${animal.name} - 等级 1'),
            subtitle: Text('产量：${animal.baseYield}/小时'),
            trailing: ElevatedButton(
              onPressed: () async {
                // 这里需要根据动物 ID 找到对应的地块
                // 简化实现，假设每个动物对应一个地块
                if (index < ranch.plots.length) {
                  await RanchController.harvestAnimal(ranch.plots[index].id);
                  await _loadRanchData();
                }
              },
              child: Text('收获'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeesTab() {
    final ranch = _ranch;
    if (ranch == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: ranch.employees.length,
      itemBuilder: (context, index) {
        final employee = ranch.employees[index];
        return Card(
          child: ListTile(
            title: Text('员工 ${index + 1} - 等级 ${employee.level}'),
            subtitle: Text('类型：${employee.type}'),
            trailing: ElevatedButton(
              onPressed: () async {
                await RanchController.upgradeEmployee(employee.id);
                await _loadRanchData();
              },
              child: Text('升级'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechnologyTab() {
    final ranch = _ranch;
    if (ranch == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: ranch.tech.length,
      itemBuilder: (context, index) {
        final techType = ranch.tech.keys.elementAt(index);
        final techLevel = ranch.tech[techType]!;
        return Card(
          child: ListTile(
            title: Text('${_getTechName(techType)} - 等级 ${techLevel}'),
            subtitle: Text('效果：${_getTechEffect(techType)}'),
            trailing: ElevatedButton(
              onPressed: () async {
                await RanchController.upgradeTechnology(techType);
                await _loadRanchData();
              },
              child: Text('升级'),
            ),
          ),
        );
      },
    );
  }

  String _getTechName(String techType) {
    switch (techType) {
      case 'breeding':
        return '养殖技术';
      case 'harvesting':
        return '收获技术';
      case 'management':
        return '管理技术';
      case 'economy':
        return '经济技术';
      default:
        return techType;
    }
  }

  String _getTechEffect(String techType) {
    switch (techType) {
      case 'breeding':
        return '提高动物产量和生长速度';
      case 'harvesting':
        return '减少收获损失';
      case 'management':
        return '提高员工效率';
      case 'economy':
        return '降低购买成本';
      default:
        return '未知效果';
    }
  }

  Widget _buildLayoutTab() {
    final ranch = _ranch;
    if (ranch == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: ranch.plots.length,
      itemBuilder: (context, index) {
        final plot = ranch.plots[index];
        return Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('地块 ${index + 1}'),
                Text('等级：${plot.level}'),
                ElevatedButton(
                  onPressed: () async {
                    await RanchController.upgradePlot(plot.id);
                    await _loadRanchData();
                  },
                  child: Text('升级'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarehouseTab() {
    // 这里可以添加牧场仓库的内容
    // 例如动物产品等
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('牧场仓库'), SizedBox(height: 20), Text('这里将显示牧场产品')],
      ),
    );
  }
}

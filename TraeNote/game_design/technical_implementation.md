# 技术实现文档

## 1. 技术架构

### 1.1 开发框架
- **前端**：Flutter
- **数据库**：SQLite（本地存储）

### 1.2 项目结构
```
IdleFarm/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/                   # 数据模型
│   │   ├── player.dart           # 玩家模型
│   │   ├── farm.dart             # 农场模型
│   │   ├── ranch.dart            # 牧场模型
│   │   ├── shop.dart             # 商店模型
│   │   └── drop_system.dart      # 掉落系统模型
│   ├── services/                 # 服务
│   │   ├── storage_service.dart  # 存储服务
│   │   ├── time_service.dart     # 时间服务
│   │   └── calculation_service.dart # 计算服务
│   ├── controllers/              # 控制器
│   │   ├── player_controller.dart # 玩家控制器
│   │   ├── farm_controller.dart  # 农场控制器
│   │   ├── ranch_controller.dart # 牧场控制器
│   │   ├── shop_controller.dart  # 商店控制器
│   │   └── drop_controller.dart  # 掉落系统控制器
│   ├── views/                    # 视图
│   │   ├── home_screen.dart      # 主界面
│   │   ├── farm_screen.dart      # 农场界面
│   │   ├── ranch_screen.dart     # 牧场界面
│   │   ├── shop_screen.dart      # 商店界面
│   │   ├── inventory_screen.dart # 背包界面
│   │   └── settings_screen.dart  # 设置界面
│   ├── widgets/                  # 通用组件
│   │   ├── crop_widget.dart      # 作物组件
│   │   ├── animal_widget.dart    # 动物组件
│   │   ├── plot_widget.dart      # 地皮组件
│   │   └── progress_bar.dart     # 进度条组件
│   └── utils/                    # 工具类
│       ├── constants.dart        # 常量
│       ├── helpers.dart          # 辅助函数
│       └── animations.dart       # 动画工具
├── assets/                       # 资源文件
│   ├── images/                   # 图片
│   ├── sounds/                   # 音效
│   └── fonts/                    # 字体
├── pubspec.yaml                  # 依赖管理
└── README.md                     # 项目说明
```

## 2. 数据存储

### 2.1 本地存储
- **SharedPreferences**：存储简单的键值对数据，如玩家设置、游戏状态等
- **SQLite**：存储复杂的游戏数据，如玩家信息、农场状态、牧场状态等

### 2.2 数据模型
- **玩家数据**：包含玩家等级、经验值、游戏货币、钻石等信息
- **农场数据**：包含地皮、作物、农民等信息
- **牧场数据**：包含牧场地皮、动物、员工等信息
- **商店数据**：包含商品、促销活动等信息
- **掉落系统数据**：包含稀有物品、收藏进度等信息

## 3. 核心系统实现

### 3.1 时间系统
- **时间戳管理**：使用 UTC 时间戳，避免时区问题
- **离线计算**：根据最后在线时间和当前时间计算离线收益
- **成熟时间管理**：使用优先级队列存储所有作物和动物的成熟时间
- **时间加速**：可通过钻石购买时间加速，立即完成部分作物/动物的生长

### 3.2 计算系统
- **生长计算**：根据作物/动物种类和当前 buff 计算生长时间
- **产量计算**：根据作物/动物种类、等级和当前 buff 计算产量
- **价格计算**：根据商品种类、购买数量和当前折扣计算价格
- **掉落计算**：根据掉落率和各种修正因素计算掉落几率

### 3.3 事件系统
- **随机事件**：使用随机数生成器触发随机事件
- **特殊事件**：根据时间和游戏进度触发特殊事件
- **事件效果**：事件对游戏参数的影响

### 3.4 成就系统
- **成就检测**：检测玩家是否达成成就条件
- **成就奖励**：给达成成就的玩家发放奖励
- **成就展示**：展示玩家的成就进度

## 4. 性能优化

### 4.1 计算优化
- **批量处理**：相同类型的作物/动物使用批量处理，减少计算量
- **缓存机制**：缓存计算结果，避免重复计算
- **分级更新**：根据物品数量和重要性，采用不同频率的更新策略

### 4.2 渲染优化
- **懒加载**：按需加载游戏资源
- **图片优化**：使用适当大小和格式的图片
- **动画优化**：使用高效的动画实现方式

### 4.3 内存管理
- **资源释放**：及时释放不再使用的资源
- **对象池**：重用对象，减少内存分配
- **内存监控**：监控内存使用情况，避免内存泄漏

## 5. 安全措施

### 5.1 数据安全
- **数据加密**：对敏感数据进行加密存储
- **防篡改**：验证数据的完整性
- **备份恢复**：定期备份游戏数据，支持恢复

### 5.2 防作弊
- **客户端验证**：在客户端进行基本验证
- **异常检测**：检测异常的游戏行为
- **惩罚机制**：对作弊行为进行惩罚

### 5.3 隐私保护
- **数据收集**：仅收集必要的游戏数据
- **数据使用**：明确数据使用目的
- **用户 consent**：获取用户对数据收集的 consent
- **数据删除**：支持用户删除游戏数据

## 6. 开发流程

### 6.1 开发阶段
1. **需求分析**：分析游戏需求，确定功能点
2. **系统设计**：设计游戏系统和数据结构
3. **代码实现**：实现游戏功能
4. **测试**：进行功能测试和性能测试
5. **优化**：优化游戏性能和用户体验
6. **发布**：发布游戏到应用商店

### 6.2 测试策略
- **单元测试**：测试单个功能模块
- **集成测试**：测试多个模块的集成
- **性能测试**：测试游戏性能
- **用户测试**：收集用户反馈

### 6.3 版本管理
- **版本控制**：使用 Git 进行版本控制
- **发布计划**：制定发布计划，包括功能更新和 bug 修复

## 7. 技术实现细节

### 7.1 时间系统实现
```dart
class TimeService {
  static const int CHECK_INTERVAL = 10000; // 10秒

  // 计算离线收益
  static Map<String, dynamic> calculateOfflineEarnings(DateTime lastOnline, DateTime currentTime) {
    Duration offlineDuration = currentTime.difference(lastOnline);
    int offlineSeconds = offlineDuration.inSeconds;

    // 计算农场收益
    Map<String, dynamic> farmEarnings = _calculateFarmEarnings(offlineSeconds);
    // 计算牧场收益
    Map<String, dynamic> ranchEarnings = _calculateRanchEarnings(offlineSeconds);

    return {
      'farm': farmEarnings,
      'ranch': ranchEarnings,
      'totalMoney': farmEarnings['money'] + ranchEarnings['money'],
      'totalExp': farmEarnings['exp'] + ranchEarnings['exp'],
    };
  }

  // 计算农场离线收益
  static Map<String, dynamic> _calculateFarmEarnings(int seconds) {
    // 实现农场离线收益计算逻辑
    return {'money': 0, 'exp': 0};
  }

  // 计算牧场离线收益
  static Map<String, dynamic> _calculateRanchEarnings(int seconds) {
    // 实现牧场离线收益计算逻辑
    return {'money': 0, 'exp': 0};
  }
}
```

### 7.2 生长系统实现
```dart
class GrowthSystem {
  // 计算作物生长时间
  static int calculateCropGrowthTime(Crop crop, List<Farmer> farmers, int plotLevel, int plantingTechLevel) {
    int baseTime = crop.growthTime;
    double speedFactor = 1.0;

    // 地皮等级修正
    speedFactor += plotLevel * 0.05;

    // 农民修正
    for (Farmer farmer in farmers) {
      speedFactor += 0.02;
    }

    // 科技修正
    speedFactor += plantingTechLevel * 0.05;

    // 事件修正（如果有）
    // speedFactor += eventBonus;

    int actualTime = (baseTime / (1 + speedFactor)).round();
    return actualTime;
  }

  // 计算动物生长时间
  static int calculateAnimalGrowthTime(Animal animal, List<RanchEmployee> employees, int plotLevel, int breedingTechLevel) {
    int baseTime = animal.growthTime;
    double speedFactor = 1.0;

    // 地皮等级修正
    speedFactor += plotLevel * 0.05;

    // 员工修正
    for (RanchEmployee employee in employees) {
      speedFactor += 0.02;
    }

    // 科技修正
    speedFactor += breedingTechLevel * 0.05;

    // 事件修正（如果有）
    // speedFactor += eventBonus;

    int actualTime = (baseTime / (1 + speedFactor)).round();
    return actualTime;
  }
}
```

### 7.3 掉落系统实现
```dart
class DropSystem {
  // 计算稀有种子掉落
  static bool checkRareSeedDrop(int farmerLevel, int harvestingTechLevel, bool isRarePlot, bool isSeedFestival) {
    double baseRate = 0.02; // 2%
    double dropRate = baseRate;

    // 农民等级修正
    dropRate += farmerLevel * 0.001;

    // 收获科技修正
    dropRate += harvestingTechLevel * 0.002;

    // 稀有地皮修正
    if (isRarePlot) {
      dropRate += 0.01;
    }

    // 种子节修正
    if (isSeedFestival) {
      dropRate = 0.05; // 5%
    }

    // 随机判定
    return Random().nextDouble() < dropRate;
  }

  // 计算稀有动物掉落
  static bool checkRareAnimalDrop(int employeeLevel, int harvestingTechLevel, bool isLuxuryPlot, bool isAnimalFestival) {
    double baseRate = 0.005; // 0.5%
    double dropRate = baseRate;

    // 员工等级修正
    dropRate += employeeLevel * 0.001;

    // 收获科技修正
    dropRate += harvestingTechLevel * 0.002;

    // 豪华牧场地皮修正
    if (isLuxuryPlot) {
      dropRate += 0.01;
    }

    // 动物节修正
    if (isAnimalFestival) {
      dropRate = 0.03; // 3%
    }

    // 随机判定
    return Random().nextDouble() < dropRate;
  }
}
```

### 7.4 商店系统实现
```dart
class ShopSystem {
  // 计算商品价格
  static int calculatePrice(Item item, int purchaseCount, int playerLevel, bool isPromotion) {
    int basePrice = item.price;
    int price = basePrice;

    // 价格递增
    if (item.isPriceIncreasing) {
      price = (basePrice * (1 + 0.1 * (purchaseCount - 1))).round();
    }

    // 等级折扣
    double discount = 1.0;
    if (playerLevel >= 6 && playerLevel <= 10) {
      discount = 0.95; // 5%折扣
    } else if (playerLevel >= 11 && playerLevel <= 15) {
      discount = 0.9; // 10%折扣
    } else if (playerLevel >= 16) {
      discount = 0.85; // 15%折扣
    }

    // 促销折扣
    if (isPromotion) {
      discount *= 0.8; // 8折
    }

    price = (price * discount).round();
    return price;
  }
}
```

## 8. 性能测试

### 8.1 测试场景
- **大量作物/动物**：测试当有大量作物和动物时的性能
- **离线收益计算**：测试长时间离线后的收益计算性能
- **UI 响应**：测试 UI 操作的响应速度
- **内存使用**：测试游戏的内存使用情况

### 8.2 优化目标
- **启动时间**：应用启动时间不超过3秒
- **响应时间**：UI 操作响应时间不超过100毫秒
- **内存使用**：内存使用不超过200MB
- **帧率**：游戏运行帧率不低于30 FPS

## 9. 未来扩展

### 9.1 功能扩展
- **季节系统**：不同季节对作物生长有不同影响
- **天气系统**：天气变化影响作物和动物的产出
- **任务系统**：完成任务获得额外奖励
- **成就系统**：更丰富的成就和奖励
- **市场系统**：玩家之间交易资源

### 9.2 技术扩展
- **跨平台支持**：支持更多平台，如 iOS、Android、Web 等
- **AI 助手**：添加 AI 助手，帮助玩家管理农场

## 10. 总结

IdleFarm 是一款以自动化管理为核心的挂机农场游戏，通过不断扩展和优化农场和牧场，玩家可以获得持续增长的收益。游戏设计注重平衡性和玩家体验，同时预留了足够的扩展空间，以适应未来的功能添加和更新。

技术实现上，使用 Flutter 作为前端框架，SQLite 作为本地存储。通过合理的架构设计和性能优化，确保游戏在各种设备上都能流畅运行。

未来，我们将继续完善游戏功能，提升玩家体验，将 IdleFarm 打造成一款受欢迎的挂机农场游戏。
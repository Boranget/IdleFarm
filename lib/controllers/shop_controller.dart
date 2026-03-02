import '../models/shop.dart';
import '../models/farm.dart';
import '../services/storage_service.dart';
import 'player_controller.dart';
import 'farm_controller.dart';

class ShopController {
  static Shop? _shop;

  // 初始化商店数据
  static Future<void> initialize() async {
    _shop = await StorageService.loadShop();
    if (_shop == null) {
      _shop = Shop(
        items: [
          Item(
            id: 'wheat_seed',
            name: '小麦种子',
            description: '种植小麦，5分钟成熟',
            price: 5,
            currency: 'money',
            category: 'crops',
            unlockLevel: 1,
          ),
          Item(
            id: 'chicken',
            name: '鸡',
            description: '养殖鸡，30分钟产蛋',
            price: 100,
            currency: 'money',
            category: 'animals',
            unlockLevel: 1,
          ),
          Item(
            id: 'basic_plot',
            name: '基础地皮',
            description: '可以种植作物的基础地皮',
            price: 1000,
            currency: 'money',
            category: 'tools',
            unlockLevel: 1,
          ),
          Item(
            id: 'premium_plot',
            name: '高级地皮',
            description: '产量和生长速度都有提升的高级地皮',
            price: 3000,
            currency: 'money',
            category: 'tools',
            unlockLevel: 2,
          ),
          Item(
            id: 'fertile_plot',
            name: '肥沃地皮',
            description: '产量和生长速度都有大幅提升的肥沃地皮',
            price: 6000,
            currency: 'money',
            category: 'tools',
            unlockLevel: 3,
          ),
          Item(
            id: 'rare_plot',
            name: '稀有地皮',
            description: '产量和生长速度都有显著提升的稀有地皮',
            price: 10000,
            currency: 'money',
            category: 'tools',
            unlockLevel: 4,
          ),
        ],
      );
      await save();
    }
  }

  // 获取商店实例
  static Shop get shop {
    if (_shop == null) {
      _shop = Shop();
    }
    return _shop!;
  }

  // 保存商店数据
  static Future<void> save() async {
    if (_shop != null) {
      await StorageService.saveShop(_shop!);
    }
  }

  // 加载商店数据
  static Future<Shop> loadShop() async {
    await initialize();
    return shop;
  }

  // 购买物品
  static bool purchaseItem(String itemId, int playerCurrency, {int quantity = 1}) {
    Item? item = shop.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => Item(id: '', name: '', description: '', price: 0, currency: 'money', category: 'crops'),
    );
    if (item.id.isEmpty) {
      return false;
    }

    int totalPrice = item.price * quantity;
    if (playerCurrency < totalPrice) {
      return false;
    }

    // 处理购买逻辑
    if (!PlayerController.spendMoney(totalPrice)) {
      return false;
    }

    // 根据物品类型执行不同的操作
    switch (item.category) {
      case 'crops':
        // 添加种子到玩家库存
        String seedId = item.id.replaceAll('_seed', '');
        PlayerController.addSeeds(seedId, quantity);
        break;
      case 'animals':
        // 可以在这里添加动物到玩家 inventory
        break;
      case 'tools':
        // 处理工具类物品
        if (item.id.endsWith('_plot')) {
          String plotType = item.id.replaceAll('_plot', '');
          for (int i = 0; i < quantity; i++) {
            FarmController.buyPlot(plotType);
          }
        }
        break;
      case 'special':
        // 可以在这里处理特殊物品
        break;
    }

    return true;
  }

  // 添加新物品
  static void addItem(Item item) {
    if (!shop.items.any((i) => i.id == item.id)) {
      shop.items.add(item);
      save();
    }
  }

  // 更新物品价格
  static void updateItemPrice(String itemId, int newPrice) {
    Item? item = shop.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => Item(id: '', name: '', description: '', price: 0, currency: 'money', category: 'crops'),
    );
    if (item.id.isNotEmpty) {
      item.price = newPrice;
      save();
    }
  }

  // 收购作物
  static bool sellCrop(String cropId, int amount) {
    // 检查玩家是否有足够的作物
    if (!PlayerController.hasEnoughCrops(cropId, amount)) {
      return false;
    }

    // 查找对应的作物信息，计算收购价格
    Crop? crop = FarmController.farm.getCropById(cropId);
    if (crop == null) {
      return false;
    }

    // 计算收购价格（这里简单使用作物的基础价格，实际可以根据市场波动调整）
    int totalPrice = crop.basePrice * amount;

    // 移除玩家的作物
    if (!PlayerController.removeCrops(cropId, amount)) {
      return false;
    }

    // 添加金钱给玩家
    PlayerController.addMoney(totalPrice);

    return true;
  }

  // 批量收购所有作物
  static Map<String, dynamic> sellAllCrops() {
    Map<String, dynamic> result = {
      'totalMoney': 0,
      'soldItems': <String, int>{},
    };

    // 遍历玩家的所有作物
    for (String cropId in PlayerController.player.crops.keys) {
      int amount = PlayerController.getCropAmount(cropId);
      if (amount > 0) {
        // 查找对应的作物信息
        Crop? crop = FarmController.farm.getCropById(cropId);
        if (crop != null) {
          // 计算收购价格
          int totalPrice = crop.basePrice * amount;
          
          // 移除玩家的作物
          PlayerController.removeCrops(cropId, amount);
          
          // 添加金钱给玩家
          PlayerController.addMoney(totalPrice);
          
          // 更新结果
          result['totalMoney'] += totalPrice;
          result['soldItems'][cropId] = amount;
        }
      }
    }

    return result;
  }
}
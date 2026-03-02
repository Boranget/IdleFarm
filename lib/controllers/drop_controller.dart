import '../models/farm.dart';
import '../models/ranch.dart';
import 'farm_controller.dart';
import 'ranch_controller.dart';
import 'player_controller.dart';
import 'dart:math';

class DropController {
  static final Random _random = Random();

  // 检查作物收获时的稀有掉落
  static Map<String, dynamic>? checkCropDrop(String cropId, String plotId) {
    Plot? plot = FarmController.farm.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => Plot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty) {
      return null;
    }

    // 计算掉落几率
    double baseRate = 0.02; // 2%
    double dropRate = baseRate;

    // 农民等级修正
    for (Farmer farmer in FarmController.farm.farmers) {
      dropRate += farmer.level * 0.001;
    }

    // 科技修正
    dropRate += FarmController.farm.tech['harvesting']! * 0.002;

    // 稀有地皮修正
    if (plot.type == 'rare') {
      dropRate += 0.01;
    }

    // 随机判定
    if (_random.nextDouble() < dropRate) {
      // 生成稀有种子
      String rareSeedId = _generateRareSeedId();
      String rareSeedName = _getRareSeedName(rareSeedId);

      // 添加到农场作物列表
      Crop rareCrop = Crop(
        id: rareSeedId,
        name: rareSeedName,
        growthTime: _getRareSeedGrowthTime(rareSeedId),
        baseYield: _getRareSeedYield(rareSeedId),
        basePrice: _getRareSeedPrice(rareSeedId),
        unlockLevel: PlayerController.player.level,
      );

      FarmController.addCrop(rareCrop);

      return {
        'type': 'rare_seed',
        'id': rareSeedId,
        'name': rareSeedName,
      };
    }

    return null;
  }

  // 检查动物收获时的稀有掉落
  static Map<String, dynamic>? checkAnimalDrop(String animalId, String plotId) {
    RanchPlot? plot = RanchController.ranch.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => RanchPlot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty) {
      return null;
    }

    // 计算掉落几率
    double baseRate = 0.005; // 0.5%
    double dropRate = baseRate;

    // 员工等级修正
    for (RanchEmployee employee in RanchController.ranch.employees) {
      dropRate += employee.level * 0.001;
    }

    // 科技修正
    dropRate += RanchController.ranch.tech['harvesting']! * 0.002;

    // 豪华牧场地皮修正
    if (plot.type == 'luxury') {
      dropRate += 0.01;
    }

    // 随机判定
    if (_random.nextDouble() < dropRate) {
      // 生成稀有动物
      String rareAnimalId = _generateRareAnimalId();
      String rareAnimalName = _getRareAnimalName(rareAnimalId);
      String rareAnimalProduct = _getRareAnimalProduct(rareAnimalId);

      // 添加到牧场动物列表
      Animal rareAnimal = Animal(
        id: rareAnimalId,
        name: rareAnimalName,
        growthTime: _getRareAnimalGrowthTime(rareAnimalId),
        baseYield: _getRareAnimalYield(rareAnimalId),
        basePrice: _getRareAnimalPrice(rareAnimalId),
        product: rareAnimalProduct,
        unlockLevel: PlayerController.player.level,
      );

      RanchController.addAnimal(rareAnimal);

      return {
        'type': 'rare_animal',
        'id': rareAnimalId,
        'name': rareAnimalName,
        'product': rareAnimalProduct,
      };
    }

    return null;
  }

  // 生成稀有种子ID
  static String _generateRareSeedId() {
    List<String> rareSeeds = [
      'gold_wheat',
      'rainbow_corn',
      'magic_carrot',
      'phoenix_tomato',
      'dragon_strawberry',
      'angel_watermelon',
      'devil_grape',
      'life_apple',
      'eternal_cherry',
    ];
    return rareSeeds[_random.nextInt(rareSeeds.length)];
  }

  // 获取稀有种子名称
  static String _getRareSeedName(String seedId) {
    Map<String, String> seedNames = {
      'gold_wheat': '金小麦',
      'rainbow_corn': '彩虹玉米',
      'magic_carrot': '魔法胡萝卜',
      'phoenix_tomato': '凤凰番茄',
      'dragon_strawberry': '龙息草莓',
      'angel_watermelon': '天使西瓜',
      'devil_grape': '恶魔葡萄',
      'life_apple': '生命苹果',
      'eternal_cherry': '永恒樱桃',
    };
    return seedNames[seedId] ?? '稀有种子';
  }

  // 获取稀有种子生长时间
  static int _getRareSeedGrowthTime(String seedId) {
    Map<String, int> growthTimes = {
      'gold_wheat': 180, // 3分钟
      'rainbow_corn': 480, // 8分钟
      'magic_carrot': 720, // 12分钟
      'phoenix_tomato': 1320, // 22分钟
      'dragon_strawberry': 1680, // 28分钟
      'angel_watermelon': 2100, // 35分钟
      'devil_grape': 2700, // 45分钟
      'life_apple': 3300, // 55分钟
      'eternal_cherry': 3900, // 65分钟
    };
    return growthTimes[seedId] ?? 600;
  }

  // 获取稀有种子产量
  static int _getRareSeedYield(String seedId) {
    Map<String, int> yields = {
      'gold_wheat': 15,
      'rainbow_corn': 10,
      'magic_carrot': 8,
      'phoenix_tomato': 5,
      'dragon_strawberry': 4,
      'angel_watermelon': 3,
      'devil_grape': 3,
      'life_apple': 2,
      'eternal_cherry': 2,
    };
    return yields[seedId] ?? 5;
  }

  // 获取稀有种子价格
  static int _getRareSeedPrice(String seedId) {
    Map<String, int> prices = {
      'gold_wheat': 20,
      'rainbow_corn': 30,
      'magic_carrot': 40,
      'phoenix_tomato': 60,
      'dragon_strawberry': 80,
      'angel_watermelon': 100,
      'devil_grape': 120,
      'life_apple': 150,
      'eternal_cherry': 200,
    };
    return prices[seedId] ?? 50;
  }

  // 生成稀有动物ID
  static String _generateRareAnimalId() {
    List<String> rareAnimals = [
      'golden_chicken',
      'silver_sheep',
      'copper_cow',
      'phoenix',
      'unicorn',
      'dragon',
      'kirin',
      '玄武',
    ];
    return rareAnimals[_random.nextInt(rareAnimals.length)];
  }

  // 获取稀有动物名称
  static String _getRareAnimalName(String animalId) {
    Map<String, String> animalNames = {
      'golden_chicken': '金鸡',
      'silver_sheep': '银羊',
      'copper_cow': '铜牛',
      'phoenix': '凤凰',
      'unicorn': '独角兽',
      'dragon': '龙',
      'kirin': '麒麟',
      '玄武': '玄武',
    };
    return animalNames[animalId] ?? '稀有动物';
  }

  // 获取稀有动物产物
  static String _getRareAnimalProduct(String animalId) {
    Map<String, String> products = {
      'golden_chicken': '金蛋',
      'silver_sheep': '银羊毛',
      'copper_cow': '铜奶',
      'phoenix': '凤凰羽',
      'unicorn': '独角',
      'dragon': '龙鳞',
      'kirin': '麒麟角',
      '玄武': '玄武壳',
    };
    return products[animalId] ?? '稀有产物';
  }

  // 获取稀有动物生长时间
  static int _getRareAnimalGrowthTime(String animalId) {
    Map<String, int> growthTimes = {
      'golden_chicken': 1500, // 25分钟
      'silver_sheep': 3000, // 50分钟
      'copper_cow': 4500, // 75分钟
      'phoenix': 9000, // 150分钟
      'unicorn': 12000, // 200分钟
      'dragon': 18000, // 300分钟
      'kirin': 24000, // 400分钟
      '玄武': 30000, // 500分钟
    };
    return growthTimes[animalId] ?? 3600;
  }

  // 获取稀有动物产量
  static int _getRareAnimalYield(String animalId) {
    Map<String, int> yields = {
      'golden_chicken': 15,
      'silver_sheep': 8,
      'copper_cow': 5,
      'phoenix': 1,
      'unicorn': 1,
      'dragon': 1,
      'kirin': 1,
      '玄武': 1,
    };
    return yields[animalId] ?? 1;
  }

  // 获取稀有动物价格
  static int _getRareAnimalPrice(String animalId) {
    Map<String, int> prices = {
      'golden_chicken': 10,
      'silver_sheep': 25,
      'copper_cow': 40,
      'phoenix': 100,
      'unicorn': 150,
      'dragon': 200,
      'kirin': 300,
      '玄武': 400,
    };
    return prices[animalId] ?? 50;
  }
}

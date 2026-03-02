import '../models/farm.dart';
import '../models/ranch.dart';
import '../models/shop.dart';

class CalculationService {
  // 计算作物产量
  static int calculateCropYield(Crop crop, Farm farm, Plot plot) {
    double yield = crop.baseYield.toDouble();

    // 地皮等级修正
    yield *= (1 + plot.level * 0.1);

    // 农民修正
    for (Farmer farmer in farm.farmers) {
      yield *= (1 + farmer.getYieldBonus());
    }

    // 科技修正
    yield *= (1 + farm.tech['planting']! * 0.05);

    // 收获损失
    double loss = 0.1; // 基础损失10%
    for (Farmer farmer in farm.farmers) {
      loss -= farmer.getLossReduction();
    }
    loss -= farm.tech['harvesting']! * 0.02;
    loss = loss.clamp(0.01, 0.1); // 损失最低1%

    yield *= (1 - loss);

    return yield.round();
  }

  // 计算动物产量
  static int calculateAnimalYield(Animal animal, Ranch ranch, RanchPlot plot) {
    double yield = animal.baseYield.toDouble();

    // 地皮等级修正
    yield *= (1 + plot.level * 0.1);

    // 员工修正
    for (RanchEmployee employee in ranch.employees) {
      yield *= (1 + employee.getYieldBonus());
    }

    // 科技修正
    yield *= (1 + ranch.tech['breeding']! * 0.05);

    // 收获损失
    double loss = 0.1; // 基础损失10%
    for (RanchEmployee employee in ranch.employees) {
      loss -= employee.getLossReduction();
    }
    loss -= ranch.tech['harvesting']! * 0.02;
    loss = loss.clamp(0.01, 0.1); // 损失最低1%

    yield *= (1 - loss);

    return yield.round();
  }

  // 计算商品价格
  static int calculateItemPrice(Item item, int playerLevel, Shop shop) {
    int basePrice = item.getNextPrice();
    double discount = 1.0;

    // 等级折扣
    if (playerLevel >= 6 && playerLevel <= 10) {
      discount = 0.95; // 5%折扣
    } else if (playerLevel >= 11 && playerLevel <= 15) {
      discount = 0.9; // 10%折扣
    } else if (playerLevel >= 16) {
      discount = 0.85; // 15%折扣
    }

    // 促销折扣
    Promotion? promotion = shop.getActivePromotionForItem(item.id);
    if (promotion != null) {
      discount *= promotion.discount;
    }

    return (basePrice * discount).round();
  }

  // 计算地皮升级价格
  static int calculatePlotUpgradePrice(String plotType, int currentLevel) {
    int basePrice;
    switch (plotType) {
      case 'basic':
        basePrice = 500;
        break;
      case 'premium':
        basePrice = 1500;
        break;
      case 'fertile':
        basePrice = 3000;
        break;
      case 'rare':
        basePrice = 5000;
        break;
      case 'luxury':
        basePrice = 8000;
        break;
      default:
        basePrice = 500;
    }

    return basePrice * currentLevel;
  }

  // 计算员工升级价格
  static int calculateEmployeeUpgradePrice(String employeeType, int currentLevel) {
    int basePrice;
    switch (employeeType) {
      case 'basic':
        basePrice = 300;
        break;
      case 'skilled':
        basePrice = 600;
        break;
      case 'professional':
        basePrice = 1200;
        break;
      case 'master':
        basePrice = 2000;
        break;
      default:
        basePrice = 300;
    }

    return basePrice * currentLevel;
  }

  // 计算科技升级价格
  static int calculateTechUpgradePrice(String techType, int currentLevel) {
    int basePrice;
    switch (techType) {
      case 'planting':
      case 'breeding':
        basePrice = 1000;
        break;
      case 'harvesting':
        basePrice = 800;
        break;
      case 'management':
        basePrice = 1500;
        break;
      case 'economy':
        basePrice = 1200;
        break;
      default:
        basePrice = 1000;
    }

    return basePrice * (currentLevel + 1);
  }

  // 计算时间加速价格
  static int calculateTimeAccelerationPrice(int seconds) {
    // 每10秒需要1钻石
    return (seconds / 10).ceil();
  }

  // 计算牧场解锁价格
  static int calculateRanchUnlockPrice(int farmLevel) {
    return 5000 * farmLevel;
  }
}

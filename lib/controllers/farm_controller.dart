import '../models/farm.dart';
import '../services/storage_service.dart';
import '../services/time_service.dart';
import '../services/calculation_service.dart';
import 'player_controller.dart';

class FarmController {
  static Farm? _farm;

  // 初始化农场数据
  static Future<void> initialize() async {
    _farm = await StorageService.loadFarm();
    if (_farm == null) {
      _farm = Farm(
        plots: [
          Plot(id: 'plot_1', type: 'basic', status: 'claimed'),
        ],
        crops: [
          Crop(
            id: 'wheat',
            name: '小麦',
            growthTime: 300, // 5分钟
            baseYield: 10,
            basePrice: 10,
          ),
        ],
        farmers: [], // 初始农民数量为0，需要在商店-人才市场雇佣
      );
      await save();
    }
  }

  // 获取农场实例
  static Farm get farm {
    if (_farm == null) {
      _farm = Farm();
    }
    return _farm!;
  }

  // 保存农场数据
  static Future<void> save() async {
    if (_farm != null) {
      await StorageService.saveFarm(_farm!);
    }
  }

  // 种植作物
  static bool plantCrop(String plotId, String cropId) {
    Plot? plot = farm.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => Plot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'claimed') {
      return false;
    }

    Crop? crop = farm.getCropById(cropId);
    if (crop == null) {
      return false;
    }

    // 检查种子数量
    if (!PlayerController.hasEnoughSeeds(cropId, 1)) {
      return false;
    }

    // 消耗种子
    PlayerController.removeSeeds(cropId, 1);

    // 计算成熟时间
    DateTime matureAt = TimeService.calculateCropMatureTime(crop, farm, plot);
    plot.plant(cropId, crop.growthTime);
    plot.matureAt = matureAt;

    save();
    return true;
  }

  // 收获作物
  static Map<String, dynamic>? harvestCrop(String plotId) {
    Plot? plot = farm.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => Plot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'planted' || !plot.isMature()) {
      return null;
    }

    Crop? crop = farm.getCropById(plot.cropId!);
    if (crop == null) {
      return null;
    }

    // 保存当前种植的作物ID，用于自动种植
    String currentCropId = plot.cropId!;

    // 计算产量
    int yield = CalculationService.calculateCropYield(crop, farm, plot);
    int exp = (crop.baseYield * 0.5).round();

    // 收获
    plot.harvest();

    // 检查是否开启自动种植，并且农场有农民
    StorageService.getBool('autoPlant', false).then((autoPlant) {
      if (autoPlant && farm.farmers.isNotEmpty) {
        // 自动重新种植相同的作物
        plantCrop(plotId, currentCropId);
      }
    });

    // 更新玩家数据：添加作物到库存，添加经验值
    PlayerController.addCrops(currentCropId, yield);
    PlayerController.addExp(exp);

    save();

    return {
      'crop': crop.name,
      'yield': yield,
      'exp': exp,
    };
  }

  // 收获所有成熟的作物
  static List<Map<String, dynamic>> harvestAllMatureCrops() {
    List<Plot> maturePlots = TimeService.checkMatureCrops(farm);
    List<Map<String, dynamic>> harvests = [];

    for (Plot plot in maturePlots) {
      Map<String, dynamic>? harvest = harvestCrop(plot.id);
      if (harvest != null) {
        harvests.add(harvest);
      }
    }

    return harvests;
  }

  // 购买地皮
  static bool buyPlot(String plotType) {
    int basePrice;
    switch (plotType) {
      case 'basic':
        basePrice = 1000;
        break;
      case 'premium':
        basePrice = 3000;
        break;
      case 'fertile':
        basePrice = 6000;
        break;
      case 'rare':
        basePrice = 10000;
        break;
      default:
        basePrice = 1000;
    }

    // 计算价格
    int plotCount = farm.plots.where((p) => p.type == plotType).length;
    int price = (basePrice * (1 + 0.1 * plotCount)).round();

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    // 添加新地皮
    String plotId = 'plot_${farm.plots.length + 1}';
    farm.plots.add(Plot(id: plotId, type: plotType, status: 'unclaimed'));

    save();
    return true;
  }

  // 开垦地皮
  static bool claimPlot(String plotId) {
    Plot? plot = farm.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => Plot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'unclaimed') {
      return false;
    }

    int claimPrice = 500;
    if (!PlayerController.spendMoney(claimPrice)) {
      return false;
    }

    plot.status = 'claimed';
    save();
    return true;
  }

  // 升级地皮
  static bool upgradePlot(String plotId) {
    Plot? plot = farm.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => Plot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.level >= 5) {
      return false;
    }

    int price = CalculationService.calculatePlotUpgradePrice(plot.type, plot.level);
    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    plot.level++;
    save();
    return true;
  }

  // 雇佣农民
  static bool hireFarmer(String farmerType) {
    int basePrice;
    switch (farmerType) {
      case 'basic':
        basePrice = 500;
        break;
      case 'skilled':
        basePrice = 1000;
        break;
      case 'professional':
        basePrice = 2000;
        break;
      case 'master':
        basePrice = 3000;
        break;
      default:
        basePrice = 500;
    }

    // 计算价格
    int farmerCount = farm.farmers.where((f) => f.type == farmerType).length;
    int price = (basePrice * (1 + 0.15 * farmerCount)).round();

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    // 添加新农民
    String farmerId = 'farmer_${farm.farmers.length + 1}';
    farm.farmers.add(Farmer(id: farmerId, type: farmerType));

    save();
    return true;
  }

  // 升级农民
  static bool upgradeFarmer(String farmerId) {
    Farmer? farmer = farm.farmers.firstWhere(
      (f) => f.id == farmerId,
      orElse: () => Farmer(id: '', type: 'basic'),
    );
    if (farmer.id.isEmpty || farmer.level >= 5) {
      return false;
    }

    int price = CalculationService.calculateEmployeeUpgradePrice(farmer.type, farmer.level);
    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    farmer.level++;
    save();
    return true;
  }

  // 升级科技
  static bool upgradeTech(String techType) {
    if (!farm.tech.containsKey(techType)) {
      return false;
    }

    int currentLevel = farm.tech[techType]!;
    int price = CalculationService.calculateTechUpgradePrice(techType, currentLevel);

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    farm.tech[techType] = currentLevel + 1;
    save();
    return true;
  }

  // 添加新作物
  static void addCrop(Crop crop) {
    if (!farm.crops.any((c) => c.id == crop.id)) {
      farm.crops.add(crop);
      save();
    }
  }
}

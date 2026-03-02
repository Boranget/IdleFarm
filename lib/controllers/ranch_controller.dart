import '../models/ranch.dart';
import '../services/storage_service.dart';
import '../services/time_service.dart';
import '../services/calculation_service.dart';
import 'player_controller.dart';

class RanchController {
  static Ranch? _ranch;

  // 初始化牧场数据
  static Future<void> initialize() async {
    _ranch = await StorageService.loadRanch();
    if (_ranch == null) {
      _ranch = Ranch(
        plots: [],
        animals: [],
        employees: [],
      );
      await save();
    }
  }

  // 加载牧场数据
  static Future<Ranch> loadRanch() async {
    await initialize();
    return ranch;
  }

  // 获取牧场实例
  static Ranch get ranch {
    if (_ranch == null) {
      _ranch = Ranch();
    }
    return _ranch!;
  }

  // 保存牧场数据
  static Future<void> save() async {
    if (_ranch != null) {
      await StorageService.saveRanch(_ranch!);
    }
  }

  // 解锁牧场
  static bool unlockRanch(int farmLevel) {
    int price = CalculationService.calculateRanchUnlockPrice(farmLevel);
    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    // 添加初始牧场地皮
    ranch.plots.add(RanchPlot(id: 'ranch_plot_1', type: 'basic', status: 'claimed'));

    // 添加初始动物
    ranch.animals.add(Animal(
      id: 'chicken',
      name: '鸡',
      growthTime: 1800, // 30分钟
      baseYield: 10,
      basePrice: 5,
      product: '蛋',
    ));

    // 添加初始员工
    ranch.employees.add(RanchEmployee(id: 'ranch_employee_1', type: 'basic'));

    save();
    return true;
  }

  // 购买动物
  static bool buyAnimal(String plotId, String animalId) {
    RanchPlot? plot = ranch.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => RanchPlot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'claimed') {
      return false;
    }

    Animal? animal = ranch.getAnimalById(animalId);
    if (animal == null) {
      return false;
    }

    // 计算成熟时间
    DateTime matureAt = TimeService.calculateAnimalMatureTime(animal, ranch, plot);
    plot.buyAnimal(animalId, animal.growthTime);
    plot.matureAt = matureAt;

    save();
    return true;
  }

  // 收获动物产物
  static Map<String, dynamic>? harvestAnimal(String plotId) {
    RanchPlot? plot = ranch.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => RanchPlot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'occupied' || !plot.isMature()) {
      return null;
    }

    Animal? animal = ranch.getAnimalById(plot.animalId!);
    if (animal == null) {
      return null;
    }

    // 计算产量
    int yield = CalculationService.calculateAnimalYield(animal, ranch, plot);
    int money = yield * animal.basePrice;
    int exp = (animal.baseYield * 0.5).round();

    // 收获
    plot.harvest();

    // 更新玩家数据
    PlayerController.addMoney(money);
    PlayerController.addExp(exp);

    save();

    return {
      'animal': animal.name,
      'product': animal.product,
      'yield': yield,
      'money': money,
      'exp': exp,
    };
  }

  // 升级牧场员工
  static bool upgradeEmployee(String employeeId) {
    return upgradeRanchEmployee(employeeId);
  }

  // 升级牧场科技
  static bool upgradeTechnology(String techType) {
    return upgradeRanchTech(techType);
  }

  // 收获所有成熟的动物产物
  static List<Map<String, dynamic>> harvestAllMatureAnimals() {
    List<RanchPlot> maturePlots = TimeService.checkMatureAnimals(ranch);
    List<Map<String, dynamic>> harvests = [];

    for (RanchPlot plot in maturePlots) {
      Map<String, dynamic>? harvest = harvestAnimal(plot.id);
      if (harvest != null) {
        harvests.add(harvest);
      }
    }

    return harvests;
  }

  // 购买牧场地皮
  static bool buyRanchPlot(String plotType) {
    int basePrice;
    switch (plotType) {
      case 'basic':
        basePrice = 2000;
        break;
      case 'premium':
        basePrice = 5000;
        break;
      case 'advanced':
        basePrice = 8000;
        break;
      case 'luxury':
        basePrice = 12000;
        break;
      default:
        basePrice = 2000;
    }

    // 计算价格
    int plotCount = ranch.plots.where((p) => p.type == plotType).length;
    int price = (basePrice * (1 + 0.1 * plotCount)).round();

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    // 添加新牧场地皮
    String plotId = 'ranch_plot_${ranch.plots.length + 1}';
    ranch.plots.add(RanchPlot(id: plotId, type: plotType, status: 'unclaimed'));

    save();
    return true;
  }

  // 开垦牧场地皮
  static bool claimRanchPlot(String plotId) {
    RanchPlot? plot = ranch.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => RanchPlot(id: '', type: 'basic', status: 'unclaimed'),
    );
    if (plot.id.isEmpty || plot.status != 'unclaimed') {
      return false;
    }

    int claimPrice = 1000;
    if (!PlayerController.spendMoney(claimPrice)) {
      return false;
    }

    plot.status = 'claimed';
    save();
    return true;
  }

  // 升级牧场地皮
  static bool upgradeRanchPlot(String plotId) {
    RanchPlot? plot = ranch.plots.firstWhere(
      (p) => p.id == plotId,
      orElse: () => RanchPlot(id: '', type: 'basic', status: 'unclaimed'),
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

  // 升级牧场地皮（兼容界面调用）
  static bool upgradePlot(String plotId) {
    return upgradeRanchPlot(plotId);
  }

  // 雇佣牧场员工
  static bool hireRanchEmployee(String employeeType) {
    int basePrice;
    switch (employeeType) {
      case 'basic':
        basePrice = 800;
        break;
      case 'skilled':
        basePrice = 1500;
        break;
      case 'professional':
        basePrice = 2500;
        break;
      case 'master':
        basePrice = 4000;
        break;
      default:
        basePrice = 800;
    }

    // 计算价格
    int employeeCount = ranch.employees.where((e) => e.type == employeeType).length;
    int price = (basePrice * (1 + 0.15 * employeeCount)).round();

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    // 添加新员工
    String employeeId = 'ranch_employee_${ranch.employees.length + 1}';
    ranch.employees.add(RanchEmployee(id: employeeId, type: employeeType));

    save();
    return true;
  }

  // 升级牧场员工
  static bool upgradeRanchEmployee(String employeeId) {
    RanchEmployee? employee = ranch.employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => RanchEmployee(id: '', type: 'basic'),
    );
    if (employee.id.isEmpty || employee.level >= 5) {
      return false;
    }

    int price = CalculationService.calculateEmployeeUpgradePrice(employee.type, employee.level);
    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    employee.level++;
    save();
    return true;
  }

  // 升级牧场科技
  static bool upgradeRanchTech(String techType) {
    if (!ranch.tech.containsKey(techType)) {
      return false;
    }

    int currentLevel = ranch.tech[techType]!;
    int price = CalculationService.calculateTechUpgradePrice(techType, currentLevel);

    if (!PlayerController.spendMoney(price)) {
      return false;
    }

    ranch.tech[techType] = currentLevel + 1;
    save();
    return true;
  }

  // 添加新动物
  static void addAnimal(Animal animal) {
    if (!ranch.animals.any((a) => a.id == animal.id)) {
      ranch.animals.add(animal);
      save();
    }
  }
}

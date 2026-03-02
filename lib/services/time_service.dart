import '../models/farm.dart';
import '../models/ranch.dart';

class TimeService {
  static const int CHECK_INTERVAL = 10000; // 10秒

  // 计算离线收益
  static Map<String, dynamic> calculateOfflineEarnings(DateTime lastOnline, DateTime currentTime, Farm farm, Ranch? ranch) {
    Duration offlineDuration = currentTime.difference(lastOnline);
    int offlineSeconds = offlineDuration.inSeconds;

    // 计算农场收益
    Map<String, dynamic> farmEarnings = _calculateFarmEarnings(offlineSeconds, farm);
    // 计算牧场收益
    Map<String, dynamic> ranchEarnings = ranch != null ? _calculateRanchEarnings(offlineSeconds, ranch) : {'money': 0, 'exp': 0};

    return {
      'farm': farmEarnings,
      'ranch': ranchEarnings,
      'totalMoney': farmEarnings['money'] + ranchEarnings['money'],
      'totalExp': farmEarnings['exp'] + ranchEarnings['exp'],
    };
  }

  // 计算农场离线收益
  static Map<String, dynamic> _calculateFarmEarnings(int seconds, Farm farm) {
    int totalMoney = 0;
    int totalExp = 0;

    // 遍历所有地皮
    for (Plot plot in farm.plots) {
      if (plot.status == 'planted' && plot.matureAt != null) {
        // 计算成熟时间与当前时间的差值
        Duration timeUntilMature = plot.matureAt!.difference(DateTime.now().subtract(Duration(seconds: seconds)));
        int secondsUntilMature = timeUntilMature.inSeconds;

        // 如果在离线期间成熟
        if (secondsUntilMature < 0) {
          // 计算可以收获的次数
          int harvestCount = (-secondsUntilMature) ~/ (plot.cropId != null ? farm.getCropById(plot.cropId!)?.growthTime ?? 300 : 300);
          harvestCount = harvestCount > 0 ? harvestCount : 1;

          // 计算每次收获的收益
          if (plot.cropId != null) {
            Crop? crop = farm.getCropById(plot.cropId!);
            if (crop != null) {
              // 计算实际产量
              double yieldBonus = farm.getTotalYieldBonus() / 100.0;
              double lossReduction = farm.getTotalLossReduction() / 100.0;
              int actualYield = (crop.baseYield * (1 + yieldBonus) * (1 - (0.1 - lossReduction))).round();
              actualYield = actualYield > 0 ? actualYield : 1;

              // 计算收益
              int moneyPerHarvest = actualYield * crop.basePrice;
              int expPerHarvest = (crop.baseYield * 0.5).round();

              totalMoney += moneyPerHarvest * harvestCount;
              totalExp += expPerHarvest * harvestCount;
            }
          }
        }
      }
    }

    return {'money': totalMoney, 'exp': totalExp};
  }

  // 计算牧场离线收益
  static Map<String, dynamic> _calculateRanchEarnings(int seconds, Ranch ranch) {
    int totalMoney = 0;
    int totalExp = 0;

    // 遍历所有牧场地皮
    for (RanchPlot plot in ranch.plots) {
      if (plot.status == 'occupied' && plot.matureAt != null) {
        // 计算成熟时间与当前时间的差值
        Duration timeUntilMature = plot.matureAt!.difference(DateTime.now().subtract(Duration(seconds: seconds)));
        int secondsUntilMature = timeUntilMature.inSeconds;

        // 如果在离线期间成熟
        if (secondsUntilMature < 0) {
          // 计算可以收获的次数
          int harvestCount = (-secondsUntilMature) ~/ (plot.animalId != null ? ranch.getAnimalById(plot.animalId!)?.growthTime ?? 1800 : 1800);
          harvestCount = harvestCount > 0 ? harvestCount : 1;

          // 计算每次收获的收益
          if (plot.animalId != null) {
            Animal? animal = ranch.getAnimalById(plot.animalId!);
            if (animal != null) {
              // 计算实际产量
              double yieldBonus = ranch.getTotalYieldBonus() / 100.0;
              double lossReduction = ranch.getTotalLossReduction() / 100.0;
              int actualYield = (animal.baseYield * (1 + yieldBonus) * (1 - (0.1 - lossReduction))).round();
              actualYield = actualYield > 0 ? actualYield : 1;

              // 计算收益
              int moneyPerHarvest = actualYield * animal.basePrice;
              int expPerHarvest = (animal.baseYield * 0.5).round();

              totalMoney += moneyPerHarvest * harvestCount;
              totalExp += expPerHarvest * harvestCount;
            }
          }
        }
      }
    }

    return {'money': totalMoney, 'exp': totalExp};
  }

  // 计算作物成熟时间
  static DateTime calculateCropMatureTime(Crop crop, Farm farm, Plot plot) {
    int growthTime = crop.growthTime;

    // 计算生长速度修正
    double speedFactor = 0.0;

    // 地皮等级修正
    speedFactor += plot.level * 0.05;

    // 农民修正
    for (Farmer farmer in farm.farmers) {
      speedFactor += farmer.getGrowthSpeedBonus();
    }

    // 科技修正
    speedFactor += farm.tech['planting']! * 0.05;

    // 计算实际生长时间
    int actualGrowthTime = (growthTime / (1 + speedFactor)).round();

    return DateTime.now().add(Duration(seconds: actualGrowthTime));
  }

  // 计算动物成熟时间
  static DateTime calculateAnimalMatureTime(Animal animal, Ranch ranch, RanchPlot plot) {
    int growthTime = animal.growthTime;

    // 计算生长速度修正
    double speedFactor = 0.0;

    // 地皮等级修正
    speedFactor += plot.level * 0.05;

    // 员工修正
    for (RanchEmployee employee in ranch.employees) {
      speedFactor += employee.getGrowthSpeedBonus();
    }

    // 科技修正
    speedFactor += ranch.tech['breeding']! * 0.05;

    // 计算实际生长时间
    int actualGrowthTime = (growthTime / (1 + speedFactor)).round();

    return DateTime.now().add(Duration(seconds: actualGrowthTime));
  }

  // 检查并更新成熟的作物
  static List<Plot> checkMatureCrops(Farm farm) {
    List<Plot> maturePlots = [];

    for (Plot plot in farm.plots) {
      if (plot.status == 'planted' && plot.isMature()) {
        maturePlots.add(plot);
      }
    }

    return maturePlots;
  }

  // 检查并更新成熟的动物
  static List<RanchPlot> checkMatureAnimals(Ranch ranch) {
    List<RanchPlot> maturePlots = [];

    for (RanchPlot plot in ranch.plots) {
      if (plot.status == 'occupied' && plot.isMature()) {
        maturePlots.add(plot);
      }
    }

    return maturePlots;
  }
}

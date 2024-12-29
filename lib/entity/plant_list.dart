// 成熟列表项类，包含成熟作物及其时间
import 'package:my_flutter/entity/plant_list_item.dart';

class PlantList {
  // 成熟时间列表
  List<int> ripeTimeList = [];
  // 成熟作物列表
  Map<int, PlantListItem> ripeMap = {};
  // 添加成熟列表项
  void addRipeListItem(int ripeTime, PlantListItem ripeListItem) {
    ripeTimeList.add(ripeTime);
    ripeTimeList.sort();
    ripeMap.putIfAbsent(ripeTime, () => ripeListItem);
  }

  // 是否存在成熟时间time
  bool hasRipeTime(int ripeTime) {
    return ripeMap.containsKey(ripeTime);
  }

  // 传入成熟时间time，如果成熟时间存在，返回已有列表项，否则新建列表项并返回
  PlantListItem getPlantListItem(int ripeTime) {
    if (hasRipeTime(ripeTime)) {
      return ripeMap[ripeTime]!;
    } else {
      PlantListItem plantListItem = PlantListItem();
      addRipeListItem(ripeTime, plantListItem);
      return plantListItem;
    }
  }
  // 打印列表
  void printPlantList() {
    print('==========');
    for (var ripeTime in ripeTimeList) {
      // 输出格式化后的时间以及列表项中的作物内容
      print('${DateTime.fromMillisecondsSinceEpoch(ripeTime).toString()} : ${ripeMap[ripeTime]!.cropsList}');
    }
    print('==========');
  }
}

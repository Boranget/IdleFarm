import 'package:flutter/material.dart';
import 'package:my_flutter/entity/crop.dart';
import 'package:my_flutter/entity/plant_list.dart';
/// 全局状态管理
class GlobalState extends ChangeNotifier {
  // 作物成熟列表
  var ripeList = PlantList();
  // 种植作物
  void plantCrop(Crop crop, int count) {
    // 获取当前系统时间
    var now = DateTime.now().millisecondsSinceEpoch;
    // 计算当前作物的成熟时间
    var ripeTime = crop.ripeTimeCost!+now;
    // 获取该成熟时间的列表项
    var plantListItem = ripeList.getPlantListItem(ripeTime);
    // 添加作物到列表项
    plantListItem.addCrop(crop, count);
    notifyListeners();
  }
}

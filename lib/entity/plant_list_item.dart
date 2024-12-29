import 'package:my_flutter/entity/crop.dart';

// 种植列表项类，包含成熟作物及其时间
class PlantListItem {
  // 种植作物列表
  List<Crops> cropsList = [];

  // 添加作物到列表
  void addCrop(Crop crop, int count) {
    cropsList.add(Crops(crop: crop, count: count));
  }
}

// 带数量的作物类
class Crops {
  // 作物对象
  Crop? crop;

  // 作物数量
  int? count;

  // 构造函数，初始化作物和数量
  Crops({this.crop, this.count});

  // 重写toString方法，返回作物名称和数量
  @override
  String toString() {
    return '${crop!.name} x $count';
  }
}
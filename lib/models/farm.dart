class Crop {
  String id;
  String name;
  int growthTime; // 秒
  int baseYield;
  int basePrice;
  int unlockLevel;

  Crop({
    required this.id,
    required this.name,
    required this.growthTime,
    required this.baseYield,
    required this.basePrice,
    this.unlockLevel = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'growthTime': growthTime,
      'baseYield': baseYield,
      'basePrice': basePrice,
      'unlockLevel': unlockLevel,
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      growthTime: json['growthTime'],
      baseYield: json['baseYield'],
      basePrice: json['basePrice'],
      unlockLevel: json['unlockLevel'] ?? 1,
    );
  }
}

class Plot {
  String id;
  String type; // basic, premium, fertile, rare
  int level;
  String status; // unclaimed, claimed, planted
  String? cropId;
  DateTime? plantedAt;
  DateTime? matureAt;

  Plot({
    required this.id,
    required this.type,
    this.level = 1,
    this.status = 'unclaimed',
    this.cropId,
    this.plantedAt,
    this.matureAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'level': level,
      'status': status,
      'cropId': cropId,
      'plantedAt': plantedAt?.toIso8601String(),
      'matureAt': matureAt?.toIso8601String(),
    };
  }

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'],
      type: json['type'],
      level: json['level'] ?? 1,
      status: json['status'] ?? 'unclaimed',
      cropId: json['cropId'],
      plantedAt: json['plantedAt'] != null ? DateTime.parse(json['plantedAt']) : null,
      matureAt: json['matureAt'] != null ? DateTime.parse(json['matureAt']) : null,
    );
  }

  bool isMature() {
    return matureAt != null && DateTime.now().isAfter(matureAt!);
  }

  void plant(String cropId, int growthTime) {
    status = 'planted';
    this.cropId = cropId;
    plantedAt = DateTime.now();
    matureAt = DateTime.now().add(Duration(seconds: growthTime));
  }

  void harvest() {
    status = 'claimed';
    cropId = null;
    plantedAt = null;
    matureAt = null;
  }
}

class Farmer {
  String id;
  String type; // basic, skilled, professional, master
  int level;
  String status; // idle, working
  List<String> skills;

  Farmer({
    required this.id,
    required this.type,
    this.level = 1,
    this.status = 'working',
    this.skills = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'level': level,
      'status': status,
      'skills': skills,
    };
  }

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      type: json['type'],
      level: json['level'] ?? 1,
      status: json['status'] ?? 'working',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }

  double getYieldBonus() {
    double bonus = 0.0;
    switch (type) {
      case 'basic':
        bonus = 0.0;
        break;
      case 'skilled':
        bonus = 0.2;
        break;
      case 'professional':
        bonus = 0.4;
        break;
      case 'master':
        bonus = 0.6;
        break;
    }
    bonus += level * 0.05; // 每级增加5%产量
    for (String skill in skills) {
      if (skill == '产量提升') {
        bonus += 0.05;
      }
    }
    return bonus;
  }

  double getGrowthSpeedBonus() {
    double bonus = 0.0;
    for (String skill in skills) {
      if (skill == '种植大师') {
        bonus += 0.1;
      }
    }
    bonus += level * 0.02; // 每级增加2%生长速度
    return bonus;
  }

  double getLossReduction() {
    double reduction = 0.0;
    for (String skill in skills) {
      if (skill == '收获专家') {
        reduction += 0.02;
      }
    }
    reduction += level * 0.01; // 每级减少1%损失
    return reduction;
  }
}

class Farm {
  int level;
  List<Plot> plots;
  List<Crop> crops;
  List<Farmer> farmers;
  Map<String, int> tech;

  Farm({
    this.level = 1,
    this.plots = const [],
    this.crops = const [],
    this.farmers = const [],
    Map<String, int>? tech,
  }) : tech = tech ?? {
          'planting': 0,
          'harvesting': 0,
          'management': 0,
          'economy': 0,
        };

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'plots': plots.map((plot) => plot.toJson()).toList(),
      'crops': crops.map((crop) => crop.toJson()).toList(),
      'farmers': farmers.map((farmer) => farmer.toJson()).toList(),
      'tech': tech,
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      level: json['level'] ?? 1,
      plots: (json['plots'] as List<dynamic>?)?.map((e) => Plot.fromJson(e)).toList() ?? [],
      crops: (json['crops'] as List<dynamic>?)?.map((e) => Crop.fromJson(e)).toList() ?? [],
      farmers: (json['farmers'] as List<dynamic>?)?.map((e) => Farmer.fromJson(e)).toList() ?? [],
      tech: Map<String, int>.from(json['tech'] ?? {}),
    );
  }

  Crop? getCropById(String id) {
    return crops.firstWhere(
      (crop) => crop.id == id,
      orElse: () => Crop(id: '', name: '', growthTime: 0, baseYield: 0, basePrice: 0),
    );
  }

  int getTotalYieldBonus() {
    double bonus = 0.0;
    for (Farmer farmer in farmers) {
      bonus += farmer.getYieldBonus();
    }
    bonus += tech['planting']! * 0.05; // 种植科技每级增加5%产量
    return (bonus * 100).toInt();
  }

  int getTotalGrowthSpeedBonus() {
    double bonus = 0.0;
    for (Farmer farmer in farmers) {
      bonus += farmer.getGrowthSpeedBonus();
    }
    bonus += tech['planting']! * 0.05; // 种植科技每级增加5%生长速度
    return (bonus * 100).toInt();
  }

  int getTotalLossReduction() {
    double reduction = 0.0;
    for (Farmer farmer in farmers) {
      reduction += farmer.getLossReduction();
    }
    reduction += tech['harvesting']! * 0.02; // 收获科技每级减少2%损失
    return (reduction * 100).toInt();
  }
}

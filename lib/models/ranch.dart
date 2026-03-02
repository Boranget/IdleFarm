class Animal {
  String id;
  String name;
  int growthTime; // 秒
  int baseYield;
  int basePrice;
  int unlockLevel;
  String product;

  Animal({
    required this.id,
    required this.name,
    required this.growthTime,
    required this.baseYield,
    required this.basePrice,
    this.unlockLevel = 1,
    required this.product,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'growthTime': growthTime,
      'baseYield': baseYield,
      'basePrice': basePrice,
      'unlockLevel': unlockLevel,
      'product': product,
    };
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      growthTime: json['growthTime'],
      baseYield: json['baseYield'],
      basePrice: json['basePrice'],
      unlockLevel: json['unlockLevel'] ?? 1,
      product: json['product'],
    );
  }
}

class RanchPlot {
  String id;
  String type; // basic, premium, advanced, luxury
  int level;
  String status; // unclaimed, claimed, occupied
  String? animalId;
  DateTime? boughtAt;
  DateTime? matureAt;

  RanchPlot({
    required this.id,
    required this.type,
    this.level = 1,
    this.status = 'unclaimed',
    this.animalId,
    this.boughtAt,
    this.matureAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'level': level,
      'status': status,
      'animalId': animalId,
      'boughtAt': boughtAt?.toIso8601String(),
      'matureAt': matureAt?.toIso8601String(),
    };
  }

  factory RanchPlot.fromJson(Map<String, dynamic> json) {
    return RanchPlot(
      id: json['id'],
      type: json['type'],
      level: json['level'] ?? 1,
      status: json['status'] ?? 'unclaimed',
      animalId: json['animalId'],
      boughtAt: json['boughtAt'] != null ? DateTime.parse(json['boughtAt']) : null,
      matureAt: json['matureAt'] != null ? DateTime.parse(json['matureAt']) : null,
    );
  }

  bool isMature() {
    return matureAt != null && DateTime.now().isAfter(matureAt!);
  }

  void buyAnimal(String animalId, int growthTime) {
    status = 'occupied';
    this.animalId = animalId;
    boughtAt = DateTime.now();
    matureAt = DateTime.now().add(Duration(seconds: growthTime));
  }

  void harvest() {
    status = 'claimed';
    animalId = null;
    boughtAt = null;
    matureAt = null;
  }
}

class RanchEmployee {
  String id;
  String type; // basic, skilled, professional, master
  int level;
  String status; // idle, working
  List<String> skills;

  RanchEmployee({
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

  factory RanchEmployee.fromJson(Map<String, dynamic> json) {
    return RanchEmployee(
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
      if (skill == '养殖大师') {
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

  double getSicknessReduction() {
    double reduction = 0.0;
    for (String skill in skills) {
      if (skill == '动物安抚') {
        reduction += 0.02;
      }
    }
    return reduction;
  }
}

class Ranch {
  int level;
  List<RanchPlot> plots;
  List<Animal> animals;
  List<RanchEmployee> employees;
  Map<String, int> tech;

  Ranch({
    this.level = 1,
    this.plots = const [],
    this.animals = const [],
    this.employees = const [],
    Map<String, int>? tech,
  }) : tech = tech ?? {
          'breeding': 0,
          'harvesting': 0,
          'management': 0,
          'economy': 0,
        };

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'plots': plots.map((plot) => plot.toJson()).toList(),
      'animals': animals.map((animal) => animal.toJson()).toList(),
      'employees': employees.map((employee) => employee.toJson()).toList(),
      'tech': tech,
    };
  }

  factory Ranch.fromJson(Map<String, dynamic> json) {
    return Ranch(
      level: json['level'] ?? 1,
      plots: (json['plots'] as List<dynamic>?)?.map((e) => RanchPlot.fromJson(e)).toList() ?? [],
      animals: (json['animals'] as List<dynamic>?)?.map((e) => Animal.fromJson(e)).toList() ?? [],
      employees: (json['employees'] as List<dynamic>?)?.map((e) => RanchEmployee.fromJson(e)).toList() ?? [],
      tech: Map<String, int>.from(json['tech'] ?? {}),
    );
  }

  Animal? getAnimalById(String id) {
    return animals.firstWhere(
      (animal) => animal.id == id,
      orElse: () => Animal(id: '', name: '', growthTime: 0, baseYield: 0, basePrice: 0, product: ''),
    );
  }

  int getTotalYieldBonus() {
    double bonus = 0.0;
    for (RanchEmployee employee in employees) {
      bonus += employee.getYieldBonus();
    }
    bonus += tech['breeding']! * 0.05; // 养殖科技每级增加5%产量
    return (bonus * 100).toInt();
  }

  int getTotalGrowthSpeedBonus() {
    double bonus = 0.0;
    for (RanchEmployee employee in employees) {
      bonus += employee.getGrowthSpeedBonus();
    }
    bonus += tech['breeding']! * 0.05; // 养殖科技每级增加5%生长速度
    return (bonus * 100).toInt();
  }

  int getTotalLossReduction() {
    double reduction = 0.0;
    for (RanchEmployee employee in employees) {
      reduction += employee.getLossReduction();
    }
    reduction += tech['harvesting']! * 0.02; // 收获科技每级减少2%损失
    return (reduction * 100).toInt();
  }

  int getTotalSicknessReduction() {
    double reduction = 0.0;
    for (RanchEmployee employee in employees) {
      reduction += employee.getSicknessReduction();
    }
    return (reduction * 100).toInt();
  }
}

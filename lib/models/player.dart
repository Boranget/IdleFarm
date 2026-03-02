class Player {
  int level;
  int exp;
  int money;
  DateTime lastOnline;
  Map<String, int> seeds; // 种子库存
  Map<String, int> crops; // 作物库存

  Player({
    this.level = 1,
    this.exp = 0,
    this.money = 1000,
    DateTime? lastOnline,
    Map<String, int>? seeds,
    Map<String, int>? crops,
  }) : 
    lastOnline = lastOnline ?? DateTime.now(),
    seeds = seeds ?? {},
    crops = crops ?? {};

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'exp': exp,
      'money': money,
      'lastOnline': lastOnline.toIso8601String(),
      'seeds': seeds,
      'crops': crops,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      level: json['level'] ?? 1,
      exp: json['exp'] ?? 0,
      money: json['money'] ?? 1000,
      lastOnline: DateTime.parse(json['lastOnline'] ?? DateTime.now().toIso8601String()),
      seeds: Map<String, int>.from(json['seeds'] ?? {}),
      crops: Map<String, int>.from(json['crops'] ?? {}),
    );
  }

  void addExp(int amount) {
    exp += amount;
    checkLevelUp();
  }

  void addMoney(int amount) {
    money += amount;
  }

  bool spendMoney(int amount) {
    if (money >= amount) {
      money -= amount;
      return true;
    }
    return false;
  }

  void checkLevelUp() {
    int requiredExp = level * 100;
    while (exp >= requiredExp) {
      exp -= requiredExp;
      level++;
      requiredExp = level * 100;
      addMoney(1000); // 升级奖励改为金钱
    }
  }

  // 添加种子
  void addSeeds(String seedId, int amount) {
    seeds[seedId] = (seeds[seedId] ?? 0) + amount;
  }

  //  // 移除种子
  bool removeSeeds(String seedId, int amount) {
    int currentAmount = seeds[seedId] ?? 0;
    if (currentAmount >= amount) {
      seeds[seedId] = currentAmount - amount;
      if (seeds[seedId] == 0) {
        seeds.remove(seedId);
      }
      return true;
    }
    return false;
  }

  // 检查种子数量
  int getSeedAmount(String seedId) {
    return seeds[seedId] ?? 0;
  }

  // 检查是否有足够的种子
  bool hasEnoughSeeds(String seedId, int amount) {
    return getSeedAmount(seedId) >= amount;
  }

  // 添加作物
  void addCrops(String cropId, int amount) {
    crops[cropId] = (crops[cropId] ?? 0) + amount;
  }

  // 移除作物
  bool removeCrops(String cropId, int amount) {
    int currentAmount = crops[cropId] ?? 0;
    if (currentAmount >= amount) {
      crops[cropId] = currentAmount - amount;
      if (crops[cropId] == 0) {
        crops.remove(cropId);
      }
      return true;
    }
    return false;
  }

  // 检查作物数量
  int getCropAmount(String cropId) {
    return crops[cropId] ?? 0;
  }

  // 检查是否有足够的作物
  bool hasEnoughCrops(String cropId, int amount) {
    return getCropAmount(cropId) >= amount;
  }
}

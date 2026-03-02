import '../models/player.dart';
import '../services/storage_service.dart';

class PlayerController {
  static Player? _player;

  // 初始化玩家数据
  static Future<void> initialize() async {
    _player = await StorageService.loadPlayer();
    if (_player == null) {
      _player = Player();
      await save();
    }
  }

  // 加载玩家数据
  static Future<Player> loadPlayer() async {
    await initialize();
    return player;
  }

  // 获取玩家实例
  static Player get player {
    if (_player == null) {
      _player = Player();
    }
    return _player!;
  }

  // 保存玩家数据
  static Future<void> save() async {
    if (_player != null) {
      await StorageService.savePlayer(_player!);
    }
  }

  // 添加经验值
  static void addExp(int amount) {
    player.addExp(amount);
    save();
  }

  // 添加游戏货币
  static void addMoney(int amount) {
    player.addMoney(amount);
    save();
  }

  // 花费游戏货币
  static bool spendMoney(int amount) {
    bool result = player.spendMoney(amount);
    if (result) {
      save();
    }
    return result;
  }

  // 更新最后在线时间
  static void updateLastOnline() {
    player.lastOnline = DateTime.now();
    save();
  }

  // 检查并处理离线收益
  static void processOfflineEarnings(Map<String, dynamic> earnings) {
    if (earnings.containsKey('totalMoney')) {
      addMoney(earnings['totalMoney']);
    }
    if (earnings.containsKey('totalExp')) {
      addExp(earnings['totalExp']);
    }
  }

  // 添加种子
  static void addSeeds(String seedId, int amount) {
    player.addSeeds(seedId, amount);
    save();
  }

  // 移除种子
  static bool removeSeeds(String seedId, int amount) {
    bool result = player.removeSeeds(seedId, amount);
    if (result) {
      save();
    }
    return result;
  }

  // 检查种子数量
  static int getSeedAmount(String seedId) {
    return player.getSeedAmount(seedId);
  }

  // 检查是否有足够的种子
  static bool hasEnoughSeeds(String seedId, int amount) {
    return player.hasEnoughSeeds(seedId, amount);
  }

  // 添加作物
  static void addCrops(String cropId, int amount) {
    player.addCrops(cropId, amount);
    save();
  }

  // 移除作物
  static bool removeCrops(String cropId, int amount) {
    bool result = player.removeCrops(cropId, amount);
    if (result) {
      save();
    }
    return result;
  }

  // 检查作物数量
  static int getCropAmount(String cropId) {
    return player.getCropAmount(cropId);
  }

  // 检查是否有足够的作物
  static bool hasEnoughCrops(String cropId, int amount) {
    return player.hasEnoughCrops(cropId, amount);
  }
}

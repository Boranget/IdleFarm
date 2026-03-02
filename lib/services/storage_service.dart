import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import '../models/player.dart';
import '../models/farm.dart';
import '../models/ranch.dart';
import '../models/shop.dart';



class StorageService {
  static const String _STORAGE_DIR = 'idle_farm_data';

  // 获取存储目录
  static Future<String> get _storageDir async {
    final appDir = Directory.current;
    final storageDir = Directory(join(appDir.path, _STORAGE_DIR));
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    return storageDir.path;
  }



  // 保存玩家数据
  static Future<void> savePlayer(Player player) async {
    final dir = await _storageDir;
    final file = File(join(dir, 'player.json'));
    await file.writeAsString(json.encode(player.toJson()));
  }

  // 加载玩家数据
  static Future<Player?> loadPlayer() async {
    final dir = await _storageDir;
    final file = File(join(dir, 'player.json'));
    if (!await file.exists()) return null;
    final data = await file.readAsString();
    return Player.fromJson(json.decode(data));
  }

  // 保存农场数据
  static Future<void> saveFarm(Farm farm) async {
    final dir = await _storageDir;
    final file = File(join(dir, 'farm.json'));
    await file.writeAsString(json.encode(farm.toJson()));
  }

  // 加载农场数据
  static Future<Farm?> loadFarm() async {
    final dir = await _storageDir;
    final file = File(join(dir, 'farm.json'));
    if (!await file.exists()) return null;
    final data = await file.readAsString();
    return Farm.fromJson(json.decode(data));
  }

  // 保存牧场数据
  static Future<void> saveRanch(Ranch ranch) async {
    final dir = await _storageDir;
    final file = File(join(dir, 'ranch.json'));
    await file.writeAsString(json.encode(ranch.toJson()));
  }

  // 加载牧场数据
  static Future<Ranch?> loadRanch() async {
    final dir = await _storageDir;
    final file = File(join(dir, 'ranch.json'));
    if (!await file.exists()) return null;
    final data = await file.readAsString();
    return Ranch.fromJson(json.decode(data));
  }

  // 保存商店数据
  static Future<void> saveShop(Shop shop) async {
    final dir = await _storageDir;
    final file = File(join(dir, 'shop.json'));
    await file.writeAsString(json.encode(shop.toJson()));
  }

  // 加载商店数据
  static Future<Shop?> loadShop() async {
    final dir = await _storageDir;
    final file = File(join(dir, 'shop.json'));
    if (!await file.exists()) return null;
    final data = await file.readAsString();
    return Shop.fromJson(json.decode(data));
  }

  // 保存游戏设置
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final dir = await _storageDir;
    final file = File(join(dir, 'settings.json'));
    await file.writeAsString(json.encode(settings));
  }

  // 加载游戏设置
  static Future<Map<String, dynamic>> loadSettings() async {
    final dir = await _storageDir;
    final file = File(join(dir, 'settings.json'));
    if (!await file.exists()) {
      return {'sound': true, 'music': true, 'notifications': true};
    }
    final data = await file.readAsString();
    return json.decode(data);
  }

  // 获取布尔值设置
  static Future<bool> getBool(String key, bool defaultValue) async {
    final settings = await loadSettings();
    return settings.containsKey(key) ? settings[key] : defaultValue;
  }

  // 设置布尔值设置
  static Future<void> setBool(String key, bool value) async {
    final settings = await loadSettings();
    settings[key] = value;
    await saveSettings(settings);
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    final dir = await _storageDir;
    final files = [
      'player.json',
      'farm.json',
      'ranch.json',
      'shop.json',
      'settings.json',
    ];
    for (final file in files) {
      final filePath = join(dir, file);
      final fileObj = File(filePath);
      if (await fileObj.exists()) {
        await fileObj.delete();
      }
    }
  }

  // 备份数据
  static Future<Map<String, dynamic>> backupData() async {
    final player = await loadPlayer();
    final farm = await loadFarm();
    final ranch = await loadRanch();
    final shop = await loadShop();
    final settings = await loadSettings();

    return {
      'player': player?.toJson(),
      'farm': farm?.toJson(),
      'ranch': ranch?.toJson(),
      'shop': shop?.toJson(),
      'settings': settings,
      'backupTime': DateTime.now().toIso8601String(),
    };
  }

  // 恢复数据
  static Future<void> restoreData(Map<String, dynamic> backup) async {
    if (backup.containsKey('player')) {
      final player = Player.fromJson(backup['player']);
      await savePlayer(player);
    }
    if (backup.containsKey('farm')) {
      final farm = Farm.fromJson(backup['farm']);
      await saveFarm(farm);
    }
    if (backup.containsKey('ranch')) {
      final ranch = Ranch.fromJson(backup['ranch']);
      await saveRanch(ranch);
    }
    if (backup.containsKey('shop')) {
      final shop = Shop.fromJson(backup['shop']);
      await saveShop(shop);
    }
    if (backup.containsKey('settings')) {
      await saveSettings(backup['settings']);
    }
  }
}

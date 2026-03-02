class Item {
  String id;
  String name;
  String description;
  int price;
  String currency; // money or diamonds
  String category; // crops, animals, tools, special
  int unlockLevel;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    this.unlockLevel = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'category': category,
      'unlockLevel': unlockLevel,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      currency: json['currency'],
      category: json['category'],
      unlockLevel: json['unlockLevel'] ?? 1,
    );
  }

  // 获取下一个价格（简单实现，返回当前价格）
  int getNextPrice() {
    return price;
  }
}

class Promotion {
  String id;
  String name;
  String itemId;
  double discount;
  DateTime startDate;
  DateTime endDate;

  Promotion({
    required this.id,
    required this.name,
    required this.itemId,
    required this.discount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemId': itemId,
      'discount': discount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      name: json['name'],
      itemId: json['itemId'],
      discount: json['discount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  bool isActive() {
    DateTime now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}

class Shop {
  List<Item> items;
  List<Promotion> promotions;

  Shop({
    this.items = const [],
    this.promotions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'promotions': promotions.map((promo) => promo.toJson()).toList(),
    };
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      items: (json['items'] as List<dynamic>?)?.map((e) => Item.fromJson(e)).toList() ?? [],
      promotions: (json['promotions'] as List<dynamic>?)?.map((e) => Promotion.fromJson(e)).toList() ?? [],
    );
  }

  Item? getItemById(String id) {
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => Item(id: '', name: '', description: '', price: 0, currency: 'money', category: 'crops'),
    );
  }

  List<Item> getItemsByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  List<Item> getUnlockedItems(int playerLevel) {
    return items.where((item) => item.unlockLevel <= playerLevel).toList();
  }

  // 获取物品的活动促销
  Promotion? getActivePromotionForItem(String itemId) {
    try {
      return promotions.firstWhere(
        (promo) => promo.itemId == itemId && promo.isActive(),
      );
    } catch (e) {
      return null;
    }
  }
}
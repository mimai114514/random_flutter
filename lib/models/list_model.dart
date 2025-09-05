import 'dart:convert';

class ListItem {
  String id;
  String content;
  int usageCount;

  ListItem({required this.id, required this.content, this.usageCount = 0});

  // 从JSON转换为ListItem对象
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'],
      content: json['content'],
      usageCount: json['usageCount'] ?? 0,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content, 'usageCount': usageCount};
  }

  // 创建ListItem的副本
  ListItem copyWith({String? id, String? content, int? usageCount}) {
    return ListItem(
      id: id ?? this.id,
      content: content ?? this.content,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  // 增加使用次数
  void incrementUsage() {
    usageCount++;
  }
}

class RandomList {
  String id;
  String name;
  List<ListItem> items;
  int usageCount;

  RandomList({
    required this.id,
    required this.name,
    required this.items,
    this.usageCount = 0,
  });

  // 从JSON转换为RandomList对象
  factory RandomList.fromJson(Map<String, dynamic> json) {
    var itemsList =
        (json['items'] as List).map((item) => ListItem.fromJson(item)).toList();

    return RandomList(
      id: json['id'],
      name: json['name'],
      items: itemsList,
      usageCount: json['usageCount'] ?? 0,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'usageCount': usageCount,
    };
  }

  // 创建RandomList的副本
  RandomList copyWith({
    String? id,
    String? name,
    List<ListItem>? items,
    int? usageCount,
  }) {
    return RandomList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  // 增加使用次数
  void incrementUsage() {
    usageCount++;
  }

  // 获取列表项数量
  int get itemCount => items.length;

  // 添加列表项
  void addItem(ListItem item) {
    items.add(item);
  }

  // 删除列表项
  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
  }

  // 更新列表项
  void updateItem(ListItem updatedItem) {
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
    }
  }

  // 随机选择一个列表项
  ListItem? getRandomItem() {
    if (items.isEmpty) return null;
    items.shuffle();
    return items.first;
  }
}

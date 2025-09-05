import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/list_model.dart';

class ListStorageService {
  static const String _listsKey = 'random_lists';

  // 保存所有列表
  Future<bool> saveLists(List<RandomList> lists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonLists = lists.map((list) => jsonEncode(list.toJson())).toList();
      return await prefs.setStringList(_listsKey, jsonLists);
    } catch (e) {
      print('保存列表失败: $e');
      return false;
    }
  }

  // 获取所有列表
  Future<List<RandomList>> getLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonLists = prefs.getStringList(_listsKey) ?? [];

      return jsonLists
          .map((jsonList) => RandomList.fromJson(jsonDecode(jsonList)))
          .toList();
    } catch (e) {
      print('获取列表失败: $e');
      return [];
    }
  }

  // 保存单个列表
  Future<bool> saveList(RandomList list) async {
    try {
      final lists = await getLists();
      final index = lists.indexWhere((item) => item.id == list.id);

      if (index != -1) {
        lists[index] = list;
      } else {
        lists.add(list);
      }

      return await saveLists(lists);
    } catch (e) {
      print('保存单个列表失败: $e');
      return false;
    }
  }

  // 删除列表
  Future<bool> deleteList(String listId) async {
    try {
      final lists = await getLists();
      lists.removeWhere((list) => list.id == listId);
      return await saveLists(lists);
    } catch (e) {
      print('删除列表失败: $e');
      return false;
    }
  }

  // 更新列表使用次数
  Future<bool> updateListUsage(String listId) async {
    try {
      final lists = await getLists();
      final index = lists.indexWhere((list) => list.id == listId);

      if (index != -1) {
        lists[index].incrementUsage();
        return await saveLists(lists);
      }
      return false;
    } catch (e) {
      print('更新列表使用次数失败: $e');
      return false;
    }
  }

  // 更新列表项使用次数
  Future<bool> updateListItemUsage(String listId, String itemId) async {
    try {
      final lists = await getLists();
      final listIndex = lists.indexWhere((list) => list.id == listId);

      if (listIndex != -1) {
        final itemIndex = lists[listIndex].items.indexWhere(
          (item) => item.id == itemId,
        );

        if (itemIndex != -1) {
          lists[listIndex].items[itemIndex].incrementUsage();
          return await saveLists(lists);
        }
      }
      return false;
    } catch (e) {
      print('更新列表项使用次数失败: $e');
      return false;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/list_model.dart';
import '../services/list_storage_service.dart';
import '../providers/history_provider.dart';

class ListProvider extends ChangeNotifier {
  final ListStorageService _storageService = ListStorageService();
  List<RandomList> _lists = [];
  RandomList? _selectedList;
  ListItem? _selectedItem;
  bool _isChoosing = false;
  bool _isLoading = true;

  // Getters
  List<RandomList> get lists => _lists;
  RandomList? get selectedList => _selectedList;
  ListItem? get selectedItem => _selectedItem;
  bool get isChoosing => _isChoosing;
  bool get isLoading => _isLoading;

  // 初始化加载列表
  Future<void> loadLists() async {
    _isLoading = true;
    notifyListeners();

    final lists = await _storageService.getLists();
    _lists = lists;
    _isLoading = false;

    // 如果之前选择了列表，尝试找到对应的列表
    if (_selectedList != null) {
      _selectedList = lists.firstWhere(
        (list) => list.id == _selectedList!.id,
        orElse: () {
          if (lists.isNotEmpty) {
            return lists.first;
          }
          return lists.first; // 返回第一个列表作为默认值
        },
      );
    } else if (lists.isNotEmpty) {
      // 默认选中第一个列表
      _selectedList = lists.first;
    }

    notifyListeners();
  }

  // 选择列表
  void selectList(RandomList list) {
    _selectedList = list;
    _selectedItem = null;
    _isChoosing = false;
    notifyListeners();
  }

  // 随机选择列表项
  Future<void> getRandomListItem(HistoryProvider? historyProvider) async {
    if (_selectedList == null || _selectedList!.items.isEmpty) {
      return;
    }

    // 更新列表使用次数
    await _storageService.updateListUsage(_selectedList!.id);

    // 随机选择一个项目
    final randomItem = _selectedList!.getRandomItem();
    if (randomItem != null) {
      // 更新项目使用次数
      await _storageService.updateListItemUsage(
        _selectedList!.id,
        randomItem.id,
      );

      _selectedItem = randomItem;
      _isChoosing = true;
      notifyListeners();
      
      // 添加历史记录
      if (historyProvider != null) {
        historyProvider.addListHistoryRecord(
          listId: _selectedList!.id,
          listName: _selectedList!.name,
          result: randomItem.text,
        );
      }
    }
  }

  // 重置选择
  void resetSelection() {
    _isChoosing = false;
    _selectedItem = null;
    notifyListeners();
  }

  // 切换选择状态
  void toggleSelection({HistoryProvider? historyProvider}) {
    if (_isChoosing) {
      resetSelection();
    } else {
      getRandomListItem(historyProvider);
    }
  }

  // 保存列表
  Future<bool> saveList(RandomList list) async {
    final result = await _storageService.saveList(list);
    if (result) {
      await loadLists(); // 重新加载列表以更新状态
    }
    return result;
  }

  // 删除列表
  Future<bool> deleteList(String listId) async {
    final result = await _storageService.deleteList(listId);
    if (result) {
      await loadLists(); // 重新加载列表以更新状态
    }
    return result;
  }
}
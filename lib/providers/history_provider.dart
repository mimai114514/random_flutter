import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/history_model.dart';
import '../services/history_storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryStorageService _storageService = HistoryStorageService();
  List<HistoryRecord> _historyRecords = [];
  bool _isLoading = true;

  // Getters
  List<HistoryRecord> get historyRecords => _historyRecords;
  List<NumberHistoryRecord> get numberHistoryRecords => 
      _historyRecords.whereType<NumberHistoryRecord>().toList();
  List<ListHistoryRecord> get listHistoryRecords => 
      _historyRecords.whereType<ListHistoryRecord>().toList();
  bool get isLoading => _isLoading;

  // 初始化加载历史记录
  Future<void> loadHistoryRecords() async {
    _isLoading = true;
    notifyListeners();

    final records = await _storageService.getHistoryRecords();
    _historyRecords = records;
    _isLoading = false;
    notifyListeners();
  }

  // 添加数字模式历史记录
  Future<bool> addNumberHistoryRecord({
    required int minValue,
    required int maxValue,
    required String result,
  }) async {
    final record = NumberHistoryRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      result: result,
      minValue: minValue,
      maxValue: maxValue,
    );

    final success = await _storageService.addHistoryRecord(record);
    if (success) {
      await loadHistoryRecords(); // 重新加载历史记录
    }
    return success;
  }

  // 添加列表模式历史记录
  Future<bool> addListHistoryRecord({
    required String listId,
    required String listName,
    required String result,
  }) async {
    final record = ListHistoryRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      result: result,
      listId: listId,
      listName: listName,
    );

    final success = await _storageService.addHistoryRecord(record);
    if (success) {
      await loadHistoryRecords(); // 重新加载历史记录
    }
    return success;
  }

  // 清除所有历史记录
  Future<bool> clearHistoryRecords() async {
    final success = await _storageService.clearHistoryRecords();
    if (success) {
      _historyRecords = [];
      notifyListeners();
    }
    return success;
  }
}
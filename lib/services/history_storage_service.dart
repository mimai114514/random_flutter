import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_model.dart';

class HistoryStorageService {
  static const String _historyKey = 'history_records';

  // 保存所有历史记录
  Future<bool> saveHistoryRecords(List<HistoryRecord> records) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonRecords = records.map((record) => jsonEncode(record.toJson())).toList();
      return await prefs.setStringList(_historyKey, jsonRecords);
    } catch (e) {
      print('保存历史记录失败: $e');
      return false;
    }
  }

  // 获取所有历史记录
  Future<List<HistoryRecord>> getHistoryRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonRecords = prefs.getStringList(_historyKey) ?? [];

      return jsonRecords
          .map((jsonRecord) => HistoryRecordFactory.fromJson(jsonDecode(jsonRecord)))
          .toList();
    } catch (e) {
      print('获取历史记录失败: $e');
      return [];
    }
  }

  // 添加历史记录
  Future<bool> addHistoryRecord(HistoryRecord record) async {
    try {
      final records = await getHistoryRecords();
      records.insert(0, record); // 在列表开头添加新记录
      
      // 限制历史记录数量，最多保存100条
      if (records.length > 100) {
        records.removeRange(100, records.length);
      }
      
      return await saveHistoryRecords(records);
    } catch (e) {
      print('添加历史记录失败: $e');
      return false;
    }
  }

  // 清除所有历史记录
  Future<bool> clearHistoryRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_historyKey);
    } catch (e) {
      print('清除历史记录失败: $e');
      return false;
    }
  }

  // 获取数字模式历史记录
  Future<List<NumberHistoryRecord>> getNumberHistoryRecords() async {
    try {
      final allRecords = await getHistoryRecords();
      return allRecords.whereType<NumberHistoryRecord>().toList();
    } catch (e) {
      print('获取数字模式历史记录失败: $e');
      return [];
    }
  }

  // 获取列表模式历史记录
  Future<List<ListHistoryRecord>> getListHistoryRecords() async {
    try {
      final allRecords = await getHistoryRecords();
      return allRecords.whereType<ListHistoryRecord>().toList();
    } catch (e) {
      print('获取列表模式历史记录失败: $e');
      return [];
    }
  }
}
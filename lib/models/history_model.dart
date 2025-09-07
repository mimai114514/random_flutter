import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'list_model.dart';

// 历史记录基类
abstract class HistoryRecord {
  final String id;
  final DateTime timestamp;
  final String result;

  HistoryRecord({
    required this.id,
    required this.timestamp,
    required this.result,
  });

  Map<String, dynamic> toJson();
  
  String get formattedTimestamp {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
           '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}

// 数字模式历史记录
class NumberHistoryRecord extends HistoryRecord {
  final int minValue;
  final int maxValue;

  NumberHistoryRecord({
    required String id,
    required DateTime timestamp,
    required String result,
    required this.minValue,
    required this.maxValue,
  }) : super(id: id, timestamp: timestamp, result: result);

  factory NumberHistoryRecord.fromJson(Map<String, dynamic> json) {
    return NumberHistoryRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      result: json['result'],
      minValue: json['minValue'],
      maxValue: json['maxValue'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'minValue': minValue,
      'maxValue': maxValue,
      'type': 'number',
    };
  }

  String get range => '$minValue-$maxValue';
}

// 列表模式历史记录
class ListHistoryRecord extends HistoryRecord {
  final String listId;
  final String listName;

  ListHistoryRecord({
    required String id,
    required DateTime timestamp,
    required String result,
    required this.listId,
    required this.listName,
  }) : super(id: id, timestamp: timestamp, result: result);

  factory ListHistoryRecord.fromJson(Map<String, dynamic> json) {
    return ListHistoryRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      result: json['result'],
      listId: json['listId'],
      listName: json['listName'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'result': result,
      'listId': listId,
      'listName': listName,
      'type': 'list',
    };
  }
}

// 历史记录工厂方法
class HistoryRecordFactory {
  static HistoryRecord fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    
    if (type == 'number') {
      return NumberHistoryRecord.fromJson(json);
    } else if (type == 'list') {
      return ListHistoryRecord.fromJson(json);
    } else {
      throw Exception('Unknown history record type: $type');
    }
  }
}
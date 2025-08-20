// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_flutter/hive_flutter.dart';

// Project imports:
import '../models/box_type_model.dart';
import '../models/database_data_model.dart';

class HiveService {
  static const Duration _loadTimeout = Duration(seconds: 30);

  Future<DatabaseTableData> loadBoxData(BoxType boxType) async {
    try {
      final boxData = await _loadHiveBox(boxType.key);
      return _convertToTableData(boxData);
    } catch (e) {
      debugPrint('Error loading box data for ${boxType.key}: $e');
      rethrow;
    }
  }

  Future<Map<dynamic, dynamic>> _loadHiveBox(String boxName) async {
    Box? box;
    try {
      // Close box if already open
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }

      // Open box with timeout
      box = await Hive.openBox(boxName).timeout(_loadTimeout);
      
      final Map<dynamic, dynamic> data = {};
      
      // Load all data from box
      for (var key in box.keys) {
        try {
          final value = box.get(key);
          if (value != null) {
            data[key] = value;
          }
        } catch (e) {
          debugPrint('Error reading key $key: $e');
          continue;
        }
      }
      
      return data;
    } finally {
      // Always close the box
      if (box != null && box.isOpen) {
        try {
          await box.close();
        } catch (e) {
          debugPrint('Error closing box: $e');
        }
      }
    }
  }

  DatabaseTableData _convertToTableData(Map<dynamic, dynamic> boxData) {
    final List<DatabaseRecord> records = [];
    final Set<String> allFields = {};

    boxData.forEach((key, value) {
      try {
        final Map<String, dynamic> recordData = {};
        
        if (value != null) {
          // Try to use toJson() method if available
          try {
            final jsonData = (value as dynamic).toJson();
            if (jsonData is Map<String, dynamic>) {
              recordData.addAll(jsonData);
              allFields.addAll(jsonData.keys);
            }
          } catch (e) {
            // Fallback: treat as simple value
            recordData['value'] = value.toString();
            allFields.add('value');
          }
        }

        final record = DatabaseRecord(
          id: key.toString(),
          data: recordData,
        );
        
        records.add(record);
      } catch (e) {
        debugPrint('Error converting record $key: $e');
      }
    });

    return DatabaseTableData(
      records: records,
      fields: allFields,
    );
  }

  Future<List<BoxInfo>> getAvailableBoxes() async {
    final List<BoxInfo> boxInfoList = [];
    
    for (BoxType boxType in BoxType.values) {
      try {
        final data = await loadBoxData(boxType);
        final boxInfo = BoxInfo(
          type: boxType,
          recordCount: data.totalRecords,
          fields: data.sortedFields,
          lastModified: DateTime.now(), // Could be enhanced to get actual last modified date
        );
        boxInfoList.add(boxInfo);
      } catch (e) {
        debugPrint('Error getting info for box ${boxType.key}: $e');
        // Add empty box info on error
        final boxInfo = BoxInfo(
          type: boxType,
          recordCount: 0,
          fields: [],
        );
        boxInfoList.add(boxInfo);
      }
    }
    
    return boxInfoList;
  }

  Future<bool> isBoxAvailable(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return true;
      }
      
      // Try to open and immediately close
      final box = await Hive.openBox(boxName).timeout(const Duration(seconds: 5));
      await box.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearBox(BoxType boxType) async {
    Box? box;
    try {
      if (Hive.isBoxOpen(boxType.key)) {
        await Hive.box(boxType.key).close();
      }
      
      box = await Hive.openBox(boxType.key);
      await box.clear();
    } finally {
      if (box != null && box.isOpen) {
        await box.close();
      }
    }
  }

  Future<int> getRecordCount(BoxType boxType) async {
    Box? box;
    try {
      if (Hive.isBoxOpen(boxType.key)) {
        await Hive.box(boxType.key).close();
      }
      
      box = await Hive.openBox(boxType.key);
      return box.length;
    } finally {
      if (box != null && box.isOpen) {
        await box.close();
      }
    }
  }
}

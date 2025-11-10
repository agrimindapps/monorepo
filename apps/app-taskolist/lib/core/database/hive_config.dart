import 'package:core/core.dart' hide Column;
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../services/task_priority_adapter.dart';
import '../services/task_status_adapter.dart';

class HiveConfig {
  static const int syncQueueItemTypeId = 6;
  static const int syncQueueTypeTypeId = 7;
  static const int syncOperationTypeTypeId = 8;

  static Future<void> initialize() async {
    if (kIsWeb) {
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
  }

  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk('tasks');
    await Hive.deleteBoxFromDisk('task_lists');
    await Hive.deleteBoxFromDisk('users');
    await Hive.deleteBoxFromDisk('settings');
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}

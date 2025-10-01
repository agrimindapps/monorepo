import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../services/task_priority_adapter.dart';
import '../services/task_status_adapter.dart';

class HiveConfig {
  // Type IDs para novos adapters
  static const int syncQueueItemTypeId = 6;
  static const int syncQueueTypeTypeId = 7;
  static const int syncOperationTypeTypeId = 8;

  static Future<void> initialize() async {
    // Inicializar Hive
    if (kIsWeb) {
      // Na web, não precisamos definir um diretório
      // O Hive usa IndexedDB automaticamente
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    // Registrar TypeAdapters (sem type parameters para evitar warnings de inferência)
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
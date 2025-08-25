import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/adapters/task_priority_adapter.dart';
import '../../data/adapters/task_status_adapter.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';

class HiveConfig {
  static Future<void> initialize() async {
    // Inicializar Hive
    if (kIsWeb) {
      // Na web, não precisamos definir um diretório
      // O Hive usa IndexedDB automaticamente
    } else {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    // Registrar TypeAdapters
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TaskStatusAdapter());
    }
    
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TaskPriorityAdapter());
    }
    
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(UserModelAdapter());
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
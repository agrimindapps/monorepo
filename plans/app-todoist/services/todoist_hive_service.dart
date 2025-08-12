// Project imports:
import '../../core/services/hive_service.dart';
import '../models/72_task_list.dart';
import '../models/73_user.dart';
import '../models/74_75_task_attachment.dart';
import '../models/76_task_comment.dart';
import '../models/task_model.dart';

// Adapters específicos do módulo app-todoist

/// Serviço de inicialização do Hive específico para o módulo app-todoist
class TodoistHiveService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Inicializa o Hive para o módulo app-todoist
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initializing Hive for app-todoist module

      // Garantir que o HiveService global está inicializado
      await HiveService().init();

      // Registrar adapters específicos do módulo app-todoist
      _registerTodoistAdapters();

      _isInitialized = true;
      // Hive initialized successfully for app-todoist
    } catch (e) {
      // Error initializing Hive for app-todoist: logged internally
      rethrow;
    }
  }

  /// Registra todos os adapters do módulo app-todoist
  static void _registerTodoistAdapters() {
    // Registering app-todoist adapters

    // Registrar adapters com typeIds específicos (70-76)
    HiveService.safeRegisterAdapter(TaskPriorityAdapter()); // typeId: 70
    HiveService.safeRegisterAdapter(TaskAdapter()); // typeId: 71
    HiveService.safeRegisterAdapter(TaskListAdapter()); // typeId: 72
    HiveService.safeRegisterAdapter(UserAdapter()); // typeId: 73
    HiveService.safeRegisterAdapter(AttachmentTypeAdapter()); // typeId: 74
    HiveService.safeRegisterAdapter(TaskAttachmentAdapter()); // typeId: 75
    HiveService.safeRegisterAdapter(TaskCommentAdapter()); // typeId: 76

    // All app-todoist adapters registered successfully
  }

  /// Informações de debug específicas do módulo
  static Map<String, dynamic> getDebugInfo() {
    return {
      'module': 'app-todoist',
      'isInitialized': _isInitialized,
      'adapters': [
        'TaskPriorityAdapter (70)',
        'TaskAdapter (71)',
        'TaskListAdapter (72)',
        'UserAdapter (73)',
        'AttachmentTypeAdapter (74)',
        'TaskAttachmentAdapter (75)',
        'TaskCommentAdapter (76)',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

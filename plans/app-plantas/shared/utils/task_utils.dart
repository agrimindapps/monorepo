// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../constants/care_type_const.dart';
import 'date_utils.dart';

/// Utilitários centralizados para tarefas de cuidado de plantas
/// Consolida funcionalidades dos TaskItemWidgets duplicados
class TaskUtils {
  /// Mapeamento de tipos de cuidado para ícones
  static const Map<String, IconData> _taskIcons = {
    'agua': Icons.water_drop_outlined,
    'adubo': Icons.eco_outlined,
    'banho_sol': Icons.wb_sunny_outlined,
    'inspecao_pragas': Icons.bug_report_outlined,
    'poda': Icons.content_cut_outlined,
    'replantio': Icons.grass_outlined,
  };

  /// Mapeamento de tipos de cuidado para cores
  static const Map<String, Color> _taskColors = {
    'agua': Color(0xFF2196F3),
    'adubo': Color(0xFF4CAF50),
    'banho_sol': Color(0xFFFF9800),
    'inspecao_pragas': Color(0xFFF44336),
    'poda': Color(0xFF9C27B0),
    'replantio': Color(0xFF795548),
  };

  /// Mapeamento de tipos de cuidado para títulos
  static const Map<String, String> _taskTitles = {
    'agua': 'Regar',
    'adubo': 'Adubar',
    'banho_sol': 'Banho de sol',
    'inspecao_pragas': 'Verificar pragas',
    'poda': 'Podar',
    'replantio': 'Replantar',
  };

  /// Ícone padrão para tipos não reconhecidos
  static const IconData _defaultIcon = Icons.task_outlined;

  /// Cor padrão para tipos não reconhecidos
  static const Color _defaultColor = Color(0xFF607D8B);

  /// Título padrão para tipos não reconhecidos
  static const String _defaultTitle = 'Cuidado';

  /// Lista de todos os tipos de cuidado disponíveis
  /// Usa CareType.allValidStrings para garantir consistência
  static List<String> get allTaskTypes => CareType.allValidStrings;

  /// Obtém o ícone para um tipo de cuidado
  static IconData getTaskIcon(String? tipoCuidado) {
    if (tipoCuidado == null) return _defaultIcon;

    final tipo = tipoCuidado.toLowerCase().trim();
    return _taskIcons[tipo] ?? _defaultIcon;
  }

  /// Obtém a cor para um tipo de cuidado
  static Color getTaskColor(String? tipoCuidado) {
    if (tipoCuidado == null) return _defaultColor;

    final tipo = tipoCuidado.toLowerCase().trim();
    return _taskColors[tipo] ?? _defaultColor;
  }

  /// Obtém o título para um tipo de cuidado
  static String getTaskTitle(String? tipoCuidado) {
    if (tipoCuidado == null) return _defaultTitle;

    final tipo = tipoCuidado.toLowerCase().trim();
    return _taskTitles[tipo] ?? _defaultTitle;
  }

  /// Verifica se uma tarefa está atrasada baseada na data
  static bool isTaskOverdue(DateTime? dataLimite) {
    return AppDateUtils.isOverdue(dataLimite);
  }

  /// Formata a data de uma tarefa com contexto apropriado
  static String formatTaskDate(DateTime? date, {bool? isOverdue}) {
    return AppDateUtils.formatTaskDate(date, isOverdue: isOverdue);
  }

  /// Formata a data de uma tarefa de forma simples (Até dd/MM ou Atrasado desde dd/MM)
  static String formatTaskDateSimple(DateTime? date, {bool? isOverdue}) {
    return AppDateUtils.formatTaskDateSimple(date, isOverdue: isOverdue);
  }

  /// Obtém informações completas de uma tarefa para renderização
  static TaskInfo getTaskInfo(String? tipoCuidado, DateTime? dataLimite) {
    final isOverdue = isTaskOverdue(dataLimite);

    return TaskInfo(
      icon: getTaskIcon(tipoCuidado),
      color: getTaskColor(tipoCuidado),
      title: getTaskTitle(tipoCuidado),
      dateText: formatTaskDate(dataLimite, isOverdue: isOverdue),
      isOverdue: isOverdue,
    );
  }

  /// Obtém a cor apropriada para o estado da tarefa (normal ou atrasada)
  static Color getTaskStateColor(
      String? tipoCuidado, DateTime? dataLimite, Map<String, Color> cores) {
    final isOverdue = isTaskOverdue(dataLimite);

    if (isOverdue) {
      return cores['erro'] ?? Colors.red;
    } else {
      return getTaskColor(tipoCuidado);
    }
  }

  /// Obtém a cor de fundo apropriada para o estado da tarefa
  static Color getTaskBackgroundColor(
      DateTime? dataLimite, Map<String, Color> cores) {
    final isOverdue = isTaskOverdue(dataLimite);

    if (isOverdue) {
      return cores['erroClaro'] ?? Colors.red.withValues(alpha: 0.1);
    } else {
      return cores['fundoCard'] ?? Colors.white;
    }
  }

  /// Obtém a cor da borda apropriada para o estado da tarefa
  static Color getTaskBorderColor(
      DateTime? dataLimite, Map<String, Color> cores) {
    final isOverdue = isTaskOverdue(dataLimite);

    if (isOverdue) {
      return (cores['erro'] ?? Colors.red).withValues(alpha: 0.3);
    } else {
      return cores['borda'] ?? Colors.grey;
    }
  }

  /// Valida se um tipo de cuidado é válido
  /// Usa CareType.isValidCareType para garantir consistência
  static bool isValidTaskType(String? tipoCuidado) {
    return CareType.isValidCareType(tipoCuidado);
  }

  /// Obtém lista de todos os tipos de cuidado disponíveis
  /// Usa CareType.allValidStrings para garantir consistência
  static List<String> getAllTaskTypes() {
    return CareType.allValidStrings;
  }

  /// Obtém mapa completo de tipo -> título para dropdowns
  static Map<String, String> getTaskTypeTitleMap() {
    return Map.from(_taskTitles);
  }

  /// Obtém mapa completo de tipo -> cor para interfaces
  static Map<String, Color> getTaskTypeColorMap() {
    return Map.from(_taskColors);
  }

  /// Obtém mapa completo de tipo -> ícone para interfaces
  static Map<String, IconData> getTaskTypeIconMap() {
    return Map.from(_taskIcons);
  }
}

/// Classe para armazenar informações completas de uma tarefa
class TaskInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String dateText;
  final bool isOverdue;

  const TaskInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.dateText,
    required this.isOverdue,
  });

  @override
  String toString() {
    return 'TaskInfo(title: $title, dateText: $dateText, isOverdue: $isOverdue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskInfo &&
        other.icon == icon &&
        other.color == color &&
        other.title == title &&
        other.dateText == dateText &&
        other.isOverdue == isOverdue;
  }

  @override
  int get hashCode {
    return icon.hashCode ^
        color.hashCode ^
        title.hashCode ^
        dateText.hashCode ^
        isOverdue.hashCode;
  }
}

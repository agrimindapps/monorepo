// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../config/lembrete_form_config.dart';

/// Utilitário específico para operações de tempo em lembretes
/// 
/// Separado do service para manter responsabilidades distintas
class LembreteTimeUtils {
  // Private constructor para prevenir instanciação
  LembreteTimeUtils._();

  /// Verifica se lembrete é hoje
  static bool isLembreteToday(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return LembreteFormConfig.isToday(dataHora);
  }

  /// Verifica se lembrete é amanhã
  static bool isLembreteTomorrow(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return LembreteFormConfig.isTomorrow(dataHora);
  }

  /// Verifica se lembrete está atrasado
  static bool isLembreteOverdue(LembreteVet lembrete) {
    if (lembrete.concluido) return false;
    
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return LembreteFormConfig.isPastDue(dataHora);
  }

  /// Calcula tempo até o lembrete
  static Duration getTimeUntilLembrete(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return LembreteFormConfig.getTimeUntil(dataHora);
  }

  /// Determina se deve agendar notificação
  static bool shouldScheduleNotification(LembreteVet lembrete) {
    if (lembrete.concluido) return false;
    
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return dataHora.isAfter(DateTime.now());
  }

  /// Gera descrição de tempo relativo para lembrete
  static String getRelativeTimeDescription(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final now = DateTime.now();
    final difference = dataHora.difference(now);

    if (lembrete.concluido) return 'Concluído';
    
    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return 'Atrasado há ${absDifference.inDays} dia${absDifference.inDays > 1 ? 's' : ''}';
      } else if (absDifference.inHours > 0) {
        return 'Atrasado há ${absDifference.inHours} hora${absDifference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Atrasado há ${absDifference.inMinutes} minuto${absDifference.inMinutes > 1 ? 's' : ''}';
      }
    } else {
      if (isLembreteToday(lembrete)) return 'Hoje';
      if (isLembreteTomorrow(lembrete)) return 'Amanhã';
      
      if (difference.inDays > 0) {
        return 'Em ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Em ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Em ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }

  /// Gera descrição curta para lembrete (usado em listas)
  static String getShortTimeDescription(LembreteVet lembrete) {
    if (lembrete.concluido) return '✅';
    
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final now = DateTime.now();
    final difference = dataHora.difference(now);

    if (difference.isNegative) {
      return '⏰'; // Atrasado
    } else if (isLembreteToday(lembrete)) {
      return 'Hoje';
    } else if (isLembreteTomorrow(lembrete)) {
      return 'Amanhã';
    } else if (difference.inDays <= 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}sem';
    }
  }

  /// Retorna cor sugerida baseada no status do lembrete
  static LembreteStatusColor getStatusColor(LembreteVet lembrete) {
    if (lembrete.concluido) {
      return LembreteStatusColor.completed;
    }
    
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final now = DateTime.now();
    final difference = dataHora.difference(now);

    if (difference.isNegative) {
      return LembreteStatusColor.overdue;
    } else if (difference.inHours <= 2) {
      return LembreteStatusColor.urgent;
    } else if (isLembreteToday(lembrete)) {
      return LembreteStatusColor.today;
    } else if (isLembreteTomorrow(lembrete)) {
      return LembreteStatusColor.tomorrow;
    } else {
      return LembreteStatusColor.future;
    }
  }

  /// Prioridade do lembrete baseada no tempo
  static LembretePriority getPriority(LembreteVet lembrete) {
    if (lembrete.concluido) {
      return LembretePriority.completed;
    }
    
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final now = DateTime.now();
    final difference = dataHora.difference(now);

    if (difference.isNegative) {
      return LembretePriority.overdue;
    } else if (difference.inHours <= 1) {
      return LembretePriority.critical;
    } else if (difference.inHours <= 6) {
      return LembretePriority.high;
    } else if (isLembreteToday(lembrete)) {
      return LembretePriority.medium;
    } else {
      return LembretePriority.low;
    }
  }

  /// Formata data e hora para exibição
  static String formatDateTime(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return '${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year} às ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}';
  }

  /// Formata apenas a data
  static String formatDate(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return '${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year}';
  }

  /// Formata apenas a hora
  static String formatTime(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return '${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}';
  }
}

/// Enum para cores de status do lembrete
enum LembreteStatusColor {
  completed,  // Verde - concluído
  overdue,    // Vermelho - atrasado
  urgent,     // Laranja - próximo (< 2h)
  today,      // Azul - hoje
  tomorrow,   // Azul claro - amanhã
  future,     // Cinza - futuro
}

/// Enum para prioridade do lembrete
enum LembretePriority {
  completed,  // Concluído
  overdue,    // Atrasado (prioridade máxima)
  critical,   // Crítico (< 1h)
  high,       // Alto (< 6h)
  medium,     // Médio (hoje)
  low,        // Baixo (futuro)
}

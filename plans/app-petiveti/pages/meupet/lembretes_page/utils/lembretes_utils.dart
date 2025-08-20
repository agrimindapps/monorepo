// Project imports:
import '../../../../models/14_lembrete_model.dart';

class LembretesUtils {
  static String formatDateToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatTimeToString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTimeToString(int timestamp) {
    return '${formatDateToString(timestamp)} às ${formatTimeToString(timestamp)}';
  }

  static String formatDateTimeToShortString(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (isSameDay(date, now)) {
      return 'Hoje às ${formatTimeToString(timestamp)}';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Amanhã às ${formatTimeToString(timestamp)}';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Ontem às ${formatTimeToString(timestamp)}';
    } else {
      return formatDateTimeToString(timestamp);
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isLembreteAtrasado(LembreteVet lembrete) {
    if (lembrete.concluido) return false;
    final now = DateTime.now();
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return dataHora.isBefore(now);
  }

  static bool isLembreteHoje(LembreteVet lembrete) {
    final now = DateTime.now();
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return isSameDay(dataHora, now);
  }

  static String formatarDataAtual() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  /// Gera lista de meses baseada nos registros de lembrete existentes
  static List<String> gerarListaMesesDisponiveis(List<LembreteVet> lembretes) {
    if (lembretes.isEmpty) {
      // Se não há registros, retorna o mês atual
      return [formatarDataAtual()];
    }

    // Ordena lembretes por data
    final sortedLembretes = List<LembreteVet>.from(lembretes)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    // Obtém data mais antiga e mais recente
    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.first.dataHora);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.last.dataHora);

    // Gera lista de meses entre as datas
    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = '${months[currentDate.month - 1]} ${currentDate.year.toString().substring(2)}';
      meses.add(mesFormatado);
      
      // Avança para o próximo mês
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Se o mês atual não está na lista, adiciona
    final mesAtual = formatarDataAtual();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList(); // Mais recente primeiro
  }

  /// Obtém o período de registros (mês mais antigo ao mais recente)
  static String formatarPeriodoLembretes(List<LembreteVet> lembretes) {
    if (lembretes.isEmpty) {
      return formatarDataAtual();
    }

    final sortedLembretes = List<LembreteVet>.from(lembretes)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.first.dataHora);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedLembretes.last.dataHora);

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    final mesInicial = '${months[dataInicial.month - 1]} ${dataInicial.year.toString().substring(2)}';
    final mesFinal = '${months[dataFinal.month - 1]} ${dataFinal.year.toString().substring(2)}';

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  static bool isLembreteAmanha(LembreteVet lembrete) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return isSameDay(dataHora, tomorrow);
  }

  static bool isLembreteUrgente(LembreteVet lembrete, {int hoursThreshold = 24}) {
    if (lembrete.concluido) return false;
    final now = DateTime.now();
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final threshold = now.add(Duration(hours: hoursThreshold));
    
    return dataHora.isAfter(now) && dataHora.isBefore(threshold);
  }

  static String getLembreteStatusText(LembreteVet lembrete) {
    if (lembrete.concluido) return 'Concluído';
    if (isLembreteAtrasado(lembrete)) return 'Atrasado';
    if (isLembreteHoje(lembrete)) return 'Hoje';
    if (isLembreteAmanha(lembrete)) return 'Amanhã';
    return 'Pendente';
  }

  static String getTempoRestante(LembreteVet lembrete) {
    if (lembrete.concluido) return 'Concluído';
    
    final now = DateTime.now();
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    final difference = dataHora.difference(now);
    
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
      if (difference.inDays > 0) {
        return 'Em ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Em ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'Em ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }

  static String getFormattedMonth() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 365) {
        final years = (absDifference.inDays / 365).floor();
        return 'há $years ano${years > 1 ? 's' : ''}';
      } else if (absDifference.inDays > 30) {
        final months = (absDifference.inDays / 30).floor();
        return 'há $months mês${months > 1 ? 'es' : ''}';
      } else if (absDifference.inDays > 0) {
        return 'há ${absDifference.inDays} dia${absDifference.inDays > 1 ? 's' : ''}';
      } else if (absDifference.inHours > 0) {
        return 'há ${absDifference.inHours} hora${absDifference.inHours > 1 ? 's' : ''}';
      } else {
        return 'há ${absDifference.inMinutes} minuto${absDifference.inMinutes > 1 ? 's' : ''}';
      }
    } else {
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return 'em $years ano${years > 1 ? 's' : ''}';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return 'em $months mês${months > 1 ? 'es' : ''}';
      } else if (difference.inDays > 0) {
        return 'em ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'em ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'em ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }

  static List<String> getTiposSuggestions() {
    return [
      'Consulta',
      'Vacina',
      'Medicamento',
      'Banho',
      'Tosa',
      'Exercício',
      'Alimentação',
      'Veterinário',
      'Exame',
      'Outro',
    ];
  }

  static List<String> getRepetirSuggestions() {
    return [
      'Não repetir',
      'Diário',
      'Semanal',
      'Quinzenal',
      'Mensal',
      'Trimestral',
      'Semestral',
      'Anual',
    ];
  }

  static DateTime? parseStringToDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) return null;
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static int dateTimeToMilliseconds(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  static DateTime millisecondsToDateTime(int milliseconds) {
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}

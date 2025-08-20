// Project imports:
import '../models/exercicio_model.dart';
import 'exercicio_cache_service.dart';

/// Service responsável por cálculos de estatísticas de exercícios
class ExercicioStatisticsService {
  
  /// Calcula totais de minutos e calorias para a semana atual
  Map<String, int> calcularTotaisSemana(List<ExercicioModel> registros) {
    // Verificar cache primeiro
    final cached = ExercicioCacheService.getCachedWeeklyTotals(registros);
    if (cached != null) {
      return cached;
    }

    final now = DateTime.now();
    final inicioSemana = _getInicioSemana(now);

    int minutos = 0;
    int calorias = 0;

    for (var registro in registros) {
      try {
        final dataRegistro = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        if (dataRegistro.isAfter(inicioSemana) || _isSameDay(dataRegistro, inicioSemana)) {
          minutos += registro.duracao;
          calorias += registro.caloriasQueimadas;
        }
      } catch (e) {
        // Ignorar registros com timestamp inválido
        continue;
      }
    }

    final result = {
      'minutos': minutos,
      'calorias': calorias,
    };

    // Cachear resultado
    ExercicioCacheService.setCachedWeeklyTotals(registros, result);
    return result;
  }

  /// Calcula totais para um período específico
  Map<String, int> calcularTotaisPeriodo(
    List<ExercicioModel> registros, 
    DateTime inicio, 
    DateTime fim
  ) {
    int minutos = 0;
    int calorias = 0;

    for (var registro in registros) {
      try {
        final dataRegistro = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        if (dataRegistro.isAfter(inicio) && dataRegistro.isBefore(fim.add(const Duration(days: 1)))) {
          minutos += registro.duracao;
          calorias += registro.caloriasQueimadas;
        }
      } catch (e) {
        continue;
      }
    }

    return {
      'minutos': minutos,
      'calorias': calorias,
    };
  }

  /// Verifica dias consecutivos de exercício
  bool verificarDiasConsecutivos(List<ExercicioModel> registros, int diasRequeridos) {
    // Verificar cache primeiro
    final cached = ExercicioCacheService.getCachedStreakValidation(registros, diasRequeridos);
    if (cached != null) {
      return cached;
    }

    if (registros.length < diasRequeridos) {
      ExercicioCacheService.setCachedStreakValidation(registros, diasRequeridos, false);
      return false;
    }

    // Converter timestamps para datas normalizadas e remover duplicatas
    final Set<DateTime> datasUnicas = {};
    for (var registro in registros) {
      try {
        final data = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        final dataNormalizada = DateTime(data.year, data.month, data.day);
        datasUnicas.add(dataNormalizada);
      } catch (e) {
        continue;
      }
    }

    if (datasUnicas.length < diasRequeridos) return false;

    // Ordenar datas da mais recente para mais antiga
    final List<DateTime> datasOrdenadas = datasUnicas.toList()
      ..sort((a, b) => b.compareTo(a));

    // Verificar sequência consecutiva a partir da data mais recente
    int diasConsecutivos = 1;
    DateTime dataAnterior = datasOrdenadas[0];

    for (int i = 1; i < datasOrdenadas.length; i++) {
      final dataAtual = datasOrdenadas[i];
      final diferencaDias = dataAnterior.difference(dataAtual).inDays;

      if (diferencaDias == 1) {
        diasConsecutivos++;
        if (diasConsecutivos >= diasRequeridos) return true;
      } else if (diferencaDias > 1) {
        diasConsecutivos = 1;
      }

      dataAnterior = dataAtual;
    }

    final result = diasConsecutivos >= diasRequeridos;
    
    // Cachear resultado
    ExercicioCacheService.setCachedStreakValidation(registros, diasRequeridos, result);
    return result;
  }

  /// Calcula estatísticas gerais
  Map<String, dynamic> calcularEstatisticasGerais(List<ExercicioModel> registros) {
    // Verificar cache primeiro
    final cached = ExercicioCacheService.getCachedGeneralStats(registros);
    if (cached != null) {
      return cached;
    }

    if (registros.isEmpty) {
      final emptyStats = {
        'totalMinutos': 0,
        'totalCalorias': 0,
        'totalSessoes': 0,
        'mediaDuracao': 0.0,
        'mediaCalorias': 0.0,
        'categoriaFavorita': '',
        'diasAtivos': 0,
      };
      ExercicioCacheService.setCachedGeneralStats(registros, emptyStats);
      return emptyStats;
    }

    int totalMinutos = 0;
    int totalCalorias = 0;
    final Set<DateTime> diasAtivos = {};
    final Map<String, int> categorias = {};

    for (var registro in registros) {
      try {
        totalMinutos += registro.duracao;
        totalCalorias += registro.caloriasQueimadas;
        
        final data = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        final dataNormalizada = DateTime(data.year, data.month, data.day);
        diasAtivos.add(dataNormalizada);

        categorias[registro.categoria] = (categorias[registro.categoria] ?? 0) + 1;
      } catch (e) {
        continue;
      }
    }

    String categoriaFavorita = '';
    int maxOcorrencias = 0;
    categorias.forEach((categoria, count) {
      if (count > maxOcorrencias) {
        maxOcorrencias = count;
        categoriaFavorita = categoria;
      }
    });

    final result = {
      'totalMinutos': totalMinutos,
      'totalCalorias': totalCalorias,
      'totalSessoes': registros.length,
      'mediaDuracao': totalMinutos / registros.length,
      'mediaCalorias': totalCalorias / registros.length,
      'categoriaFavorita': categoriaFavorita,
      'diasAtivos': diasAtivos.length,
    };

    // Cachear resultado
    ExercicioCacheService.setCachedGeneralStats(registros, result);
    return result;
  }

  /// Obtém dados para gráfico agrupados por dia
  Map<DateTime, Map<String, int>> getDadosGrafico(List<ExercicioModel> registros) {
    // Verificar cache primeiro
    final cached = ExercicioCacheService.getCachedChartData(registros);
    if (cached != null) {
      return cached;
    }

    final Map<DateTime, Map<String, int>> dadosDiarios = {};

    for (var registro in registros) {
      try {
        final data = DateTime.fromMillisecondsSinceEpoch(registro.dataRegistro);
        final dataNormalizada = DateTime(data.year, data.month, data.day);

        if (!dadosDiarios.containsKey(dataNormalizada)) {
          dadosDiarios[dataNormalizada] = {'minutos': 0, 'calorias': 0, 'sessoes': 0};
        }

        dadosDiarios[dataNormalizada]!['minutos'] = 
            (dadosDiarios[dataNormalizada]!['minutos'] ?? 0) + registro.duracao;
        dadosDiarios[dataNormalizada]!['calorias'] = 
            (dadosDiarios[dataNormalizada]!['calorias'] ?? 0) + registro.caloriasQueimadas;
        dadosDiarios[dataNormalizada]!['sessoes'] = 
            (dadosDiarios[dataNormalizada]!['sessoes'] ?? 0) + 1;
      } catch (e) {
        continue;
      }
    }

    // Cachear resultado
    ExercicioCacheService.setCachedChartData(registros, dadosDiarios);
    return dadosDiarios;
  }

  /// Calcula progresso em relação às metas
  Map<String, double> calcularProgressoMetas(
    List<ExercicioModel> registros,
    double metaMinutos,
    double metaCalorias,
  ) {
    final totaisSemana = calcularTotaisSemana(registros);
    
    return {
      'progressoMinutos': metaMinutos > 0 
          ? (totaisSemana['minutos']! / metaMinutos).clamp(0.0, 1.0)
          : 0.0,
      'progressoCalorias': metaCalorias > 0 
          ? (totaisSemana['calorias']! / metaCalorias).clamp(0.0, 1.0)
          : 0.0,
    };
  }

  /// Métodos auxiliares privados
  DateTime _getInicioSemana(DateTime data) {
    final diasParaSegunda = data.weekday - 1;
    final inicioSemana = data.subtract(Duration(days: diasParaSegunda));
    return DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

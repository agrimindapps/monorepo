// Project imports:
import '../constants/exercicio_constants.dart';
import '../models/achievement_model.dart';
import '../models/exercicio_model.dart';
import 'exercicio_statistics_service.dart';

/// Service responsável pelo sistema de conquistas de exercícios
class ExercicioAchievementService {
  final ExercicioStatisticsService _statisticsService = ExercicioStatisticsService();

  /// Lista de conquistas padrão
  static const List<Map<String, dynamic>> _conquistasPadrao = [
    {
      'id': 'primeiro_passo',
      'title': 'Primeiro Passo',
      'description': 'Registre seu primeiro exercício',
      'type': 'count',
      'target': 1,
      'metric': 'total_sessoes',
    },
    {
      'id': 'constancia',
      'title': 'Constância',
      'description': 'Registre exercícios em ${ExercicioConstants.conquistaDiasConsecutivos} dias consecutivos',
      'type': 'streak',
      'target': ExercicioConstants.conquistaDiasConsecutivos,
      'metric': 'dias_consecutivos',
    },
    {
      'id': 'queimando_calorias',
      'title': 'Queimando Calorias',
      'description': 'Queime mais de ${ExercicioConstants.conquistaCaloriasMeta} calorias em uma semana',
      'type': 'weekly',
      'target': ExercicioConstants.conquistaCaloriasMeta,
      'metric': 'calorias_semana',
    },
    {
      'id': 'meta_atingida',
      'title': 'Meta Atingida',
      'description': 'Atinja sua meta semanal de minutos de exercício',
      'type': 'goal',
      'target': 0, // Will be set based on user's goal
      'metric': 'minutos_semana',
    },
    {
      'id': 'dedicado',
      'title': 'Dedicado',
      'description': 'Complete ${ExercicioConstants.conquistaSessoesMeta} sessões de exercício',
      'type': 'count',
      'target': ExercicioConstants.conquistaSessoesMeta,
      'metric': 'total_sessoes',
    },
    {
      'id': 'atleta',
      'title': 'Atleta',
      'description': 'Acumule 20 horas de exercício',
      'type': 'count',
      'target': 1200, // 20 hours in minutes
      'metric': 'total_minutos',
    },
    {
      'id': 'versatil',
      'title': 'Versátil',
      'description': 'Pratique exercícios de pelo menos 5 categorias diferentes',
      'type': 'variety',
      'target': 5,
      'metric': 'categorias_diferentes',
    },
  ];

  /// Avalia todas as conquistas baseado nos registros atuais
  List<ExercicioAchievement> avaliarConquistas(
    List<ExercicioModel> registros,
    double metaMinutosSemanal,
    double metaCaloriasSemanal,
  ) {
    final estatisticas = _statisticsService.calcularEstatisticasGerais(registros);
    final totaisSemana = _statisticsService.calcularTotaisSemana(registros);
    final categorias = _getCategoriasDiferentes(registros);

    return _conquistasPadrao.map((conquista) {
      final isUnlocked = _avaliarConquista(
        conquista,
        registros,
        estatisticas,
        totaisSemana,
        categorias,
        metaMinutosSemanal,
        metaCaloriasSemanal,
      );

      return ExercicioAchievement(
        title: conquista['title'],
        description: conquista['description'],
        isUnlocked: isUnlocked,
      );
    }).toList();
  }

  /// Verifica conquistas recém desbloqueadas
  List<ExercicioAchievement> verificarNovasConquistas(
    List<ExercicioModel> registrosAntigos,
    List<ExercicioModel> registrosNovos,
    double metaMinutosSemanal,
    double metaCaloriasSemanal,
  ) {
    final conquistasAntigas = avaliarConquistas(
      registrosAntigos, 
      metaMinutosSemanal, 
      metaCaloriasSemanal
    );
    final conquistasNovas = avaliarConquistas(
      registrosNovos, 
      metaMinutosSemanal, 
      metaCaloriasSemanal
    );

    final novasConquistas = <ExercicioAchievement>[];

    for (int i = 0; i < conquistasNovas.length; i++) {
      final antiga = conquistasAntigas[i];
      final nova = conquistasNovas[i];

      if (!antiga.isUnlocked && nova.isUnlocked) {
        novasConquistas.add(nova);
      }
    }

    return novasConquistas;
  }

  /// Obtém progresso de uma conquista específica
  double getProgressoConquista(
    String conquistaId,
    List<ExercicioModel> registros,
    double metaMinutosSemanal,
    double metaCaloriasSemanal,
  ) {
    final conquista = _conquistasPadrao.firstWhere(
      (c) => c['id'] == conquistaId,
      orElse: () => {},
    );

    if (conquista.isEmpty) return 0.0;

    final estatisticas = _statisticsService.calcularEstatisticasGerais(registros);
    final totaisSemana = _statisticsService.calcularTotaisSemana(registros);

    final valorAtual = _getValorMetrica(
      conquista['metric'],
      registros,
      estatisticas,
      totaisSemana,
      metaMinutosSemanal,
      metaCaloriasSemanal,
    );

    final target = _getTarget(conquista, metaMinutosSemanal);
    
    return target > 0 ? (valorAtual / target).clamp(0.0, 1.0) : 0.0;
  }

  /// Avalia uma conquista específica
  bool _avaliarConquista(
    Map<String, dynamic> conquista,
    List<ExercicioModel> registros,
    Map<String, dynamic> estatisticas,
    Map<String, int> totaisSemana,
    Set<String> categorias,
    double metaMinutosSemanal,
    double metaCaloriasSemanal,
  ) {
    final type = conquista['type'];
    final target = _getTarget(conquista, metaMinutosSemanal);

    switch (type) {
      case 'count':
        final valorAtual = _getValorMetrica(
          conquista['metric'],
          registros,
          estatisticas,
          totaisSemana,
          metaMinutosSemanal,
          metaCaloriasSemanal,
        );
        return valorAtual >= target;

      case 'streak':
        return _statisticsService.verificarDiasConsecutivos(registros, target);

      case 'weekly':
        final metrica = conquista['metric'];
        if (metrica == 'calorias_semana') {
          return totaisSemana['calorias']! >= target;
        } else if (metrica == 'minutos_semana') {
          return totaisSemana['minutos']! >= target;
        }
        return false;

      case 'goal':
        final metrica = conquista['metric'];
        if (metrica == 'minutos_semana' && metaMinutosSemanal > 0) {
          return totaisSemana['minutos']! >= metaMinutosSemanal;
        } else if (metrica == 'calorias_semana' && metaCaloriasSemanal > 0) {
          return totaisSemana['calorias']! >= metaCaloriasSemanal;
        }
        return false;

      case 'variety':
        return categorias.length >= target;

      default:
        return false;
    }
  }

  /// Obtém o valor da métrica especificada
  double _getValorMetrica(
    String metrica,
    List<ExercicioModel> registros,
    Map<String, dynamic> estatisticas,
    Map<String, int> totaisSemana,
    double metaMinutosSemanal,
    double metaCaloriasSemanal,
  ) {
    switch (metrica) {
      case 'total_sessoes':
        return estatisticas['totalSessoes'].toDouble();
      case 'total_minutos':
        return estatisticas['totalMinutos'].toDouble();
      case 'total_calorias':
        return estatisticas['totalCalorias'].toDouble();
      case 'minutos_semana':
        return totaisSemana['minutos']!.toDouble();
      case 'calorias_semana':
        return totaisSemana['calorias']!.toDouble();
      case 'categorias_diferentes':
        return _getCategoriasDiferentes(registros).length.toDouble();
      default:
        return 0.0;
    }
  }

  /// Obtém o target da conquista
  int _getTarget(Map<String, dynamic> conquista, double metaMinutosSemanal) {
    if (conquista['id'] == 'meta_atingida') {
      return metaMinutosSemanal.toInt();
    }
    return conquista['target'];
  }

  /// Obtém todas as categorias diferentes dos registros
  Set<String> _getCategoriasDiferentes(List<ExercicioModel> registros) {
    return registros.map((r) => r.categoria).toSet();
  }

  /// Obtém dicas motivacionais baseadas no progresso
  List<String> getDicasMotivacionais(List<ExercicioModel> registros) {
    final estatisticas = _statisticsService.calcularEstatisticasGerais(registros);
    final dicas = <String>[];

    if (estatisticas['totalSessoes'] == 0) {
      dicas.add('Que tal começar com uma caminhada de 10 minutos?');
      dicas.add('O primeiro passo é sempre o mais importante!');
    } else if (estatisticas['totalSessoes'] < 5) {
      dicas.add('Você está no caminho certo! Continue assim.');
      dicas.add('Tente estabelecer uma rotina regular de exercícios.');
    } else {
      dicas.add('Parabéns pelo progresso! Você está formando um ótimo hábito.');
      dicas.add('Considere aumentar gradualmente a intensidade dos exercícios.');
    }

    if (estatisticas['categoriaFavorita'] != '') {
      dicas.add('Que tal experimentar exercícios de outras categorias também?');
    }

    return dicas;
  }
}

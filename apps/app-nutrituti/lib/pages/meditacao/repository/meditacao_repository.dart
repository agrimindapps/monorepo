// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../constants/meditacao_constants.dart';
import '../models/meditacao_achievement_model.dart';
import '../models/meditacao_model.dart';
import '../models/meditacao_stats_model.dart';

class MeditacaoRepository {
  // Chaves para armazenamento no SharedPreferences
  static const String _sessoesKey = 'meditacao_sessoes';
  static const String _statsKey = 'meditacao_stats';
  static const String _achievementsKey = 'meditacao_achievements';
  static const String _notificacoesKey = 'meditacao_notificacoes_habilitadas';
  static const String _notificacaoHoraKey = 'meditacao_notificacao_hora';
  static const String _notificacaoMinutoKey = 'meditacao_notificacao_minuto';

  // Definições de conquistas padrão
  final List<MeditacaoAchievementModel> _achievementsPadrao = [
    MeditacaoAchievementModel(
      id: 'first_session',
      titulo: 'Primeira Meditação',
      descricao: 'Complete sua primeira sessão de meditação',
      icone: 'self_improvement',
      conquistado: false,
    ),
    MeditacaoAchievementModel(
      id: 'week_streak',
      titulo: 'Sequência Semanal',
      descricao: 'Medite por ${MeditacaoConstants.conquistaDiasConsecutivos} dias consecutivos',
      icone: 'date_range',
      conquistado: false,
    ),
    MeditacaoAchievementModel(
      id: 'hour_milestone',
      titulo: 'Hora de Paz',
      descricao: 'Acumule ${MeditacaoConstants.conquistaTotalMinutos} minutos de meditação',
      icone: 'hourglass_full',
      conquistado: false,
    ),
    MeditacaoAchievementModel(
      id: 'variety',
      titulo: 'Explorador',
      descricao: 'Experimente todos os tipos de meditação',
      icone: 'explore',
      conquistado: false,
    ),
  ];

  // Obter todas as sessões de meditação
  Future<List<MeditacaoModel>> getSessoes() async {
    final prefs = await SharedPreferences.getInstance();
    final sessoesList = prefs.getStringList(_sessoesKey) ?? [];

    return sessoesList
        .map((e) => MeditacaoModel.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  // Salvar uma nova sessão de meditação
  Future<void> salvarSessao(MeditacaoModel sessao) async {
    final prefs = await SharedPreferences.getInstance();

    // Obter sessões existentes
    final sessoesList = prefs.getStringList(_sessoesKey) ?? [];

    // Adicionar nova sessão
    sessoesList.add(jsonEncode(sessao.toMap()));

    // Salvar a lista atualizada
    await prefs.setStringList(_sessoesKey, sessoesList);

    // Atualizar estatísticas
    await _atualizarEstatisticas(sessao);

    // Verificar conquistas
    await _verificarConquistas();
  }

  // Atualizar estatísticas após adicionar uma sessão
  Future<void> _atualizarEstatisticas(MeditacaoModel sessao) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    MeditacaoStatsModel stats;
    if (statsJson != null) {
      stats = MeditacaoStatsModel.fromMap(jsonDecode(statsJson) as Map<String, dynamic>);
    } else {
      stats = MeditacaoStatsModel();
    }

    final novasStats = stats.adicionarSessao(sessao.tipo, sessao.duracao);
    await prefs.setString(_statsKey, jsonEncode(novasStats.toMap()));
  }

  // Obter estatísticas da meditação
  Future<MeditacaoStatsModel> getEstatisticas() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      return MeditacaoStatsModel.fromMap(jsonDecode(statsJson) as Map<String, dynamic>);
    }

    return MeditacaoStatsModel();
  }

  // Obter conquistas
  Future<List<MeditacaoAchievementModel>> getConquistas() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);

    if (achievementsJson != null) {
      final List<dynamic> list = jsonDecode(achievementsJson) as List<dynamic>;
      return list.map((e) => MeditacaoAchievementModel.fromMap(e as Map<String, dynamic>)).toList();
    }

    // Retorna as conquistas padrão se não houver conquistas salvas
    await _salvarConquistas(_achievementsPadrao);
    return _achievementsPadrao;
  }

  // Salvar conquistas
  Future<void> _salvarConquistas(
      List<MeditacaoAchievementModel> conquistas) async {
    final prefs = await SharedPreferences.getInstance();
    final conquistasList = conquistas.map((e) => e.toMap()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(conquistasList));
  }

  // Verificar conquistas após uma nova sessão
  Future<List<MeditacaoAchievementModel>> _verificarConquistas() async {
    final conquistas = await getConquistas();
    final stats = await getEstatisticas();
    final List<MeditacaoAchievementModel> conquistasAtualizadas = [];
    bool foiAtualizado = false;

    for (var conquista in conquistas) {
      // Pular se já foi conquistada
      if (conquista.conquistado) {
        conquistasAtualizadas.add(conquista);
        continue;
      }

      bool concluida = false;

      // Verificar condições de cada conquista
      switch (conquista.id) {
        case 'first_session':
          concluida = stats.totalSessoes >= MeditacaoConstants.conquistaPrimeiraSessao;
          break;
        case 'week_streak':
          concluida = stats.sequenciaAtual >= MeditacaoConstants.conquistaDiasConsecutivos;
          break;
        case 'hour_milestone':
          concluida = stats.totalMinutos >= MeditacaoConstants.conquistaTotalMinutos;
          break;
        case 'variety':
          concluida = stats.tiposUsados.length >= MeditacaoConstants.conquistaTiposDiferentes;
          break;
      }

      // Se concluída, atualizar
      if (concluida) {
        conquistasAtualizadas.add(conquista.comoConcluido());
        foiAtualizado = true;
      } else {
        conquistasAtualizadas.add(conquista);
      }
    }

    // Salvar apenas se houve alterações
    if (foiAtualizado) {
      await _salvarConquistas(conquistasAtualizadas);
    }

    return conquistasAtualizadas;
  }

  // Verificar se há novas conquistas e retorná-las
  Future<List<MeditacaoAchievementModel>> getNovasConquistas() async {
    final List<MeditacaoAchievementModel> conquistas =
        await _verificarConquistas();

    // Filtrar apenas conquistas recentes (últimas 24 horas)
    final agora = DateTime.now();
    final ontem = agora.subtract(const Duration(hours: MeditacaoConstants.conquistasRecentesHoras));

    return conquistas.where((conquista) {
      return conquista.conquistado &&
          conquista.dataConquista != null &&
          conquista.dataConquista!.isAfter(ontem);
    }).toList();
  }

  // Métodos para gerenciar notificações
  Future<bool> getNotificacoesHabilitadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificacoesKey) ?? false;
  }

  Future<void> setNotificacoesHabilitadas(bool habilitado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificacoesKey, habilitado);
  }

  Future<Map<String, int>> getHorarioNotificacao() async {
    final prefs = await SharedPreferences.getInstance();
    final hora = prefs.getInt(_notificacaoHoraKey) ?? MeditacaoConstants.notificacaoHoraPadrao;
    final minuto = prefs.getInt(_notificacaoMinutoKey) ?? MeditacaoConstants.notificacaoMinutoPadrao;

    return {
      'hora': hora,
      'minuto': minuto,
    };
  }

  Future<void> setHorarioNotificacao(int hora, int minuto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificacaoHoraKey, hora);
    await prefs.setInt(_notificacaoMinutoKey, minuto);
  }
}

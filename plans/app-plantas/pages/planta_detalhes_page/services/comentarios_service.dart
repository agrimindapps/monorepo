// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/comentario_model.dart';
import '../../../repository/planta_repository.dart';
import 'concurrency_service.dart';

/// Service especializado para CRUD e validações de comentários
/// Centraliza toda lógica de manipulação de comentários com controle de concorrência
class ComentariosService {
  // Singleton pattern para otimização
  static ComentariosService? _instance;
  static ComentariosService get instance =>
      _instance ??= ComentariosService._();
  ComentariosService._();

  // ========== OPERAÇÕES CRUD ==========

  /// Adiciona novo comentário com validação e controle de concorrência
  Future<ComentarioOperationResult> adicionarComentario({
    required String plantaId,
    required String conteudo,
  }) async {
    // Usar debounce para evitar adições múltiplas rápidas
    return await ConcurrencyService.debounceAsync(
      'adicionar_comentario_$plantaId',
      const Duration(milliseconds: 500),
      () => _executarAdicaoComentario(plantaId, conteudo),
    );
  }

  /// Execução interna da adição de comentário
  Future<ComentarioOperationResult> _executarAdicaoComentario(
    String plantaId,
    String conteudo,
  ) async {
    return await ConcurrencyService.withLock('comentarios_$plantaId', () async {
      try {
        debugPrint(
            '💬 ComentariosService: Adicionando comentário para planta $plantaId');

        // Validar conteúdo
        final validationResult = _validarConteudoComentario(conteudo);
        if (!validationResult.isValid) {
          return ComentarioOperationResult(
            success: false,
            error: validationResult.errors.join(', '),
          );
        }

        // Criar novo comentário
        final novoComentario = ComentarioModel(
          id: _generateCommentId(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          conteudo: conteudo.trim(),
          dataCriacao: DateTime.now(),
        );

        // Adicionar à planta
        final result =
            await _adicionarComentarioNaPlanta(plantaId, novoComentario);

        if (result.success) {
          debugPrint('✅ ComentariosService: Comentário adicionado com sucesso');
          return ComentarioOperationResult(
            success: true,
            comentario: novoComentario,
          );
        } else {
          return result;
        }
      } catch (e) {
        debugPrint('❌ ComentariosService: Erro ao adicionar comentário: $e');
        return ComentarioOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Remove comentário específico
  Future<ComentarioOperationResult> removerComentario({
    required String plantaId,
    required ComentarioModel comentario,
  }) async {
    return await ConcurrencyService.withLock('comentarios_$plantaId', () async {
      try {
        debugPrint(
            '🗑️ ComentariosService: Iniciando remoção de comentário ${comentario.id} da planta $plantaId');

        final result = await _removerComentarioDaPlanta(plantaId, comentario);

        if (result.success) {
          debugPrint(
              '✅ ComentariosService: Comentário ${comentario.id} removido com sucesso');
        } else {
          debugPrint(
              '❌ ComentariosService: Falha ao remover comentário: ${result.error}');
        }

        return result;
      } catch (e) {
        debugPrint(
            '❌ ComentariosService: Exceção ao remover comentário ${comentario.id}: $e');
        return ComentarioOperationResult(
          success: false,
          error: 'Erro interno: $e',
        );
      }
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint(
            '⏰ ComentariosService: Timeout ao remover comentário ${comentario.id}');
        return ComentarioOperationResult(
          success: false,
          error: 'Operação demorou muito para ser concluída. Tente novamente.',
        );
      },
    );
  }

  /// Edita comentário existente
  Future<ComentarioOperationResult> editarComentario({
    required String plantaId,
    required ComentarioModel comentario,
    required String novoConteudo,
  }) async {
    return await ConcurrencyService.withLock('comentarios_$plantaId', () async {
      try {
        debugPrint(
            '✏️ ComentariosService: Editando comentário ${comentario.id}');

        // Validar novo conteúdo
        final validationResult = _validarConteudoComentario(novoConteudo);
        if (!validationResult.isValid) {
          return ComentarioOperationResult(
            success: false,
            error: validationResult.errors.join(', '),
          );
        }

        final comentarioEditado = comentario.copyWith(
          conteudo: novoConteudo.trim(),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        final result =
            await _atualizarComentarioNaPlanta(plantaId, comentarioEditado);

        if (result.success) {
          debugPrint('✅ ComentariosService: Comentário editado com sucesso');
          return ComentarioOperationResult(
            success: true,
            comentario: comentarioEditado,
          );
        } else {
          return result;
        }
      } catch (e) {
        debugPrint('❌ ComentariosService: Erro ao editar comentário: $e');
        return ComentarioOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  // ========== OPERAÇÕES DE CONSULTA ==========

  /// Obtém comentários ordenados de uma planta
  Future<List<ComentarioModel>> obterComentariosOrdenados(
      String plantaId) async {
    try {
      debugPrint(
          '📋 ComentariosService: Carregando comentários da planta $plantaId');

      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();
      final planta = await plantaRepo.findById(plantaId);

      if (planta?.comentarios == null) {
        return [];
      }

      final comentarios = List<ComentarioModel>.from(planta!.comentarios!);

      // Ordenar por data de criação (mais recentes primeiro)
      comentarios.sort((a, b) {
        final dateA =
            a.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(a.createdAt);
        final dateB =
            b.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(b.createdAt);
        return dateB.compareTo(dateA);
      });

      debugPrint(
          '✅ ComentariosService: ${comentarios.length} comentários carregados');
      return comentarios;
    } catch (e) {
      debugPrint('❌ ComentariosService: Erro ao carregar comentários: $e');
      return [];
    }
  }

  /// Conta comentários de uma planta
  Future<int> contarComentarios(String plantaId) async {
    try {
      final comentarios = await obterComentariosOrdenados(plantaId);
      return comentarios.length;
    } catch (e) {
      debugPrint('❌ ComentariosService: Erro ao contar comentários: $e');
      return 0;
    }
  }

  /// Busca comentários por conteúdo
  Future<List<ComentarioModel>> buscarComentarios({
    required String plantaId,
    required String query,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      final comentarios = await obterComentariosOrdenados(plantaId);
      final queryLower = query.toLowerCase().trim();

      return comentarios.where((comentario) {
        return comentario.conteudo.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      debugPrint('❌ ComentariosService: Erro na busca de comentários: $e');
      return [];
    }
  }

  // ========== OPERAÇÕES PRIVADAS ==========

  /// Adiciona comentário na planta via repository
  Future<ComentarioOperationResult> _adicionarComentarioNaPlanta(
    String plantaId,
    ComentarioModel comentario,
  ) async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();

      final planta = await plantaRepo.findById(plantaId);
      if (planta == null) {
        return ComentarioOperationResult(
          success: false,
          error: 'Planta não encontrada',
        );
      }

      final comentarios = List<ComentarioModel>.from(planta.comentarios ?? []);
      comentarios.add(comentario);

      final plantaAtualizada = planta.copyWith(
        comentarios: comentarios,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await plantaRepo.update(plantaId, plantaAtualizada);

      return ComentarioOperationResult(success: true);
    } catch (e) {
      return ComentarioOperationResult(
        success: false,
        error: 'Erro ao salvar comentário: $e',
      );
    }
  }

  /// Remove comentário da planta via repository
  Future<ComentarioOperationResult> _removerComentarioDaPlanta(
    String plantaId,
    ComentarioModel comentario,
  ) async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();

      final planta = await plantaRepo.findById(plantaId);
      if (planta == null) {
        return ComentarioOperationResult(
          success: false,
          error: 'Planta não encontrada',
        );
      }

      final comentarios = List<ComentarioModel>.from(planta.comentarios ?? []);
      comentarios.removeWhere((c) => c.id == comentario.id);

      final plantaAtualizada = planta.copyWith(
        comentarios: comentarios,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await plantaRepo.update(plantaId, plantaAtualizada);

      return ComentarioOperationResult(success: true);
    } catch (e) {
      return ComentarioOperationResult(
        success: false,
        error: 'Erro ao remover comentário: $e',
      );
    }
  }

  /// Atualiza comentário na planta via repository
  Future<ComentarioOperationResult> _atualizarComentarioNaPlanta(
    String plantaId,
    ComentarioModel comentarioEditado,
  ) async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();

      final planta = await plantaRepo.findById(plantaId);
      if (planta == null) {
        return ComentarioOperationResult(
          success: false,
          error: 'Planta não encontrada',
        );
      }

      final comentarios = List<ComentarioModel>.from(planta.comentarios ?? []);
      final index = comentarios.indexWhere((c) => c.id == comentarioEditado.id);

      if (index == -1) {
        return ComentarioOperationResult(
          success: false,
          error: 'Comentário não encontrado',
        );
      }

      comentarios[index] = comentarioEditado;

      final plantaAtualizada = planta.copyWith(
        comentarios: comentarios,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await plantaRepo.update(plantaId, plantaAtualizada);

      return ComentarioOperationResult(success: true);
    } catch (e) {
      return ComentarioOperationResult(
        success: false,
        error: 'Erro ao atualizar comentário: $e',
      );
    }
  }

  // ========== VALIDAÇÃO E UTILITÁRIOS ==========

  /// Valida conteúdo de comentário
  CommentValidationResult _validarConteudoComentario(String conteudo) {
    final errors = <String>[];

    // Validar conteúdo básico
    if (conteudo.trim().isEmpty) {
      errors.add('Comentário não pode estar vazio');
    }

    if (conteudo.trim().length < 2) {
      errors.add('Comentário deve ter pelo menos 2 caracteres');
    }

    if (conteudo.length > 500) {
      errors.add('Comentário muito longo (máximo 500 caracteres)');
    }

    // Validar caracteres especiais suspeitos (básico)
    if (conteudo.contains(RegExp(r'[<>{}]'))) {
      errors.add('Comentário contém caracteres não permitidos');
    }

    return CommentValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Gera ID único para comentário
  String _generateCommentId() {
    return 'comment_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Cancela operações pendentes para uma planta
  void cancelarOperacoesPendentes(String plantaId) {
    ConcurrencyService.cancelOperation('adicionar_comentario_$plantaId');
    ConcurrencyService.cancelOperation('comentarios_$plantaId');
    debugPrint(
        '🚫 ComentariosService: Operações canceladas para planta $plantaId');
  }

  // ========== MÉTRICAS E ESTATÍSTICAS ==========

  /// Obtém estatísticas dos comentários
  Future<ComentarioStatistics> obterEstatisticas(String plantaId) async {
    try {
      final comentarios = await obterComentariosOrdenados(plantaId);

      if (comentarios.isEmpty) {
        return ComentarioStatistics.empty();
      }

      final agora = DateTime.now();
      final ultimaSemana = agora.subtract(const Duration(days: 7));
      final ultimoMes = agora.subtract(const Duration(days: 30));

      final comentariosUltimaSemana = comentarios.where((c) {
        final data =
            c.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(c.createdAt);
        return data.isAfter(ultimaSemana);
      }).length;

      final comentariosUltimoMes = comentarios.where((c) {
        final data =
            c.dataCriacao ?? DateTime.fromMillisecondsSinceEpoch(c.createdAt);
        return data.isAfter(ultimoMes);
      }).length;

      final primeiroComentario = comentarios.last;
      final ultimoComentario = comentarios.first;

      return ComentarioStatistics(
        total: comentarios.length,
        ultimaSemana: comentariosUltimaSemana,
        ultimoMes: comentariosUltimoMes,
        primeiroComentario: primeiroComentario.dataCriacao ??
            DateTime.fromMillisecondsSinceEpoch(primeiroComentario.createdAt),
        ultimoComentario: ultimoComentario.dataCriacao ??
            DateTime.fromMillisecondsSinceEpoch(ultimoComentario.createdAt),
        mediaCaracteres:
            comentarios.map((c) => c.conteudo.length).reduce((a, b) => a + b) /
                comentarios.length,
      );
    } catch (e) {
      debugPrint('❌ ComentariosService: Erro ao obter estatísticas: $e');
      return ComentarioStatistics.empty();
    }
  }
}

// ========== CLASSES DE DADOS ==========

/// Resultado de operações com comentários
class ComentarioOperationResult {
  final bool success;
  final String? error;
  final ComentarioModel? comentario;

  ComentarioOperationResult({
    required this.success,
    this.error,
    this.comentario,
  });
}

/// Resultado de validação de comentário
class CommentValidationResult {
  final bool isValid;
  final List<String> errors;

  CommentValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}

/// Estatísticas de comentários
class ComentarioStatistics {
  final int total;
  final int ultimaSemana;
  final int ultimoMes;
  final DateTime? primeiroComentario;
  final DateTime? ultimoComentario;
  final double mediaCaracteres;

  ComentarioStatistics({
    required this.total,
    required this.ultimaSemana,
    required this.ultimoMes,
    this.primeiroComentario,
    this.ultimoComentario,
    required this.mediaCaracteres,
  });

  factory ComentarioStatistics.empty() {
    return ComentarioStatistics(
      total: 0,
      ultimaSemana: 0,
      ultimoMes: 0,
      mediaCaracteres: 0.0,
    );
  }

  String get resumo {
    if (total == 0) return 'Nenhum comentário';
    return '$total comentário(s), $ultimaSemana esta semana';
  }
}

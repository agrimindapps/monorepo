// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../database/espaco_model.dart';
import '../../../database/planta_config_model.dart';
import '../../../database/planta_model.dart';
import '../../../repository/espaco_repository.dart';
import '../../../repository/planta_config_repository.dart';
import '../../../repository/planta_repository.dart';
import 'concurrency_service.dart';

/// Service especializado para operações complexas com dados da planta
/// Centraliza toda lógica de carregamento, sincronização e integridade
class PlantaDetalhesService {
  // Singleton pattern para otimização
  static PlantaDetalhesService? _instance;
  static PlantaDetalhesService get instance =>
      _instance ??= PlantaDetalhesService._();
  PlantaDetalhesService._();

  // ========== OPERAÇÕES DE CARREGAMENTO ==========

  /// Carrega todos os dados relacionados à planta de forma otimizada
  Future<PlantaDetalhesData> carregarDadosCompletos(String plantaId) async {
    return await ConcurrencyService.withLock('carregar_dados_$plantaId',
        () async {
      debugPrint(
          '🔄 PlantaDetalhesService: Carregando dados completos para planta $plantaId');

      try {
        // Carregar dados em paralelo com timeout para melhor performance
        final results = await ConcurrencyService.executeWithTimeout([
          _carregarConfiguracoes(plantaId),
          _carregarEspaco(plantaId),
          _buscarPlantaAtualizada(plantaId),
        ], const Duration(seconds: 30));

        final configuracoes = results[0] as PlantaConfigModel?;
        final espaco = results[1] as EspacoModel?;
        final plantaAtualizada = results[2] as PlantaModel?;

        debugPrint('✅ PlantaDetalhesService: Dados carregados com sucesso');

        return PlantaDetalhesData(
          planta: plantaAtualizada,
          configuracoes: configuracoes,
          espaco: espaco,
          success: true,
        );
      } catch (e) {
        debugPrint('❌ PlantaDetalhesService: Erro ao carregar dados: $e');
        return PlantaDetalhesData(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Carrega configurações específicas da planta
  Future<PlantaConfigModel?> _carregarConfiguracoes(String plantaId) async {
    try {
      final configRepo = PlantaConfigRepository.instance;
      await configRepo.initialize();
      final config = await configRepo.findByPlantaId(plantaId);
      debugPrint('✅ PlantaDetalhesService: Configurações carregadas');
      return config;
    } catch (e) {
      debugPrint('❌ PlantaDetalhesService: Erro ao carregar configurações: $e');
      return null;
    }
  }

  /// Carrega dados do espaço da planta
  Future<EspacoModel?> _carregarEspaco(String plantaId) async {
    try {
      // Primeiro precisamos buscar a planta para obter o espacoId
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();
      final planta = await plantaRepo.findById(plantaId);

      if (planta?.espacoId == null) {
        debugPrint(
            'ℹ️ PlantaDetalhesService: Planta não possui espaço definido');
        return null;
      }

      final espacoRepo = EspacoRepository.instance;
      await espacoRepo.initialize();
      final espaco = await espacoRepo.findById(planta!.espacoId!);
      debugPrint('✅ PlantaDetalhesService: Espaço carregado: ${espaco?.nome}');
      return espaco;
    } catch (e) {
      debugPrint('❌ PlantaDetalhesService: Erro ao carregar espaço: $e');
      return null;
    }
  }

  /// Busca versão atualizada da planta
  Future<PlantaModel?> _buscarPlantaAtualizada(String plantaId) async {
    try {
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();
      final planta = await plantaRepo.findById(plantaId);
      debugPrint('✅ PlantaDetalhesService: Planta atualizada encontrada');
      return planta;
    } catch (e) {
      debugPrint(
          '❌ PlantaDetalhesService: Erro ao buscar planta atualizada: $e');
      return null;
    }
  }

  // ========== OPERAÇÕES DE ATUALIZAÇÃO ==========

  /// Atualiza dados da planta com validação
  Future<PlantOperationResult> atualizarPlanta(PlantaModel planta) async {
    return await ConcurrencyService.withLock('atualizar_planta_${planta.id}',
        () async {
      try {
        debugPrint(
            '🔄 PlantaDetalhesService: Atualizando planta ${planta.nome}');

        final plantaRepo = PlantaRepository.instance;
        await plantaRepo.initialize();

        // Validar dados antes da atualização
        final validationResult = _validarDadosPlanta(planta);
        if (!validationResult.isValid) {
          return PlantOperationResult(
            success: false,
            error: 'Dados inválidos: ${validationResult.errors.join(', ')}',
          );
        }

        // Atualizar com timeout
        await ConcurrencyService.executeWithTimeout([
          plantaRepo.update(planta.id, planta),
        ], const Duration(seconds: 20));

        debugPrint('✅ PlantaDetalhesService: Planta atualizada com sucesso');
        return PlantOperationResult(success: true);
      } catch (e) {
        debugPrint('❌ PlantaDetalhesService: Erro ao atualizar planta: $e');
        return PlantOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  /// Remove planta com todas as dependências
  Future<PlantOperationResult> removerPlanta(String plantaId) async {
    return await ConcurrencyService.withLock('remover_planta_$plantaId',
        () async {
      try {
        debugPrint('🗑️ PlantaDetalhesService: Removendo planta $plantaId');

        // Remover com timeout
        await ConcurrencyService.executeWithTimeout([
          () async {
            final plantaRepo = PlantaRepository.instance;
            await plantaRepo.initialize();
            await plantaRepo.delete(plantaId);
          }(),
        ], const Duration(seconds: 20));

        debugPrint('✅ PlantaDetalhesService: Planta removida com sucesso');
        return PlantOperationResult(success: true);
      } catch (e) {
        debugPrint('❌ PlantaDetalhesService: Erro ao remover planta: $e');
        return PlantOperationResult(
          success: false,
          error: e.toString(),
        );
      }
    });
  }

  // ========== OPERAÇÕES DE SINCRONIZAÇÃO ==========

  /// Força sincronização completa dos dados
  Future<PlantaDetalhesData> sincronizarDados(String plantaId) async {
    debugPrint(
        '🔄 PlantaDetalhesService: Forçando sincronização para planta $plantaId');

    // Cancelar operações pendentes antes de sincronizar
    ConcurrencyService.cancelOperation('carregar_dados_$plantaId');

    // Recarregar todos os dados
    return await carregarDadosCompletos(plantaId);
  }

  /// Verifica integridade dos dados da planta
  Future<IntegrityCheckResult> verificarIntegridade(String plantaId) async {
    try {
      debugPrint(
          '🔍 PlantaDetalhesService: Verificando integridade da planta $plantaId');

      final issues = <String>[];
      final warnings = <String>[];

      // Verificar se planta existe
      final plantaRepo = PlantaRepository.instance;
      await plantaRepo.initialize();
      final planta = await plantaRepo.findById(plantaId);

      if (planta == null) {
        issues.add('Planta não encontrada');
        return IntegrityCheckResult(
          isValid: false,
          issues: issues,
          warnings: warnings,
        );
      }

      // Verificar referências
      if (planta.espacoId != null) {
        final espacoRepo = EspacoRepository.instance;
        await espacoRepo.initialize();
        final espaco = await espacoRepo.findById(planta.espacoId!);
        if (espaco == null) {
          warnings.add('Espaço referenciado não existe mais');
        }
      }

      // Verificar configurações
      final configRepo = PlantaConfigRepository.instance;
      await configRepo.initialize();
      final config = await configRepo.findByPlantaId(plantaId);
      if (config == null) {
        warnings.add('Planta não possui configurações de cuidados');
      }

      debugPrint(
          '✅ PlantaDetalhesService: Verificação concluída - ${issues.length} problemas, ${warnings.length} avisos');

      return IntegrityCheckResult(
        isValid: issues.isEmpty,
        issues: issues,
        warnings: warnings,
      );
    } catch (e) {
      debugPrint(
          '❌ PlantaDetalhesService: Erro na verificação de integridade: $e');
      return IntegrityCheckResult(
        isValid: false,
        issues: ['Erro na verificação: $e'],
      );
    }
  }

  // ========== MÉTODOS UTILITÁRIOS PRIVADOS ==========

  /// Valida dados da planta antes de operações
  ValidationResult _validarDadosPlanta(PlantaModel planta) {
    final errors = <String>[];

    if (planta.nome == null || planta.nome!.trim().isEmpty) {
      errors.add('Nome da planta é obrigatório');
    }

    if (planta.nome != null && planta.nome!.length > 100) {
      errors.add('Nome da planta muito longo (máximo 100 caracteres)');
    }

    if (planta.especie != null && planta.especie!.length > 150) {
      errors.add('Nome da espécie muito longo (máximo 150 caracteres)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Cancela todas as operações pendentes para uma planta
  void cancelarOperacoesPendentes(String plantaId) {
    ConcurrencyService.cancelOperation('carregar_dados_$plantaId');
    ConcurrencyService.cancelOperation('atualizar_planta_$plantaId');
    ConcurrencyService.cancelOperation('remover_planta_$plantaId');
    debugPrint(
        '🚫 PlantaDetalhesService: Operações canceladas para planta $plantaId');
  }
}

// ========== CLASSES DE DADOS ==========

/// Dados completos de uma planta para exibição
class PlantaDetalhesData {
  final PlantaModel? planta;
  final PlantaConfigModel? configuracoes;
  final EspacoModel? espaco;
  final bool success;
  final String? error;

  PlantaDetalhesData({
    this.planta,
    this.configuracoes,
    this.espaco,
    required this.success,
    this.error,
  });

  bool get hasData => planta != null;
  bool get hasConfiguracoes => configuracoes != null;
  bool get hasEspaco => espaco != null;
}

/// Resultado de operações com plantas
class PlantOperationResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;

  PlantOperationResult({
    required this.success,
    this.error,
    this.data,
  });
}

/// Resultado de verificação de integridade
class IntegrityCheckResult {
  final bool isValid;
  final List<String> issues;
  final List<String> warnings;

  IntegrityCheckResult({
    required this.isValid,
    this.issues = const [],
    this.warnings = const [],
  });

  String get summary {
    if (isValid && warnings.isEmpty) {
      return 'Dados íntegros';
    } else if (isValid) {
      return '${warnings.length} aviso(s) encontrado(s)';
    } else {
      return '${issues.length} problema(s) crítico(s)';
    }
  }
}

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
  });
}

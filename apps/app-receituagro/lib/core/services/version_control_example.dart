import 'dart:developer' as developer;
import 'app_data_manager.dart';
import 'auto_version_control_service.dart';

/// Exemplo de uso do sistema de controle automático de versão
/// Este arquivo demonstra como usar o novo sistema em diferentes cenários
class VersionControlExample {
  late final AppDataManager _appDataManager;
  late final AutoVersionControlService _versionControlService;

  VersionControlExample() {
    _appDataManager = AppDataManager();
  }

  /// Exemplo 1: Inicialização normal da aplicação
  /// Este é o fluxo que deve ser executado no main.dart ou bootstrap
  Future<void> exampleNormalStartup() async {
    try {
      developer.log('=== EXEMPLO: Inicialização Normal ===', name: 'VersionControlExample');
      
      // Inicializa o sistema completo (incluindo controle de versão automático)
      final result = await _appDataManager.initialize();
      
      result.fold(
        (error) {
          developer.log('❌ Erro na inicialização: $error', name: 'VersionControlExample');
        },
        (_) {
          developer.log('✅ Sistema inicializado com sucesso!', name: 'VersionControlExample');
        },
      );

      // Obtém estatísticas do sistema
      final stats = await _appDataManager.getDataStats();
      developer.log('📊 Estatísticas do sistema: $stats', name: 'VersionControlExample');

    } catch (e) {
      developer.log('💥 Erro crítico no exemplo: $e', name: 'VersionControlExample');
    }
  }

  /// Exemplo 2: Verificação manual de versão
  /// Útil para debug ou telas de configuração
  Future<void> exampleManualVersionCheck() async {
    try {
      developer.log('=== EXEMPLO: Verificação Manual ===', name: 'VersionControlExample');
      
      await _appDataManager.initialize();
      _versionControlService = _appDataManager.versionControlService;

      // Verifica se controle de versão é necessário
      final isNeeded = await _versionControlService.isVersionControlNeeded();
      developer.log('🔍 Controle de versão necessário: $isNeeded', name: 'VersionControlExample');

      // Executa dry-run para ver o que aconteceria
      final dryRunResult = await _versionControlService.performDryRun();
      developer.log('🧪 Dry-run result: ${dryRunResult.toString()}', name: 'VersionControlExample');

      // Obtém status completo do sistema
      final systemStatus = await _versionControlService.getSystemStatus();
      developer.log('🖥️ Status do sistema: $systemStatus', name: 'VersionControlExample');

    } catch (e) {
      developer.log('💥 Erro no exemplo manual: $e', name: 'VersionControlExample');
    }
  }

  /// Exemplo 3: Recarregamento forçado
  /// Útil para desenvolvimento ou quando usuário quer forçar atualização
  Future<void> exampleForcedReload() async {
    try {
      developer.log('=== EXEMPLO: Recarregamento Forçado ===', name: 'VersionControlExample');
      
      await _appDataManager.initialize();
      
      // Força recarregamento completo
      final result = await _appDataManager.forceReloadData();
      
      result.fold(
        (error) {
          developer.log('❌ Erro no recarregamento forçado: $error', name: 'VersionControlExample');
        },
        (_) {
          developer.log('✅ Recarregamento forçado concluído!', name: 'VersionControlExample');
        },
      );

    } catch (e) {
      developer.log('💥 Erro no exemplo de recarregamento: $e', name: 'VersionControlExample');
    }
  }

  /// Exemplo 4: Reimportação de categoria específica
  /// Útil para correção de dados específicos
  Future<void> exampleSpecificCategoryReimport() async {
    try {
      developer.log('=== EXEMPLO: Reimportação Específica ===', name: 'VersionControlExample');
      
      await _appDataManager.initialize();
      _versionControlService = _appDataManager.versionControlService;

      // Reimporta apenas culturas
      final result = await _versionControlService.reimportSpecificCategory('tbculturas');
      
      result.fold(
        (error) {
          developer.log('❌ Erro na reimportação de culturas: $error', name: 'VersionControlExample');
        },
        (count) {
          developer.log('✅ Culturas reimportadas com sucesso: $count registros', name: 'VersionControlExample');
        },
      );

    } catch (e) {
      developer.log('💥 Erro no exemplo de reimportação específica: $e', name: 'VersionControlExample');
    }
  }

  /// Exemplo 5: Monitoramento com callback de progresso
  /// Mostra como implementar loading screens durante importação
  Future<void> exampleWithProgressMonitoring() async {
    try {
      developer.log('=== EXEMPLO: Monitoramento de Progresso ===', name: 'VersionControlExample');
      
      await _appDataManager.initialize();
      _versionControlService = _appDataManager.versionControlService;

      // Executa controle de versão com callbacks de progresso
      final result = await _versionControlService.executeVersionControl(
        onProgress: (stage, message, progress) {
          // Este callback pode ser usado para atualizar uma UI de loading
          developer.log(
            '📊 [$stage] $message - ${(progress * 100).toStringAsFixed(1)}%', 
            name: 'VersionControlExample'
          );
          
          // Exemplos de como usar em diferentes estágios:
          switch (stage) {
            case 'Verificação':
              // Mostrar: "Verificando versão..."
              break;
            case 'Limpeza':
              // Mostrar: "Limpando dados antigos..."
              break;
            case 'Importação':
              // Mostrar: "Carregando [categoria]..."
              break;
            case 'Finalizando':
              // Mostrar: "Finalizando..."
              break;
            case 'Concluído':
              // Mostrar: "Processo concluído!"
              break;
          }
        },
      );

      result.fold(
        (error) {
          developer.log('❌ Erro com monitoramento: $error', name: 'VersionControlExample');
        },
        (versionResult) {
          developer.log('✅ Processo monitorado concluído: ${versionResult.toString()}', 
            name: 'VersionControlExample');
        },
      );

    } catch (e) {
      developer.log('💥 Erro no exemplo de monitoramento: $e', name: 'VersionControlExample');
    }
  }

  /// Exemplo 6: Simulação de mudança de versão
  /// Para testar o comportamento do sistema
  Future<void> exampleVersionChangeSimulation() async {
    try {
      developer.log('=== EXEMPLO: Simulação de Mudança de Versão ===', name: 'VersionControlExample');
      
      await _appDataManager.initialize();
      _versionControlService = _appDataManager.versionControlService;

      // Força uma "mudança de versão" limpando as informações
      final result = await _versionControlService.forceVersionControl(
        onProgress: (stage, message, progress) {
          developer.log('🔄 [$stage] $message (${(progress * 100).toInt()}%)', 
            name: 'VersionControlExample');
        },
      );

      result.fold(
        (error) {
          developer.log('❌ Erro na simulação: $error', name: 'VersionControlExample');
        },
        (versionResult) {
          developer.log('✅ Simulação concluída: ${versionResult.toString()}', 
            name: 'VersionControlExample');
          
          // Mostra detalhes da simulação
          final details = versionResult.details;
          developer.log('📋 Detalhes da simulação:', name: 'VersionControlExample');
          developer.log('   - Ação tomada: ${versionResult.actionTaken}', name: 'VersionControlExample');
          developer.log('   - Tempo de execução: ${versionResult.executionTime}', name: 'VersionControlExample');
          developer.log('   - Primeira execução: ${details['is_first_run']}', name: 'VersionControlExample');
          developer.log('   - Versão mudou: ${details['version_changed']}', name: 'VersionControlExample');
        },
      );

    } catch (e) {
      developer.log('💥 Erro na simulação: $e', name: 'VersionControlExample');
    }
  }

  /// Executa todos os exemplos em sequência
  Future<void> runAllExamples() async {
    developer.log('🚀 Iniciando todos os exemplos do sistema de controle de versão...', 
      name: 'VersionControlExample');

    await exampleNormalStartup();
    await Future.delayed(const Duration(seconds: 1));

    await exampleManualVersionCheck();
    await Future.delayed(const Duration(seconds: 1));

    await exampleWithProgressMonitoring();
    await Future.delayed(const Duration(seconds: 1));

    await exampleSpecificCategoryReimport();
    await Future.delayed(const Duration(seconds: 1));

    await exampleVersionChangeSimulation();
    await Future.delayed(const Duration(seconds: 1));

    await exampleForcedReload();

    developer.log('🎉 Todos os exemplos executados!', name: 'VersionControlExample');
  }

  /// Cleanup de recursos
  Future<void> dispose() async {
    await _appDataManager.dispose();
  }
}

/// Função utilitária para executar exemplos em main.dart
Future<void> runVersionControlExamples() async {
  final example = VersionControlExample();
  
  try {
    await example.runAllExamples();
  } finally {
    await example.dispose();
  }
}
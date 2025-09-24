import 'package:flutter/foundation.dart';
import 'core/di/injection_container.dart' as di;
import 'core/repositories/diagnostico_hive_repository.dart';
import 'core/services/diagnosticos_data_loader.dart';

/// Script de debug para verificar status dos diagnósticos
class DiagnosticosDebug {
  /// Função principal de debug - chame esta função para verificar tudo
  static Future<void> checkStatus() async {
    try {
      debugPrint('🔍 [DEBUG] ===== VERIFICAÇÃO DE DIAGNÓSTICOS =====');
      
      // 1. Verificar repository
      final repository = di.sl<DiagnosticoHiveRepository>();
      final allDiagnosticos = repository.getAll();
      debugPrint('📊 [DEBUG] Diagnósticos no repository: ${allDiagnosticos.length}');
      
      if (allDiagnosticos.isEmpty) {
        debugPrint('⚠️ [DEBUG] Box vazia! Tentando forçar carregamento...');
        
        // 2. Tentar carregar
        await DiagnosticosDataLoader.forceReload();
        
        // 3. Verificar novamente
        final newCount = repository.getAll().length;
        debugPrint('📊 [DEBUG] Após reload: $newCount diagnósticos');
        
        if (newCount > 0) {
          debugPrint('✅ [DEBUG] Sucesso! Carregamento funcionou');
          _showSample(repository);
        } else {
          debugPrint('❌ [DEBUG] Falha! Ainda 0 diagnósticos');
          await _debugLoadingProcess();
        }
      } else {
        debugPrint('✅ [DEBUG] Box tem dados!');
        _showSample(repository);
      }
      
      debugPrint('🔍 [DEBUG] ===== FIM DA VERIFICAÇÃO =====');
    } catch (e) {
      debugPrint('❌ [DEBUG] Erro: $e');
    }
  }
  
  /// Mostra sample dos dados
  static void _showSample(DiagnosticoHiveRepository repository) {
    final sample = repository.getAll().take(5).toList();
    debugPrint('📋 [DEBUG] SAMPLE (5 primeiros):');
    for (int i = 0; i < sample.length; i++) {
      final diag = sample[i];
      debugPrint('  [$i] fkIdDefensivo: "${diag.fkIdDefensivo}"');
      debugPrint('      nomeDefensivo: "${diag.nomeDefensivo}"');
      debugPrint('      nomeCultura: "${diag.nomeCultura}"');
      debugPrint('      nomePraga: "${diag.nomePraga}"');
    }
  }
  
  /// Debug do processo de carregamento
  static Future<void> _debugLoadingProcess() async {
    try {
      debugPrint('🔧 [DEBUG] Debugando processo de carregamento...');
      
      // Verificar stats do loader
      final stats = await DiagnosticosDataLoader.getStats();
      debugPrint('📊 [DEBUG] Stats do loader: $stats');
      
      // Verificar se loader pensa que está carregado
      final isLoaded = DiagnosticosDataLoader.isLoaded;
      debugPrint('🔍 [DEBUG] Loader isLoaded: $isLoaded');
      
      // Tentar verificar dados
      final hasData = await DiagnosticosDataLoader.isDataLoaded();
      debugPrint('🔍 [DEBUG] isDataLoaded(): $hasData');
      
      debugPrint('🚨 [DEBUG] POSSÍVEIS PROBLEMAS:');
      debugPrint('  - Arquivos JSON não encontrados');
      debugPrint('  - Erro na leitura dos assets');
      debugPrint('  - Problema no Hive repository');
      debugPrint('  - DI não configurado corretamente');
      
    } catch (e) {
      debugPrint('❌ [DEBUG] Erro no debug: $e');
    }
  }
}
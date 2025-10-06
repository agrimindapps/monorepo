import 'package:flutter/foundation.dart';

import 'core/data/repositories/diagnostico_hive_repository.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/diagnosticos_data_loader.dart';

/// Script de debug para verificar status dos diagnósticos
class DiagnosticosDebug {
  /// Função principal de debug - chame esta função para verificar tudo
  static Future<void> checkStatus() async {
    try {
      debugPrint('🔍 [DEBUG] ===== VERIFICAÇÃO DE DIAGNÓSTICOS =====');
      final repository = di.sl<DiagnosticoHiveRepository>();
      final allDiagnosticosResult = await repository.getAll();

      await allDiagnosticosResult.fold(
        (error) async {
          debugPrint('❌ [DEBUG] Erro ao acessar repository: $error');
          await _debugLoadingProcess();
        },
        (allDiagnosticos) async {
          debugPrint(
            '📊 [DEBUG] Diagnósticos no repository: ${allDiagnosticos.length}',
          );

          if (allDiagnosticos.isEmpty) {
            debugPrint('⚠️ [DEBUG] Box vazia! Tentando forçar carregamento...');
            await DiagnosticosDataLoader.forceReload();
            final newResult = await repository.getAll();
            await newResult.fold(
              (error) async {
                debugPrint('❌ [DEBUG] Erro após reload: $error');
                await _debugLoadingProcess();
              },
              (newDiagnosticos) async {
                debugPrint(
                  '📊 [DEBUG] Após reload: ${newDiagnosticos.length} diagnósticos',
                );

                if (newDiagnosticos.isNotEmpty) {
                  debugPrint('✅ [DEBUG] Sucesso! Carregamento funcionou');
                  await _showSample(repository);
                } else {
                  debugPrint('❌ [DEBUG] Falha! Ainda 0 diagnósticos');
                  await _debugLoadingProcess();
                }
              },
            );
          } else {
            debugPrint('✅ [DEBUG] Box tem dados!');
            await _showSample(repository);
          }
        },
      );

      debugPrint('🔍 [DEBUG] ===== FIM DA VERIFICAÇÃO =====');
    } catch (e) {
      debugPrint('❌ [DEBUG] Erro: $e');
    }
  }

  /// Mostra sample dos dados
  static Future<void> _showSample(DiagnosticoHiveRepository repository) async {
    final result = await repository.getAll();
    await result.fold(
      (error) async {
        debugPrint('❌ [DEBUG] Erro ao obter sample: $error');
      },
      (allDiagnosticos) async {
        final sample = allDiagnosticos.take(5).toList();
        debugPrint('📋 [DEBUG] SAMPLE (5 primeiros):');
        for (int i = 0; i < sample.length; i++) {
          final diag = sample[i];
          debugPrint('  [$i] fkIdDefensivo: "${diag.fkIdDefensivo}"');
          debugPrint('      nomeDefensivo: "${diag.nomeDefensivo}"');
          debugPrint('      nomeCultura: "${diag.nomeCultura}"');
          debugPrint('      nomePraga: "${diag.nomePraga}"');
        }
      },
    );
  }

  /// Debug do processo de carregamento
  static Future<void> _debugLoadingProcess() async {
    try {
      debugPrint('🔧 [DEBUG] Debugando processo de carregamento...');
      final stats = await DiagnosticosDataLoader.getStats();
      debugPrint('📊 [DEBUG] Stats do loader: $stats');
      final isLoaded = DiagnosticosDataLoader.isLoaded;
      debugPrint('🔍 [DEBUG] Loader isLoaded: $isLoaded');
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

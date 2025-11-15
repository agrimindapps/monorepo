import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics/gasometer_analytics_service.dart';
import '../../data/repositories/data_export_repository_impl.dart';
import '../../domain/entities/export_progress.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/services/platform_export_service.dart';
import '../state/data_export_state.dart';

part 'data_export_notifier.g.dart';

/// Provider para o repository de exportação
@riverpod
DataExportRepository dataExportRepository(Ref ref) {
  return DataExportRepositoryImpl();
}

/// Provider para o serviço de plataforma
@riverpod
PlatformExportService platformExportService(Ref ref) {
  return PlatformExportServiceFactory.create();
}

/// Provider para o analytics service (GetIt)
@riverpod
GasometerAnalyticsService? gasometerAnalyticsService(
  Ref ref,
) {
  return null;
}

/// Notifier para gerenciar o estado da exportação de dados LGPD
@riverpod
class DataExportNotifier extends _$DataExportNotifier {
  late final DataExportRepository _repository;
  late final PlatformExportService _platformService;
  late final GasometerAnalyticsService? _analyticsService;

  @override
  DataExportState build() {
    _repository = ref.watch(dataExportRepositoryProvider);
    _platformService = ref.watch(platformExportServiceProvider);
    _analyticsService = ref.watch(gasometerAnalyticsServiceProvider);

    return DataExportState.initial();
  }

  /// Inicia uma exportação de dados
  Future<bool> startExport({
    required String userId,
    required List<String> categories,
    DateTime? startDate,
    DateTime? endDate,
    bool includeAttachments = true,
  }) async {
    if (state.isExporting || !state.canExport) return false;

    state = state.copyWith(
      isExporting: true,
      errorMessage: '',
      currentProgress: null,
    );

    try {
      final request = ExportRequest(
        userId: userId,
        includedCategories: categories,
        startDate: startDate,
        endDate: endDate,
        outputFormats: ['json'],
        includeAttachments: includeAttachments,
      );
      await _analyticsService?.logDataExportStarted(
        userId: userId,
        categories: categories,
        estimatedSizeMb: state.exportEstimate?['estimated_size_mb'] as int?,
        includeAttachments: includeAttachments,
      );

      final result = await _repository.exportUserData(
        request,
        onProgress: _updateProgress,
      );
      await _analyticsService?.logDataExportCompleted(
        userId: userId,
        success: result.success,
        fileSizeMb: result.metadata?.fileSizeMb,
        processingTimeMs: result.processingTime.inMilliseconds,
        errorReason: result.errorMessage,
      );

      if (result.success) {
        if (_platformService.supportsSharing && result.filePath != null) {
          await _platformService.shareExportFile(
            result.filePath!,
            'gasometer_export_${DateTime.now().millisecondsSinceEpoch}.json',
          );
        }

        await _refreshExportHistory(userId);
        await _checkCanExport(userId);

        state = state.copyWith(
          lastResult: result,
          isExporting: false,
        );

        return true;
      } else {
        state = state.withError(
          result.errorMessage ?? 'Erro desconhecido durante exportação',
        );
        return false;
      }
    } catch (e) {
      state = state.withError('Erro durante exportação: $e');
      return false;
    }
  }

  /// Estima o tamanho da exportação
  Future<void> estimateExportSize({
    required String userId,
    required List<String> categories,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final request = ExportRequest(
        userId: userId,
        includedCategories: categories,
        startDate: startDate,
        endDate: endDate,
        outputFormats: ['json'],
      );

      final estimate = await _repository.estimateExportSize(request);

      state = state.copyWith(exportEstimate: estimate);
    } catch (e) {
      print('Erro ao estimar tamanho da exportação: $e');
      state = state.copyWith(exportEstimate: {});
    }
  }

  /// Verifica se o usuário pode exportar dados
  Future<void> checkCanExport(String userId) async {
    await _checkCanExport(userId);
  }

  /// Carrega histórico de exportações
  Future<void> loadExportHistory(String userId) async {
    await _refreshExportHistory(userId);
  }

  /// Compartilha um arquivo de exportação existente
  Future<bool> shareExportFile(String filePath, String fileName) async {
    if (!_platformService.supportsSharing) {
      state = state.withError('Compartilhamento não suportado nesta plataforma');
      return false;
    }

    try {
      return await _platformService.shareExportFile(filePath, fileName);
    } catch (e) {
      state = state.withError('Erro ao compartilhar arquivo: $e');
      return false;
    }
  }

  /// Limpa arquivos temporários
  Future<void> cleanupTemporaryFiles() async {
    try {
      await _repository.cleanupTemporaryFiles();
    } catch (e) {
      print('Erro durante limpeza de arquivos temporários: $e');
    }
  }

  /// Limpa o estado de erro
  void clearError() {
    state = state.clearError();
  }

  /// Limpa o progresso atual
  void clearProgress() {
    state = state.clearProgress();
  }

  Future<void> _checkCanExport(String userId) async {
    try {
      final canExport = await _repository.canExportData(userId);
      state = state.copyWith(canExport: canExport);
    } catch (e) {
      print('Erro ao verificar se pode exportar: $e');
      state = state.copyWith(canExport: false);
    }
  }

  Future<void> _refreshExportHistory(String userId) async {
    try {
      final history = await _repository.getExportHistory(userId);
      state = state.copyWith(exportHistory: history);
    } catch (e) {
      print('Erro ao carregar histórico de exportações: $e');
      state = state.copyWith(exportHistory: []);
    }
  }

  void _updateProgress(ExportProgress progress) {
    state = state.copyWith(currentProgress: progress);
  }
}

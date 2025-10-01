import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import 'package:gasometer/core/services/gasometer_analytics_service.dart';
import '../../data/repositories/data_export_repository_impl.dart';
import '../../domain/entities/export_progress.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/entities/export_result.dart';
import '../../domain/repositories/data_export_repository.dart';
import '../../domain/services/platform_export_service.dart';

/// Provider para gerenciar o estado da exportação de dados LGPD
@injectable
class DataExportProvider extends ChangeNotifier {

  DataExportProvider({
    DataExportRepository? repository,
    PlatformExportService? platformService,
    @factoryParam GasometerAnalyticsService? analyticsService,
  }) : _repository = repository ?? DataExportRepositoryImpl(),
       _platformService = platformService ?? PlatformExportServiceFactory.create(),
       _analyticsService = analyticsService;
  final DataExportRepository _repository;
  final PlatformExportService _platformService;
  final GasometerAnalyticsService? _analyticsService;

  // Estado da exportação
  bool _isExporting = false;
  bool _canExport = true;
  ExportProgress? _currentProgress;
  ExportResult? _lastResult;
  String? _errorMessage;
  List<ExportResult> _exportHistory = [];
  Map<String, dynamic>? _exportEstimate;

  // Getters
  bool get isExporting => _isExporting;
  bool get canExport => _canExport && !_isExporting;
  ExportProgress? get currentProgress => _currentProgress;
  ExportResult? get lastResult => _lastResult;
  String? get errorMessage => _errorMessage;
  List<ExportResult> get exportHistory => _exportHistory;
  Map<String, dynamic>? get exportEstimate => _exportEstimate;
  bool get hasError => _errorMessage != null;

  /// Inicia uma exportação de dados
  Future<bool> startExport({
    required String userId,
    required List<String> categories,
    DateTime? startDate,
    DateTime? endDate,
    bool includeAttachments = true,
  }) async {
    if (_isExporting || !_canExport) return false;

    _setLoading(true);
    _clearError();
    _currentProgress = null;
    notifyListeners();

    try {
      final request = ExportRequest(
        userId: userId,
        includedCategories: categories,
        startDate: startDate,
        endDate: endDate,
        outputFormats: ['json'],
        includeAttachments: includeAttachments,
      );

      // Log analytics de início
      await _analyticsService?.logDataExportStarted(
        userId: userId,
        categories: categories,
        estimatedSizeMb: _exportEstimate?['estimated_size_mb'] as int?,
        includeAttachments: includeAttachments,
      );

      final result = await _repository.exportUserData(
        request,
        onProgress: _updateProgress,
      );

      _lastResult = result;

      // Log analytics de conclusão
      await _analyticsService?.logDataExportCompleted(
        userId: userId,
        success: result.success,
        fileSizeMb: result.metadata?.fileSizeMb,
        processingTimeMs: result.processingTime.inMilliseconds,
        errorReason: result.errorMessage,
      );

      if (result.success) {
        // Tentar compartilhar arquivo se a plataforma suportar
        if (_platformService.supportsSharing && result.filePath != null) {
          await _platformService.shareExportFile(
            result.filePath!,
            'gasometer_export_${DateTime.now().millisecondsSinceEpoch}.json',
          );
        }
        
        await _refreshExportHistory(userId);
        await _checkCanExport(userId);
        return true;
      } else {
        _setError(result.errorMessage ?? 'Erro desconhecido durante exportação');
        return false;
      }
    } catch (e) {
      _setError('Erro durante exportação: $e');
      return false;
    } finally {
      _setLoading(false);
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

      _exportEstimate = await _repository.estimateExportSize(request);
      notifyListeners();
    } catch (e) {
      print('Erro ao estimar tamanho da exportação: $e');
      _exportEstimate = null;
      notifyListeners();
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
      _setError('Compartilhamento não suportado nesta plataforma');
      return false;
    }

    try {
      return await _platformService.shareExportFile(filePath, fileName);
    } catch (e) {
      _setError('Erro ao compartilhar arquivo: $e');
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
    _clearError();
  }

  /// Limpa o progresso atual
  void clearProgress() {
    _currentProgress = null;
    notifyListeners();
  }

  // Métodos privados auxiliares

  Future<void> _checkCanExport(String userId) async {
    try {
      _canExport = await _repository.canExportData(userId);
      notifyListeners();
    } catch (e) {
      print('Erro ao verificar se pode exportar: $e');
      _canExport = false;
      notifyListeners();
    }
  }

  Future<void> _refreshExportHistory(String userId) async {
    try {
      _exportHistory = await _repository.getExportHistory(userId);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar histórico de exportações: $e');
      _exportHistory = [];
      notifyListeners();
    }
  }

  void _updateProgress(ExportProgress progress) {
    _currentProgress = progress;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isExporting = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// Extensão para facilitar o uso do Provider
extension DataExportProviderExtension on BuildContext {
  DataExportProvider get dataExportProvider => read<DataExportProvider>();
  DataExportProvider get watchDataExportProvider => watch<DataExportProvider>();
}


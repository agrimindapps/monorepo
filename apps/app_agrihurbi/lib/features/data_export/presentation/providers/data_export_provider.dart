import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/usecases/check_export_availability_usecase.dart';
import '../../domain/usecases/export_user_data_usecase.dart';

class DataExportProvider extends ChangeNotifier {
  final CheckExportAvailabilityUsecase _checkAvailabilityUsecase;
  final ExportUserDataUsecase _exportDataUsecase;

  DataExportProvider(
    this._checkAvailabilityUsecase,
    this._exportDataUsecase,
  );

  // Export availability
  ExportAvailabilityResult? _availabilityResult;
  bool _isCheckingAvailability = false;

  // Export progress
  ExportProgress? _exportProgress;
  bool _isExporting = false;
  StreamSubscription<ExportProgress>? _exportSubscription;

  // Getters
  ExportAvailabilityResult? get availabilityResult => _availabilityResult;
  bool get isCheckingAvailability => _isCheckingAvailability;

  ExportProgress? get exportProgress => _exportProgress;
  bool get isExporting => _isExporting;

  bool get canExport =>
      _availabilityResult?.isAvailable == true && !_isExporting;

  String? get availabilityError => _availabilityResult?.error;

  String? get exportError => _exportProgress?.error;

  bool get hasAvailabilityError => availabilityError != null;
  bool get hasExportError => exportError != null;

  Duration? get timeUntilNextExport => _availabilityResult?.timeUntilNextExport;

  @override
  void dispose() {
    _exportSubscription?.cancel();
    super.dispose();
  }

  /// Verifica se o usuário pode realizar um export
  Future<void> checkExportAvailability() async {
    if (_isCheckingAvailability) return;

    _isCheckingAvailability = true;
    _availabilityResult = null;
    notifyListeners();

    try {
      _availabilityResult = await _checkAvailabilityUsecase.execute();
    } catch (e) {
      _availabilityResult = ExportAvailabilityResult.error(e.toString());
    } finally {
      _isCheckingAvailability = false;
      notifyListeners();
    }
  }

  /// Inicia o processo de exportação
  Future<void> startExport(ExportRequest request) async {
    if (_isExporting) return;

    _isExporting = true;
    _exportProgress = null;
    notifyListeners();

    _exportSubscription?.cancel();
    _exportSubscription = _exportDataUsecase.execute(request).listen(
      (progress) {
        _exportProgress = progress;
        notifyListeners();

        if (progress.isCompleted || progress.hasError) {
          _isExporting = false;
          _exportSubscription?.cancel();
          notifyListeners();

          // Atualizar disponibilidade após export bem-sucedido
          if (progress.isCompleted) {
            Future.delayed(Duration(seconds: 1), () {
              checkExportAvailability();
            });
          }
        }
      },
      onError: (error) {
        _exportProgress = ExportProgress(
          current: 0,
          total: 6,
          currentTask: 'Erro durante exportação',
          error: error.toString(),
        );
        _isExporting = false;
        notifyListeners();
      },
    );
  }

  /// Cancela a exportação em andamento
  void cancelExport() {
    _exportSubscription?.cancel();
    _isExporting = false;
    _exportProgress = null;
    notifyListeners();
  }

  /// Limpa os resultados de exportação
  void clearResults() {
    _exportProgress = null;
    notifyListeners();
  }

  /// Reset do estado do provider
  void reset() {
    _exportSubscription?.cancel();
    _isCheckingAvailability = false;
    _isExporting = false;
    _availabilityResult = null;
    _exportProgress = null;
    notifyListeners();
  }
}
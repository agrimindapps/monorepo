import 'package:freezed_annotation/freezed_annotation.dart';

import '../feedback_system.dart';
import '../../loading/contextual_loading_manager.dart';

part 'operation_config.freezed.dart';

/// Configuração para execução de operações com feedback
@freezed
sealed class OperationConfig with _$OperationConfig {
  const factory OperationConfig({
    required String loadingMessage,
    String? successMessage,
    String? errorMessage,
    @Default(LoadingType.standard) LoadingType loadingType,
    @Default(SuccessAnimationType.checkmark)
    SuccessAnimationType successAnimation,
    @Default(true) bool includeHaptic,
    @Default(true) bool showToast,
    Duration? timeout,
  }) = _OperationConfig;
}

/// Configuração para operações com progresso determinado
@freezed
sealed class ProgressOperationConfig with _$ProgressOperationConfig {
  const factory ProgressOperationConfig({
    required String title,
    String? description,
    String? successMessage,
    @Default(true) bool includeHaptic,
    @Default(true) bool showToast,
  }) = _ProgressOperationConfig;
}

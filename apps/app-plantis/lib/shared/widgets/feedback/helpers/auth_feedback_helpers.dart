import 'package:flutter/material.dart';

import '../../loading/contextual_loading_manager.dart';
import '../core/feedback_orchestrator.dart';
import '../core/operation_config.dart';
import '../feedback_system.dart';

/// Extension helpers para operações de autenticação e premium
extension AuthFeedbackHelpers on FeedbackOrchestrator {
  /// Login com feedback
  Future<T> login<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? userName,
  }) {
    return executeOperation<T>(
      context: context,
      operationKey: 'login_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: OperationConfig(
        loadingMessage: 'Fazendo login...',
        successMessage: userName != null
            ? 'Bem-vindo, $userName!'
            : 'Login realizado com sucesso!',
        loadingType: LoadingType.auth,
        successAnimation: SuccessAnimationType.checkmark,
      ),
    );
  }

  /// Compra premium com feedback
  Future<T> purchasePremium<T>({
    required BuildContext context,
    required Future<T> Function() operation,
  }) {
    return executeOperation<T>(
      context: context,
      operationKey: 'purchase_premium_${DateTime.now().millisecondsSinceEpoch}',
      operation: operation,
      config: const OperationConfig(
        loadingMessage: 'Processando compra...',
        successMessage: 'Premium ativado com sucesso!',
        loadingType: LoadingType.purchase,
        successAnimation: SuccessAnimationType.confetti,
        timeout: Duration(minutes: 2),
      ),
    );
  }
}

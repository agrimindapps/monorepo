import 'package:flutter/material.dart';

/// Diálogo de progresso para exclusão de conta
/// Mostra o progresso passo-a-passo da exclusão com feedback visual
class AccountDeletionProgressDialog extends StatelessWidget {
  final List<String> steps;
  final int currentStepIndex;
  final bool isComplete;
  final bool hasError;
  final String? errorMessage;

  const AccountDeletionProgressDialog({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    this.isComplete = false,
    this.hasError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => isComplete || hasError,
      child: AlertDialog(
        title: Row(
          children: [
            if (!isComplete && !hasError)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (isComplete)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            if (hasError) const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasError
                    ? 'Erro na Exclusão'
                    : isComplete
                    ? 'Exclusão Concluída'
                    : 'Excluindo Conta...',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasError && errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (!hasError) ...[
                LinearProgressIndicator(
                  value:
                      isComplete
                          ? 1.0
                          : steps.isEmpty
                          ? 0.0
                          : (currentStepIndex + 1) / steps.length,
                ),
                const SizedBox(height: 16),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final isPast = index < currentStepIndex;
                    final isCurrent = index == currentStepIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPast || (isComplete && !hasError))
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          else if (isCurrent && !hasError)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              steps[index],
                              style: TextStyle(
                                color:
                                    isPast || isCurrent
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                fontWeight:
                                    isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (isComplete) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sua conta foi excluída com sucesso. '
                          'Você será redirecionado para a tela de login.',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (isComplete || hasError)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isComplete ? 'Fechar' : 'OK'),
            ),
        ],
      ),
    );
  }

  /// Mostra o diálogo de progresso
  static void show(
    BuildContext context, {
    required List<String> steps,
    required int currentStepIndex,
    bool isComplete = false,
    bool hasError = false,
    String? errorMessage,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AccountDeletionProgressDialog(
            steps: steps,
            currentStepIndex: currentStepIndex,
            isComplete: isComplete,
            hasError: hasError,
            errorMessage: errorMessage,
          ),
    );
  }
}

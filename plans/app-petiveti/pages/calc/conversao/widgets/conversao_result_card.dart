// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';

// Project imports:
import '../controller/conversao_controller.dart';

/// Widget para exibir o resultado do cálculo de conversão
class ConversaoResultCard extends StatelessWidget {
  final ConversaoController controller;

  const ConversaoResultCard({
    super.key,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Responsive padding
    final cardPadding = isSmallScreen ? 16.0 : 20.0;

    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoadingNotifier,
      builder: (context, isLoading, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.calculadoNotifier,
          builder: (context, calculado, child) {
            return ValueListenableBuilder<double?>(
              valueListenable: controller.resultadoNotifier,
              builder: (context, resultado, child) {
                final hasResult = calculado && resultado != null;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isLoading
                                        ? colorScheme.primary.withValues(alpha: 0.1)
                                        : hasResult
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          hasResult ? Icons.check_circle : Icons.calculate,
                                          color: hasResult ? Colors.green : colorScheme.primary,
                                          size: 20,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isLoading ? 'Calculando...' : 'Resultado da Conversão',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (hasResult && !isLoading)
                                  IconButton(
                                    onPressed: () => _shareResult(),
                                    icon: const Icon(Icons.share),
                                    tooltip: 'Compartilhar resultado',
                                    style: IconButton.styleFrom(
                                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                      foregroundColor: colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                if (hasResult) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withValues(alpha: 0.1),
                          Colors.green.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Valor Convertido',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.model.resultado!.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Resultado calculado',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Resultado baseado no valor informado. Verifique se a conversão está correta para sua aplicação.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calculate,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aguardando cálculo...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color:
                                colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Preencha os dados acima e clique em "Calcular"',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _shareResult() {
    if (controller.model.resultado != null) {
      final resultado = controller.model.resultado!.toStringAsFixed(2);
      final valor = controller.model.valorController.text;

      Share.share(
        'Resultado da Conversão 🧮\n\n'
        'Valor original: $valor\n'
        'Valor convertido: $resultado\n\n'
        '📱 Calculado com fNutriTuti',
        subject: 'Resultado da Conversão',
      );
    }
  }
}

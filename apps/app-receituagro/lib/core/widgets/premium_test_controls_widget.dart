import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interfaces/i_premium_service.dart';
import '../providers/premium_providers.dart';

// Provider para gerenciar o estado de processamento do widget
final _isProcessingProvider = StateProvider<bool>((ref) => false);

/// Widget de controle para testar funcionalidades premium
/// Permite ativar/desativar licença teste facilmente durante desenvolvimento
class PremiumTestControlsWidget extends ConsumerWidget {
  final bool showInProduction;

  const PremiumTestControlsWidget({
    super.key,
    this.showInProduction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumService = ref.watch(premiumServiceProvider);

    if (!showInProduction && const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.developer_mode, size: 20),
              const SizedBox(width: 8),
              Text(
                'Controles de Teste Premium',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, child) {
              final isProcessing = ref.watch(_isProcessingProvider);
              final isPremium = premiumService.isPremium;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPremium ? 'PREMIUM ATIVO' : 'FREE USER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isPremium)
                    ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _activateTestSubscription(
                              context, ref, premiumService),
                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.diamond, size: 16),
                      label: const Text('Ativar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  if (isPremium)
                    ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _removeTestSubscription(
                              context, ref, premiumService),
                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel, size: 16),
                      label: const Text('Desativar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _activateTestSubscription(BuildContext context, WidgetRef ref,
      IPremiumService premiumService) async {
    final isProcessingNotifier = ref.read(_isProcessingProvider.notifier);

    if (ref.read(_isProcessingProvider)) return;

    isProcessingNotifier.state = true;

    try {
      await premiumService.generateTestSubscription();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Licença teste ativada com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao ativar licença teste: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      isProcessingNotifier.state = false;
    }
  }

  Future<void> _removeTestSubscription(BuildContext context, WidgetRef ref,
      IPremiumService premiumService) async {
    final isProcessingNotifier = ref.read(_isProcessingProvider.notifier);

    if (ref.read(_isProcessingProvider)) return;

    isProcessingNotifier.state = true;

    try {
      await premiumService.removeTestSubscription();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔓 Licença teste removida com sucesso!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao remover licença teste: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      isProcessingNotifier.state = false;
    }
  }
}

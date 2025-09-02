import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';

/// Widget responsável pelas ações de gerenciamento de assinatura
///
/// Responsabilidades:
/// - Botão para gerenciar assinatura (cancelar, pausar, etc.)
/// - Botão para restaurar compras
/// - Ações de suporte ao usuário
/// - Estados de loading por ação
class SubscriptionManagementActionsWidget extends ConsumerWidget {
  const SubscriptionManagementActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isLoading = subscriptionState.isLoading;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título da seção
            const Text(
              'Gerenciar Assinatura',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão de gerenciamento
            _buildManagementButton(context, ref, isLoading),
            
            const SizedBox(height: 12),
            
            // Botão de restaurar compras
            _buildRestoreButton(context, ref, isLoading),
            
            const SizedBox(height: 16),
            
            // Texto informativo
            _buildInfoText(),
          ],
        ),
      ),
    );
  }

  /// Constrói o botão de gerenciamento
  Widget _buildManagementButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => _handleManageSubscription(ref),
        icon: const Icon(Icons.settings),
        label: const Text('Gerenciar Assinatura'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Constrói o botão de restaurar compras
  Widget _buildRestoreButton(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : () => _handleRestorePurchases(ref),
        icon: const Icon(Icons.restore),
        label: const Text('Restaurar Compras'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue.shade600,
          side: BorderSide(color: Colors.blue.shade600),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// Constrói o texto informativo
  Widget _buildInfoText() {
    return Text(
      'Você pode cancelar ou modificar sua assinatura a qualquer momento através '
      'do gerenciamento de assinaturas da sua conta.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Manipula o gerenciamento de assinatura
  Future<void> _handleManageSubscription(WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).openSubscriptionManagement();
  }

  /// Manipula a restauração de compras
  Future<void> _handleRestorePurchases(WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).restorePurchases();
  }
}
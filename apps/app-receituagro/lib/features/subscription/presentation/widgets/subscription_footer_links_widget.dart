import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';

/// Widget responsável pelos links do footer
///
/// Responsabilidades:
/// - Exibir links para termos de uso
/// - Exibir links para política de privacidade
/// - Botão para restaurar compras
/// - Textos legais obrigatórios
/// - Design consistente com tema
class SubscriptionFooterLinksWidget extends ConsumerWidget {
  const SubscriptionFooterLinksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final isLoading = subscriptionState.isLoading;

    return Column(
      children: [
        // Botão restaurar compras
        TextButton(
          onPressed: isLoading ? null : () => _handleRestorePurchases(ref),
          child: Text(
            'Restaurar Compras',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Links legais
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegalLink('Termos de Uso', () => _openTerms()),
            
            Text(
              ' • ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            
            _buildLegalLink('Política de Privacidade', () => _openPrivacyPolicy()),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Texto legal
        Text(
          'A assinatura será renovada automaticamente. '
          'Cancele a qualquer momento nas configurações da sua conta.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  /// Constrói um link legal
  Widget _buildLegalLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  /// Manipula restauração de compras
  Future<void> _handleRestorePurchases(WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).restorePurchases();
  }

  /// Abre termos de uso
  void _openTerms() {
    // TODO: Implementar abertura de termos de uso
    // Pode usar url_launcher ou navegação interna
  }

  /// Abre política de privacidade
  void _openPrivacyPolicy() {
    // TODO: Implementar abertura de política de privacidade
    // Pode usar url_launcher ou navegação interna
  }
}
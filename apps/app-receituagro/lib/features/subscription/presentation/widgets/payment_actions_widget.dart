import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_notifier.dart';

/// Widget responsável pelas ações relacionadas a pagamento e subscription
///
/// Funcionalidades:
/// - Botão principal de compra
/// - Botão de gerenciamento de subscription
/// - Links de rodapé (Termos, Privacidade, Restaurar)
/// - Configuração flexível via parâmetros
///
/// Modes:
/// - Purchase: Botão principal para compra
/// - Management: Botão para gerenciar subscription ativa
/// - Footer: Links de termos, privacidade e restaurar
class PaymentActionsWidget extends ConsumerWidget {
  final bool showPurchaseButton;
  final bool showSubscriptionManagement;
  final bool showFooterLinks;

  const PaymentActionsWidget({
    super.key,
    this.showPurchaseButton = false,
    this.showSubscriptionManagement = false,
    this.showFooterLinks = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionNotifierProvider);

    return subscriptionAsync.when(
      data: (subscriptionState) {
        if (showPurchaseButton) {
          return _buildPurchaseButton(ref, subscriptionState.isLoading);
        } else if (showSubscriptionManagement) {
          return _buildManagementButton(ref, subscriptionState.isLoading);
        } else if (showFooterLinks) {
          return _buildFooterLinks(ref, subscriptionState.isLoading);
        }

        return const SizedBox.shrink();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  /// Botão principal para compra do plano selecionado
  Widget _buildPurchaseButton(WidgetRef ref, bool isLoading) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => ref.read(subscriptionNotifierProvider.notifier).purchaseSelectedPlan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1B4332),  // Dark green text
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B4332)),
                ),
              )
            : const Text(
                'Obter Acesso Completo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Botão para gerenciamento de subscription ativa
  Widget _buildManagementButton(WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () => ref.read(subscriptionNotifierProvider.notifier).openManagementUrl(),
        icon: const Icon(Icons.settings),
        label: const Text('Gerenciar Assinatura'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),  // Medium green for management
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// Links de rodapé (Termos, Privacidade, Restaurar)
  Widget _buildFooterLinks(WidgetRef ref, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildFooterLink(
              'Termos de Uso',
              () => ref.read(subscriptionNotifierProvider.notifier).openTermsOfUse(),
              isLoading,
            ),
          ),
          _buildFooterDivider(),
          Expanded(
            child: _buildFooterLink(
              'Política de Privacidade',
              () => ref.read(subscriptionNotifierProvider.notifier).openPrivacyPolicy(),
              isLoading,
            ),
          ),
          _buildFooterDivider(),
          Expanded(
            child: _buildFooterLink(
              'Restaurar',
              () => ref.read(subscriptionNotifierProvider.notifier).restorePurchases(),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }

  /// Link individual do rodapé
  Widget _buildFooterLink(String text, VoidCallback onPressed, bool isLoading) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
    );
  }

  /// Divisor entre links do rodapé
  Widget _buildFooterDivider() {
    return Text(
      '•',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../providers/subscription_provider.dart';

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
class PaymentActionsWidget extends StatelessWidget {
  final SubscriptionProvider provider;
  final bool showPurchaseButton;
  final bool showSubscriptionManagement;
  final bool showFooterLinks;

  const PaymentActionsWidget({
    super.key,
    required this.provider,
    this.showPurchaseButton = false,
    this.showSubscriptionManagement = false,
    this.showFooterLinks = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPurchaseButton) {
      return _buildPurchaseButton();
    } else if (showSubscriptionManagement) {
      return _buildManagementButton();
    } else if (showFooterLinks) {
      return _buildFooterLinks();
    }
    
    return const SizedBox.shrink();
  }

  /// Botão principal para compra do plano selecionado
  Widget _buildPurchaseButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : provider.purchaseSelectedPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF4A148C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: provider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A148C)),
                ),
              )
            : const Text(
                'Obter Acesso Completo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Botão para gerenciamento de subscription ativa
  Widget _buildManagementButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: provider.isLoading ? null : provider.openManagementUrl,
        icon: const Icon(Icons.settings),
        label: const Text('Gerenciar Assinatura'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
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
  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildFooterLink(
            'Termos',
            provider.openTermsOfUse,
          ),
        ),
        _buildFooterDivider(),
        Expanded(
          child: _buildFooterLink(
            'Privacidade',
            provider.openPrivacyPolicy,
          ),
        ),
        _buildFooterDivider(),
        Expanded(
          child: _buildFooterLink(
            'Restaurar',
            provider.restorePurchases,
          ),
        ),
      ],
    );
  }

  /// Link individual do rodapé
  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: provider.isLoading ? null : onPressed,
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
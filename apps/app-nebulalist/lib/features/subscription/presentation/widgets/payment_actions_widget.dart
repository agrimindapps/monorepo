import 'package:flutter/material.dart';

import '../../../../core/theme/nebula_colors.dart';

/// Widget responsável pelas ações de pagamento para Nebulalist
///
/// Funcionalidades:
/// - Botão principal de compra com gradiente Nebula
/// - Botão de restaurar compras
/// - Botão de gerenciar assinatura
/// - Links de rodapé (Termos, Privacidade)
/// - Loading states contextuais
///
/// Estados:
/// - Usuário sem subscription: Botões de compra e restaurar
/// - Usuário com subscription: Botão de gerenciar
/// - Loading: Botões desabilitados com indicadores
class PaymentActionsWidget extends StatelessWidget {
  final String? selectedPlanId;
  final bool isPremium;
  final bool isLoading;
  final VoidCallback? onPurchase;
  final VoidCallback? onRestore;
  final VoidCallback? onManageSubscription;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onTermsOfService;
  final bool showPurchaseButton;
  final bool showFooterLinks;
  final bool showSubscriptionManagement;

  const PaymentActionsWidget({
    super.key,
    this.selectedPlanId,
    this.isPremium = false,
    this.isLoading = false,
    this.onPurchase,
    this.onRestore,
    this.onManageSubscription,
    this.onPrivacyPolicy,
    this.onTermsOfService,
    this.showPurchaseButton = false,
    this.showFooterLinks = false,
    this.showSubscriptionManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPurchaseButton && !isPremium) _buildPurchaseButton(),
        if (!isPremium && !showPurchaseButton && onRestore != null)
          _buildRestoreButton(),
        if (showSubscriptionManagement && isPremium)
          _buildManageSubscriptionButton(),
        if (showFooterLinks) _buildFooterLinks(),
      ],
    );
  }

  /// Botão principal de compra com gradiente Nebula
  Widget _buildPurchaseButton() {
    final isEnabled = selectedPlanId != null && !isLoading;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [
                  NebulaColors.primaryPurple,
                  NebulaColors.accentCyan,
                ],
              )
            : null,
        color: isEnabled ? null : Colors.grey.withValues(alpha: 0.3),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: NebulaColors.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPurchase : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.auto_awesome, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isLoading
                      ? 'Processando...'
                      : (selectedPlanId != null
                            ? 'Assinar Premium'
                            : 'Selecione um Plano'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Botão de restaurar compras
  Widget _buildRestoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: isLoading ? null : onRestore,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              )
            : Text(
                'Restaurar Compras',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// Botão de gerenciar assinatura
  Widget _buildManageSubscriptionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NebulaColors.primaryPurple.withValues(alpha: 0.5),
        ),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onManageSubscription,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.settings, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isLoading ? 'Abrindo...' : 'Gerenciar Assinatura',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Links de rodapé (Termos, Privacidade, etc.)
  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          if (onRestore != null && !isPremium) ...[
            _buildRestoreButton(),
            const SizedBox(height: 20),
          ],
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  NebulaColors.primaryPurple.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterLink('Política de Privacidade', onPrivacyPolicy),
              Container(
                width: 1,
                height: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildFooterLink('Termos de Uso', onTermsOfService),
            ],
          ),
          const SizedBox(height: 16),
          _buildAutoRenewalText(),
        ],
      ),
    );
  }

  /// Link individual do rodapé
  Widget _buildFooterLink(String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  /// Texto explicativo sobre renovação automática
  Widget _buildAutoRenewalText() {
    return Text(
      'A assinatura será renovada automaticamente. Você pode cancelar a qualquer momento nas configurações da loja.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        height: 1.4,
      ),
    );
  }
}

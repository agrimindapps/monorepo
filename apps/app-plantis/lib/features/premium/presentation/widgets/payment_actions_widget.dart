import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/loading/loading_components.dart';

/// Widget responsável pelas ações de pagamento para Plantis
///
/// Funcionalidades:
/// - Botão principal de compra
/// - Botão de restaurar compras
/// - Botão de gerenciar assinatura
/// - Links de rodapé (Termos, Privacidade)
/// - Loading states contextuais
///
/// Estados:
/// - Usuário sem subscription: Botões de compra e restaurar
/// - Usuário com subscription: Botão de gerenciar
/// - Loading: Botões desabilitados com indicadores
class PlantisPaymentActionsWidget extends StatelessWidget {
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

  const PlantisPaymentActionsWidget({
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
        // Botão principal de compra
        if (showPurchaseButton && !isPremium) _buildPurchaseButton(),

        // Botão de restaurar compras
        if (!isPremium && !showPurchaseButton && onRestore != null)
          _buildRestoreButton(),

        // Botão de gerenciar assinatura
        if (showSubscriptionManagement && isPremium)
          _buildManageSubscriptionButton(),

        // Links de rodapé
        if (showFooterLinks) _buildFooterLinks(),
      ],
    );
  }

  /// Botão principal de compra
  Widget _buildPurchaseButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: LoadingButton(
        onPressedAsync: () async {
          if (selectedPlanId != null && !isLoading) {
            onPurchase?.call();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: PlantisColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        type: LoadingButtonType.elevated,
        loadingText: 'Processando...',
        disabled: selectedPlanId == null || isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 20),
            const SizedBox(width: 8),
            Text(
              selectedPlanId != null ? 'Assinar Premium' : 'Selecione um Plano',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão de restaurar compras
  Widget _buildRestoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: LoadingButton(
        onPressedAsync: () async {
          if (!isLoading) {
            onRestore?.call();
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        type: LoadingButtonType.text,
        loadingText: 'Restaurando...',
        disabled: isLoading,
        child: Text(
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
      child: LoadingButton(
        onPressedAsync: () async {
          if (!isLoading) {
            onManageSubscription?.call();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          elevation: 0,
        ),
        type: LoadingButtonType.elevated,
        loadingText: 'Abrindo...',
        disabled: isLoading,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 20),
            SizedBox(width: 8),
            Text(
              'Gerenciar Assinatura',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
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
          // Botão de restaurar se fornecido
          if (onRestore != null && !isPremium) ...[
            _buildRestoreButton(),
            const SizedBox(height: 20),
          ],

          // Linha de separação
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Links principais
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

          // Texto de renovação automática
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

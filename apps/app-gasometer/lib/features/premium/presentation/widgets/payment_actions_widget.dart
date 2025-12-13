import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';

class PaymentActionsWidget extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

  Widget _buildPurchaseButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: (selectedPlanId == null || isLoading)
            ? null
            : () {
                onPurchase?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: GasometerDesignTokens.colorPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      GasometerDesignTokens.colorPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    selectedPlanId != null
                        ? 'Assinar Premium'
                        : 'Selecione um Plano',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: isLoading
            ? null
            : () {
                onRestore?.call();
              },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildManageSubscriptionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                onManageSubscription?.call();
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
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Gerenciar Assinatura',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

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
                  Colors.white.withValues(alpha: 0.2),
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

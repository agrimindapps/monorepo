import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/premium_notifier.dart';
import '../providers/subscription_ui_provider.dart';

class PaymentActionsWidget extends ConsumerWidget {
  const PaymentActionsWidget({
    super.key,
    this.showPurchaseButton = false,
    this.showSubscriptionManagement = false,
    this.showFooterLinks = false,
  });

  final bool showPurchaseButton;
  final bool showSubscriptionManagement;
  final bool showFooterLinks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumProvider);

    return premiumAsync.when(
      data: (premiumState) {
        final isLoading = premiumState.isProcessingPurchase || premiumState.isLoadingProducts;

        if (showPurchaseButton) {
          return _buildPurchaseButton(ref, premiumState, isLoading);
        } else if (showSubscriptionManagement) {
          return _buildManagementActions(context, ref, isLoading);
        } else if (showFooterLinks) {
          return _buildFooterLinks(ref, isLoading);
        }

        return const SizedBox.shrink();
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildPurchaseButton(WidgetRef ref, PremiumNotifierState state, bool isLoading) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _purchaseSelectedPlan(ref, state),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0D47A1), // Dark blue text
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
                ),
              )
            : const Text(
                'Obter Acesso Completo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _purchaseSelectedPlan(WidgetRef ref, PremiumNotifierState state) async {
    final selectedPlan = ref.read(selectedPlanProvider);
    final products = state.availableProducts;

    if (products.isEmpty) return;

    final product = products.firstWhere(
      (p) {
        if (selectedPlan == 'yearly') return p.productId.contains('anual');
        if (selectedPlan == 'monthly') return p.productId.contains('mensal');
        if (selectedPlan == 'semiannual') return p.productId.contains('semestral');
        return false;
      },
      orElse: () => products.first,
    );

    await ref.read<PremiumNotifier>(premiumProvider.notifier).purchaseProduct(product.productId);
  }

  Widget _buildManagementActions(BuildContext context, WidgetRef ref, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                // TODO: Implement management URL opening
                // ref.read(premiumProvider.notifier).openManagementUrl();
              },
        icon: const Icon(Icons.settings),
        label: const Text('Gerenciar Assinatura'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3), // Gasometer Primary
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(WidgetRef ref, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildFooterLink(
              'Termos de Uso',
              () => _launchUrl('https://agrimind.com.br/termos'), // Placeholder
              isLoading,
            ),
          ),
          _buildFooterDivider(),
          Expanded(
            child: _buildFooterLink(
              'Política de Privacidade',
              () => _launchUrl('https://agrimind.com.br/privacidade'), // Placeholder
              isLoading,
            ),
          ),
          _buildFooterDivider(),
          Expanded(
            child: _buildFooterLink(
              'Restaurar',
              () => ref.read<PremiumNotifier>(premiumProvider.notifier).restorePurchases(),
              isLoading,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildFooterDivider() {
    return Text(
      '•',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}

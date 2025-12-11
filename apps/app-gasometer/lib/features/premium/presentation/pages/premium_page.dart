import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_notifier.dart';
import '../widgets/modern_header_widget.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_plans_widget.dart';
import '../widgets/subscription_status_widget.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumProvider.notifier).loadAvailableProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final premiumAsync = ref.watch(premiumProvider);

    ref.listen<AsyncValue<PremiumNotifierState>>(
      premiumProvider,
      (previous, next) {
        next.whenData((state) {
          if (state.errorMessage != null) {
            _showSnackBar(context, state.errorMessage!, Colors.red);
            ref.read(premiumProvider.notifier).clearError();
          }
        });
      },
    );

    return premiumAsync.when(
      data: (state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1), // Very dark blue
                  Color(0xFF1565C0), // Dark blue
                  Color(0xFF1976D2), // Blue
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    const ModernHeaderWidget(
                      title: 'Planos',
                      subtitle: 'Gerencie sua assinatura premium',
                      leftIcon: Icons.workspace_premium,
                      isDark: true,
                      showBackButton: true,
                      showActions: false,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: state.isLoadingProducts
                          ? _buildLoadingView()
                          : state.isPremium
                              ? _buildActiveSubscriptionView()
                              : _buildPlansView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        body: _buildLoadingView(),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'Erro ao carregar dados: $error',
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Carregando informações...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionView() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SubscriptionStatusWidget(),

          SizedBox(height: 12),
          SubscriptionBenefitsWidget(
            showModernStyle: false,
          ),

          SizedBox(height: 12),
          PaymentActionsWidget(
            showSubscriptionManagement: true,
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPlansView() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tenha acesso ilimitado\na todos os recursos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),

          SizedBox(height: 24),
          SubscriptionPlansWidget(),

          SizedBox(height: 24),
          SubscriptionBenefitsWidget(
            showModernStyle: true,
          ),

          SizedBox(height: 32),
          PaymentActionsWidget(
            showPurchaseButton: true,
          ),

          SizedBox(height: 16),
          PaymentActionsWidget(
            showFooterLinks: true,
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

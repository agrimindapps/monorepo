import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_notifier.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_plans_widget.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  String? _selectedPlanId;
  bool _hasLoadedProducts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedProducts) {
        _hasLoadedProducts = true;
        ref.read(premiumProvider.notifier).loadAvailableProducts();
      }
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
          if (state.successMessage != null) {
            _showSnackBar(context, state.successMessage!, Colors.green);
            ref.read(premiumProvider.notifier).clearSuccess();
          }
        });
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBF360C), // Deep Orange 900
              Color(0xFFE64A19), // Deep Orange 700
              Color(0xFFFF5722), // Deep Orange 500
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: premiumAsync.when(
                  loading: () => _buildLoadingView(),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Erro ao carregar premium\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  data: (premiumState) {
                    return premiumState.isPremium
                        ? _buildActiveSubscriptionView(premiumState)
                        : _buildPlansView(premiumState);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header estilo Plantis/ReceitaAgro
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Text(
            'Premium Gasometer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildActiveSubscriptionView(PremiumNotifierState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPremiumStatusCard(),

          const SizedBox(height: 32),
          const SubscriptionBenefitsWidget(showModernStyle: false),

          const SizedBox(height: 32),
          PaymentActionsWidget(
            isPremium: true,
            isLoading: state.isLoading,
            showSubscriptionManagement: true,
            onManageSubscription: () => _manageSubscription(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlansView(PremiumNotifierState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tenha controle total\ndos seus veículos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 32),
          SubscriptionPlansWidget(
            availableProducts: state.availableProducts,
            selectedPlanId: _selectedPlanId,
            onPlanSelected: (planId) {
              setState(() {
                _selectedPlanId = planId;
              });
            },
          ),

          const SizedBox(height: 40),
          const SubscriptionBenefitsWidget(showModernStyle: true),

          const SizedBox(height: 40),
          PaymentActionsWidget(
            selectedPlanId: _selectedPlanId,
            isPremium: false,
            isLoading: state.isLoading,
            showPurchaseButton: true,
            showFooterLinks: true,
            onPurchase: () => _purchaseSelectedPlan(),
            onRestore: () => _restorePurchases(),
            onPrivacyPolicy: () => _openPrivacyPolicy(),
            onTermsOfService: () => _openTermsOfService(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPremiumStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Premium Ativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você tem acesso a todos os recursos premium do Gasometer',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSelectedPlan() async {
    if (_selectedPlanId == null) return;
    await ref.read(premiumProvider.notifier).purchaseProduct(_selectedPlanId!);
  }

  Future<void> _restorePurchases() async {
    await ref.read(premiumProvider.notifier).restorePurchases();
  }

  Future<void> _manageSubscription() async {
    _showSnackBar(context, 'Redirecionando para gerenciamento...', Colors.blue);
  }

  Future<void> _openPrivacyPolicy() async {
    _showSnackBar(context, 'Abrindo política de privacidade...', Colors.blue);
  }

  Future<void> _openTermsOfService() async {
    _showSnackBar(context, 'Abrindo termos de serviço...', Colors.blue);
  }

  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

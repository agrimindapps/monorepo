import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/modern_header_widget.dart';
import '../providers/subscription_notifier.dart';
import '../widgets/payment_actions_widget.dart';
import '../widgets/subscription_benefits_widget.dart';
import '../widgets/subscription_plans_widget.dart';
import '../widgets/subscription_status_widget.dart';

/// Página principal de subscription refatorada
///
/// Responsabilidades:
/// - Orchestração da UI principal
/// - Gerenciamento de mensagens/snackbars
/// - Loading state management
/// - Navegação entre diferentes views (ativo vs planos)
///
/// Estrutura:
/// - Header com título e botão de fechar
/// - Loading indicator quando necessário
/// - View ativa: SubscriptionStatusWidget
/// - View planos: SubscriptionPlansWidget + SubscriptionBenefitsWidget
/// - Footer com ações: PaymentActionsWidget
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionNotifierProvider.notifier).loadSubscriptionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    // Listen to state changes and show messages only when they change
    ref.listen<AsyncValue<SubscriptionState>>(
      subscriptionNotifierProvider,
      (previous, next) {
        next.whenData((state) {
          if (state.errorMessage != null) {
            _showSnackBar(context, state.errorMessage!, Colors.red);
            ref.read(subscriptionNotifierProvider.notifier).clearMessages();
          } else if (state.successMessage != null) {
            _showSnackBar(context, state.successMessage!, Colors.green);
            ref.read(subscriptionNotifierProvider.notifier).clearMessages();
          } else if (state.infoMessage != null) {
            _showSnackBar(context, state.infoMessage!, Colors.blue);
            ref.read(subscriptionNotifierProvider.notifier).clearMessages();
          }
        });
      },
    );

    return subscriptionState.when(
      data: (state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  ModernHeaderWidget(
                    title: 'Planos',
                    subtitle: 'Gerencie sua assinatura premium',
                    leftIcon: Icons.workspace_premium,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    showBackButton: true,
                    showActions: false,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: state.isLoading
                        ? _buildLoadingView()
                        : state.hasActiveSubscription
                            ? _buildActiveSubscriptionView()
                            : _buildPlansView(),
                  ),
                ],
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

  /// Loading view centralizado
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
      ),
    );
  }

  /// View para usuários com subscription ativa
  Widget _buildActiveSubscriptionView() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SubscriptionStatusWidget(),

          SizedBox(height: 12),
          SubscriptionBenefitsWidget(
            showModernStyle: false, // Estilo card para subscription ativa
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

  /// View para seleção de planos (usuário sem subscription)
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
            showModernStyle: true, // Estilo moderno para marketing
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

  /// Helper para mostrar snackbars
  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    if (mounted) {
      // Clear any existing snackbars to prevent duplicates
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';
import '../widgets/subscription_active_view_widget.dart';
import '../widgets/subscription_plans_view_widget.dart';

/// Página principal de subscription com Riverpod
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
/// - View ativa: SubscriptionActiveViewWidget
/// - View planos: SubscriptionPlansViewWidget
class SubscriptionRiverpodPage extends ConsumerStatefulWidget {
  const SubscriptionRiverpodPage({super.key});

  @override
  ConsumerState<SubscriptionRiverpodPage> createState() => _SubscriptionRiverpodPageState();
}

class _SubscriptionRiverpodPageState extends ConsumerState<SubscriptionRiverpodPage> {
  @override
  void initState() {
    super.initState();
    // Carrega dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).loadSubscriptionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);

    // Escutar mudanças de mensagens
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      _handleMessages(context, next);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B3E),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1B3E),
              Color(0xFF2D1B69),
              Color(0xFF4A148C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: subscriptionState.isLoading
                    ? _buildLoadingView()
                    : subscriptionState.hasActiveSubscription
                        ? const SubscriptionActiveViewWidget()
                        : const SubscriptionPlansViewWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o header da página
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Planos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a view de loading
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  /// Manipula mensagens de sucesso/erro/info
  void _handleMessages(BuildContext context, SubscriptionState state) {
    if (state.errorMessage != null) {
      _showSnackBar(
        context,
        state.errorMessage!,
        Colors.red,
      );
      // Limpar mensagem após mostrar
      Future.microtask(() => ref.read(subscriptionProvider.notifier).clearMessages());
    } else if (state.successMessage != null) {
      _showSnackBar(
        context,
        state.successMessage!,
        Colors.green,
      );
      Future.microtask(() => ref.read(subscriptionProvider.notifier).clearMessages());
    } else if (state.infoMessage != null) {
      _showSnackBar(
        context,
        state.infoMessage!,
        Colors.blue,
      );
      Future.microtask(() => ref.read(subscriptionProvider.notifier).clearMessages());
    }
  }

  /// Mostra snackbar com mensagem
  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
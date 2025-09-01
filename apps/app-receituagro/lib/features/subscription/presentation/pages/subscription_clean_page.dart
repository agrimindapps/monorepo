import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/subscription_provider.dart';
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
class SubscriptionCleanPage extends StatefulWidget {
  const SubscriptionCleanPage({super.key});

  @override
  State<SubscriptionCleanPage> createState() => _SubscriptionCleanPageState();
}

class _SubscriptionCleanPageState extends State<SubscriptionCleanPage> {
  
  @override
  void initState() {
    super.initState();
    // Inicializar carregamento dos dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscriptionData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          // Mostrar mensagens se existirem
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showMessages(context, provider);
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
                    // Header com título e botão de fechar
                    _buildHeader(context),
                    
                    // Conteúdo principal
                    Expanded(
                      child: provider.isLoading 
                          ? _buildLoadingView()
                          : provider.hasActiveSubscription
                              ? _buildActiveSubscriptionView(provider)
                              : _buildPlansView(provider),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Header padrão com título e botão de fechar
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

  /// Loading view centralizado
  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  /// View para usuários com subscription ativa
  Widget _buildActiveSubscriptionView(SubscriptionProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Status da subscription ativa
          SubscriptionStatusWidget(provider: provider),
          
          const SizedBox(height: 24),
          
          // Lista de recursos/benefícios
          SubscriptionBenefitsWidget(
            provider: provider,
            showModernStyle: false, // Estilo card para subscription ativa
          ),
          
          const SizedBox(height: 24),
          
          // Ações de gerenciamento
          PaymentActionsWidget(
            provider: provider,
            showSubscriptionManagement: true,
          ),
        ],
      ),
    );
  }

  /// View para seleção de planos (usuário sem subscription)
  Widget _buildPlansView(SubscriptionProvider provider) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Título principal
                const Text(
                  'Tenha acesso ilimitado\na todos os recursos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Seleção de planos
                SubscriptionPlansWidget(provider: provider),
                
                const SizedBox(height: 40),
                
                // Lista de benefícios/recursos
                SubscriptionBenefitsWidget(
                  provider: provider,
                  showModernStyle: true, // Estilo moderno para marketing
                ),
                
                const Spacer(),
                
                // Botão principal de compra
                PaymentActionsWidget(
                  provider: provider,
                  showPurchaseButton: true,
                ),
                
                const SizedBox(height: 20),
                
                // Links de rodapé (Termos, Privacidade, Restaurar)
                PaymentActionsWidget(
                  provider: provider,
                  showFooterLinks: true,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Exibe mensagens de erro, sucesso ou informação
  void _showMessages(BuildContext context, SubscriptionProvider provider) {
    if (provider.errorMessage != null) {
      _showSnackBar(
        context,
        provider.errorMessage!,
        Colors.red,
      );
      provider.clearMessages();
    } else if (provider.successMessage != null) {
      _showSnackBar(
        context,
        provider.successMessage!,
        Colors.green,
      );
      provider.clearMessages();
    } else if (provider.infoMessage != null) {
      _showSnackBar(
        context,
        provider.infoMessage!,
        Colors.blue,
      );
      provider.clearMessages();
    }
  }

  /// Helper para mostrar snackbars
  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
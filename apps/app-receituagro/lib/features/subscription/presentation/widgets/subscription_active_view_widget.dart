import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_riverpod_provider.dart';
import 'subscription_active_status_card_widget.dart';
import 'subscription_features_card_widget.dart';
import 'subscription_management_actions_widget.dart';

/// Widget responsável pela view quando usuário tem assinatura ativa
///
/// Responsabilidades:
/// - Mostrar status da assinatura ativa
/// - Exibir recursos premium disponíveis
/// - Fornecer ações de gerenciamento
///
/// Estrutura:
/// - ScrollView para suporte a diferentes tamanhos de tela
/// - SubscriptionActiveStatusCard: status e detalhes da assinatura
/// - SubscriptionFeaturesCard: lista de recursos premium
/// - SubscriptionManagementActions: botões de ação
class SubscriptionActiveViewWidget extends ConsumerWidget {
  const SubscriptionActiveViewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final currentSubscription = subscriptionState.currentSubscription;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          SubscriptionActiveStatusCardWidget(
            subscription: currentSubscription,
          ),
          
          const SizedBox(height: 20),
          
          // Features Card
          const SubscriptionFeaturesCardWidget(),
          
          const SizedBox(height: 20),
          
          // Management Actions
          const SubscriptionManagementActionsWidget(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
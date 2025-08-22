import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_providers.dart';
import '../pages/premium_page.dart';
import '../../domain/entities/user_limits.dart' as local;
import '../../domain/entities/usage_stats.dart' as local_stats;

class PremiumBanner extends ConsumerWidget {
  final VoidCallback? onUpgradePressed;

  const PremiumBanner({
    super.key,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremiumAsync = ref.watch(hasPremiumProvider);
    
    return hasPremiumAsync.when(
      data: (hasPremium) {
        if (hasPremium) {
          return _PremiumActiveBanner();
        } else {
          return _UpgradeBanner(onPressed: onUpgradePressed);
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _PremiumActiveBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(currentSubscriptionProvider);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premium Ativo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subscriptionAsync.when(
                  data: (subscription) {
                    if (subscription != null) {
                      final expiryDate = subscription.expirationDate;
                      if (expiryDate != null) {
                        return Text(
                          'Expira em ${_formatDate(expiryDate)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        );
                      }
                    }
                    return const Text(
                      'Aproveite todos os recursos',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showManagementOptions(context, ref),
            child: const Icon(
              Icons.settings,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showManagementOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ManagementBottomSheet(),
    );
  }
}

class _UpgradeBanner extends ConsumerWidget {
  final VoidCallback? onPressed;

  const _UpgradeBanner({this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageStatsAsync = ref.watch(usageStatsProvider);
    
    return usageStatsAsync.when(
      data: (stats) {
        final userLimitsAsync = ref.watch(userLimitsProvider(UserLimitsParams(
          currentTasks: stats.totalTasks,
          currentSubtasks: stats.totalSubtasks,
          currentTags: stats.totalTags,
          completedTasks: stats.completedTasks,
          completedSubtasks: stats.totalCompletedSubtasks,
        )));
        
        return userLimitsAsync.when(
          data: (limits) => _buildUpgradeBanner(context, stats, limits),
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, local_stats.UsageStats stats, local.UserLimits limits) {
    final isNearLimit = _isNearAnyLimit(limits);
    
    if (!isNearLimit) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Você está próximo do limite',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildLimitWarnings(limits),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed ?? () => _navigateToPremium(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Upgrade para Premium'),
            ),
          ),
        ],
      ),
    );
  }

  bool _isNearAnyLimit(local.UserLimits? limits) {
    if (limits == null) return false;
    if (limits.isPremium == true) return false;
    
    const threshold = 0.8; // 80% do limite
    
    return (limits.remainingTasks / limits.maxTasks) <= (1 - threshold) ||
           (limits.remainingSubtasks / limits.maxSubtasks) <= (1 - threshold) ||
           (limits.remainingTags / limits.maxTags) <= (1 - threshold);
  }

  List<Widget> _buildLimitWarnings(local.UserLimits? limits) {
    final warnings = <Widget>[];
    
    if (limits == null) return warnings;
    
    if (limits.remainingTasks <= 10) {
      warnings.add(_buildLimitWarning(
        'Tarefas: ${limits.maxTasks - limits.remainingTasks}/${limits.maxTasks}',
        limits.remainingTasks / limits.maxTasks,
      ));
    }
    
    if (limits.remainingSubtasks <= 2) {
      warnings.add(_buildLimitWarning(
        'Subtarefas: ${limits.maxSubtasks - limits.remainingSubtasks}/${limits.maxSubtasks}',
        limits.remainingSubtasks / limits.maxSubtasks,
      ));
    }
    
    if (limits.remainingTags <= 1) {
      warnings.add(_buildLimitWarning(
        'Tags: ${limits.maxTags - limits.remainingTags}/${limits.maxTags}',
        limits.remainingTags / limits.maxTags,
      ));
    }
    
    return warnings;
  }

  Widget _buildLimitWarning(String text, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 60,
            child: LinearProgressIndicator(
              value: 1 - progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.2 ? Colors.red : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PremiumPage(),
      ),
    );
  }
}

class _ManagementBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managementUrlAsync = ref.watch(managementUrlProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Gerenciar Assinatura',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Ver Histórico'),
            subtitle: const Text('Visualizar compras anteriores'),
            onTap: () => _showSubscriptionHistory(context, ref),
          ),
          
          managementUrlAsync.when(
            data: (url) {
              if (url != null) {
                return ListTile(
                  leading: const Icon(Icons.manage_accounts),
                  title: const Text('Gerenciar na Loja'),
                  subtitle: const Text('Cancelar ou modificar assinatura'),
                  onTap: () => _openManagementUrl(url),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const ListTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('Carregando...'),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restaurar Compras'),
            subtitle: const Text('Recuperar assinaturas anteriores'),
            onTap: () => _restorePurchases(context, ref),
          ),
          
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionHistory(BuildContext context, WidgetRef ref) {
    // Implementar visualização do histórico
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico de assinaturas')),
    );
  }

  void _openManagementUrl(String url) {
    // Implementar abertura da URL
    // launch(url);
  }

  void _restorePurchases(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    
    final actions = ref.read(subscriptionActionsProvider);
    final success = await actions.restorePurchases();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'Compras restauradas com sucesso!'
              : 'Nenhuma compra encontrada',
          ),
          backgroundColor: success ? Colors.green : null,
        ),
      );
    }
  }
}
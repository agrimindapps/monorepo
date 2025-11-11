import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../features/premium/presentation/premium_page.dart';
import '../providers/subscription_providers.dart';

/// Widget que controla acesso a features premium
class PremiumGate extends ConsumerWidget {
  final String featureName;
  final Widget child;
  final Widget? premiumChild;
  final VoidCallback? onPremiumRequired;
  final String? premiumMessage;
  final bool showPremiumDialog;

  const PremiumGate({
    super.key,
    required this.featureName,
    required this.child,
    this.premiumChild,
    this.onPremiumRequired,
    this.premiumMessage,
    this.showPremiumDialog = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFeatureAsync = ref.watch(hasFeatureProvider(featureName));

    return hasFeatureAsync.when(
      data: (hasFeature) {
        if (hasFeature) {
          return child;
        } else {
          return premiumChild ?? _buildPremiumPlaceholder(context);
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => child, // Em caso de erro, permite acesso
    );
  }

  Widget _buildPremiumPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => _handlePremiumRequired(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange[50],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, color: Colors.orange[700], size: 32),
            const SizedBox(height: 8),
            Text(
              premiumMessage ?? 'Feature Premium',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Toque para fazer upgrade',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handlePremiumRequired(BuildContext context) {
    if (onPremiumRequired != null) {
      onPremiumRequired!();
    } else if (showPremiumDialog) {
      _showPremiumDialog(context);
    } else {
      _navigateToPremium(context);
    }
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder:
          (context) => PremiumRequiredDialog(
            featureName: featureName,
            message: premiumMessage,
          ),
    );
  }

  void _navigateToPremium(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<dynamic>(builder: (context) => const PremiumPage()),
    );
  }
}

/// Widget para verificar limites de criação
class CreationLimitGate extends ConsumerWidget {
  final int currentCount;
  final String limitType; // 'tasks', 'subtasks', 'tags'
  final Widget child;
  final VoidCallback? onLimitReached;

  const CreationLimitGate({
    super.key,
    required this.currentCount,
    required this.limitType,
    required this.child,
    this.onLimitReached,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final AsyncValue<bool> canCreateAsync;

    switch (limitType) {
      case 'tasks':
        canCreateAsync = ref.watch(canCreateTasksProvider(currentCount));
        break;
      case 'subtasks':
        canCreateAsync = ref.watch(canCreateSubtasksProvider(currentCount));
        break;
      case 'tags':
        canCreateAsync = ref.watch(canCreateTagsProvider(currentCount));
        break;
      default:
        return child;
    }

    return canCreateAsync.when(
      data: (canCreate) {
        if (canCreate) {
          return child;
        } else {
          return _buildLimitReachedWidget(context);
        }
      },
      loading: () => child,
      error: (error, stack) => child,
    );
  }

  Widget _buildLimitReachedWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLimitReached(context),
      child: Opacity(
        opacity: 0.6,
        child: Stack(
          children: [
            child,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(77),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLimitReached(BuildContext context) {
    if (onLimitReached != null) {
      onLimitReached!();
    } else {
      _showLimitDialog(context);
    }
  }

  void _showLimitDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => LimitReachedDialog(limitType: limitType),
    );
  }
}

/// Dialog para quando uma feature premium é necessária
class PremiumRequiredDialog extends StatelessWidget {
  final String featureName;
  final String? message;

  const PremiumRequiredDialog({
    super.key,
    required this.featureName,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.workspace_premium, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Premium Necessário'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message ?? _getDefaultMessage(featureName)),
          const SizedBox(height: 16),
          const Text(
            'Com o Premium você tem acesso a:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._buildPremiumFeatures(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (context) => const PremiumPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
          ),
          child: const Text('Fazer Upgrade'),
        ),
      ],
    );
  }

  String _getDefaultMessage(String featureName) {
    switch (featureName) {
      case 'advanced_filtering':
        return 'Filtros avançados estão disponíveis apenas no Premium.';
      case 'time_tracking':
        return 'Controle de tempo está disponível apenas no Premium.';
      case 'custom_tags':
        return 'Tags personalizadas estão disponíveis apenas no Premium.';
      case 'export_data':
        return 'Exportação de dados está disponível apenas no Premium.';
      default:
        return 'Esta funcionalidade está disponível apenas no Premium.';
    }
  }

  List<Widget> _buildPremiumFeatures() {
    const features = [
      'Tarefas e subtarefas ilimitadas',
      'Filtros avançados',
      'Controle de tempo',
      'Tags personalizadas',
      'Sincronização na nuvem',
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.check, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(feature, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

/// Dialog para quando um limite é atingido
class LimitReachedDialog extends StatelessWidget {
  final String limitType;

  const LimitReachedDialog({super.key, required this.limitType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Limite Atingido'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getLimitMessage(limitType)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.workspace_premium, color: Colors.blue, size: 32),
                SizedBox(height: 8),
                Text(
                  'Premium = Ilimitado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Crie quantas tarefas, subtarefas e tags quiser',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (context) => const PremiumPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Upgrade'),
        ),
      ],
    );
  }

  String _getLimitMessage(String limitType) {
    switch (limitType) {
      case 'tasks':
        return 'Você atingiu o limite de 50 tarefas gratuitas. Faça upgrade para Premium e crie tarefas ilimitadas!';
      case 'subtasks':
        return 'Você atingiu o limite de 10 subtarefas gratuitas. Com Premium você pode criar subtarefas ilimitadas!';
      case 'tags':
        return 'Você atingiu o limite de 5 tags gratuitas. Com Premium você pode criar tags personalizadas ilimitadas!';
      default:
        return 'Você atingiu o limite da versão gratuita. Faça upgrade para Premium!';
    }
  }
}

import 'package:core/core.dart' hide SubscriptionState;
import 'package:flutter/material.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../providers/subscription_notifier.dart';

/// Premium Validation Widget for Cross-platform Premium Status
///
/// Features:
/// - Real-time premium status validation
/// - Cross-platform subscription sync
/// - Device-specific premium indicators
/// - Subscription conflict resolution
/// - Premium restoration functionality
class PremiumValidationWidget extends ConsumerStatefulWidget {
  final bool showFullDetails;
  final VoidCallback? onRestorePressed;
  final VoidCallback? onSyncPressed;

  const PremiumValidationWidget({
    super.key,
    this.showFullDetails = true,
    this.onRestorePressed,
    this.onSyncPressed,
  });

  @override
  ConsumerState<PremiumValidationWidget> createState() => _PremiumValidationWidgetState();
}

class _PremiumValidationWidgetState extends ConsumerState<PremiumValidationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final featureFlagsAsync = ref.watch(featureFlagsNotifierProvider);

    return subscriptionState.when(
      data: (state) => featureFlagsAsync.when(
        data: (featureFlagsState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildValidationCard(context, state, featureFlagsState),

            if (widget.showFullDetails) ...[
              const SizedBox(height: 16),
              _buildDeviceStatusCard(context, state),

              const SizedBox(height: 16),
              _buildSyncStatusCard(context, state, featureFlagsState),
            ],
            if (widget.showFullDetails) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erro: $error'),
      ),
    );
  }

  /// Main Premium Validation Card
  Widget _buildValidationCard(
    BuildContext context,
    SubscriptionState subscriptionState,
    FeatureFlagsState featureFlagsState,
  ) {
    final theme = Theme.of(context);
    final hasActiveSubscription = subscriptionState.hasActiveSubscription;
    final notifier = ref.read(featureFlagsNotifierProvider.notifier);
    final isValidationEnabled = notifier.isSubscriptionValidationEnabled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: hasActiveSubscription
            ? LinearGradient(
                colors: [Colors.green.shade600, Colors.teal.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.orange.shade600, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: hasActiveSubscription ? _pulseAnimation : _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: hasActiveSubscription ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasActiveSubscription 
                        ? Icons.verified_user
                        : Icons.warning_amber,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveSubscription ? 'Premium Ativo' : 'Premium Inativo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasActiveSubscription
                      ? 'Todos os recursos premium desbloqueados'
                      : 'Recursos premium bloqueados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (hasActiveSubscription) ...[
                  const SizedBox(height: 8),
                  _buildSubscriptionDetails(context, subscriptionState),
                ],
              ],
            ),
          ),
          if (isValidationEnabled)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    _isValidating ? Icons.sync : Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isValidating ? 'SYNC' : 'OK',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Subscription Details
  Widget _buildSubscriptionDetails(BuildContext context, SubscriptionState subscriptionState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            _formatExpiryDate(subscriptionState.subscriptionExpiryDate),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Device-specific Premium Status Card
  Widget _buildDeviceStatusCard(BuildContext context, SubscriptionState subscriptionState) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status do Dispositivo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              context,
              'Validação Local',
              subscriptionState.hasLocalPremiumValidation ? 'Ativa' : 'Inativa',
              subscriptionState.hasLocalPremiumValidation,
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              context,
              'Sincronização Premium',
              subscriptionState.isPremiumSyncActive ? 'Sincronizado' : 'Pendente',
              subscriptionState.isPremiumSyncActive,
            ),
            const SizedBox(height: 8),
            _buildStatusItem(
              context,
              'Cache Premium',
              subscriptionState.hasPremiumCache ? 'Disponível' : 'Indisponível',
              subscriptionState.hasPremiumCache,
            ),
          ],
        ),
      ),
    );
  }

  /// Cross-platform Sync Status Card
  Widget _buildSyncStatusCard(
    BuildContext context,
    SubscriptionState subscriptionState,
    FeatureFlagsState featureFlagsState,
  ) {
    final theme = Theme.of(context);
    final notifier = ref.read(featureFlagsNotifierProvider.notifier);
    final isSyncEnabled = notifier.isContentSynchronizationEnabled;
    final isIOSPremiumActive = subscriptionState.hasActiveSubscription;
    final isAndroidPremiumActive = subscriptionState.hasActiveSubscription;
    const isWebPremiumActive = false; // Web ainda não tem subscription

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sync_alt,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sincronização Cross-platform',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (isSyncEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ATIVO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (isSyncEnabled) ...[
              _buildSyncItem(
                context,
                'iOS',
                isIOSPremiumActive,
                Icons.phone_iphone,
              ),
              const SizedBox(height: 8),
              _buildSyncItem(
                context,
                'Android',
                isAndroidPremiumActive,
                Icons.android,
              ),
              const SizedBox(height: 8),
              _buildSyncItem(
                context,
                'Web',
                isWebPremiumActive,
                Icons.web,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sincronização cross-platform não disponível no momento',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Status Item Widget
  Widget _buildStatusItem(BuildContext context, String label, String status, bool isActive) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          status,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Sync Item Widget
  Widget _buildSyncItem(BuildContext context, String platform, bool isActive, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          platform,
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isActive 
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isActive ? 'ATIVO' : 'INATIVO',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive ? Colors.green : Colors.grey.shade600,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isValidating ? null : _restorePurchases,
            icon: const Icon(Icons.restore, size: 16),
            label: const Text('Restaurar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isValidating ? null : _syncPremiumStatus,
            icon: _isValidating 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync, size: 16),
            label: Text(_isValidating ? 'Sincronizando...' : 'Sincronizar'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Restore Purchases Action
  Future<void> _restorePurchases() async {
    if (widget.onRestorePressed != null) {
      widget.onRestorePressed!();
    } else {
      await ref.read(subscriptionNotifierProvider.notifier).restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tentativa de restauração concluída'),
          ),
        );
      }
    }
  }

  /// Sync Premium Status Action
  Future<void> _syncPremiumStatus() async {
    setState(() {
      _isValidating = true;
    });

    try {
      if (widget.onSyncPressed != null) {
        widget.onSyncPressed!();
      } else {
        final notifier = ref.read(subscriptionNotifierProvider.notifier);
        await notifier.validatePremiumStatus();
        await notifier.syncPremiumStatus();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status Premium sincronizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na sincronização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  /// Format subscription expiry date
  String _formatExpiryDate(DateTime? expiryDate) {
    if (expiryDate == null) return 'Sem limite';
    
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    
    if (difference < 0) return 'Expirado';
    if (difference == 0) return 'Expira hoje';
    if (difference == 1) return 'Expira amanhã';
    if (difference < 30) return 'Expira em $difference dias';
    
    return 'Ativo até ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}';
  }
}
import 'package:flutter/material.dart';
import '../../../../core/services/auth_rate_limiter.dart';

/// Widget para mostrar informações de rate limiting de login
class RateLimitInfoWidget extends StatelessWidget {
  final AuthRateLimitInfo rateLimitInfo;
  final VoidCallback? onReset; // Para desenvolvimento/admin apenas
  
  const RateLimitInfoWidget({
    super.key,
    required this.rateLimitInfo,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (rateLimitInfo.isLocked) {
      return _buildLockoutCard(context);
    }
    
    if (rateLimitInfo.warningMessage.isNotEmpty) {
      return _buildWarningCard(context);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildLockoutCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outlined,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conta Temporariamente Bloqueada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rateLimitInfo.lockoutMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            if (rateLimitInfo.lockoutTimeRemainingMinutes > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1 - (rateLimitInfo.lockoutTimeRemainingMinutes / rateLimitInfo.lockoutDurationMinutes),
                backgroundColor: theme.colorScheme.error.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.error),
              ),
              const SizedBox(height: 4),
              Text(
                'Tempo restante: ${rateLimitInfo.lockoutTimeRemainingMinutes} min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer.withOpacity(0.8),
                ),
              ),
            ],
            if (onReset != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset (Dev)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      color: theme.colorScheme.warningContainer ?? Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: theme.colorScheme.warning ?? Colors.orange.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rateLimitInfo.warningMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onWarningContainer ?? Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extensões para adicionar cores de warning ao ColorScheme se não existirem
extension ColorSchemeWarning on ColorScheme {
  Color? get warningContainer => brightness == Brightness.light
      ? Colors.orange.shade50
      : Colors.orange.shade900.withOpacity(0.3);
      
  Color? get onWarningContainer => brightness == Brightness.light
      ? Colors.orange.shade800
      : Colors.orange.shade200;
      
  Color? get warning => brightness == Brightness.light
      ? Colors.orange.shade700
      : Colors.orange.shade400;
}
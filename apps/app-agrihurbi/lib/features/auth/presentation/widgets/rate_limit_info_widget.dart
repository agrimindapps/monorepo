import 'package:app_agrihurbi/core/theme/design_tokens.dart';
import 'package:app_agrihurbi/features/auth/domain/services/auth_rate_limiter.dart';
import 'package:flutter/material.dart';

/// Widget para exibir informações de rate limiting ao usuário
class RateLimitInfoWidget extends StatelessWidget {
  const RateLimitInfoWidget({
    super.key,
    required this.rateLimitInfo,
  });

  final AuthRateLimitInfo rateLimitInfo;

  @override
  Widget build(BuildContext context) {
    if (rateLimitInfo.isLocked) {
      return _buildLockoutMessage();
    }

    if (rateLimitInfo.warningMessage.isNotEmpty) {
      return _buildWarningMessage();
    }

    return const SizedBox.shrink();
  }

  Widget _buildLockoutMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DesignTokens.errorColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_clock,
              color: DesignTokens.errorColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conta Temporariamente Bloqueada',
                  style: TextStyle(
                    color: DesignTokens.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rateLimitInfo.lockoutMessage,
                  style: TextStyle(
                    color: DesignTokens.errorColor.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignTokens.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: DesignTokens.warningColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rateLimitInfo.warningMessage,
              style: TextStyle(
                color: DesignTokens.warningColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

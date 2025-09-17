import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/components/user_avatar_widget.dart';
import '../../../../core/presentation/widgets/standard_loading_view.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountSectionWidget extends StatelessWidget {
  const AccountSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          children: [
            if (!authProvider.isInitialized)
              _buildAccountLoadingCard(context)
            else if (authProvider.isAuthenticated)
              _buildAuthenticatedAccountCard(context, authProvider)
            else
              _buildUnauthenticatedAccountCard(context, authProvider),
            const SizedBox(height: 16),
            _buildPremiumCard(context, authProvider),
          ],
        );
      },
    );
  }


  Widget _buildAccountLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          const StandardLoadingView(height: 120),
          const SizedBox(height: 16),
          Text(
            'Verificando estado da conta...',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedAccountCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final isAnonymous = authProvider.isAnonymous;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/profile');
          },
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                UserAvatarLarge(
                  user: user,
                  size: 80,
                  showEditIcon: true,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnonymous 
                            ? 'Usuário Anônimo'
                            : user?.displayName ?? 'Usuário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAnonymous 
                            ? 'Dados salvos localmente'
                            : user?.email ?? 'Email não disponível',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      if (authProvider.isPremium) ...[  
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: GasometerDesignTokens.colorPremiumAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedAccountCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: GasometerDesignTokens.iconSizeXxl,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Faça login em sua conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse recursos avançados, sincronize seus\ndados e mantenha suas informações seguras',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          
          // Show error message if any
          if (authProvider.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => authProvider.clearError(),
                    icon: const Icon(Icons.close, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: authProvider.isLoading ? null : () {
                    HapticFeedback.lightImpact();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Fazer Login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: authProvider.isLoading ? null : () {
                    HapticFeedback.lightImpact();
                    _handleAnonymousLogin(context, authProvider);
                  },
                  icon: authProvider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.visibility_off, size: 16),
                  label: Text(
                    authProvider.isLoading ? 'Entrando...' : 'Modo Anônimo',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isPremium) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GasometerDesignTokens.getPremiumBackgroundWithOpacity(0.1),
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          border: Border.all(
            color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: GasometerDesignTokens.colorPremiumAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: GasometerDesignTokens.iconSizeListItem,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GasOMeter Premium Ativo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aproveitando todos os recursos avançados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => context.go('/premium'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: GasometerDesignTokens.colorPremiumAccent),
                foregroundColor: GasometerDesignTokens.colorPremiumAccent,
              ),
              child: const Text('Gerenciar'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: GasometerDesignTokens.colorPremiumAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: GasometerDesignTokens.iconSizeListItem,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GasOMeter Premium',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Desbloqueie recursos avançados e tenha a\nmelhor experiência',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.go('/premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GasometerDesignTokens.colorPremiumAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upgrade'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPremiumFeature(
            context,
            icon: Icons.bar_chart,
            title: 'Relatórios Avançados',
            subtitle: 'Análises detalhadas de consumo e economia',
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: GasometerDesignTokens.getPremiumBackgroundWithOpacity(0.1),
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusSm),
          ),
          child: Icon(
            icon,
            color: GasometerDesignTokens.colorPremiumAccent,
            size: GasometerDesignTokens.iconSizeXs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Auth handling methods
  Future<void> _handleAnonymousLogin(BuildContext context, AuthProvider authProvider) async {
    await authProvider.signInAnonymously();
    if (context.mounted && authProvider.errorMessage != null) {
      _showSnackBar(context, authProvider.errorMessage!);
    } else if (context.mounted) {
      _showSnackBar(context, 'Login anônimo realizado com sucesso');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
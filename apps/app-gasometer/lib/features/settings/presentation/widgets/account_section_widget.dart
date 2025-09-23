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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
      ),
    );
  }

  Widget _buildAuthenticatedAccountCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final isAnonymous = authProvider.isAnonymous;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
    ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isPremium) {
      return Card(
        elevation: 8,
        shadowColor: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.05),
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.15),
                GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.08),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
            border: Border.all(
              color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header with premium avatar
                Row(
                  children: [
                    // Hero Avatar Premium
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            GasometerDesignTokens.colorPremiumAccent,
                            GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
                            GasometerDesignTokens.colorPrimary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Premium Ativo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: GasometerDesignTokens.colorPremiumAccent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      GasometerDesignTokens.colorPremiumAccent,
                                      GasometerDesignTokens.colorPrimary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'ATIVO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Todos os recursos premium desbloqueados',
                            style: TextStyle(
                              fontSize: 14,
                              color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Premium Benefits
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benefícios Ativos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: GasometerDesignTokens.colorPremiumAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        context,
                        Icons.auto_awesome,
                        'Relatórios avançados ilimitados',
                        GasometerDesignTokens.colorPremiumAccent,
                      ),
                      const SizedBox(height: 8),
                      _buildBenefitItem(
                        context,
                        Icons.cloud_sync,
                        'Sincronização em nuvem',
                        GasometerDesignTokens.colorPremiumAccent,
                      ),
                      const SizedBox(height: 8),
                      _buildBenefitItem(
                        context,
                        Icons.support_agent,
                        'Suporte prioritário 24/7',
                        GasometerDesignTokens.colorPremiumAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Management Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/premium'),
                    icon: const Icon(Icons.settings, size: 20),
                    label: Text(
                      'Gerenciar Assinatura',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GasometerDesignTokens.colorPremiumAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/premium'),
          borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GasometerDesignTokens.colorPrimary.withValues(alpha: 0.9),
                  GasometerDesignTokens.colorPrimary,
                  GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: GasometerDesignTokens.borderRadius(GasometerDesignTokens.radiusDialog),
              border: Border.all(
                color: GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Premium Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            GasometerDesignTokens.colorPremiumAccent,
                            GasometerDesignTokens.colorPremiumAccent.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'GasOMeter Premium',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Desbloqueie recursos avançados',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

  /// Build benefit item widget
  Widget _buildBenefitItem(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
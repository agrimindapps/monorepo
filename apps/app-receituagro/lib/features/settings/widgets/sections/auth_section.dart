import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../constants/settings_design_tokens.dart';
import '../../pages/profile_page.dart';

/// Seção simplificada de usuário nas configurações
/// Mostra apenas resumo do usuário com navegação para perfil completo
class AuthSection extends ConsumerWidget {
  const AuthSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return _buildLoadingSection(context);
    }

    if (!authState.isAuthenticated || authState.isAnonymous) {
      return _buildGuestSummary(context);
    }

    return _buildUserSummary(context, authState);
  }

  Widget _buildLoadingSection(BuildContext context) {
    return Container(
      decoration: SettingsDesignTokens.getCardDecoration(context),
      margin: SettingsDesignTokens.sectionMargin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: SettingsDesignTokens.getCardDecoration(context),
      margin: SettingsDesignTokens.sectionMargin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToLogin(context),
          borderRadius: BorderRadius.circular(
            SettingsDesignTokens.cardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade400, Colors.grey.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visitante',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toque para fazer login ou criar conta',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: SettingsDesignTokens.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Faça login para sincronizar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SettingsDesignTokens.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSummary(
    BuildContext context,
    AuthState authState,
  ) {
    final user = authState.currentUser!;
    final theme = Theme.of(context);
    final createdDate = user.createdAt != null
        ? _formatDate(user.createdAt!)
        : 'Data não disponível';

    final userInitial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : (user.email.isNotEmpty ? user.email[0].toUpperCase() : '?');

    return Container(
      decoration: SettingsDesignTokens.getCardDecoration(context),
      margin: SettingsDesignTokens.sectionMargin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToUserProfile(context),
          borderRadius: BorderRadius.circular(
            SettingsDesignTokens.cardBorderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            SettingsDesignTokens.primaryColor,
                            Color(0xFF66BB6A), // Slightly lighter green
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: SettingsDesignTokens.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            userInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (user.isEmailVerified)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: SettingsDesignTokens.successColor,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : user.email,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user.displayName.isNotEmpty &&
                              user.email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 4),
                          Text(
                            'Membro desde $createdDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
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

  void _navigateToLogin(BuildContext context) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      );
    }
  }

  void _navigateToUserProfile(BuildContext context) {
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const ProfilePage()),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildErrorSection(BuildContext context, Object error) {
    return Container(
      decoration: SettingsDesignTokens.getCardDecoration(context),
      margin: SettingsDesignTokens.sectionMargin,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados do usuário',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

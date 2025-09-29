import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider_lib;

import '../../../../core/providers/auth_provider.dart';
import '../../constants/settings_design_tokens.dart';
import '../../pages/profile_page.dart';

/// Seção simplificada de usuário nas configurações
/// Mostra apenas resumo do usuário com navegação para perfil completo
class AuthSection extends StatelessWidget {
  const AuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return provider_lib.Consumer<ReceitaAgroAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return _buildLoadingSection(context);
        }

        if (!authProvider.isAuthenticated || authProvider.isAnonymous) {
          return _buildGuestSummary(context);
        }

        return _buildUserSummary(context, authProvider);
      },
    );
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
          onTap: () => _navigateToUserProfile(context),
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
    ReceitaAgroAuthProvider authProvider,
  ) {
    final user = authProvider.currentUser!;
    final theme = Theme.of(context);
    final createdDate =
        user.createdAt != null
            ? _formatDate(user.createdAt!)
            : 'Data não disponível';

    final userInitial =
        user.displayName.isNotEmpty
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
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar Hero com gradiente
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

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome/Email principal
                          Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : user.email,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Email secundário (se houver nome)
                          if (user.displayName.isNotEmpty &&
                              user.email.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Data de criação
                          Text(
                            'Membro desde $createdDate',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action button
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

  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const ProfilePage()),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

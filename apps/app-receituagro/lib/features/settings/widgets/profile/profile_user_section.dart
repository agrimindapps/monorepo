import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/settings_design_tokens.dart';

/// Widget para exibir informações do usuário (avatar, nome, email)
/// Responsabilidade: Display de avatar, nome, email, membro desde
class ProfileUserSection extends ConsumerWidget {
  const ProfileUserSection({
    required this.authData,
    this.onLoginTap,
    super.key,
  });

  final dynamic authData;
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bool isAuthBool = authData?.isAuthenticated == true;
    final bool isAnonBool = authData?.isAnonymous == true;
    final isAuthenticated = isAuthBool && !isAnonBool;
    final user = authData?.currentUser;

    return Container(
      decoration: _getCardDecoration(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: !isAuthenticated ? onLoginTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isAuthenticated
                        ? SettingsDesignTokens.primaryColor
                        : Colors.grey.shade400,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isAuthenticated
                          ? SettingsDesignTokens.primaryColor.withValues(
                              alpha: 0.3,
                            )
                          : Colors.grey.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: isAuthenticated
                      ? SettingsDesignTokens.primaryColor
                      : Colors.grey.shade400,
                  child: Text(
                    _getInitials(_getUserDisplayTitle(user)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAuthenticated
                                ? _getUserDisplayTitle(user)
                                : 'Visitante',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAuthenticated
                          ? _getUserEmail(user)
                          : 'Faça login para acessar recursos completos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isAuthenticated && user?.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getMemberSince(user?.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isAuthenticated)
                Icon(Icons.login, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  /// Obter iniciais do nome
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Obter título para exibição do usuário
  String _getUserDisplayTitle(dynamic user) {
    if (user == null) return 'Usuário';
    
    // Se user é UserEntity, usa extension
    if (user is UserEntity) {
      return user.safeDisplayName;
    }
    
    // Fallback para acesso dinâmico
    final displayName = user?.displayName;
    if (displayName != null &&
        displayName is String &&
        displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    
    // Fallback para parte do email (antes do @)
    final email = user?.email;
    if (email is String && email.trim().isNotEmpty) {
      final emailParts = email.split('@');
      if (emailParts.isNotEmpty && emailParts.first.isNotEmpty) {
        return emailParts.first;
      }
    }
    
    return 'Usuário';
  }

  /// Obter email do usuário
  String _getUserEmail(dynamic user) {
    if (user == null) return 'email@usuario.com';
    
    // Se user é UserEntity, usa extension
    if (user is UserEntity) {
      return user.safeEmail;
    }
    
    // Fallback para acesso dinâmico
    final email = user?.email;
    if (email is String && email.trim().isNotEmpty) {
      return email.trim();
    }
    
    return 'email@usuario.com';
  }

  /// Helper: Obter tempo de membro
  String _getMemberSince(dynamic createdAt) {
    if (createdAt == null) return 'Membro desde 10 dias';
    final DateTime date = createdAt is DateTime ? createdAt : DateTime.now();

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return 'Membro desde ${difference.inDays} dias';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Membro desde $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Membro desde $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  /// Helper: Decoração de card
  BoxDecoration _getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

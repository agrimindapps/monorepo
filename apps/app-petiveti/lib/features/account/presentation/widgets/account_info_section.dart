import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart'
    hide AuthState, AuthStatus, deviceManagementProvider;
import 'package:flutter/material.dart';

import '../../../../core/services/data_sanitization_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountInfoSection extends ConsumerStatefulWidget {
  const AccountInfoSection({super.key});

  @override
  ConsumerState<AccountInfoSection> createState() => _AccountInfoSectionState();
}

class _AccountInfoSectionState extends ConsumerState<AccountInfoSection> {
  Future<void> _handleImageSelection(bool hasCurrentImage) async {
    final imageService = ref.read(localProfileImageServiceProvider);

    await ProfileImagePickerWidget.show(
      context: context,
      hasCurrentImage: hasCurrentImage,
      onImageSelected: (File file) {
        imageService.processImageToBase64(file).then((result) {
          result.fold(
            (failure) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(failure.message)));
              }
            },
            (base64String) async {
              final updateResult = await ref
                  .read(authProvider.notifier)
                  .updateProfile(null, base64String);
              if (mounted) {
                if (updateResult) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto de perfil atualizada!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao atualizar foto: ${ref.read(authProvider).error ?? "Erro desconhecido"}',
                      ),
                    ),
                  );
                }
              }
            },
          );
        });
      },
      onRemoveImage: () async {
        final updateResult = await ref
            .read(authProvider.notifier)
            .updateProfile(null, null);
        if (mounted) {
          if (updateResult) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto de perfil removida!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Erro ao remover foto: ${ref.read(authProvider).error ?? "Erro desconhecido"}',
                ),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _handleChangePassword() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.email.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Senha'),
        content: Text(
          'Deseja enviar um email de redefinição de senha para ${user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ref
          .read(authProvider.notifier)
          .sendPasswordResetEmail(user.email);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email de redefinição enviado! Verifique sua caixa de entrada.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar email de redefinição.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = authState.user;
    final isAnonymous =
        authState.status == AuthStatus.unauthenticated ||
        user?.provider.name == 'anonymous';

    if (user == null) {
      return const SizedBox.shrink();
    }

    final displayName =
        user.name ??
        DataSanitizationService.sanitizeDisplayName(null, isAnonymous);
    final email = user.email;
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar e informações básicas
            Row(
              children: [
                GestureDetector(
                  onTap: !isAnonymous
                      ? () => _handleImageSelection(hasPhoto)
                      : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !isAnonymous
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: !isAnonymous
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : Colors.grey.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: !isAnonymous
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          backgroundImage: hasPhoto
                              ? (user.photoUrl!.startsWith('http')
                                    ? NetworkImage(user.photoUrl!)
                                    : MemoryImage(base64Decode(user.photoUrl!))
                                          as ImageProvider)
                              : null,
                          child: !hasPhoto
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (!isAnonymous)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isAnonymous)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Funcionalidade em desenvolvimento',
                                    ),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isAnonymous) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Membro desde ${_formatDate(user.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (!isAnonymous) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Seção de Informações da Conta
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informações da Conta',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Último acesso',
                _formatDate(user.lastLoginAt),
              ),
              if (!isAnonymous && user.provider == AuthProvider.email) ...[
                const SizedBox(height: 8),
                _buildActionRow(
                  context,
                  'Senha',
                  'Alterar',
                  Icons.lock_reset,
                  _handleChangePassword,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    String label,
    String actionLabel,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final DateTime dateTime = date is DateTime ? date : DateTime.now();
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }
}

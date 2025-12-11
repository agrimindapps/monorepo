import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart' hide AuthState;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../constants/settings_design_tokens.dart';

/// Widget combinado para exibir e editar informações do usuário e da conta
class ProfileCombinedInfoSection extends ConsumerStatefulWidget {
  const ProfileCombinedInfoSection({
    required this.authData,
    this.onLoginTap,
    this.onEditProfile,
    this.onChangePassword,
    super.key,
  });

  final AuthState authData;
  final VoidCallback? onLoginTap;
  final void Function(String, String?)? onEditProfile;
  final VoidCallback? onChangePassword;

  @override
  ConsumerState<ProfileCombinedInfoSection> createState() =>
      _ProfileCombinedInfoSectionState();
}

class _ProfileCombinedInfoSectionState
    extends ConsumerState<ProfileCombinedInfoSection> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    final user = widget.authData.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    // Se o usuário já tiver imagem em base64 ou URL, inicializar aqui
    final photoUrl = user?.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Lógica para verificar se é base64 ou url se necessário
      // Por enquanto vamos assumir que se não começar com http, é base64 (simplificação)
      if (!photoUrl.startsWith('http')) {
        _imageBase64 = photoUrl;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageService = ref.read(localProfileImageServiceProvider);

    await ProfileImagePickerWidget.show(
      context: context,
      hasCurrentImage: _imageBase64 != null ||
          (widget.authData.currentUser?.photoUrl != null),
      onImageSelected: (File file) async {
        final result = await imageService.processImageToBase64(file);
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
          },
          (base64String) {
            setState(() {
              _imageBase64 = base64String;
            });
            if (!_isEditing) {
              widget.onEditProfile?.call(_nameController.text, _imageBase64);
            }
          },
        );
      },
      onRemoveImage: () {
        setState(() {
          _imageBase64 = null;
        });
        if (!_isEditing) {
          widget.onEditProfile?.call(_nameController.text, null);
        }
      },
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Salvar alterações
        widget.onEditProfile?.call(_nameController.text, _imageBase64);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAuthBool = widget.authData.isAuthenticated;
    final bool isAnonBool = widget.authData.isAnonymous;
    final isAuthenticated = isAuthBool && !isAnonBool;
    final user = widget.authData.currentUser;

    // Atualiza o controller se o usuário mudar externamente e não estiver editando
    if (!_isEditing &&
        user != null &&
        _nameController.text != user.displayName) {
      _nameController.text = user.displayName;
    }

    return Container(
      decoration: _getCardDecoration(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cabeçalho com Avatar e Nome
            Row(
              children: [
                GestureDetector(
                  onTap: isAuthenticated ? _pickImage : widget.onLoginTap,
                  child: Stack(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
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
                                  ? SettingsDesignTokens.primaryColor
                                        .withValues(alpha: 0.3)
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
                          backgroundImage: _imageBase64 != null
                              ? MemoryImage(base64Decode(_imageBase64!))
                              : (user != null &&
                                        user.photoUrl != null &&
                                        user.photoUrl!.startsWith('http')
                                    ? NetworkImage(user.photoUrl!)
                                    : null),
                          child:
                              (_imageBase64 == null &&
                                  (user?.photoUrl == null ||
                                      user!.photoUrl!.isEmpty))
                              ? Text(
                                  _getInitials(_getUserDisplayTitle(user)),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (isAuthenticated)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
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
                      if (_isEditing)
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getUserDisplayTitle(user),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAuthenticated)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: _toggleEdit,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Visitante',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isAuthenticated) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Membro desde ${_formatDate(user?.createdAt)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade800,
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
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _toggleEdit,
                    color: Colors.green,
                  ),
              ],
            ),

            if (isAuthenticated) ...[
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
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Último acesso',
                _formatDate(DateTime.now()),
              ),
              if (widget.onChangePassword != null) ...[
                const SizedBox(height: 8),
                _buildActionRow(
                  context,
                  'Senha',
                  'Alterar',
                  Icons.lock_reset,
                  widget.onChangePassword!,
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
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: theme.colorScheme.primary),
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

  String _getUserDisplayTitle(UserEntity? user) {
    if (user == null) return 'Visitante';
    if (user.displayName.isNotEmpty) {
      return user.displayName;
    }
    return user.email;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final DateTime dateTime = date is DateTime ? date : DateTime.now();
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

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

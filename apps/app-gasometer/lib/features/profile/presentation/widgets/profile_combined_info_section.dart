import 'dart:io';

import 'package:core/core.dart' hide AuthState;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../controllers/profile_controller.dart';
import 'profile_image_picker_widget.dart';

/// Widget combinado para exibir e editar informações do usuário e da conta
/// Adaptado do app-receituagro para o app-gasometer
class ProfileCombinedInfoSection extends ConsumerStatefulWidget {
  const ProfileCombinedInfoSection({
    required this.user,
    required this.isAnonymous,
    required this.profileController,
    this.onLoginTap,
    this.onChangePassword,
    super.key,
  });

  final dynamic user; // UserEntity or similar
  final bool isAnonymous;
  final ProfileController profileController;
  final VoidCallback? onLoginTap;
  final VoidCallback? onChangePassword;

  @override
  ConsumerState<ProfileCombinedInfoSection> createState() =>
      _ProfileCombinedInfoSectionState();
}

class _ProfileCombinedInfoSectionState
    extends ConsumerState<ProfileCombinedInfoSection> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _getUserDisplayName());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getUserDisplayName() {
    if (widget.user == null) return '';
    // Handle different user objects if necessary, assuming standard UserEntity structure
    try {
      return (widget.user.displayName as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  String? _getUserPhotoUrl() {
    if (widget.user == null) return null;
    try {
      return widget.user.photoUrl as String?;
    } catch (_) {
      return null;
    }
  }

  String _getUserEmail() {
    if (widget.user == null) return 'Visitante';
    try {
      return (widget.user.email as String?) ?? 'Visitante';
    } catch (_) {
      return 'Visitante';
    }
  }

  DateTime? _getUserCreatedAt() {
    if (widget.user == null) return null;
    try {
      return widget.user.createdAt as DateTime?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    // Use existing ProfileImagePickerWidget logic or direct picker
    // Using ProfileImagePickerWidget.show to maintain app consistency with features
    // but triggered from the avatar tap
    await ProfileImagePickerWidget.show(
      context: context,
      hasCurrentImage: _getUserPhotoUrl() != null,
      onImageSelected: (File file) {
        widget.profileController.processNewAvatarImage(context, ref, file);
      },
      onRemoveImage: () {
        widget.profileController.removeCurrentAvatar(context, ref);
      },
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Save changes
        if (_nameController.text != _getUserDisplayName()) {
          widget.profileController.updateName(
            context,
            ref,
            _nameController.text,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAuthenticated = !widget.isAnonymous;
    final userDisplayName = _getUserDisplayName();

    // Update controller if user changes externally and not editing
    if (!_isEditing && _nameController.text != userDisplayName) {
      _nameController.text = userDisplayName;
    }

    return Container(
      decoration: _getCardDecoration(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with Avatar and Name
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
                                ? GasometerDesignTokens.colorPrimary
                                : GasometerDesignTokens.colorNeutral400,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAuthenticated
                                  ? GasometerDesignTokens.colorPrimary
                                        .withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: isAuthenticated
                              ? GasometerDesignTokens.colorPrimary
                              : GasometerDesignTokens.colorNeutral400,
                          backgroundImage: _getUserPhotoUrl() != null
                              ? NetworkImage(_getUserPhotoUrl()!)
                              : null,
                          child: _getUserPhotoUrl() == null
                              ? Text(
                                  _getInitials(
                                    userDisplayName.isEmpty
                                        ? _getUserEmail()
                                        : userDisplayName,
                                  ),
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
                              color: GasometerDesignTokens.colorPrimary,
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
                                userDisplayName.isNotEmpty
                                    ? userDisplayName
                                    : (isAuthenticated
                                          ? 'Usuário sem nome'
                                          : 'Visitante'),
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
                                color: GasometerDesignTokens.colorPrimary,
                              ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _getUserEmail(),
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
                            color: GasometerDesignTokens.colorAccent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 12,
                                color: GasometerDesignTokens.colorAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Membro desde ${_formatDate(_getUserCreatedAt())}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: GasometerDesignTokens.colorAccent,
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
                    color: GasometerDesignTokens.colorSuccess,
                  ),
              ],
            ),

            if (isAuthenticated) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Account Info Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informações da Conta',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GasometerDesignTokens.colorPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                'Último acesso',
                _formatDate(widget.user?.lastSignInAt),
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
                    color: GasometerDesignTokens.colorSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 16,
                  color: GasometerDesignTokens.colorSecondary,
                ),
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

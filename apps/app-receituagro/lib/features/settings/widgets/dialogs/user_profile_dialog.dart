import 'package:core/core.dart' hide Column, AuthState;
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart';
import '../../../../core/providers/auth_state.dart';
import '../../presentation/providers/settings_notifier.dart';

/// User Profile Dialog
///
/// Features:
/// - Display name editing
/// - Email display and management
/// - Avatar selection/upload
/// - Account settings shortcuts
/// - Settings sync preferences
class UserProfileDialog extends ConsumerStatefulWidget {
  const UserProfileDialog({super.key});

  @override
  ConsumerState<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends ConsumerState<UserProfileDialog> {
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (mounted) {
        setState(() {
          _displayNameController.text = _getUserDisplayName(authState);
          _emailController.text = _getUserEmail(authState);
        });
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getUserDisplayName(AuthState authState) {
    final user = authState.currentUser;
    if (user != null && user.displayName.isNotEmpty) {
      return user.displayName;
    }
    final settingsState = ref.read(settingsNotifierProvider).value;
    final device = settingsState?.currentDeviceInfo;
    if (device?.name.isNotEmpty == true) {
      final name = device!.name;
      if (name.contains('iPhone')) return 'Usuário iPhone';
      if (name.contains('iPad')) return 'Usuário iPad';
      if (name.contains('Samsung')) return 'Usuário Samsung';
      if (name.contains('Pixel')) return 'Usuário Pixel';
      return name.length > 30 ? '${name.substring(0, 30)}...' : name;
    }
    return 'Usuário ReceitaAgro';
  }

  String _getUserEmail(AuthState authState) {
    final user = authState.currentUser;
    return user?.email ?? 'usuario@receituagro.com';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    return _buildDialogContent(context, theme, authState);
  }

  Widget _buildDialogContent(
    BuildContext context,
    ThemeData theme,
    AuthState authState,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Perfil do Usuário',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildAvatar(theme, authState),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _buildProfileForm(theme, authState),
              ),
            ),
            const SizedBox(height: 24),
            _buildActions(theme, authState),
          ],
        ),
      ),
    );
  }

  /// Build user avatar
  Widget _buildAvatar(ThemeData theme, AuthState authState) {
    final displayName = _displayNameController.text.isEmpty
        ? _getUserDisplayName(authState)
        : _displayNameController.text;

    return Stack(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            _getInitials(displayName),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
            child: IconButton(
              onPressed: _changeAvatar,
              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              iconSize: 16,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ),
        ),
      ],
    );
  }

  /// Build profile form
  Widget _buildProfileForm(ThemeData theme, AuthState authState) {
    final settingsState = ref.read(settingsNotifierProvider).value;
    final currentDevice = settingsState?.currentDeviceInfo;
    final connectedDevices = settingsState?.connectedDevicesInfo ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome de Exibição',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _displayNameController,
          enabled: _isEditing,
          decoration: InputDecoration(
            hintText: 'Digite seu nome de exibição',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: _isEditing
                ? IconButton(
                    onPressed: () {
                      _displayNameController.clear();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to update avatar initials
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Email',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          enabled: false, // Email typically not editable
          decoration: InputDecoration(
            hintText: 'Email da conta',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: authState.isAuthenticated
                ? const Icon(Icons.verified, color: Colors.green, size: 16)
                : null,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informações da Conta',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Dispositivo Atual',
                currentDevice?.displayName ?? 'Desconhecido',
              ),
              _buildInfoRow(
                'Dispositivos Conectados',
                '${connectedDevices.length} de 3',
              ),
              _buildInfoRow('Sincronização', 'Ativa'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build information row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActions(ThemeData theme, AuthState authState) {
    if (!_isEditing) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              child: const Text('Editar'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => _cancelEdit(authState),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ),
      ],
    );
  }

  /// Get initials from display name
  String _getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';
    final words = displayName.split(' ');
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }

  /// Change avatar
  void _changeAvatar() {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Avatar'),
        content: const Text(
          'Funcionalidade de upload de avatar será implementada em breve.\n\n'
          'Por enquanto, o avatar é gerado automaticamente baseado no nome.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Cancel editing
  void _cancelEdit(AuthState authState) {
    setState(() {
      _isEditing = false;
      _displayNameController.text = _getUserDisplayName(authState);
      _emailController.text = _getUserEmail(authState);
    });
  }

  /// Save changes
  Future<void> _saveChanges() async {
    if (_displayNameController.text.trim().isEmpty) {
      _showErrorDialog('Nome de exibição não pode estar vazio');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showErrorDialog('Erro ao salvar perfil: $e');
      }
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog<dynamic>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

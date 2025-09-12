import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/feature_flags_provider.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_provider.dart';
import '../dialogs/user_profile_dialog.dart';
import '../items/sync_status_item.dart';

/// User Profile & Settings Sync Section
/// 
/// Features:
/// - User profile display and editing
/// - Avatar, display name, email management
/// - Settings sync status indicators
/// - Account management options
/// - Theme/language sync between devices
class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, FeatureFlagsProvider>(
      builder: (context, settingsProvider, featureFlags, child) {
        // Only show if user is logged in or sync is enabled
        if (!_shouldShowSection(settingsProvider, featureFlags)) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: SettingsDesignTokens.sectionMargin,
          elevation: SettingsDesignTokens.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              _buildSectionHeader(context, settingsProvider),
              
              // User Profile Info
              _buildUserProfile(context, settingsProvider),
              
              // Settings Sync Status
              if (featureFlags.isContentSynchronizationEnabled)
                _buildSyncStatus(context, settingsProvider, featureFlags),
              
              // Account Management Actions
              _buildAccountActions(context, settingsProvider),
            ],
          ),
        );
      },
    );
  }

  /// Determine if section should be shown
  bool _shouldShowSection(SettingsProvider settingsProvider, FeatureFlagsProvider featureFlags) {
    // Show if user has settings OR sync is enabled
    return settingsProvider.hasSettings || 
           featureFlags.isContentSynchronizationEnabled;
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);

    return Padding(
      padding: SettingsDesignTokens.sectionHeaderPadding,
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: SettingsDesignTokens.sectionIconSize,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil do Usuário',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Configurações e sincronização',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// User Profile Display
  Widget _buildUserProfile(BuildContext context, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);
    final currentDevice = settingsProvider.currentDevice;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: () => _openUserProfileDialog(context, settingsProvider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // User Avatar
              _buildUserAvatar(context, currentDevice),
              
              const SizedBox(width: 12),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getUserDisplayName(currentDevice),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getUserEmail(settingsProvider),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDevice?.displayName ?? 'Dispositivo desconhecido',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Edit Icon
              Icon(
                Icons.edit,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// User Avatar Widget
  Widget _buildUserAvatar(BuildContext context, DeviceInfo? device) {
    final theme = Theme.of(context);
    final displayName = _getUserDisplayName(device);
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      child: Text(
        _getInitials(displayName),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Settings Sync Status
  Widget _buildSyncStatus(BuildContext context, SettingsProvider settingsProvider, FeatureFlagsProvider featureFlags) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sincronização de Configurações',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sync Status Items
          SyncStatusItem(
            label: 'Tema',
            value: settingsProvider.isDarkTheme ? 'Escuro' : 'Claro',
            isSynced: true,
            icon: Icons.palette,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Idioma',
            value: _getLanguageDisplay(settingsProvider.language),
            isSynced: true,
            icon: Icons.language,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Notificações',
            value: settingsProvider.notificationsEnabled ? 'Ativadas' : 'Desativadas',
            isSynced: true,
            icon: Icons.notifications,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Som',
            value: settingsProvider.soundEnabled ? 'Ativado' : 'Desativado',
            isSynced: true,
            icon: Icons.volume_up,
          ),
        ],
      ),
    );
  }

  /// Account Management Actions
  Widget _buildAccountActions(BuildContext context, SettingsProvider settingsProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openUserProfileDialog(context, settingsProvider),
              icon: const Icon(Icons.person_outline, size: 16),
              label: const Text('Editar Perfil'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Account Management Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _openAccountManagement(context, settingsProvider),
              icon: const Icon(Icons.manage_accounts, size: 16),
              label: const Text('Gerenciar Conta'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get user display name
  String _getUserDisplayName(DeviceInfo? device) {
    if (device?.name.isNotEmpty == true) {
      final name = device!.name;
      // Extract user-friendly name from device name if possible
      if (name.contains('iPhone')) return 'Usuário iPhone';
      if (name.contains('iPad')) return 'Usuário iPad';
      if (name.contains('Samsung')) return 'Usuário Samsung';
      if (name.contains('Pixel')) return 'Usuário Pixel';
      return name.length > 20 ? '${name.substring(0, 20)}...' : name;
    }
    return 'Usuário ReceitaAgro';
  }

  /// Get user email (mock)
  String _getUserEmail(SettingsProvider settingsProvider) {
    // In real implementation, this would come from auth service
    return 'usuario@receituagro.com';
  }

  /// Get initials from display name
  String _getInitials(String displayName) {
    final words = displayName.split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Get language display name
  String _getLanguageDisplay(String languageCode) {
    switch (languageCode) {
      case 'pt-BR':
        return 'Português (Brasil)';
      case 'en-US':
        return 'English (US)';
      case 'es-ES':
        return 'Español';
      default:
        return 'Português (Brasil)';
    }
  }

  /// Open User Profile Dialog
  Future<void> _openUserProfileDialog(BuildContext context, SettingsProvider settingsProvider) async {
    await showDialog(
      context: context,
      builder: (context) => UserProfileDialog(provider: settingsProvider),
    );
  }

  /// Open Account Management
  void _openAccountManagement(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gerenciar Conta'),
        content: const Text(
          'Funcionalidades de gerenciamento de conta:\n\n'
          '• Alterar senha\n'
          '• Configurar autenticação em dois fatores\n'
          '• Gerenciar dados de cobrança\n'
          '• Exportar dados\n'
          '• Excluir conta\n\n'
          'Em breve disponível!',
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
}
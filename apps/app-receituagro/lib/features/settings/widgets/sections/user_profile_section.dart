import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/feature_flags_notifier.dart';
import '../../../../core/providers/receituagro_auth_notifier.dart';
import '../../../../core/services/device_identity_service.dart';
import '../../constants/settings_design_tokens.dart';
import '../../presentation/providers/settings_notifier.dart';
import '../../presentation/providers/settings_state.dart';
import '../items/sync_status_item.dart';
import '../shared/settings_list_tile.dart';

/// User Profile & Account Management Section
///
/// Features:
/// - Authentication options for guests (login/register)
/// - User profile display and editing for authenticated users
/// - Avatar, display name, email management
/// - Device management (when applicable)
/// - Settings sync status indicators
/// - Account management options
/// - Theme/language sync between devices
class UserProfileSection extends ConsumerWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(receitaAgroAuthNotifierProvider);

    return authState.when(
      data: (authData) => _UserProfileCard(authData: authData),
      loading: () => const Card(
        margin: SettingsDesignTokens.sectionMargin,
        elevation: SettingsDesignTokens.cardElevation,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        margin: SettingsDesignTokens.sectionMargin,
        elevation: SettingsDesignTokens.cardElevation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text('Erro ao carregar perfil: $error'),
          ),
        ),
      ),
    );
  }
}

/// Internal widget to handle the card with SettingsNotifier and FeatureFlagsProvider
class _UserProfileCard extends ConsumerWidget {
  final ReceitaAgroAuthState authData;

  const _UserProfileCard({required this.authData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final featureFlagsAsync = ref.watch(featureFlagsNotifierProvider);

    return settingsAsync.when(
      data: (settingsState) => featureFlagsAsync.when(
        data: (featureFlagsState) {
          final featureFlags = ref.read(featureFlagsNotifierProvider.notifier);

          return Card(
            margin: SettingsDesignTokens.sectionMargin,
            elevation: SettingsDesignTokens.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SettingsDesignTokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, authData),
                if (!authData.isAuthenticated || authData.isAnonymous) ...[
                  _buildAuthenticationOptions(context, ref),
                ] else ...[
                  _buildUserProfile(context, settingsState, authData),
                  if (featureFlags.isContentSynchronizationEnabled)
                    _buildSyncStatus(context, settingsState, featureFlags),

                ],
              ],
            ),
          );
        },
        loading: () => const Card(
          margin: SettingsDesignTokens.sectionMargin,
          elevation: SettingsDesignTokens.cardElevation,
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (error, _) => Card(
          margin: SettingsDesignTokens.sectionMargin,
          elevation: SettingsDesignTokens.cardElevation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text('Erro ao carregar feature flags: $error'),
            ),
          ),
        ),
      ),
      loading: () => const Card(
        margin: SettingsDesignTokens.sectionMargin,
        elevation: SettingsDesignTokens.cardElevation,
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => Card(
        margin: SettingsDesignTokens.sectionMargin,
        elevation: SettingsDesignTokens.cardElevation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text('Erro ao carregar configurações: $error'),
          ),
        ),
      ),
    );
  }

  /// Authentication options for guests
  Widget _buildAuthenticationOptions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SettingsListTile(
          leadingIcon: Icons.login,
          title: 'Fazer Login',
          subtitle: 'Acesse sua conta existente',
          onTap: () => _showLoginDialog(context, ref),
        ),
        const Divider(height: 1),
        SettingsListTile(
          leadingIcon: Icons.person_add,
          title: 'Criar Conta',
          subtitle: 'Cadastre-se para sincronizar dados',
          onTap: () => _showSignupDialog(context, ref),
        ),
        const Divider(height: 1),
        SettingsListTile(
          leadingIcon: Icons.info_outline,
          title: 'Sobre Conta',
          subtitle: 'Benefícios de ter uma conta',
          onTap: () => _showAccountBenefitsDialog(context, ref),
        ),
      ],
    );
  }

  /// Section Header
  Widget _buildSectionHeader(BuildContext context, ReceitaAgroAuthState authState) {
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
  Widget _buildUserProfile(BuildContext context, SettingsState settingsState, ReceitaAgroAuthState authState) {
    final theme = Theme.of(context);
    final currentDevice = settingsState.currentDeviceInfo;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: InkWell(
        onTap: () => _openUserProfileDialog(context, settingsState),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildUserAvatar(context, currentDevice),
              
              const SizedBox(width: 12),
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
                      _getUserEmail(settingsState),
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
  Widget _buildSyncStatus(BuildContext context, SettingsState settingsState, FeatureFlagsNotifier featureFlags) {
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
          SyncStatusItem(
            label: 'Tema',
            value: settingsState.isDarkTheme ? 'Escuro' : 'Claro',
            isSynced: true,
            icon: Icons.palette,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Idioma',
            value: _getLanguageDisplay(settingsState.language),
            isSynced: true,
            icon: Icons.language,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Notificações',
            value: settingsState.notificationsEnabled ? 'Ativadas' : 'Desativadas',
            isSynced: true,
            icon: Icons.notifications,
          ),
          const SizedBox(height: 4),
          SyncStatusItem(
            label: 'Som',
            value: settingsState.soundEnabled ? 'Ativado' : 'Desativado',
            isSynced: true,
            icon: Icons.volume_up,
          ),
        ],
      ),
    );
  }


  /// Get user display name
  String _getUserDisplayName(DeviceInfo? device) {
    if (device?.name.isNotEmpty == true) {
      final name = device!.name;
      if (name.contains('iPhone')) return 'Usuário iPhone';
      if (name.contains('iPad')) return 'Usuário iPad';
      if (name.contains('Samsung')) return 'Usuário Samsung';
      if (name.contains('Pixel')) return 'Usuário Pixel';
      return name.length > 20 ? '${name.substring(0, 20)}...' : name;
    }
    return 'Usuário ReceitaAgro';
  }

  /// Get user email (mock)
  String _getUserEmail(SettingsState settingsState) {
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

  /// Navigate to Profile Page
  Future<void> _openUserProfileDialog(BuildContext context, SettingsState settingsState) async {
    await Navigator.pushNamed(context, '/profile');
  }


  /// Show login dialog
  void _showLoginDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _performLogin(context, ref, emailController.text, passwordController.text),
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  /// Show signup dialog
  void _showSignupDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _performSignup(
              context,
              ref,
              nameController.text,
              emailController.text,
              passwordController.text
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  /// Show account benefits dialog
  void _showAccountBenefitsDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Benefícios de ter uma conta'),
        content: const Text(
          'Ao criar uma conta no ReceitaAgro você pode:\n\n'
          '✅ Sincronizar dados entre dispositivos\n'
          '✅ Backup automático de favoritos\n'
          '✅ Histórico de consultas\n'
          '✅ Acesso a recursos premium\n'
          '✅ Suporte prioritário\n'
          '✅ Personalização avançada\n\n'
          'É grátis e leva apenas alguns minutos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSignupDialog(context, ref);
            },
            child: const Text('Criar Conta'),
          ),
        ],
      ),
    );
  }

  /// Perform login
  Future<void> _performLogin(BuildContext context, WidgetRef ref, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Preencha todos os campos', Colors.red);
      return;
    }

    Navigator.pop(context);

    final result = await ref.read(receitaAgroAuthNotifierProvider.notifier).signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (context.mounted) {
      _showSnackBar(
        context,
        result.isSuccess ? 'Login realizado com sucesso!' : 'Erro ao fazer login: ${result.errorMessage ?? "Erro desconhecido"}',
        result.isSuccess ? Colors.green : Colors.red,
      );
    }
  }

  /// Perform signup
  Future<void> _performSignup(BuildContext context, WidgetRef ref, String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Preencha todos os campos', Colors.red);
      return;
    }

    Navigator.pop(context);

    final result = await ref.read(receitaAgroAuthNotifierProvider.notifier).signUpWithEmailAndPassword(
      email: email.trim(),
      password: password,
      displayName: name.trim(),
    );

    if (context.mounted) {
      _showSnackBar(
        context,
        result.isSuccess ? 'Conta criada com sucesso!' : 'Erro ao criar conta: ${result.errorMessage ?? "Erro desconhecido"}',
        result.isSuccess ? Colors.green : Colors.red,
      );
    }
  }

  /// Show snackbar helper
  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

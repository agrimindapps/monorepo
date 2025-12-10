import 'package:core/core.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_providers.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/modern_header_widget.dart';
import '../../../core/widgets/responsive_content_wrapper.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../../subscription/presentation/providers/subscription_notifier.dart';
import '../constants/settings_design_tokens.dart';
import '../presentation/providers/user_settings_notifier.dart';
import '../widgets/dialogs/clear_data_dialog.dart';
import '../widgets/dialogs/delete_account_dialog.dart';
import '../widgets/dialogs/device_management_dialog.dart';
import '../widgets/dialogs/logout_confirmation_dialog.dart';
import '../widgets/profile/profile_account_actions_section.dart';
import '../widgets/profile/profile_account_info_section.dart';
import '../widgets/profile/profile_data_sync_section.dart';
import '../widgets/profile/profile_devices_section.dart';
import '../widgets/profile/profile_subscription_section.dart';
import '../widgets/profile/profile_user_section.dart';

/// Página de perfil do usuário
/// Funciona tanto para visitantes quanto usuários logados
/// VERSÃO ATUALIZADA: Reage automaticamente a mudanças de autenticação
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  bool _settingsInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authAsync = ref.watch(authProvider);
    final settingsState = ref.watch(userSettingsProvider);
    final premiumState = ref.watch(subscriptionManagementProvider);
    final syncState = ref.watch(receitaAgroSyncServiceProvider).syncState;
    final lastSync = ref.watch(receitaAgroSyncServiceProvider).lastSyncTime;

    // Handle AsyncValue states
    return authAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Erro: $error'))),
      data: (authState) {
        final authData = authState;
        final isAuthenticated =
            authData.isAuthenticated && !authData.isAnonymous;
        final user = authData.currentUser;
        if (!_settingsInitialized && isAuthenticated && user?.id != null) {
          _settingsInitialized = true;
          final userId = user?.id;
          if (userId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(userSettingsProvider.notifier).initialize(userId);
            });
          }
        }
        debugPrint(
          '🔍 ProfilePage: Auth state - isAuthenticated: $isAuthenticated, user: ${user?.email}',
        );

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ResponsiveContentWrapper(
                child: Column(
                  children: [
                    ModernHeaderWidget(
                      title: isAuthenticated
                          ? _getUserDisplayTitle(user)
                          : 'Perfil do Visitante',
                      subtitle: isAuthenticated
                          ? 'Gerencie sua conta e configurações'
                          : 'Entre em sua conta para recursos completos',
                      leftIcon: Icons.person,
                      showBackButton: true,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 12),
                    Expanded(
                      child: settingsState.when(
                        data: (settingsData) => SingleChildScrollView(
                          child: Column(
                            children: [
                              ProfileUserSection(
                                authData: authData,
                                onLoginTap: () => _navigateToLoginPage(context),
                                onEditProfile: (newName) =>
                                    _handleEditProfile(context, ref, newName),
                              ),
                              const SizedBox(height: 8),
                              if (isAuthenticated) ...[
                                const ProfileSubscriptionSection(),
                                const SizedBox(height: 8),
                              ],
                              if (isAuthenticated) ...[
                                ProfileAccountInfoSection(authData: authData),
                                const SizedBox(height: 8),
                              ],
                              if (isAuthenticated) ...[
                                ProfileDevicesSection(
                                  settingsData: settingsData,
                                  onManageDevices: () => _showDeviceManagement(
                                    context,
                                    settingsData,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (isAuthenticated) ...[
                                ProfileDataSyncSection(
                                  authData: authData,
                                  onSyncData: () =>
                                      _handleSyncNow(context, ref),
                                  onExportDataJson: () =>
                                      _handleExportData(context, ref, 'json'),
                                  onExportDataCsv: () =>
                                      _handleExportData(context, ref, 'csv'),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (isAuthenticated) ...[
                                ProfileAccountActionsSection(
                                  authData: authData,
                                  onLogout: () => _handleLogout(context, ref),
                                  onDeleteAccount: () =>
                                      _handleDeleteAccount(context, ref),
                                  onClearData: () =>
                                      _handleClearData(context, ref),
                                  onChangePassword: () =>
                                      _handleChangePassword(context, ref),
                                ),
                                const SizedBox(height: 8),
                              ],

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) =>
                            Center(child: Text('Erro: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEditProfile(
    BuildContext context,
    WidgetRef ref,
    String newName,
  ) async {
    final result = await ref
        .read(authProvider.notifier)
        .updateProfile(displayName: newName);

    if (context.mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleChangePassword(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final user = ref.read(authProvider).value?.currentUser;
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

    if (confirm == true && context.mounted) {
      final result = await ref
          .read(authProvider.notifier)
          .sendPasswordResetEmail(user.email);

      if (context.mounted) {
        if (result.isSuccess) {
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
            SnackBar(
              content: Text('Erro ao enviar email: ${result.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ... existing methods ...
  void _navigateToLoginPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
    );
  }

  void _showDeviceManagement(BuildContext context, dynamic settingsData) {
    showDialog<void>(
      context: context,
      builder: (context) => DeviceManagementDialog(settingsData: settingsData),
    );
  }

  Future<void> _handleSyncNow(BuildContext context, WidgetRef ref) async {
    // Implement sync logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sincronizando dados...')));
    await ref.read(receitaAgroSyncServiceProvider).sync();
  }

  void _handleExportData(BuildContext context, WidgetRef ref, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportando dados como ${format.toUpperCase()}...'),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }

  void _handleClearData(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => const ClearDataDialog(),
    );
  }

  String _getUserDisplayTitle(dynamic user) {
    if (user == null) return 'Usuário';
    if (user is core.UserEntity) return user.safeDisplayName;

    final name = user.displayName;
    if (name is String && name.isNotEmpty) return name;

    final email = user.email;
    if (email is String && email.isNotEmpty) return email.split('@').first;

    return 'Usuário';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'
        .toUpperCase();
  }
}

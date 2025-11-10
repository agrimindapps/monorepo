import 'package:core/core.dart' hide User, AuthState, AuthStatus, Column;
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/constants/profile_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../services/profile_actions_service.dart';
import '../widgets/profile_state_handlers.dart';

/// Profile page widget for displaying user information and settings
///
/// **SOLID Principles:**
/// - **Single Responsibility**: Only handles UI rendering
/// - **Dependency Inversion**: Depends on ProfileActionsService abstraction
/// - **Open/Closed**: Business logic extracted to service
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  // Lazy initialization of service
  ProfileActionsService get _actionsService =>
      di.getIt<ProfileActionsService>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), centerTitle: true),
      body: _buildBody(context, ref, authState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AuthState authState) {
    if (authState.status == AuthStatus.loading) {
      return ProfileStateHandlers.buildLoadingState(context);
    }
    if (authState.status == AuthStatus.error && authState.error != null) {
      return ProfileStateHandlers.buildErrorState(
        context: context,
        error: authState.error,
        onRetry: () => _retryLoadProfile(ref),
      );
    }
    if (authState.status == AuthStatus.unauthenticated ||
        authState.user == null) {
      return ProfileStateHandlers.buildUnauthenticatedState(
        context: context,
        onSignIn: () => context.push('/login'),
      );
    }
    return Semantics(
      label: 'Página de perfil do usuário',
      hint: 'Visualize e gerencie suas informações de perfil e configurações',
      child: SingleChildScrollView(
        padding: ProfileConstants.pageContentPadding,
        child: Column(
          children: [
            ProfileStateHandlers.buildProfileHeader(context, authState.user!),
            const SizedBox(height: ProfileConstants.headerTopSpacing),
            _buildMenuSection(context, ProfileConstants.financialSectionTitle, [
              _buildMenuItem(
                context,
                ProfileConstants.expensesMenuTitle,
                ProfileIcons.expensesIcon,
                () => context.push(ProfileConstants.expensesRoute),
              ),
              _buildMenuItem(
                context,
                ProfileConstants.subscriptionMenuTitle,
                ProfileIcons.subscriptionIcon,
                () => context.push(ProfileConstants.subscriptionRoute),
              ),
            ]),
            const SizedBox(height: 24),
            _buildMenuSection(context, ProfileConstants.settingsSectionTitle, [
              _buildMenuItem(
                context,
                'Notificações',
                Icons.notifications,
                () => _actionsService.showNotificationsSettings(context),
              ),
              _buildMenuItem(
                context,
                'Tema',
                Icons.palette,
                () => _actionsService.showThemeSettings(context),
              ),
              _buildMenuItem(
                context,
                'Idioma',
                Icons.language,
                () => _actionsService.showLanguageSettings(context),
              ),
              _buildMenuItem(
                context,
                'Backup e Sincronização',
                Icons.cloud_sync,
                () => _actionsService.showBackupSettings(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildMenuSection(context, ProfileConstants.supportSectionTitle, [
              _buildMenuItem(
                context,
                'Central de Ajuda',
                Icons.help,
                () => _actionsService.showHelp(context),
              ),
              _buildMenuItem(
                context,
                'Contatar Suporte',
                Icons.support_agent,
                () => _actionsService.contactSupport(context),
              ),
              _buildMenuItem(
                context,
                'Sobre o App',
                Icons.info,
                () => _actionsService.showAbout(context),
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Semantics(
                label: 'Sair da conta do usuário',
                hint: 'Faz logout e retorna para a tela de login',
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'Sair da Conta',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Informações da versão do aplicativo',
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? 'Versão ${snapshot.data!.version}'
                      : 'Versão 1.0.0';
                  return Text(
                    version,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Retry Profile Loading**
  ///
  /// Attempts to reload the user profile data when an error occurs.
  void _retryLoadProfile(WidgetRef ref) {
    ref.invalidate(authProvider);
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Semantics(
            label: 'Cabeçalho da seção $title',
            header: true,
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Semantics(
          label: 'Lista de opções da seção $title',
          child: Card(child: Column(children: items)),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Semantics(
      label: 'Menu $title',
      hint: 'Toque para acessar $title',
      button: true,
      child: ListTile(
        leading: Semantics(label: 'Ícone de $title', child: Icon(icon)),
        title: Text(title),
        trailing: Semantics(
          label: 'Indicador de navegação',
          child: const Icon(Icons.chevron_right),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    _actionsService.showLogoutDialog(
      context: context,
      onConfirm: () {
        ref.read(authProvider.notifier).signOut();
        context.go('/login');
      },
    );
  }
}

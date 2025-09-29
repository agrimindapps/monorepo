import 'package:flutter/material.dart';
import 'package:core/core.dart' hide User, AuthState, AuthStatus;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../shared/constants/profile_constants.dart';
import '../../../../shared/widgets/dialogs/app_dialogs.dart';
import '../widgets/profile_state_handlers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, authState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AuthState authState) {
    // Handle loading state
    if (authState.status == AuthStatus.loading) {
      return ProfileStateHandlers.buildLoadingState(context);
    }

    // Handle error state
    if (authState.status == AuthStatus.error && authState.error != null) {
      return ProfileStateHandlers.buildErrorState(
        context: context,
        error: authState.error,
        onRetry: () => _retryLoadProfile(ref),
      );
    }

    // Handle unauthenticated state
    if (authState.status == AuthStatus.unauthenticated || authState.user == null) {
      return ProfileStateHandlers.buildUnauthenticatedState(
        context: context,
        onSignIn: () => context.push('/login'),
      );
    }

    // Handle authenticated state with user data
    return Semantics(
      label: 'Página de perfil do usuário',
      hint: 'Visualize e gerencie suas informações de perfil e configurações',
      child: SingleChildScrollView(
        padding: ProfileConstants.pageContentPadding,
        child: Column(
        children: [
          // Header do perfil
          ProfileStateHandlers.buildProfileHeader(context, authState.user!),
            const SizedBox(height: ProfileConstants.headerTopSpacing),
            
            // Seções do menu
            _buildMenuSection(
              context,
              ProfileConstants.financialSectionTitle,
              [
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
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildMenuSection(
              context,
              ProfileConstants.settingsSectionTitle,
              [
                _buildMenuItem(
                  context,
                  'Notificações',
                  Icons.notifications,
                  () => _showNotificationsSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Tema',
                  Icons.palette,
                  () => _showThemeSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Idioma',
                  Icons.language,
                  () => _showLanguageSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Backup e Sincronização',
                  Icons.cloud_sync,
                  () => _showBackupSettings(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildMenuSection(
              context,
              ProfileConstants.supportSectionTitle,
              [
                _buildMenuItem(
                  context,
                  'Central de Ajuda',
                  Icons.help,
                  () => _showHelp(context),
                ),
                _buildMenuItem(
                  context,
                  'Contatar Suporte',
                  Icons.support_agent,
                  () => _contactSupport(context),
                ),
                _buildMenuItem(
                  context,
                  'Sobre o App',
                  Icons.info,
                  () => _showAbout(context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botão de logout
            SizedBox(
              width: double.infinity,
              child: Semantics(
                label: 'Sair da conta do usuário',
                hint: 'Faz logout e retorna para a tela de login',
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                  label: Text(
                    'Sair da Conta',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Versão do app com acessibilidade
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
    // Trigger a refresh by invalidating the provider
    ref.invalidate(authProvider);
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            child: user?.photoUrl != null
                ? Semantics(
                    label: 'Foto do perfil do usuário ${user?.displayName ?? ""}'.trim(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.network(
                        user!.photoUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40,
                            color: Theme.of(context).colorScheme.onPrimary,
                          );
                        },
                      ),
                    ),
                  )
                : Semantics(
                    label: 'Avatar padrão do usuário',
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'Usuário',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@exemplo.com',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          if (user?.hasValidPremium == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'PREMIUM',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Lista de opções da seção $title',
          child: Card(
            child: Column(children: items),
          ),
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
        leading: Semantics(
          label: 'Ícone de $title',
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: Semantics(
          label: 'Indicador de navegação',
          child: const Icon(Icons.chevron_right),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String title) {
    AppDialogs.showComingSoon(context, title);
  }

  void _showNotificationsSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Notificação');
  }

  void _showThemeSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Tema');
  }

  void _showLanguageSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Configurações de Idioma');
  }

  void _showBackupSettings(BuildContext context) {
    _showComingSoonDialog(context, 'Backup e Sincronização');
  }

  void _showHelp(BuildContext context) {
    _showComingSoonDialog(context, 'Central de Ajuda');
  }

  void _contactSupport(BuildContext context) {
    AppDialogs.showContactSupport(
      context,
      supportEmail: 'suporte@petiveti.com',
      supportPhone: '(11) 99999-9999',
      showSocialMedia: true,
    );
  }

  void _showAbout(BuildContext context) {
    AppDialogs.showAboutApp(
      context,
      appName: 'PetiVeti',
      appIcon: Icon(Icons.pets, size: 32, color: Theme.of(context).colorScheme.primary),
      customDescription: 'App completo para cuidados veterinários com calculadoras especializadas, controle de medicamentos, agendamento de consultas e muito mais.',
      showTechnicalInfo: true,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    AppDialogs.showLogoutConfirmation(
      context,
      onConfirm: () {
        ref.read(authProvider.notifier).signOut();
        context.go('/login');
      },
    );
  }
}
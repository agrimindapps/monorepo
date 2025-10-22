import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/providers/auth_providers.dart' as auth;
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/providers/theme_providers.dart' as theme;
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with LoadingPageMixin {
  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final authState = ref.watch(auth.authProvider);
    final settingsState = ref.watch(settingsNotifierProvider);

    return ContextualLoadingListener(
      context: LoadingContexts.settings,
      child: BasePageScaffold(
        body: ResponsiveLayout(
          horizontalPadding: 4.0,
          child: authState.when(
            data: (authData) {
              final user = authData.currentUser;

              return Column(
                children: [
                  PlantisHeader(
                    title: 'Configurações',
                    subtitle: 'Personalize sua experiência',
                    leading: _buildHeaderIcon(Icons.settings),
                    actions: [
                      Consumer(
                        builder: (context, ref, _) {
                          final themeMode = ref.watch(theme.themeModeProvider);
                          return Semantics(
                            label: 'Alterar tema',
                            hint:
                                'Abre diálogo para escolher entre tema claro, escuro ou automático. Atualmente: ${_getThemeDescription(themeMode)}',
                            button: true,
                            onTap: () => _showThemeDialog(context, ref),
                            child: GestureDetector(
                              onTap: () => _showThemeDialog(context, ref),
                              child: _buildHeaderIcon(_getThemeIcon(themeMode)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      children: [
                        _buildUserSection(context, appTheme, user, authData),
                        const SizedBox(height: 8),
                        _buildPremiumSectionCard(context, appTheme),
                        const SizedBox(height: 8),
                        settingsState.when(
                          data: (settings) => _buildConfigSection(context, appTheme, settings),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(child: Text('Erro: $error')),
                        ),
                        const SizedBox(height: 8),
                        _buildSupportSection(context, appTheme),
                        const SizedBox(height: 8),
                        _buildAboutSection(context, appTheme),
                        const SizedBox(height: 8),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Text('Erro ao carregar configurações: $error'),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(
    BuildContext context,
    ThemeData theme,
    dynamic user,
    dynamic authState,
  ) {
    final hasPhoto = user?.hasProfilePhoto == true;
    final photoUrl = user?.photoUrl?.toString() ?? '';
    final initials = (user?.initials as String?) ?? '...';
    final email = (user?.email as String?) ?? 'Carregando...';
    const memberSince = 'Membro desde...';

    return PlantisCard(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => context.push('/account-profile'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: PlantisColors.primary,
                child:
                    hasPhoto
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        )
                        : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName?.toString() ?? 'Usuário',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      memberSince,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PlantisColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: PlantisColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verificado',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PlantisColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSectionCard(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary,
            PlantisColors.primaryDark,
            PlantisColors.leaf,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => context.push('/premium'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ Plantis Premium ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desbloqueie recursos avançados',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigSection(
    BuildContext context,
    ThemeData theme,
    SettingsState settingsState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Configurações'),
        _buildSettingsCard(context, [
          _buildNotificationSwitchItem(context, settingsState),
          _buildSettingsItem(
            context,
            icon: Icons.devices,
            title: 'Dispositivos Conectados',
            subtitle: 'Gerencie aparelhos com acesso à conta',
            onTap: () => context.push('/device-management'),
          ),
        ]),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Suporte'),
        _buildSettingsCard(context, [
          _buildSettingsItem(
            context,
            icon: Icons.star_rate,
            title: 'Avaliar o App',
            subtitle: 'Avalie nossa experiência na loja',
            onTap: () => _showRateAppDialog(context),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.feedback,
            title: 'Enviar Feedback',
            subtitle: 'Nos ajude a melhorar o app',
            onTap: () => _showAboutDialog(context),
          ),
        ]),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Sobre o Plantis'),
        _buildSettingsCard(context, [
          _buildSettingsItem(
            context,
            icon: Icons.info,
            title: 'Informações do App',
            subtitle: 'Versão, suporte e feedback',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Política de Privacidade',
            subtitle: 'Como protegemos seus dados',
            onTap: () => context.push('/privacy-policy'),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.description,
            title: 'Termos de Uso',
            subtitle: 'Termos e condições de uso',
            onTap: () => context.push('/terms-of-service'),
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: PlantisColors.primary,
          fontSize:
              (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return PlantisCard(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.zero, // Remove padding padrão para usar o dos items
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PlantisColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: PlantisColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitchItem(
    BuildContext context,
    SettingsState settingsState,
  ) {
    final theme = Theme.of(context);
    final isEnabled = settingsState.settings.notifications.taskRemindersEnabled;
    const isWebPlatform = kIsWeb;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isWebPlatform ? Colors.grey : PlantisColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isWebPlatform
                  ? Icons.web
                  : isEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: isWebPlatform ? Colors.grey : PlantisColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isWebPlatform ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isWebPlatform
                      ? 'Não disponível na versão web'
                      : isEnabled
                      ? 'Receba lembretes sobre suas plantas'
                      : 'Notificações desabilitadas',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isWebPlatform ? false : isEnabled,
            onChanged:
                isWebPlatform
                    ? null
                    : (value) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .toggleTaskReminders(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Notificações ativadas'
                                : 'Notificações desativadas',
                          ),
                          backgroundColor: PlantisColors.primary,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
            activeColor: PlantisColors.primary,
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: Row(
              children: [
                const Icon(Icons.star_rate, color: PlantisColors.sun, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Avaliar o App',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Está gostando do Plantis?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sua avaliação nos ajuda a melhorar e alcançar mais pessoas que amam plantas como você!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star,
                        color: PlantisColors.sun,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PlantisColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PlantisColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: PlantisColors.flower,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Obrigado por fazer parte da nossa comunidade!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Mais tarde',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _handleRateApp(context);
                },
                icon: const Icon(Icons.star, size: 18),
                label: const Text('Avaliar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlantisColors.sun,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleRateApp(BuildContext context) async {
    try {
      final appRatingService = di.sl<IAppRatingRepository>();
      final success = await appRatingService.showRatingDialog(context: context);
      if (!context.mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigado pelo feedback!'),
            backgroundColor: PlantisColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: PlantisColors.primaryGradient,
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'Plantis',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu companheiro para cuidar de plantas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(context, 'Versão', '1.0.0'),
                _buildInfoRow(context, 'Build', '1'),
                _buildInfoRow(context, 'Plataforma', 'Flutter'),
                const SizedBox(height: 16),
                Text(
                  'Sistema inteligente de lembretes e cuidados para suas plantas, com sincronização automática e recursos premium.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: PlantisColors.flower,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Feito com carinho para amantes de plantas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeDescription(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Automático (Sistema)';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF),
            title: const Text('Escolher Tema'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.system,
                  'Automático (Sistema)',
                  'Segue a configuração do sistema',
                  Icons.brightness_auto,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.light,
                  'Claro',
                  'Tema claro sempre ativo',
                  Icons.brightness_high,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  ThemeMode.dark,
                  'Escuro',
                  'Tema escuro sempre ativo',
                  Icons.brightness_2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final currentThemeMode = ref.watch(theme.themeModeProvider);
    final isSelected = currentThemeMode == mode;

    return InkWell(
      onTap: () {
        ref.read(theme.themeProvider.notifier).setThemeMode(mode);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? PlantisColors.primary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? PlantisColors.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: PlantisColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeaderIcon(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}

IconData _getThemeIcon(ThemeMode themeMode) {
  switch (themeMode) {
    case ThemeMode.dark:
      return Icons.brightness_2;
    case ThemeMode.light:
      return Icons.brightness_high;
    default:
      return Icons.brightness_auto;
  }
}

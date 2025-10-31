import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/providers/auth_providers.dart' as auth;
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/providers/theme_providers.dart' as theme;
import '../../../../core/theme/plantis_colors.dart';
import '../../../../shared/widgets/base_page_scaffold.dart';
import '../../../../shared/widgets/loading/loading_components.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../managers/settings_sections_builder.dart';
import '../managers/settings_dialog_manager.dart';

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
                            onTap: () {
                              _showThemeDialog(context, ref);
                            },
                            child: GestureDetector(
                              onTap: () => _showThemeDialog(context, ref),
                              child: SettingsSectionsBuilder.buildHeaderIcon(
                                _getThemeIcon(themeMode),
                              ),
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
                        // Hide user section on desktop (>= 1200px) since sidebar shows user info
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final shouldHideUserSection = constraints.maxWidth >= 1200;
                            if (shouldHideUserSection) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: [
                                _buildUserSection(context, appTheme, user, authData),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                        _buildPremiumSectionCard(context, appTheme),
                        const SizedBox(height: 8),
                        settingsState.when(
                          data: (settings) =>
                              _buildConfigSection(context, appTheme, settings),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) =>
                              Center(child: Text('Erro: $error')),
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
            error: (error, stack) =>
                Center(child: Text('Erro ao carregar configurações: $error')),
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
    return SettingsSectionsBuilder.buildUserSection(
      context,
      theme,
      user,
      authState,
    );
  }

  Widget _buildPremiumSectionCard(BuildContext context, ThemeData theme) {
    return SettingsSectionsBuilder.buildPremiumSectionCard(context, theme);
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
            icon: Icons.feedback,
            title: 'Enviar Feedback',
            subtitle: 'Ajude-nos a melhorar o app',
            onTap: () => _showFeedbackDialog(),
          ),
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
            onChanged: isWebPlatform
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
            activeThumbColor: PlantisColors.primary,
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    final dialogManager = SettingsDialogManager(context: context, ref: null);
    dialogManager.showRateAppDialog();
  }

  void _showFeedbackDialog() {
    final dialogManager = SettingsDialogManager(context: context, ref: null);
    dialogManager.showFeedbackDialog();
  }

  void _showAboutDialog(BuildContext context) {
    final dialogManager = SettingsDialogManager(context: context, ref: null);
    dialogManager.showAboutDialog();
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final dialogManager = SettingsDialogManager(context: context, ref: ref);
    dialogManager.showThemeDialog();
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

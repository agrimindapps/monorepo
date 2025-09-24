import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import 'package:core/core.dart';

import '../../shared/widgets/responsive_layout.dart';
import '../../shared/widgets/base_page_scaffold.dart';
import '../../core/theme/plantis_colors.dart';
import '../../core/theme/plantis_design_tokens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart'
    as auth_providers;
import '../../features/development/presentation/pages/database_inspector_page.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/settings/presentation/widgets/premium_components.dart';
import '../../shared/widgets/loading/loading_components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with LoadingPageMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ContextualLoadingListener(
      context: LoadingContexts.settings,
      child: ChangeNotifierProvider<SettingsProvider>.value(
        value: di.sl<SettingsProvider>(), // Using pre-initialized singleton
        child: BasePageScaffold(
          body: ResponsiveLayout(
            horizontalPadding: 4.0,
            child: Consumer2<auth_providers.AuthProvider, SettingsProvider>(
              builder: (context, authProvider, settingsProvider, _) {
                final user = authProvider.currentUser;

                return Column(
                  children: [
                    // Header seguindo mockup
                    PlantisHeader(
                      title: 'Configurações',
                      subtitle: 'Personalize sua experiência',
                      leading: Container(
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      actions: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return Semantics(
                              label: 'Alterar tema',
                              hint:
                                  'Abre diálogo para escolher entre tema claro, escuro ou automático. Atualmente: ${_getThemeDescription(themeProvider.themeMode)}',
                              button: true,
                              onTap:
                                  () =>
                                      _showThemeDialog(context, themeProvider),
                              child: GestureDetector(
                                onTap:
                                    () => _showThemeDialog(
                                      context,
                                      themeProvider,
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? Icons.brightness_2
                                        : themeProvider.themeMode ==
                                            ThemeMode.light
                                        ? Icons.brightness_high
                                        : Icons.brightness_auto,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // ListView com seções organizadas
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        children: [
                          // Seção do Usuário
                          _buildUserSection(context, theme, user, authProvider),
                          const SizedBox(height: 8),

                          // Seção Premium
                          _buildPremiumSectionCard(context, theme),
                          const SizedBox(height: 8),

                          // Seção de Configurações
                          _buildConfigSection(context, theme, settingsProvider),
                          const SizedBox(height: 8),

                          // Seção de Suporte
                          _buildSupportSection(context, theme),
                          const SizedBox(height: 8),

                          // Seção Sobre (com privacidade e termos)
                          _buildAboutSection(context, theme),
                          const SizedBox(height: 8),


                          // Seção de Desenvolvimento (debug only)
                          if (kDebugMode) ...[
                            _buildDevelopmentSection(context, theme),
                            const SizedBox(height: 8),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PlantisColors.primary, PlantisColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Preferências e ajustes do app',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Semantics(
                label: 'Alterar tema',
                hint:
                    'Abre diálogo para escolher entre tema claro, escuro ou automático. Atualmente: ${_getThemeDescription(themeProvider.themeMode)}',
                button: true,
                onTap: () => _showThemeDialog(context, themeProvider),
                child: GestureDetector(
                  onTap: () => _showThemeDialog(context, themeProvider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      themeProvider.themeMode == ThemeMode.dark
                          ? Icons.brightness_2
                          : themeProvider.themeMode == ThemeMode.light
                          ? Icons.brightness_high
                          : Icons.brightness_auto,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(
    BuildContext context,
    ThemeData theme,
    dynamic user,
  ) {
    return Container(
      padding: const EdgeInsets.all(PlantisDesignTokens.spacing6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primaryLight.withValues(alpha: 0.1),
            PlantisColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusXL),
        border: Border.all(
          color: PlantisColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PlantisDesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    PlantisDesignTokens.radiusLG,
                  ),
                ),
                child: const Icon(
                  Icons.eco,
                  color: PlantisColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: PlantisDesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minha Conta',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      user != null &&
                              user.displayName != null &&
                              ((user.displayName as String?)?.isNotEmpty ??
                                  false)
                          ? 'Bem-vindo, ${user.displayName}'
                          : 'Bem-vindo ao seu jardim digital 🌱',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PlantThemedPremiumIndicator(
                isActive: false,
                label: 'GRÁTIS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfileCard(
    BuildContext context,
    ThemeData theme,
    dynamic user,
  ) {
    return GestureDetector(
      onTap: () => context.push('/account-profile'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PlantisColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Enhanced Avatar with plant-themed border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: PlantisColors.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: PlantisColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: PlantisColors.primary,
                child:
                    user?.hasProfilePhoto == true
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Image.network(
                            user!.photoUrl?.toString() ?? '',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                (user.initials as String?) ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        )
                        : Text(
                          (user?.initials as String?) ?? 'UA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: PlantisDesignTokens.spacing4),

            // Enhanced User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          (user?.displayName as String?) ?? 'Usuário Anônimo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const FeatureAvailabilityIndicator(
                        isAvailable: true,
                        isPremium: false,
                        tooltip: 'Conta verificada',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (user?.email as String?) ?? 'usuario@anonimo.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PlantisColors.leafLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: PlantisColors.leaf,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMemberSince(user?.createdAt as DateTime?),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PlantisColors.leafDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: PlantisColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesSection(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PlantisColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispositivos Conectados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gerencie quais aparelhos têm acesso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de dispositivos resumida
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDeviceItem(
                  context,
                  'Este Dispositivo',
                  'Web • Chrome',
                  Icons.computer,
                  isCurrentDevice: true,
                ),
                const SizedBox(height: 12),
                _buildDeviceItem(
                  context,
                  'iPhone de João',
                  'iOS • Último acesso: 2 dias',
                  Icons.phone_iphone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(
    BuildContext context,
    String deviceName,
    String deviceInfo,
    IconData icon, {
    bool isCurrentDevice = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isCurrentDevice
                    ? PlantisColors.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color:
                isCurrentDevice
                    ? PlantisColors.primary
                    : theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    deviceName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isCurrentDevice) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PlantisColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ATUAL',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: PlantisColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                deviceInfo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (!isCurrentDevice)
          Icon(
            Icons.more_vert,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
      ],
    );
  }

  Widget _buildSyncStatusSection(
    BuildContext context,
    ThemeData theme,
    auth_providers.AuthProvider authProvider,
  ) {
    final isSyncing = authProvider.isSyncInProgress;
    final syncMessage =
        authProvider.syncMessage.isNotEmpty
            ? authProvider.syncMessage
            : 'Sincronização completa';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isSyncing
                  ? Colors.orange.withValues(alpha: 0.3)
                  : PlantisColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isSyncing
                        ? Colors.orange.withValues(alpha: 0.2)
                        : PlantisColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSyncing ? Icons.sync : Icons.cloud_done,
                color: isSyncing ? Colors.orange : PlantisColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSyncing ? 'Sincronizando...' : 'Dados Sincronizados',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSyncing
                        ? syncMessage
                        : 'Todos os dados estão atualizados na nuvem',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSyncing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: () {
                  authProvider.startAutoSyncIfNeeded();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Sincronizar agora',
                color: PlantisColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(
    BuildContext context,
    ThemeData theme,
    dynamic user,
    auth_providers.AuthProvider authProvider,
  ) {
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
                    user?.hasProfilePhoto == true
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            user!.photoUrl?.toString() ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                (user.initials as String?) ?? 'LL',
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
                          (user?.initials as String?) ?? 'LL',
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
                      'Usuário',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (user?.email as String?) ?? 'lucineiy@hotmail.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Membro desde 12 de agosto de 2025',
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
                        Icon(
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
            PlantisColors.primary, // Verde Plantis principal
            PlantisColors.primaryDark, // Verde escuro
            PlantisColors.leaf, // Verde folha
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
                    Row(
                      children: [
                        Text(
                          '✨ Plantis Premium ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Desbloqueie recursos avançados',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 4),
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
    SettingsProvider settingsProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Configurações'),
        _buildSettingsCard(context, [
          _buildNotificationSwitchItem(context, settingsProvider),
          _buildSettingsItem(
            context,
            icon: Icons.devices,
            title: 'Dispositivos Conectados',
            subtitle: 'Gerencie aparelhos com acesso à conta',
            onTap: () => context.push('/device-management'),
          ),
          _buildSettingsItem(
            context,
            icon: Icons.workspace_premium,
            title: 'Status da Licença',
            subtitle: 'Visualizar informações da licença trial',
            onTap: () => context.push('/license-status'),
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

  Widget _buildDevelopmentSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Desenvolvimento'),
        _buildSettingsCard(context, [
          _buildSettingsItem(
            context,
            icon: Icons.storage,
            title: 'Inspetor de Dados',
            subtitle: 'Visualizar e gerenciar dados locais',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataInspectorPage(),
                ),
              );
            },
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
          fontSize: (Theme.of(context).textTheme.titleSmall?.fontSize ?? 14) + 2,
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

  Widget _buildDangerousSettingsItem(
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
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.red, size: 20),
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
                      color: Colors.red,
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
    SettingsProvider settingsProvider,
  ) {
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        final isEnabled = provider.notificationsEnabled;
        final isWebPlatform = provider.isWebPlatform;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWebPlatform 
                      ? Colors.grey.withValues(alpha: 0.1)
                      : PlantisColors.primary.withValues(alpha: 0.1),
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
                onChanged: isWebPlatform ? null : (value) {
                  provider.setNotificationsEnabled(value);

                  // Mostrar feedback ao usuário
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
      },
    );
  }

  String _formatDateShort(dynamic date) {
    if (date == null) return '';

    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return '';
    }

    final months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    return '${dateTime.day} de ${months[dateTime.month - 1]} de ${dateTime.year}';
  }

  Widget _buildPremiumFeature(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Membro desde 10 dias';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return 'Membro desde ${difference.inDays} dias';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Membro desde $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Membro desde $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF), // Fundo branco puro
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

                // Star rating visual
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

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigado pelo feedback!'),
            backgroundColor: PlantisColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF), // Fundo branco puro
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

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFFFFFFF), // Fundo branco puro
            title: const Text('Escolher Tema'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context,
                  themeProvider,
                  ThemeMode.system,
                  'Automático (Sistema)',
                  'Segue a configuração do sistema',
                  Icons.brightness_auto,
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
                  ThemeMode.light,
                  'Claro',
                  'Tema claro sempre ativo',
                  Icons.brightness_high,
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
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
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
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
              Icon(Icons.check, color: PlantisColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

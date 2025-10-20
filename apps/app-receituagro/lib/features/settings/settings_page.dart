import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart' as di;
import '../../core/services/device_identity_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'constants/settings_design_tokens.dart';
import 'presentation/providers/settings_notifier.dart';
import 'widgets/dialogs/theme_selection_dialog.dart';
import 'widgets/sections/auth_section.dart';
import 'widgets/sections/development_section.dart';
import 'widgets/sections/feature_flags_section.dart';
import 'widgets/sections/notifications_section.dart';
import 'widgets/sections/premium_section.dart';
import 'widgets/sections/support_section.dart';

/// Refactored Settings Page with Clean Architecture
/// Uses modular components and unified notifier
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsState = ref.watch(settingsNotifierProvider);
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeSettings();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: ResponsiveContentWrapper(
            child: Column(
              children: [
                _buildModernHeader(context, isDark),
                Expanded(
                  child: settingsState.when(
                    data: (state) => _buildSettingsContent(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar configurações',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(settingsNotifierProvider.notifier)
                                .refresh(),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      children: const [
        SizedBox(height: 8),
        AuthSection(),
        SizedBox(height: 8),
        PremiumSection(),
        NotificationsSection(),
        FeatureFlagsSection(),
        DevelopmentSection(),
        SupportSection(),
      ],
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    return ModernHeaderWidget(
      title: 'Configurações',
      subtitle: 'Preferências e ajustes do app',
      leftIcon: Icons.settings,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      additionalActions: [_buildThemeSettingsButton(context)],
    );
  }

  Widget _buildThemeSettingsButton(BuildContext context) {
    return Semantics(
      label: 'Configurações de tema',
      hint: 'Toque para abrir as opções de tema',
      button: true,
      child: GestureDetector(
        onTap: () => _openThemeDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            SettingsDesignTokens.paletteIcon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 17,
          ),
        ),
      ),
    );
  }

  Future<void> _openThemeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const ThemeSelectionDialog(),
    );
  }

  Future<void> _initializeSettings() async {
    try {
      final deviceService = di.sl<DeviceIdentityService>();
      final deviceId = await deviceService.getDeviceUuid();
      await ref.read(settingsNotifierProvider.notifier).initialize(deviceId);
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      await ref
          .read(settingsNotifierProvider.notifier)
          .initialize('anonymous-${DateTime.now().millisecondsSinceEpoch}');
    }
  }
}

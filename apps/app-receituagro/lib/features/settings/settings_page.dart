import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../core/services/device_identity_service.dart';
import '../../core/widgets/modern_header_widget.dart';
import '../../core/widgets/responsive_content_wrapper.dart';
import 'presentation/providers/settings_notifier.dart';
import 'presentation/providers/settings_providers.dart';
import 'widgets/sections/auth_section.dart';
import 'widgets/sections/feature_flags_section.dart';
import 'widgets/sections/legal_section.dart';
import 'widgets/sections/new_notification_section.dart';
import 'widgets/sections/new_premium_section.dart';
import 'widgets/sections/support_section.dart';
import 'widgets/sections/tts_settings_section.dart';

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
    final settingsState = ref.watch(settingsProvider);
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
                                .read(settingsProvider.notifier)
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
        SizedBox(height: 16),
        AuthSection(),
        SizedBox(height: 16),
        // New refactored sections using new notifiers
        NewNotificationSection(),
        SizedBox(height: 16),
        NewPremiumSection(),
        SizedBox(height: 16),
        // Legacy sections (to be removed after migration)
        // PremiumSection(),
        // NotificationsSection(),
        TtsSettingsSection(),
        FeatureFlagsSection(),
        LegalSection(),
        SupportSection(),
        SizedBox(height: 32),
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
    );
  }

  Future<void> _initializeSettings() async {
    try {
      final deviceService = ref.read(deviceIdentityServiceProvider);
      final deviceId = await deviceService.getDeviceUuid();
      await ref.read(settingsProvider.notifier).initialize(deviceId);
    } catch (e) {
      debugPrint('Error initializing settings: $e');
      await ref
          .read(settingsProvider.notifier)
          .initialize('anonymous-${DateTime.now().millisecondsSinceEpoch}');
    }
  }
}

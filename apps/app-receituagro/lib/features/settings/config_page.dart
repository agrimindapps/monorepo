import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/settings_design_tokens.dart';
import 'models/settings_state.dart';
import 'services/theme_service.dart';
import 'services/premium_service.dart';
import 'services/device_service.dart';
import 'services/navigation_service.dart';
import 'sections/publicidade_section.dart';
import 'sections/site_access_section.dart';
import 'sections/speech_to_text_section.dart';
import 'sections/desenvolvimento_section.dart';
import 'sections/sobre_section.dart';

/// Main configuration page following SOLID principles
class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late SettingsState _settingsState;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettingsState();
  }

  Future<void> _initializeSettingsState() async {
    final deviceService = context.read<IDeviceService>();
    final themeService = context.read<IThemeService>();
    final premiumService = context.read<IPremiumService>();
    
    final isDevelopment = await deviceService.isDevelopmentVersion();
    
    setState(() {
      _settingsState = SettingsState(
        isDarkTheme: themeService.isDark,
        premiumStatus: premiumService.status,
        isDevelopmentMode: isDevelopment,
      );
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiProvider(
      providers: [
        // Make navigation service context-aware
        Provider<INavigationService>(
          create: (_) {
            final navService = MockNavigationService();
            navService.setContext(context);
            return navService;
          },
        ),
      ],
      child: Consumer3<IThemeService, IPremiumService, IDeviceService>(
        builder: (context, themeService, premiumService, deviceService, _) {
          
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SettingsDesignTokens.maxPageWidth,
                  ),
                  child: Column(
                    children: [
                      _buildModernHeader(context, themeService),
                      Expanded(
                        child: _buildSettingsContent(context, deviceService),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, IThemeService themeService) {
    final theme = Theme.of(context);
    
    return Container(
      padding: SettingsDesignTokens.defaultPadding,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            SettingsDesignTokens.cardBorderRadius,
          ),
        ),
        child: Padding(
          padding: SettingsDesignTokens.cardPadding,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SettingsDesignTokens.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  SettingsDesignTokens.configIcon,
                  color: SettingsDesignTokens.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opções',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configurações e personalização',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(themeService.themeIcon),
                onPressed: themeService.toggleTheme,
                tooltip: themeService.isDark 
                    ? 'Alternar para tema claro' 
                    : 'Alternar para tema escuro',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, IDeviceService deviceService) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Show sections based on platform and development mode
          if (!deviceService.isWeb) ...[
            const PublicidadeSection(),
            const SiteAccessSection(),
          ],
          const SpeechToTextSection(),
          if (_settingsState.isDevelopmentMode)
            const DesenvolvimentoSection(),
          const SobreSection(),
          const SizedBox(height: 80), // Extra space for navigation
        ],
      ),
    );
  }
}
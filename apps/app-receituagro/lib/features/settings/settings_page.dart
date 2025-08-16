import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/widgets/modern_header_widget.dart';
import '../subscription/subscription_page.dart';
import '../../core/services/receituagro_notification_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildModernHeader(context, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // App Info Card
                  Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pragas Soja',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Versão 1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compêndio de pragas e receitas de defensivos agrícolas',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notifications Section
                  Text(
                    'Notificações',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Notification Settings
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Configurar Notificações',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Gerenciar alertas e lembretes',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showNotificationSettings(context),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Test Notification
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Testar Notificação',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Enviar notificação de teste',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _testNotification(context),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Subscription Section
          Text(
            'Premium',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Subscription Option
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Planos Premium',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Acesse recursos exclusivos',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Support Section
          Text(
            'Suporte',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Rate App Option
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Avaliar o App',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Avalie nossa experiência na loja',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRateAppDialog(context),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Feedback Option
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  color: theme.colorScheme.secondary,
                ),
              ),
              title: const Text(
                'Enviar Feedback',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Nos ajude a melhorar o app',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sistema de feedback em desenvolvimento'),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Development Section (only show in debug mode)
          if (EnvironmentConfig.isDebugMode) ...[
            Text(
              'Desenvolvimento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Test Analytics
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                title: const Text(
                  'Testar Analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Enviar evento de teste',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _testAnalytics(context),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Test Crashlytics
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bug_report,
                    color: theme.colorScheme.error,
                  ),
                ),
                title: const Text(
                  'Testar Crashlytics',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Enviar erro de teste',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _testCrashlytics(context),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          // About Section
          Text(
            'Sobre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // About App
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.secondary,
                ),
              ),
              title: const Text(
                'Sobre o App',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Informações do aplicativo',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRateAppDialog(BuildContext context) async {
    final appRatingRepository = di.sl<IAppRatingRepository>();
    
    try {
      // Check if we can show the rating dialog
      final canShow = await appRatingRepository.canShowRatingDialog();
      
      if (canShow) {
        // Show the rate my app dialog
        if (context.mounted) {
          await appRatingRepository.showRatingDialog(context: context);
        }
      } else {
        // Fallback: directly open the app store
        final success = await appRatingRepository.openAppStore();
        
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível abrir a loja de aplicativos'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao abrir avaliação do app'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _testAnalytics(BuildContext context) async {
    try {
      final analyticsRepository = di.sl<IAnalyticsRepository>();
      
      // Log test event
      await analyticsRepository.logEvent(
        'test_analytics_button_pressed',
        parameters: {
          'screen': 'settings_page',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'app_version': '1.0.0',
        },
      );
      
      // Set user properties
      await analyticsRepository.setUserProperties(
        properties: {
          'user_type': 'developer',
          'app_name': 'receituagro',
        },
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📊 Evento de Analytics enviado com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no Analytics: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _testCrashlytics(BuildContext context) async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Testar Crashlytics'),
          ],
        ),
        content: const Text(
          'Isso irá enviar um erro de teste para o Firebase Crashlytics. Continuar?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Testar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      try {
        final crashlyticsRepository = di.sl<ICrashlyticsRepository>();
        
        // Record a test non-fatal error
        await crashlyticsRepository.recordError(
          exception: Exception('Test error from ReceitaAgro settings'),
          stackTrace: StackTrace.current,
          reason: 'User triggered test error from settings page',
          fatal: false,
        );
        
        // Log a test message
        await crashlyticsRepository.log('Test Crashlytics from ReceitaAgro settings');
        
        // Set user identifier for testing
        await crashlyticsRepository.setUserId('test_user_receituagro');
        
        // Set custom keys
        await crashlyticsRepository.setCustomKey(
          key: 'test_feature', 
          value: 'settings_crashlytics',
        );
        await crashlyticsRepository.setCustomKey(
          key: 'app_section', 
          value: 'development',
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🐛 Erro de teste enviado para Crashlytics!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no Crashlytics: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.science,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('ReceitaAgro'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Versão 1.0.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'O ReceitaAgro é um compêndio completo de pragas agrícolas, oferecendo diagnósticos precisos e receitas de defensivos para agricultores e profissionais do setor.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'RECURSOS:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                '''• Diagnóstico de pragas agrícolas
• Receitas de defensivos
• Base de dados completa
• Interface intuitiva
• Busca avançada''',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Desenvolvido com 💚 para agricultores',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showNotificationSettings(BuildContext context) async {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Configurar Notificações'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure os tipos de notificações que deseja receber:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Lista de opções de notificação
            _buildNotificationOption(
              context,
              title: 'Pragas Detectadas',
              subtitle: 'Alertas quando uma praga for identificada',
              icon: Icons.bug_report,
              enabled: true, // TODO: Implementar preferências
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Lembretes de Aplicação',
              subtitle: 'Lembretes para aplicar defensivos',
              icon: Icons.schedule,
              enabled: true,
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Novas Receitas',
              subtitle: 'Notificações de receitas adicionadas',
              icon: Icons.library_books,
              enabled: false,
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Alertas Climáticos',
              subtitle: 'Condições climáticas favoráveis',
              icon: Icons.wb_sunny,
              enabled: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Abrir configurações do sistema
              final notificationService = ReceitaAgroNotificationService();
              await notificationService.openNotificationSettings();
            },
            child: Text(
              'Configurações do Sistema',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Fechar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: enabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: (value) {
            // TODO: Implementar toggle de preferências
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value ? 'Notificação ativada' : 'Notificação desativada',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _testNotification(BuildContext context) async {
    try {
      final notificationService = ReceitaAgroNotificationService();
      
      // Verifica se as notificações estão habilitadas
      final isEnabled = await notificationService.areNotificationsEnabled();
      
      if (!isEnabled) {
        // Solicita permissão
        final granted = await notificationService.requestNotificationPermission();
        
        if (!granted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permissão de notificação negada'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
      }
      
      // Envia notificação de teste
      await notificationService.showPestDetectedNotification(
        pestName: 'Lagarta-da-soja',
        plantName: 'Plantação Norte',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🔔 Notificação de teste enviada!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao enviar notificação: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return ModernHeaderWidget(
      title: 'Configurações',
      subtitle: 'Preferências e ajustes do app',
      leftIcon: Icons.settings,
      showBackButton: false,
      showActions: true,
      isDark: isDark,
      additionalActions: [
        _buildThemeToggleButton(context, themeProvider),
      ],
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () => _toggleTheme(themeProvider),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(
          themeProvider.isDarkMode
              ? Icons.light_mode
              : themeProvider.isLightMode
                  ? Icons.dark_mode
                  : Icons.auto_mode,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 17,
        ),
      ),
    );
  }

  void _toggleTheme(ThemeProvider themeProvider) async {
    if (themeProvider.isSystemMode) {
      await themeProvider.setThemeMode(ThemeMode.light);
    } else if (themeProvider.isLightMode) {
      await themeProvider.setThemeMode(ThemeMode.dark);
    } else {
      await themeProvider.setThemeMode(ThemeMode.system);
    }
  }
}
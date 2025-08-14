import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/core.dart';
import '../../core/di/injection_container.dart' as di;
import '../subscription/subscription_page.dart';
import '../../core/services/receituagro_notification_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configurações'),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView(
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
          
          // Appearance Section
          Text(
            'Aparência',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Theme Selection
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
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : themeProvider.isLightMode
                          ? Icons.light_mode
                          : Icons.auto_mode,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: const Text(
                'Tema do App',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                themeProvider.themeDisplayName,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeSelector(context, themeProvider),
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: Colors.blue.shade600,
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
              color: Colors.orange.shade700,
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
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.orange.shade600,
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
              color: Colors.green.shade700,
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
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star_outline,
                  color: Colors.orange.shade600,
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
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.feedback_outlined,
                  color: Colors.green.shade600,
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
                color: Colors.orange.shade700,
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
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.purple.shade600,
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
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bug_report,
                    color: Colors.red.shade600,
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
              color: Colors.green.shade700,
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
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.green.shade600,
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
            const SnackBar(
              content: Text('Não foi possível abrir a loja de aplicativos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir avaliação do app'),
            backgroundColor: Colors.red,
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
          const SnackBar(
            content: Text('📊 Evento de Analytics enviado com sucesso!'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no Analytics: $e'),
            backgroundColor: Colors.red,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange.shade600,
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
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
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
          const SnackBar(
            content: Text('🐛 Erro de teste enviado para Crashlytics!'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no Crashlytics: $e'),
            backgroundColor: Colors.red,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.science,
              color: Colors.green.shade600,
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

  Future<void> _showThemeSelector(BuildContext context, ThemeProvider themeProvider) async {
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
              Icons.palette,
              color: theme.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Escolher Tema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // System Theme
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.system,
              title: 'Sistema',
              subtitle: 'Segue o tema do sistema',
              icon: Icons.auto_mode,
              isSelected: themeProvider.isSystemMode,
            ),
            
            const SizedBox(height: 8),
            
            // Light Theme
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.light,
              title: 'Claro',
              subtitle: 'Tema claro sempre',
              icon: Icons.light_mode,
              isSelected: themeProvider.isLightMode,
            ),
            
            const SizedBox(height: 8),
            
            // Dark Theme
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.dark,
              title: 'Escuro',
              subtitle: 'Tema escuro sempre',
              icon: Icons.dark_mode,
              isSelected: themeProvider.isDarkMode,
            ),
          ],
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

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await themeProvider.setThemeMode(mode);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
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
          color: enabled ? theme.colorScheme.primary : Colors.grey,
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
                  color: enabled ? theme.colorScheme.onSurface : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
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
            const SnackBar(
              content: Text('Permissão de notificação negada'),
              backgroundColor: Colors.red,
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
          const SnackBar(
            content: Text('🔔 Notificação de teste enviada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao enviar notificação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
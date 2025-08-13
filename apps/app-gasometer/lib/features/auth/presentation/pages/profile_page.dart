import 'package:flutter/material.dart';
import 'package:core/core.dart';
import '../../../../core/services/gasometer_notification_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    Icons.local_gas_station,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GasOMeter',
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
                    'Controle completo de abastecimentos e manutenções',
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
          
          // Notificações Section
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
                'Gerenciar lembretes e alertas',
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
                  Icons.local_gas_station,
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
          
          // About Section
          Text(
            'Sobre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.blue.shade700,
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
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
          
          // Development Section (only show in debug mode)
          if (EnvironmentConfig.isDebugMode) ...[
            const SizedBox(height: 24),
            
            Text(
              'Desenvolvimento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Test Fuel Reminder
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
                    Icons.local_gas_station,
                    color: Colors.orange.shade600,
                  ),
                ),
                title: const Text(
                  'Teste Lembrete Combustível',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Simular notificação de combustível baixo',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _testFuelReminder(context),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Test Maintenance Reminder
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
                    Icons.build,
                    color: Colors.red.shade600,
                  ),
                ),
                title: const Text(
                  'Teste Lembrete Manutenção',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Simular notificação de manutenção',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _testMaintenanceReminder(context),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
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
              title: 'Lembretes de Combustível',
              subtitle: 'Alertas quando o combustível estiver baixo',
              icon: Icons.local_gas_station,
              enabled: true, // TODO: Implementar preferências
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Lembretes de Manutenção',
              subtitle: 'Lembretes para manutenções programadas',
              icon: Icons.build,
              enabled: true,
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Relatórios Mensais',
              subtitle: 'Relatórios automáticos de gastos',
              icon: Icons.bar_chart,
              enabled: true,
            ),
            const SizedBox(height: 12),
            
            _buildNotificationOption(
              context,
              title: 'Preços de Combustível',
              subtitle: 'Alertas de preços vantajosos',
              icon: Icons.attach_money,
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Abrir configurações do sistema
              final notificationService = GasOMeterNotificationService();
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
      final notificationService = GasOMeterNotificationService();
      
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
      await notificationService.showFuelReminderNotification(
        vehicleName: 'Meu Carro',
        currentKm: 50000,
        estimatedKmToEmpty: 45,
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

  Future<void> _testFuelReminder(BuildContext context) async {
    try {
      final notificationService = GasOMeterNotificationService();
      
      await notificationService.showFuelReminderNotification(
        vehicleName: 'Honda Civic',
        currentKm: 85000,
        estimatedKmToEmpty: 32,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⛽ Lembrete de combustível enviado!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testMaintenanceReminder(BuildContext context) async {
    try {
      final notificationService = GasOMeterNotificationService();
      
      await notificationService.showMaintenanceReminderNotification(
        vehicleName: 'Honda Civic',
        maintenanceType: 'Troca de Óleo',
        currentKm: 85000,
        maintenanceKm: 90000,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔧 Lembrete de manutenção enviado!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
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
              Icons.local_gas_station,
              color: Colors.blue.shade600,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('GasOMeter'),
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
                'O GasOMeter é seu companheiro ideal para controle completo de abastecimentos, manutenções e custos do seu veículo.',
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
                '''• Controle de abastecimentos
• Registro de manutenções
• Relatórios de gastos
• Lembretes automáticos
• Análise de consumo''',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Desenvolvido com 💙 para motoristas',
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
}
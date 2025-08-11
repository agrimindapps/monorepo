import 'package:flutter/material.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/premium_subscription_card.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Minha Conta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo, Usuário Anônimo',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            // Profile Card
            UserProfileCard(
              name: 'Lucinei Robson Lo...',
              email: 'lucinei@controlsoft.com.br',
              membershipInfo: 'Membro desde 10 dias',
              initials: 'LR',
              onTap: () {
                // Handle profile tap
              },
            ),

            // Premium Subscription Card
            PremiumSubscriptionCard(
              planName: 'Plano Gratuito',
              description: 'Desbloqueie recursos premium',
              features: [
                'Plantas ilimitadas',
                'Backup automático na nuvem',
                'Relatórios avançados de cuidados',
                'Lembretes personalizados',
              ],
              ctaText: 'Assinar Premium',
              onSubscribeTap: () {
                // Handle subscription tap
                _showSubscriptionDialog(context);
              },
            ),

            // Configurations Section
            SettingsSection(
              title: 'Configurações',
              children: [
                SettingsItem(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Configure quando ser notificado',
                  iconColor: Colors.teal,
                  isFirst: true,
                  isLast: true,
                  onTap: () {
                    // Handle notifications tap
                  },
                ),
              ],
            ),

            // Legal Section
            SettingsSection(
              title: 'Legal',
              children: [
                SettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidade',
                  subtitle: 'Como protegemos seus dados',
                  iconColor: Colors.teal,
                  isFirst: true,
                  onTap: () {
                    // Handle privacy policy tap
                  },
                ),
                SettingsItem(
                  icon: Icons.description,
                  title: 'Termos de Uso',
                  subtitle: 'Termos e condições de uso',
                  iconColor: Colors.teal,
                  onTap: () {
                    // Handle terms tap
                  },
                ),
                SettingsItem(
                  icon: Icons.info,
                  title: 'Sobre o App',
                  subtitle: 'Versão e informações do app',
                  iconColor: Colors.teal,
                  isLast: true,
                  onTap: () {
                    // Handle about tap
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),

            // Development Section
            SettingsSection(
              title: 'Desenvolvimento',
              children: [
                SettingsItem(
                  icon: Icons.bug_report,
                  title: 'Gerar dados de teste',
                  iconColor: Colors.orange,
                  isFirst: true,
                  onTap: () {
                    // Handle generate test data tap
                  },
                ),
                SettingsItem(
                  icon: Icons.clear_all,
                  title: 'Limpar todos os registros',
                  iconColor: Colors.red,
                  onTap: () {
                    // Handle clear data tap
                    _showClearDataDialog(context);
                  },
                ),
                SettingsItem(
                  icon: Icons.campaign,
                  title: 'Página promocional',
                  iconColor: Colors.purple,
                  onTap: () {
                    // Handle promotional page tap
                  },
                ),
                SettingsItem(
                  icon: Icons.verified,
                  title: 'Gerar Licença Local',
                  subtitle: 'Ativa premium por 30 dias',
                  iconColor: Colors.green,
                  onTap: () {
                    // Handle local license tap
                  },
                ),
                SettingsItem(
                  icon: Icons.remove_circle,
                  title: 'Revogar Licença Local',
                  subtitle: 'Remove licença de teste',
                  iconColor: Colors.red,
                  isLast: true,
                  onTap: () {
                    // Handle revoke license tap
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.exit_to_app, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sair do App Plantas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Account tab selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Minhas plantas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Minha conta',
          ),
        ],
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              // Navigate to tasks
              break;
            case 1:
              // Navigate to plants
              Navigator.of(context).popUntil((route) => route.isFirst);
              break;
            case 2:
              // Already on account page
              break;
          }
        },
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Assinar Premium',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja ativar o plano premium para acessar todos os recursos?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle subscription
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Assinar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Sobre o App',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plantis - Gerenciamento de Plantas', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Versão: 1.0.0', style: TextStyle(color: Colors.grey)),
            Text('Build: 1', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            Text('Sistema de cuidados e lembretes para suas plantas',
                style: TextStyle(color: Colors.grey)),
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

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Limpar Dados',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja limpar todos os dados? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle clear data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dados limpos com sucesso'),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Sair do App',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle logout
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
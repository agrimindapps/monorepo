import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header do perfil
            _buildProfileHeader(context, user),
            const SizedBox(height: 32),
            
            // Seções do menu
            _buildMenuSection(
              context,
              'Financeiro',
              [
                _buildMenuItem(
                  context,
                  'Controle de Despesas',
                  Icons.receipt_long,
                  () => context.push('/expenses'),
                ),
                _buildMenuItem(
                  context,
                  'Assinaturas',
                  Icons.star,
                  () => context.push('/subscription'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildMenuSection(
              context,
              'Configurações',
              [
                _buildMenuItem(
                  context,
                  'Notificações',
                  Icons.notifications,
                  () => _showNotificationsSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Tema',
                  Icons.palette,
                  () => _showThemeSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Idioma',
                  Icons.language,
                  () => _showLanguageSettings(context),
                ),
                _buildMenuItem(
                  context,
                  'Backup e Sincronização',
                  Icons.cloud_sync,
                  () => _showBackupSettings(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildMenuSection(
              context,
              'Suporte',
              [
                _buildMenuItem(
                  context,
                  'Central de Ajuda',
                  Icons.help,
                  () => _showHelp(context),
                ),
                _buildMenuItem(
                  context,
                  'Contatar Suporte',
                  Icons.support_agent,
                  () => _contactSupport(context),
                ),
                _buildMenuItem(
                  context,
                  'Sobre o App',
                  Icons.info,
                  () => _showAbout(context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botão de logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sair da Conta',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Versão do app
            Text(
              'Versão 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user?.photoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user!.photoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'Usuário',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'email@exemplo.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          if (user?.hasValidPremium == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showNotificationsSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Notificação'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Tema'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Idioma'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup e Sincronização'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Central de Ajuda'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contatar Suporte'),
        content: const Text('Email: suporte@petiveti.com\nTelefone: (11) 99999-9999'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PetiVeti',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.pets, size: 64),
      children: const [
        Text('App completo para cuidados veterinários'),
        Text('Desenvolvido com Flutter'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
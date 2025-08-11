import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: PlantisColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.currentUser;
            
            if (user == null) {
              return const Center(
                child: Text('Usuário não encontrado'),
              );
            }
            
            return Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: PlantisColors.surface,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: PlantisColors.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: PlantisColors.primaryLight,
                        child: user.hasProfilePhoto
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user.photoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      user.initials,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: PlantisColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                user.initials,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: PlantisColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // User Info
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PlantisColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Account Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isEmailVerified
                              ? PlantisColors.successLight
                              : PlantisColors.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isEmailVerified
                              ? 'Email Verificado'
                              : 'Email Não Verificado',
                          style: TextStyle(
                            color: user.isEmailVerified
                                ? PlantisColors.success
                                : PlantisColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Account Info
                _buildInfoCard(
                  'Informações da Conta',
                  [
                    _buildInfoItem(
                      Icons.person_outline,
                      'Nome',
                      user.displayName,
                    ),
                    _buildInfoItem(
                      Icons.email_outlined,
                      'Email',
                      user.email,
                    ),
                    _buildInfoItem(
                      Icons.verified_user_outlined,
                      'Provedor',
                      user.provider.name,
                    ),
                    if (user.lastLoginAt != null)
                      _buildInfoItem(
                        Icons.access_time,
                        'Último Login',
                        _formatDate(user.lastLoginAt!),
                      ),
                    if (user.createdAt != null)
                      _buildInfoItem(
                        Icons.calendar_today_outlined,
                        'Membro desde',
                        _formatDate(user.createdAt!),
                      ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                _buildInfoCard(
                  'Ações',
                  [
                    if (!user.isEmailVerified)
                      _buildActionItem(
                        Icons.mark_email_read_outlined,
                        'Verificar Email',
                        'Enviar email de verificação',
                        () => _sendEmailVerification(context),
                      ),
                    _buildActionItem(
                      Icons.settings_outlined,
                      'Configurações',
                      'Ajustes da conta',
                      () => context.go('/settings'),
                    ),
                    _buildActionItem(
                      Icons.help_outline,
                      'Ajuda',
                      'Central de ajuda',
                      () => _showHelp(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _showLogoutDialog(context),
                    icon: authProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: const Text('Sair da Conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlantisColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: PlantisColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: PlantisColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: PlantisColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: PlantisColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PlantisColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
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
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: PlantisColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: PlantisColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Future<void> _sendEmailVerification(BuildContext context) async {
    // TODO: Implement email verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento'),
        backgroundColor: PlantisColors.info,
      ),
    );
  }
  
  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
          'Para suporte técnico, entre em contato conosco através do email: suporte@plantis.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: PlantisColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    if (result == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
    }
  }
}
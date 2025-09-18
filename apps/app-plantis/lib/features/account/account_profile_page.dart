import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/data_sanitization_service.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../../core/theme/plantis_colors.dart';
import '../../shared/widgets/loading/loading_components.dart';
import '../auth/presentation/providers/auth_provider.dart' as auth_providers;

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});
  
  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage> with LoadingPageMixin {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: PlantisColors.getPageBackgroundColor(context),
      body: ResponsiveLayout(
        child: Column(
          children: [
            // Header estilo ReceitaAgro
            _buildHeader(context, theme),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Consumer<auth_providers.AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  final isAnonymous = authProvider.isAnonymous;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Header com informações do usuário
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      // Avatar with edit functionality
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: PlantisColors.primary,
                            child: DataSanitizationService.shouldShowProfilePhoto(user, isAnonymous)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Image.network(
                                      user!.photoUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          DataSanitizationService.sanitizeInitials(user, isAnonymous),
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
                                    DataSanitizationService.sanitizeInitials(user, isAnonymous),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          if (!isAnonymous)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showImagePickerOptions(context),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: PlantisColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DataSanitizationService.sanitizeDisplayName(user, isAnonymous),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DataSanitizationService.sanitizeEmail(user, isAnonymous),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAnonymous ? Colors.orange.withValues(alpha: 0.2) : PlantisColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAnonymous ? 'Conta Anônima' : 'Conta Autenticada',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isAnonymous ? Colors.orange : PlantisColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card especial para usuário anônimo
                if (isAnonymous) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Conta Anônima',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seus dados estão armazenados apenas neste dispositivo. Para maior segurança e sincronização entre dispositivos, recomendamos criar uma conta.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/auth');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.person_add, size: 18),
                            label: const Text('Criar Conta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Informações detalhadas da conta (apenas para usuários registrados)
                if (!isAnonymous) ...[
                  _buildAccountInfoSection(context, user, authProvider),
                  const SizedBox(height: 24),
                ],

                // Status de sincronização (apenas para usuários registrados)
                if (!isAnonymous) ...[
                  _buildSyncSection(context, authProvider),
                  const SizedBox(height: 24),
                ],

                // Exportação de dados (apenas para usuários registrados)
                if (!isAnonymous) ...[
                  _buildDataExportSection(context),
                  const SizedBox(height: 24),
                ],

                // Ações da conta
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      if (!isAnonymous) ...[
                        ListTile(
                          leading: const Icon(
                            Icons.edit_outlined,
                            color: PlantisColors.primary,
                          ),
                          title: const Text('Editar Perfil'),
                          subtitle: const Text('Nome, foto e informações pessoais'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showComingSoonDialog(context);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip_outlined,
                            color: PlantisColors.primary,
                          ),
                          title: const Text('Política de Privacidade'),
                          subtitle: const Text('Como tratamos seus dados'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/privacy-policy');
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.description_outlined,
                            color: PlantisColors.primary,
                          ),
                          title: const Text('Termos de Serviço'),
                          subtitle: const Text('Termos e condições de uso'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/terms-of-service');
                          },
                        ),
                        const Divider(height: 1),
                      ],
                      ListTile(
                        leading: Icon(
                          Icons.logout_outlined,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'Sair da Conta',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        subtitle: const Text('Fazer logout da aplicação'),
                        onTap: () {
                          _showLogoutDialog(context, authProvider);
                        },
                      ),
                      if (!isAnonymous) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          title: Text(
                            'Excluir Conta',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          subtitle: const Text('Remover conta permanentemente'),
                          onTap: () {
                            _showDeleteAccountDialog(context, authProvider);
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            );
          },
        ), // Consumer
      ), // SingleChildScrollView
    ), // Expanded
        ],
      ), // Column
    ), // ResponsiveLayout
  ); // Scaffold
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primary,
            PlantisColors.primaryDark,
          ],
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minha Conta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Perfil e configurações pessoais',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection(BuildContext context, dynamic user, auth_providers.AuthProvider authProvider) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações da Conta',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              _buildInfoRow('Tipo de Conta', authProvider.isPremium ? 'Premium' : 'Gratuita'),
              if (user?.createdAt != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Criada em', _formatDate(user!.createdAt)),
              ],
              if (user?.lastLoginAt != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Último acesso', _formatDate(user!.lastLoginAt)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else {
      return 'N/A';
    }
    
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Widget _buildSyncSection(BuildContext context, auth_providers.AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isSyncing = authProvider.isSyncInProgress;
    final lastSyncMessage = authProvider.syncMessage;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sincronização',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSyncing 
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
            title: Text(
              isSyncing ? 'Sincronizando...' : 'Dados Sincronizados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              isSyncing ? lastSyncMessage : 'Todos os dados estão atualizados',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: isSyncing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: () {
                      authProvider.startAutoSyncIfNeeded();
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Sincronizar agora',
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataExportSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exportação de Dados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: PlantisColors.primary,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar Dados'),
                subtitle: const Text('Baixar todos os seus dados em formato JSON'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonDialog(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: PlantisColors.secondary,
                    size: 20,
                  ),
                ),
                title: const Text('Relatório PDF'),
                subtitle: const Text('Gerar relatório completo das suas plantas'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showComingSoonDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Alterar Foto de Perfil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha uma nova foto para seu perfil',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: PlantisColors.primary,
                  size: 20,
                ),
              ),
              title: const Text('Câmera'),
              subtitle: const Text('Tirar uma nova foto'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PlantisColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: PlantisColors.secondary,
                  size: 20,
                ),
              ),
              title: const Text('Galeria'),
              subtitle: const Text('Escolher da galeria de fotos'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: const Text('Remover Foto'),
              subtitle: const Text('Voltar para avatar padrão'),
              onTap: () {
                Navigator.of(context).pop();
                _showComingSoonDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve'),
        content: const Text('Esta funcionalidade estará disponível em breve!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, auth_providers.AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Start auth loading
              startAuthLoading(operation: 'Fazendo logout...');
              
              try {
                await authProvider.logout();
                
                // Stop loading
                stopAuthLoading();
                
                if (context.mounted) {
                  context.go('/welcome');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao sair: ${DataSanitizationService.sanitizeForLogging(e.toString())}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, auth_providers.AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Excluir Conta',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação não pode ser desfeita. Ao excluir sua conta:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text('• Todos seus dados serão removidos permanentemente'),
            const Text('• Suas plantas e tarefas serão excluídas'),
            const Text('• Você não poderá recuperar essas informações'),
            const Text('• Sua assinatura premium será cancelada'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta ação é irreversível',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context, authProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, auth_providers.AuthProvider authProvider) {
    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Excluir Conta Permanentemente',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta ação é IRREVERSÍVEL. Todos os seus dados serão excluídos permanentemente.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para confirmar, digite sua senha atual:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Senha atual',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Ao confirmar, você concorda com nossa ',
                    ),
                    TextSpan(
                      text: 'Política de Exclusão de Contas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: passwordController.text.isEmpty
                  ? null
                  : () async {
                      final success = await authProvider.deleteAccount(
                        password: passwordController.text,
                        downloadData: false,
                      );

                      passwordController.dispose();
                      Navigator.of(context).pop();

                      if (success) {
                        if (context.mounted) {
                          _showDeletionSuccessDialog(context);
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider.errorMessage ??
                                    'Erro ao excluir conta. Tente novamente.',
                              ),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Excluir Conta'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeletionSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Conta Excluída com Sucesso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua conta foi excluída permanentemente. Todos os seus dados foram removidos de nossos servidores.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'Obrigado por ter usado o Plantis. Se precisar de ajuda, entre em contato conosco.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para tela de login ou inicial
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.support_agent_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Contatar Suporte'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para solicitar a exclusão da sua conta ou tirar dúvidas, entre em contato conosco:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DataSanitizationService.getSupportContactInfo()['email']!),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tempo de Resposta',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DataSanitizationService.getSupportContactInfo()['response_time']!),
                ],
              ),
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
}
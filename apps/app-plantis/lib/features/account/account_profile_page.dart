import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import '../../core/services/data_cleaner_service.dart';
import '../../core/services/data_sanitization_service.dart';
import '../../core/theme/plantis_colors.dart';
import '../../shared/widgets/base_page_scaffold.dart';
import '../../shared/widgets/loading/loading_components.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../auth/presentation/providers/auth_provider.dart' as auth_providers;

class AccountProfilePage extends StatefulWidget {
  const AccountProfilePage({super.key});

  @override
  State<AccountProfilePage> createState() => _AccountProfilePageState();
}

class _AccountProfilePageState extends State<AccountProfilePage>
    with LoadingPageMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BasePageScaffold(
      body: ResponsiveLayout(
        child: Column(
          children: [
            // Header seguindo mockup
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: PlantisHeader(
                title: 'Perfil do Visitante',
                subtitle: 'Entre em sua conta para recursos completos',
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Consumer<auth_providers.AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.currentUser;
                    final isAnonymous = authProvider.isAnonymous;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com informações do usuário
                        PlantisCard(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              // Avatar with edit functionality
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: PlantisColors.primary,
                                    child:
                                        DataSanitizationService.shouldShowProfilePhoto(
                                              user,
                                              isAnonymous,
                                            )
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                user!.photoUrl!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Text(
                                                    DataSanitizationService.sanitizeInitials(
                                                      user,
                                                      isAnonymous,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                            : Text(
                                              DataSanitizationService.sanitizeInitials(
                                                user,
                                                isAnonymous,
                                              ),
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
                                        onTap:
                                            () => _showImagePickerOptions(
                                              context,
                                            ),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: PlantisColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                      DataSanitizationService.sanitizeDisplayName(
                                        user,
                                        isAnonymous,
                                      ),
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DataSanitizationService.sanitizeEmail(
                                        user,
                                        isAnonymous,
                                      ),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isAnonymous
                                                ? Colors.orange.withValues(
                                                  alpha: 0.2,
                                                )
                                                : PlantisColors.primary
                                                    .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isAnonymous
                                            ? 'Conta Anônima'
                                            : 'Conta Autenticada',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  isAnonymous
                                                      ? Colors.orange
                                                      : PlantisColors.primary,
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
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
                                    icon: const Icon(
                                      Icons.person_add,
                                      size: 18,
                                    ),
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

                        // Controle de Dispositivos (apenas para usuários registrados)
                        if (!isAnonymous) ...[
                          _buildDeviceManagementSectionSimple(context),
                          const SizedBox(height: 24),
                        ],

                        // Dados e Sincronização (apenas para usuários registrados)
                        if (!isAnonymous) ...[
                          _buildDataSyncSection(context, authProvider),
                          const SizedBox(height: 24),
                        ],

                        // Ações de Conta - Subgrupo separado
                        PlantisCard(
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.delete_sweep,
                                  color: Colors.orange,
                                ),
                                title: const Text(
                                  'Limpar Dados',
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Limpar plantas e tarefas mantendo conta',
                                ),
                                onTap: () {
                                  _showClearDataDialog(context, authProvider);
                                },
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.logout_outlined,
                                  color: theme.colorScheme.error,
                                ),
                                title: Text(
                                  'Sair da Conta',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Fazer logout da aplicação',
                                ),
                                onTap: () {
                                  _showLogoutDialog(context, authProvider);
                                },
                              ),
                              if (!isAnonymous) ...[
                                ListTile(
                                  leading: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                  ),
                                  title: Text(
                                    'Excluir Conta',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Remover conta permanentemente',
                                  ),
                                  onTap: () {
                                    _showDeleteAccountDialog(
                                      context,
                                      authProvider,
                                    );
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

  Widget _buildAccountInfoSection(
    BuildContext context,
    dynamic user,
    auth_providers.AuthProvider authProvider,
  ) {
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
        PlantisCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoRow(
                'Tipo de Conta',
                authProvider.isPremium ? 'Premium' : 'Gratuita',
              ),
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

  Widget _buildDataSyncSection(
    BuildContext context,
    auth_providers.AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final isSyncing = authProvider.isSyncInProgress;
    final lastSyncMessage = authProvider.syncMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dados e Sincronização',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        PlantisCard(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSyncing
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
                  isSyncing
                      ? lastSyncMessage
                      : 'Todos os dados estão atualizados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing:
                    isSyncing
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlantisColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: PlantisColors.secondary,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar JSON'),
                subtitle: const Text(
                  'Baixar dados em formato JSON para backup',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/data-export'),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_view,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Exportar CSV'),
                subtitle: const Text(
                  'Baixar dados em planilha para análise',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/data-export'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceManagementSectionSimple(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dispositivos Conectados',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        PlantisCard(
          child: Column(
            children: [
              // Status resumido dos dispositivos
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices_other,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Nenhum dispositivo registrado',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Recursos em desenvolvimento',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/data-export'),
              ),

              // Ações rápidas
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showComingSoonDialog(context),
                        icon: const Icon(Icons.devices, size: 18),
                        label: const Text('Gerenciar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null, // Desabilitado
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Desconectar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
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
      builder:
          (context) => Container(
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
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Em breve'),
            content: const Text(
              'Esta funcionalidade estará disponível em breve!',
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

  void _showLogoutDialog(
    BuildContext context,
    auth_providers.AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Sair da Conta',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ao sair da sua conta, as seguintes ações serão realizadas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLogoutItem(
                  context,
                  Icons.cleaning_services,
                  'Limpeza de dados locais armazenados',
                ),
                _buildLogoutItem(
                  context,
                  Icons.sync_disabled,
                  'Interrupção da sincronização automática',
                ),
                _buildLogoutItem(
                  context,
                  Icons.login,
                  'Necessário fazer login novamente para acessar',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seus dados na nuvem permanecem seguros e serão restaurados no próximo login',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimaryContainer,
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
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout realizado com sucesso'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.go('/welcome');
                    }
                  } catch (e) {
                    stopAuthLoading();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro ao sair: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
                          ),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
    );
  }

  /// Constrói item de informação sobre logout
  Widget _buildLogoutItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(
    BuildContext context,
    auth_providers.AuthProvider authProvider,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _DataClearDialog(authProvider: authProvider);
      },
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    auth_providers.AuthProvider authProvider,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AccountDeletionDialog(authProvider: authProvider);
      },
    );
  }
}

/// Dialog stateful para confirmação de limpeza de dados
class _DataClearDialog extends StatefulWidget {
  final auth_providers.AuthProvider authProvider;

  const _DataClearDialog({required this.authProvider});

  @override
  State<_DataClearDialog> createState() => __DataClearDialogState();
}

class __DataClearDialogState extends State<_DataClearDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'LIMPAR';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone centralizado
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.delete_sweep,
              size: 32,
              color: Colors.orange,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Título
          Text(
            'Limpar Dados do App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Conteúdo alinhado à esquerda
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta ação limpará todos os dados em todos seus dispositivos:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
          const SizedBox(height: 16),
          _buildClearItem(
            context,
            Icons.local_florist,
            'Todas as suas plantas',
          ),
          _buildClearItem(
            context,
            Icons.task_alt,
            'Todas as tarefas e lembretes',
          ),
          _buildClearItem(
            context,
            Icons.space_dashboard,
            'Todos os espaços criados',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Serão mantidos: perfil, configurações, tema e assinatura',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Para confirmar, digite LIMPAR abaixo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Digite LIMPAR para confirmar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.orange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [_UpperCaseTextFormatter()],
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid && !_isLoading
                  ? () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final dataCleanerService = GetIt.instance<DataCleanerService>();
                      final result = await dataCleanerService.clearUserContentOnly();

                      if (context.mounted) {
                        Navigator.of(context).pop();

                        if (result['success'] as bool) {
                          final plantsCleaned = result['plantsCleaned'] as int;
                          final tasksCleaned = result['tasksCleaned'] as int;
                          final spacesCleaned = result['spacesCleaned'] as int;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dados limpos com sucesso!\n'
                                'Plantas: $plantsCleaned | Tarefas: $tasksCleaned | Espaços: $spacesCleaned',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else {
                          final errors = result['errors'] as List<String>;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erro ao limpar dados: ${errors.join(', ')}',
                              ),
                              backgroundColor: theme.colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao limpar dados: ${DataSanitizationService.sanitizeForLogging(e.toString())}',
                            ),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid && !_isLoading
                    ? Colors.orange
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid && !_isLoading
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Limpar Dados'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre limpeza
  Widget _buildClearItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog stateful para confirmação de exclusão de conta
class _AccountDeletionDialog extends StatefulWidget {
  final auth_providers.AuthProvider authProvider;

  const _AccountDeletionDialog({required this.authProvider});

  @override
  State<_AccountDeletionDialog> createState() => __AccountDeletionDialogState();
}

class __AccountDeletionDialogState extends State<_AccountDeletionDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    setState(() {
      _isConfirmationValid =
          _confirmationController.text.trim().toUpperCase() == 'CONCORDO';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: theme.colorScheme.error, size: 28),
          const SizedBox(width: 12),
          Text(
            'Excluir Conta',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esta ação é irreversível e resultará em:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeletionItem(
            context,
            Icons.delete_forever,
            'Exclusão permanente de todos seus dados',
          ),
          _buildDeletionItem(
            context,
            Icons.history,
            'Perda do histórico e informações armazenadas',
          ),
          _buildDeletionItem(
            context,
            Icons.cloud_off,
            'Impossibilidade de recuperar informações',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para cancelar assinaturas, acesse a loja onde a comprou (App Store ou Google Play)',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Para confirmar, digite CONCORDO abaixo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            decoration: InputDecoration(
              hintText: 'Digite CONCORDO para confirmar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [_UpperCaseTextFormatter()],
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isConfirmationValid
                  ? () async {
                    Navigator.of(context).pop();

                    final success = await widget.authProvider.deleteAccount(
                      password: '', // Plantis não requer senha para exclusão
                      downloadData: false,
                    );

                    if (context.mounted) {
                      if (success) {
                        _showDeletionSuccessDialog(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.authProvider.errorMessage ??
                                  'Erro ao excluir conta. Tente novamente.',
                            ),
                            backgroundColor: theme.colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isConfirmationValid
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            foregroundColor:
                _isConfirmationValid
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Excluir Conta'),
        ),
      ],
    );
  }

  /// Constrói item de informação sobre exclusão
  Widget _buildDeletionItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletionSuccessDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                  // Navegar para tela de welcome/inicial
                  context.go('/welcome');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }
}

/// Formatter que converte automaticamente o texto para uppercase
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

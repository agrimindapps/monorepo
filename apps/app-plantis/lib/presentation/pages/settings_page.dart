import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/injection_container.dart' as di;
import 'package:core/core.dart';

import '../../core/services/data_cleaner_service.dart';
import '../../core/services/test_data_generator_service.dart';
import '../../shared/widgets/responsive_layout.dart';
import '../../core/theme/plantis_colors.dart';
import '../../core/theme/plantis_design_tokens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_providers;
import '../../features/development/presentation/pages/database_inspector_page.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/settings/presentation/widgets/enhanced_settings_item.dart';
import '../../features/settings/presentation/widgets/premium_components.dart';
import '../../features/settings/presentation/widgets/settings_card.dart';
import '../../shared/widgets/loading/loading_components.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with LoadingPageMixin {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ContextualLoadingListener(
      context: LoadingContexts.settings,
      child: ChangeNotifierProvider<SettingsProvider>.value(
        value: di.sl<SettingsProvider>(), // Using pre-initialized singleton
        child: Scaffold(
          backgroundColor: PlantisColors.getPageBackgroundColor(context),
          body: ResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Consumer2<auth_providers.AuthProvider, SettingsProvider>(
              builder: (context, authProvider, settingsProvider, _) {
                final user = authProvider.currentUser;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Enhanced Header with plant-themed design
                const SizedBox(height: PlantisDesignTokens.spacing2),
                _buildEnhancedHeader(context, theme, user),
                
                const SizedBox(height: 24),

                // Enhanced User Profile Card
                _buildEnhancedProfileCard(context, theme, user),
                
                const SizedBox(height: 24),

                // Enhanced Premium Plan Card with upgrade prompt
                UpgradePrompt(
                  title: 'Desbloqueie o Poder das Plantas 🌱',
                  description: 'Transforme seu jardim com recursos premium que levam seus cuidados ao próximo nível.',
                  buttonText: 'Assinar Premium',
                  onUpgrade: () => context.push('/premium'),
                  features: const [
                    'Plantas ilimitadas',
                    'Backup automático na nuvem',
                    'Relatórios avançados de cuidados',
                    'Lembretes personalizados',
                    'Identificação de doenças por IA',
                    'Comunidade premium de jardineiros',
                  ],
                ),

                const SizedBox(height: 32),

            // Enhanced App Settings Card
            SettingsCard(
              title: 'Configurações do App',
              subtitle: 'Personalize sua experiência no Plantis',
              icon: Icons.settings,
              category: SettingsCardCategory.general,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.notifications_active,
                  title: 'Notificações',
                  subtitle: 'Configure quando ser notificado sobre tarefas',
                  type: SettingsItemType.normal,
                  isFirst: true,
                  onTap: () => context.push('/notifications-settings'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Tema',
                  subtitle: settingsProvider.themeSubtitle,
                  type: SettingsItemType.normal,
                  iconColor: settingsProvider.isDarkMode
                      ? PlantisColors.sun
                      : PlantisColors.primaryDark,
                  isLast: true,
                  trailing: Switch(
                    value: settingsProvider.isDarkMode,
                    onChanged: (value) {
                      if (value) {
                        settingsProvider.setDarkTheme();
                      } else {
                        settingsProvider.setLightTheme();
                      }
                    },
                    activeColor: PlantisColors.primary,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    thumbColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return PlantisColors.primary;
                      }
                      return theme.colorScheme.onSurface.withValues(alpha: 0.6);
                    }),
                    trackColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return PlantisColors.primary.withValues(alpha: 0.5);
                      }
                      return theme.colorScheme.onSurface.withValues(alpha: 0.2);
                    }),
                  ),
                  onTap: () {
                    if (settingsProvider.isDarkMode) {
                      settingsProvider.setLightTheme();
                    } else {
                      settingsProvider.setDarkTheme();
                    }
                  },
                ),
              ],
            ),

            // Enhanced Account Section
            SettingsCard(
              title: 'Conta 🌱',
              subtitle: 'Gerencie seus dados e preferências',
              icon: Icons.account_circle,
              category: SettingsCardCategory.account,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.devices,
                  title: 'Gerenciar Dispositivos',
                  subtitle: 'Controle quais aparelhos têm acesso',
                  type: SettingsItemType.normal,
                  isFirst: true,
                  onTap: () => context.push('/device-management'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.cloud_upload,
                  title: 'Backup na Nuvem',
                  subtitle: 'Proteja seus dados com backup automático',
                  type: SettingsItemType.info,
                  onTap: () => context.push('/backup-settings'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.star,
                  title: 'Premium',
                  subtitle: 'Recursos exclusivos e benefícios',
                  type: SettingsItemType.premium,
                  badge: 'NOVO',
                  isLast: true,
                  onTap: () => context.push('/premium'),
                ),
              ],
            ),

            // Enhanced Privacy & Legal Section
            SettingsCard(
              title: 'Privacidade e Legal 🔒',
              subtitle: 'Seus direitos e nossa responsabilidade',
              icon: Icons.security,
              category: SettingsCardCategory.privacy,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.download_for_offline,
                  title: 'Exportar Meus Dados',
                  subtitle: 'Baixe seus dados pessoais - LGPD',
                  type: SettingsItemType.info,
                  isFirst: true,
                  onTap: () => context.push('/data-export'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidade',
                  subtitle: 'Como protegemos seus dados',
                  type: SettingsItemType.info,
                  onTap: () => context.push('/privacy-policy'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.description,
                  title: 'Termos de Uso',
                  subtitle: 'Termos e condições de uso',
                  type: SettingsItemType.info,
                  onTap: () => context.push('/terms-of-service'),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.campaign,
                  title: 'Ofertas Promocionais',
                  subtitle: 'Conheça nossas promoções especiais',
                  type: SettingsItemType.premium,
                  isLast: true,
                  onTap: () => context.push('/promotional'),
                ),
              ],
            ),

            // Enhanced Development Section - Only visible in debug mode
            if (kDebugMode)
              SettingsCard(
                title: 'Desenvolvimento 🔧',
                subtitle: 'Ferramentas para desenvolvedores',
                icon: Icons.developer_mode,
                category: SettingsCardCategory.development,
                children: [
                  EnhancedSettingsItem(
                    icon: Icons.storage,
                    title: 'Inspetor de Dados',
                    subtitle: 'Visualizar dados locais do app',
                    type: SettingsItemType.info,
                    isFirst: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DataInspectorPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: PlantisDesignTokens.spacing2),
                  EnhancedSettingsItem(
                    icon: Icons.bug_report,
                    title: 'Gerar Dados de Teste',
                    subtitle: 'Criar plantas e tarefas de exemplo',
                    type: SettingsItemType.success,
                    onTap: () => _showGenerateTestDataDialog(context),
                  ),
                  const SizedBox(height: PlantisDesignTokens.spacing2),
                  EnhancedSettingsItem(
                    icon: Icons.clear_all,
                    title: 'Limpar Todos os Dados',
                    subtitle: 'Remove todos os registros locais',
                    type: SettingsItemType.danger,
                    isLast: true,
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),


            // Enhanced App Info Section
            SettingsCard(
              title: 'Sobre o Plantis 🌿',
              subtitle: 'Versão, avaliações e suporte',
              icon: Icons.info_outline,
              category: SettingsCardCategory.general,
              children: [
                EnhancedSettingsItem(
                  icon: Icons.star_rate,
                  title: 'Avaliar o App',
                  subtitle: 'Deixe sua avaliação na loja',
                  type: SettingsItemType.premium,
                  isFirst: true,
                  onTap: () => _showRateAppDialog(context),
                ),
                const SizedBox(height: PlantisDesignTokens.spacing2),
                EnhancedSettingsItem(
                  icon: Icons.info,
                  title: 'Informações do App',
                  subtitle: 'Versão, suporte e feedback',
                  type: SettingsItemType.info,
                  isLast: true,
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),

                const SizedBox(height: 40),
              ],
            );
              },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeData theme, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(PlantisDesignTokens.spacing6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlantisColors.primaryLight.withValues(alpha: 0.1),
            PlantisColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusXL),
        border: Border.all(
          color: PlantisColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PlantisDesignTokens.spacing2),
                decoration: BoxDecoration(
                  color: PlantisColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PlantisDesignTokens.radiusLG),
                ),
                child: const Icon(
                  Icons.eco,
                  color: PlantisColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: PlantisDesignTokens.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minha Conta',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      user != null && user.displayName != null && user.displayName.isNotEmpty
                          ? 'Bem-vindo, ${user.displayName}'
                          : 'Bem-vindo ao seu jardim digital 🌱',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const PlantThemedPremiumIndicator(
                isActive: false,
                label: 'GRÁTIS',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProfileCard(BuildContext context, ThemeData theme, dynamic user) {
    return SettingsCard(
      title: 'Perfil do Usuário',
      icon: Icons.person,
      category: SettingsCardCategory.account,
      expandable: false,
      onTap: () => context.push('/account-profile'),
      children: [
        Row(
          children: [
            // Enhanced Avatar with plant-themed border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: PlantisColors.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PlantisColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: PlantisColors.primary,
                child: user?.hasProfilePhoto == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          user!.photoUrl?.toString() ?? '',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        user?.initials ?? 'UA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: PlantisDesignTokens.spacing4),

            // Enhanced User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user?.displayName ?? 'Usuário Anônimo',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const FeatureAvailabilityIndicator(
                        isAvailable: true,
                        isPremium: false,
                        tooltip: 'Conta verificada',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'usuario@anonimo.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: PlantisColors.leafLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: PlantisColors.leaf,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMemberSince(user?.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PlantisColors.leafDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumFeature(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }




  String _getMemberSince(DateTime? createdAt) {
    if (createdAt == null) return 'Membro desde 10 dias';

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays < 30) {
      return 'Membro desde ${difference.inDays} dias';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Membro desde $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Membro desde $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }


  void _showRateAppDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.star_rate,
              color: PlantisColors.sun,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Avaliar o App',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
              'Está gostando do Plantis?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sua avaliação nos ajuda a melhorar e alcançar mais pessoas que amam plantas como você!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
            // Star rating visual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.star,
                  color: PlantisColors.sun,
                  size: 32,
                ),
              )),
            ),
            
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PlantisColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PlantisColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: PlantisColors.flower,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Obrigado por fazer parte da nossa comunidade!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
              'Mais tarde',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await _handleRateApp(context);
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Avaliar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.sun,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRateApp(BuildContext context) async {
    try {
      final appRatingService = di.sl<IAppRatingRepository>();
      final success = await appRatingService.showRatingDialog(context: context);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigado pelo feedback!'),
            backgroundColor: PlantisColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: PlantisColors.primaryGradient,
              ),
              child: const Icon(
                Icons.eco,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Plantis',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
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
              'Seu companheiro para cuidar de plantas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Versão', '1.0.0'),
            _buildInfoRow(context, 'Build', '1'),
            _buildInfoRow(context, 'Plataforma', 'Flutter'),
            const SizedBox(height: 16),
            Text(
              'Sistema inteligente de lembretes e cuidados para suas plantas, com sincronização automática e recursos premium.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: PlantisColors.flower,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Feito com carinho para amantes de plantas',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateTestDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Gerar Dados de Teste',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isso criará plantas e tarefas fictícias para testar a interface.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlantisColors.leafLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PlantisColors.leaf.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: PlantisColors.leaf,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Útil para demonstrações e testes',
                      style: TextStyle(
                        color: PlantisColors.leafDark,
                        fontSize: 12,
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
          ElevatedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final theme = Theme.of(context);

              navigator.pop();
              _showLoadingDialog(context, 'Gerando dados de teste...');

              try {
                final testDataService = di.sl<TestDataGeneratorService>();
                await testDataService.generateTestData();

                navigator.pop(); // Close loading

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Dados de teste gerados com sucesso!'),
                    backgroundColor: PlantisColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                navigator.pop(); // Close loading
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erro ao gerar dados: $e'),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Gerar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PlantisColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) async {
    final dataCleanerService = di.sl<DataCleanerService>();
    final stats = await dataCleanerService.getDataStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Limpar Todos os Dados',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta ação irá remover permanentemente:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            if (stats.hasData) ...[
              _buildDataItem(context, Icons.eco, '${stats.plantsCount} plantas'),
              _buildDataItem(context, Icons.task_alt, '${stats.tasksCount} tarefas'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta ação não pode ser desfeita',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: PlantisColors.leaf,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Não há dados para limpar',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          if (stats.hasData)
            ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final theme = Theme.of(context);

                navigator.pop();
                _showLoadingDialog(context, 'Limpando dados...');

                try {
                  final result = await dataCleanerService.clearAllData();
                  navigator.pop(); // Close loading

                  result.fold(
                    (failure) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Erro: ${failure.message}'),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    (_) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            '${stats.totalItems} itens removidos com sucesso',
                          ),
                          backgroundColor: PlantisColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                } catch (e) {
                  navigator.pop(); // Close loading
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro inesperado: $e'),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Limpar Tudo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: PlantisColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
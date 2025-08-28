import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/premium_provider.dart';

class PremiumFeaturesList extends StatelessWidget {
  const PremiumFeaturesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        final features = _getPremiumFeatures();
        
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 56,
              color: AppColors.grey200,
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return FutureBuilder<bool>(
                future: _checkFeatureAccess(premiumProvider, feature['id'] as String? ?? ''),
                builder: (context, snapshot) {
                  final hasAccess = snapshot.data ?? false;
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasAccess 
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.grey200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        feature['icon'] as IconData? ?? Icons.help,
                        color: hasAccess 
                          ? AppColors.success
                          : AppColors.grey500,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      feature['title'] as String? ?? '',
                      style: AppTextStyles.titleSmall,
                    ),
                    subtitle: Text(
                      feature['description'] as String? ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    trailing: hasAccess 
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.premiumGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.premiumGold.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.premiumGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getPremiumFeatures() {
    return [
      {
        'id': 'unlimited_vehicles',
        'icon': Icons.directions_car,
        'title': 'Veículos Ilimitados',
        'description': 'Adicione quantos veículos quiser ao seu perfil',
      },
      {
        'id': 'advanced_reports',
        'icon': Icons.analytics,
        'title': 'Relatórios Avançados',
        'description': 'Análises detalhadas e comparativos de consumo',
      },
      {
        'id': 'export_data',
        'icon': Icons.file_download,
        'title': 'Exportar Dados',
        'description': 'Exporte seus dados em formato CSV/Excel',
      },
      {
        'id': 'custom_categories',
        'icon': Icons.category,
        'title': 'Categorias Personalizadas',
        'description': 'Crie suas próprias categorias de gastos',
      },
      {
        'id': 'premium_themes',
        'icon': Icons.palette,
        'title': 'Temas Premium',
        'description': 'Acesse temas exclusivos e personalize o app',
      },
      {
        'id': 'cloud_backup',
        'icon': Icons.cloud_upload,
        'title': 'Backup na Nuvem',
        'description': 'Seus dados sempre seguros e sincronizados',
      },
      {
        'id': 'location_history',
        'icon': Icons.location_on,
        'title': 'Histórico de Localização',
        'description': 'Registre onde você abasteceu automaticamente',
      },
      {
        'id': 'advanced_analytics',
        'icon': Icons.trending_up,
        'title': 'Análises Avançadas',
        'description': 'Previsões e tendências de consumo inteligentes',
      },
      {
        'id': 'maintenance_alerts',
        'icon': Icons.notification_important,
        'title': 'Alertas de Manutenção',
        'description': 'Notificações personalizadas para manutenções',
      },
      {
        'id': 'fuel_efficiency_optimizer',
        'icon': Icons.eco,
        'title': 'Otimizador de Eficiência',
        'description': 'Dicas personalizadas para economizar combustível',
      },
      {
        'id': 'priority_support',
        'icon': Icons.support_agent,
        'title': 'Suporte Prioritário',
        'description': 'Atendimento premium com resposta em até 24h',
      },
      {
        'id': 'ad_free',
        'icon': Icons.block,
        'title': 'Sem Anúncios',
        'description': 'Use o app sem interrupções publicitárias',
      },
    ];
  }

  Future<bool> _checkFeatureAccess(PremiumProvider provider, String featureId) async {
    switch (featureId) {
      case 'unlimited_vehicles':
        return provider.isPremium;
      case 'advanced_reports':
        return await provider.canAccessAdvancedReports();
      case 'export_data':
        return await provider.canExportData();
      case 'custom_categories':
        return await provider.canUseCustomCategories();
      case 'premium_themes':
        return await provider.canAccessPremiumThemes();
      case 'cloud_backup':
        return await provider.canBackupToCloud();
      case 'location_history':
        return await provider.canUseLocationHistory();
      case 'advanced_analytics':
        return await provider.canAccessAdvancedAnalytics();
      default:
        return provider.isPremium;
    }
  }
}
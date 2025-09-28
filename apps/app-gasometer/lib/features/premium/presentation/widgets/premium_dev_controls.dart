import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/premium_provider.dart';

class PremiumDevControls extends StatelessWidget {
  const PremiumDevControls({super.key});

  @override
  Widget build(BuildContext context) {
    // Só mostrar em modo debug
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Consumer<PremiumProvider>(
      builder: (context, premiumProvider, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.developer_mode,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Controles de Desenvolvimento',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Licença Local',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use para testar funcionalidades premium durante desenvolvimento.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: premiumProvider.isLoading 
                              ? null 
                              : () => _generateLicense(context, premiumProvider, 7),
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: const Text('7 dias'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: premiumProvider.isLoading 
                              ? null 
                              : () => _generateLicense(context, premiumProvider, 30),
                            icon: const Icon(Icons.calendar_month, size: 18),
                            label: const Text('30 dias'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.info,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: premiumProvider.isLoading 
                          ? null 
                          : () => _revokeLicense(context, premiumProvider),
                        icon: const Icon(
                          Icons.block,
                          size: 18,
                          color: AppColors.error,
                        ),
                        label: const Text(
                          'Revogar Licença',
                          style: TextStyle(color: AppColors.error),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Divider(),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Outras Ações',
                      style: AppTextStyles.titleSmall,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: premiumProvider.isLoading 
                              ? null 
                              : () => _refreshStatus(context, premiumProvider),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Atualizar Status'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: premiumProvider.isLoading 
                              ? null 
                              : () => _restorePurchases(context, premiumProvider),
                            icon: const Icon(Icons.restore, size: 18),
                            label: const Text('Restaurar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status atual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Atual',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Premium: ${premiumProvider.isPremium ? "Ativo" : "Inativo"}',
                            style: AppTextStyles.bodySmall,
                          ),
                          Text(
                            'Fonte: ${premiumProvider.premiumSource}',
                            style: AppTextStyles.bodySmall,
                          ),
                          if (premiumProvider.expirationDate != null)
                            Text(
                              'Expira: ${_formatDate(premiumProvider.expirationDate!)}',
                              style: AppTextStyles.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateLicense(
    BuildContext context,
    PremiumProvider provider,
    int days,
  ) async {
    try {
      await provider.generateLocalLicense(days: days);
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Licença local gerada por $days dias'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar licença: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _revokeLicense(
    BuildContext context,
    PremiumProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Licença'),
        content: const Text(
          'Tem certeza que deseja revogar a licença local? '
          'Isso removerá o acesso premium de desenvolvimento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.revokeLocalLicense();
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Licença local revogada'),
          backgroundColor: AppColors.info,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao revogar licença: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _refreshStatus(
    BuildContext context,
    PremiumProvider provider,
  ) async {
    try {
      await provider.refreshPremiumStatus();
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status atualizado'),
          backgroundColor: AppColors.info,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _restorePurchases(
    BuildContext context,
    PremiumProvider provider,
  ) async {
    try {
      final success = await provider.restorePurchases();
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'Compras restauradas com sucesso'
              : 'Nenhuma compra encontrada para restaurar',
          ),
          backgroundColor: success ? AppColors.success : AppColors.info,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar compras: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injectable_config.dart' as gasometer_di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/premium_provider.dart';
import '../widgets/premium_dev_controls.dart';
import '../widgets/premium_features_list.dart';
import '../widgets/premium_products_list.dart';
import '../widgets/premium_status_card.dart';
import '../widgets/premium_upgrade_button.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PremiumProvider>(
      create: (_) => gasometer_di.getIt<PremiumProvider>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('GasOMeter Premium'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<PremiumProvider>(
          builder: (context, premiumProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await premiumProvider.refreshPremiumStatus();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status atual do premium
                    const PremiumStatusCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Lista de funcionalidades premium
                    const Text(
                      'Funcionalidades Premium',
                      style: AppTextStyles.headlineSmall,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const PremiumFeaturesList(),
                    
                    const SizedBox(height: 24),
                    
                    // Botão de upgrade ou produtos disponíveis
                    if (!premiumProvider.isPremium) ...[
                      const PremiumUpgradeButton(),
                      
                      const SizedBox(height: 24),
                      
                      const Text(
                        'Planos Disponíveis',
                        style: AppTextStyles.headlineSmall,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const PremiumProductsList(),
                    ],
                    
                    // Controles de desenvolvimento (apenas em debug)
                    if (_isDebugMode()) ...[
                      const SizedBox(height: 32),
                      const PremiumDevControls(),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isDebugMode() {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }
}
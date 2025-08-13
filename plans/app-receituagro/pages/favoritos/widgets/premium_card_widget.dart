// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:icons_plus/icons_plus.dart';

// Project imports:
import '../../../../core/themes/manager.dart';
import '../constants/favoritos_design_tokens.dart';

class PremiumCardWidget extends StatefulWidget {
  const PremiumCardWidget({super.key});

  @override
  State<PremiumCardWidget> createState() => _PremiumCardWidgetState();
}

class _PremiumCardWidgetState extends State<PremiumCardWidget> {
  bool _isUpgradeLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDark.value;
    const premiumColor = Color(0xFFFF9800);

    return Center(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  premiumColor.withValues(alpha: 0.15),
                  premiumColor.withValues(alpha: 0.1),
                ]
              : [
                  const Color(0xFFFFF8E1),
                  const Color(0xFFFFF3E0),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(FavoritosDesignTokens.largeBorderRadius),
        border: Border.all(
          color: premiumColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: premiumColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: FavoritosDesignTokens.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        premiumColor.withValues(alpha: 0.8),
                        premiumColor.withValues(alpha: 1.0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                        FavoritosDesignTokens.defaultBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: premiumColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    FontAwesome.crown_solid,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: FavoritosDesignTokens.largeSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seja Premium',
                        style: TextStyle(
                          fontSize: FavoritosDesignTokens.headingFontSize,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.amber.shade200
                              : const Color(0xFF6D4C41),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Desbloqueie recursos exclusivos e tenha acesso ilimitado a todos os conteúdos do app!',
                        style: TextStyle(
                          fontSize: FavoritosDesignTokens.bodyFontSize,
                          color: isDark
                              ? Colors.amber.shade100
                              : const Color(0xFF8D6E63),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: FavoritosDesignTokens.largeSpacing),
            ElevatedButton.icon(
              onPressed: _isUpgradeLoading
                  ? null
                  : () {
                      _showPremiumUpgradeDialog(context);
                    },
              icon: const Icon(
                FontAwesome.rocket_solid,
                size: 16,
              ),
              label: const Text(
                'Desbloquear Agora',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: premiumColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: premiumColor.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(
                  horizontal: FavoritosDesignTokens.extraLargeSpacing,
                  vertical: FavoritosDesignTokens.mediumSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      FavoritosDesignTokens.defaultBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _showPremiumUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                FontAwesome.crown_solid,
                color: Colors.amber.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Upgrade Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Desbloquear recursos premium:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildBenefitItem('✨ Favoritos ilimitados'),
              _buildBenefitItem('🔍 Busca avançada'),
              _buildBenefitItem('📱 Suporte prioritário'),
              _buildBenefitItem('🚀 Recursos exclusivos'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Funcionalidade em desenvolvimento. Em breve disponível!',
                        style: TextStyle(fontSize: 12),
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
              child: const Text('Fechar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                setState(() => _isUpgradeLoading = true);

                // Simular carregamento
                await Future.delayed(const Duration(seconds: 1));

                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('🚀 Upgrade premium em desenvolvimento!'),
                      backgroundColor: Colors.amber,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  setState(() => _isUpgradeLoading = false);
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Em breve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

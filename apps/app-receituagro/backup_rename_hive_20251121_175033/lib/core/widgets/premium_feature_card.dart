import 'package:flutter/material.dart';

/// Widget genérico para cards de recursos premium
///
/// Características:
/// - Suporte a dark mode
/// - Altamente customizável
/// - Design consistente
/// - Lista opcional de benefícios
///
/// Uso:
/// ```dart
/// PremiumFeatureCard(
///   title: 'Recurso Premium',
///   description: 'Descrição do recurso',
///   onUpgradePressed: () => navigateToSubscription(),
/// )
/// ```
class PremiumFeatureCard extends StatelessWidget {
  /// Título do card
  final String title;

  /// Descrição do recurso premium
  final String description;

  /// Texto do botão de upgrade (default: 'Upgrade para Premium')
  final String? buttonText;

  /// Ícone a ser exibido (default: Icons.diamond)
  final IconData? icon;

  /// Lista de benefícios a exibir (opcional)
  final List<String>? benefits;

  /// Título da seção de benefícios
  final String? benefitsTitle;

  /// Callback quando botão de upgrade é pressionado
  final VoidCallback? onUpgradePressed;

  /// Tamanho do card (default: 360)
  final double? width;

  /// Mostrar ícone de foguete no botão ao invés de diamond
  final bool useRocketIcon;

  const PremiumFeatureCard({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.icon,
    this.benefits,
    this.benefitsTitle,
    this.onUpgradePressed,
    this.width,
    this.useRocketIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: width ?? 360,
          child: Card(
            color: isDark
              ? Colors.orange.shade900.withValues(alpha: 0.3)
              : Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark
                  ? Colors.orange.shade700.withValues(alpha: 0.5)
                  : Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(isDark),
                  const SizedBox(height: 20),
                  _buildTitle(theme, isDark),
                  const SizedBox(height: 12),
                  _buildDescription(theme, isDark),
                  if (benefits != null && benefits!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildBenefitsList(theme, isDark),
                  ],
                  const SizedBox(height: 28),
                  _buildUpgradeButton(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o ícone
  Widget _buildIcon(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [Colors.orange.shade700, Colors.orange.shade900]
            : [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon ?? Icons.diamond,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  /// Constrói o título
  Widget _buildTitle(ThemeData theme, bool isDark) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Constrói a descrição
  Widget _buildDescription(ThemeData theme, bool isDark) {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Constrói lista de benefícios
  Widget _buildBenefitsList(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
          ? Colors.grey.shade800.withValues(alpha: 0.5)
          : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
            ? Colors.orange.shade700.withValues(alpha: 0.3)
            : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (benefitsTitle != null) ...[
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: isDark ? Colors.orange.shade300 : Colors.orange.shade600,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  benefitsTitle!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...benefits!.map((benefit) => _buildBenefitItem(benefit, theme, isDark)),
        ],
      ),
    );
  }

  /// Constrói item de benefício
  Widget _buildBenefitItem(String benefit, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: isDark ? Colors.green.shade400 : Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói botão de upgrade
  Widget _buildUpgradeButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onUpgradePressed ?? () {},
        icon: Icon(
          useRocketIcon ? Icons.rocket_launch : Icons.diamond,
          size: 20,
        ),
        label: Text(
          buttonText ?? 'Upgrade para Premium',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.orange.shade700 : Colors.orange.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Factory constructor para versão compacta
  factory PremiumFeatureCard.compact({
    required String title,
    required String description,
    VoidCallback? onUpgradePressed,
  }) {
    return PremiumFeatureCard(
      title: title,
      description: description,
      onUpgradePressed: onUpgradePressed,
      width: 280,
    );
  }

  /// Factory constructor para versão com benefícios
  factory PremiumFeatureCard.withBenefits({
    required String title,
    required String description,
    required List<String> benefits,
    String? benefitsTitle,
    VoidCallback? onUpgradePressed,
    bool useRocketIcon = false,
  }) {
    return PremiumFeatureCard(
      title: title,
      description: description,
      benefits: benefits,
      benefitsTitle: benefitsTitle ?? 'Benefícios Premium:',
      onUpgradePressed: onUpgradePressed,
      useRocketIcon: useRocketIcon,
      width: 400,
    );
  }
}

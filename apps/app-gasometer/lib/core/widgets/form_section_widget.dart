import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// FormSectionWidget - Versão Simplificada
/// 
/// NOTA: Existe também uma versão mais avançada em core/presentation/widgets/form_section_widget.dart
/// Esta versão usa API: FormSectionWidget(title, icon, children)
/// A versão avançada usa API: FormSectionWidget(title, content, titleIcon, etc.)
/// 
/// TODO: Considerar unificação das APIs no futuro
class FormSectionWidget extends StatelessWidget {

  const FormSectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// Factory com títulos padronizados usando design tokens
  factory FormSectionWidget.withTitle({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    return FormSectionWidget(
      title: title,
      icon: icon,
      children: children,
    );
  }
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: GasometerDesignTokens.spacingSectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: GasometerDesignTokens.iconSizeButton,
              ),
              const SizedBox(width: GasometerDesignTokens.spacingSm),
              Text(
                title,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeLg,
                  fontWeight: GasometerDesignTokens.fontWeightSemiBold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: GasometerDesignTokens.spacingLg),
          ...children,
        ],
      ),
    );
  }
}

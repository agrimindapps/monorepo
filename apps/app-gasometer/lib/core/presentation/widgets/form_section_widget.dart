import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';
import 'standard_card.dart';

/// Widget para seções de formulário consistentes
/// 
/// Encapsula campos relacionados em cards padronizados
/// com título opcional e espaçamento semântico.
class FormSectionWidget extends StatelessWidget {
  /// Título da seção
  final String? title;
  
  /// Ícone do título
  final IconData? titleIcon;
  
  /// Cor do ícone
  final Color? titleIconColor;
  
  /// Conteúdo da seção (campos do formulário)
  final Widget content;
  
  /// Margin externa do card
  final EdgeInsets? margin;
  
  /// Se deve mostrar border ao redor do card
  final bool showBorder;

  const FormSectionWidget({
    super.key,
    this.title,
    this.titleIcon,
    this.titleIconColor,
    required this.content,
    this.margin,
    this.showBorder = true,
  });

  /// Factory para seção com título
  factory FormSectionWidget.withTitle({
    required String title,
    IconData? icon,
    Color? iconColor,
    required Widget content,
    EdgeInsets? margin,
    bool showBorder = true,
  }) {
    return FormSectionWidget(
      title: title,
      titleIcon: icon,
      titleIconColor: iconColor,
      content: content,
      margin: margin,
      showBorder: showBorder,
    );
  }

  /// Factory para seção simples (sem título)
  factory FormSectionWidget.simple({
    required Widget content,
    EdgeInsets? margin,
    bool showBorder = true,
  }) {
    return FormSectionWidget(
      content: content,
      margin: margin,
      showBorder: showBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StandardCard.formSection(
      margin: margin,
      showBorder: showBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            CardSectionTitle(
              title: title!,
              icon: titleIcon,
              iconColor: titleIconColor,
            ),
          content,
        ],
      ),
    );
  }
}

/// Widget para agrupamento de campos em linha
class FormFieldRow extends StatelessWidget {
  /// Campos a serem organizados em linha
  final List<Widget> children;
  
  /// Espaçamento entre os campos
  final double spacing;

  const FormFieldRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
  });

  /// Factory com spacing padrão baseado nos design tokens
  factory FormFieldRow.standard({
    required List<Widget> children,
  }) {
    return FormFieldRow(
      children: children,
      spacing: GasometerDesignTokens.spacingLg,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    
    final List<Widget> rowChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      rowChildren.add(Expanded(child: children[i]));
      
      if (i < children.length - 1) {
        rowChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(children: rowChildren);
  }
}

/// Widget para espaçamento vertical entre elementos de formulário
class FormSpacing extends StatelessWidget {
  /// Altura do espaçamento
  final double height;

  const FormSpacing({
    super.key,
    required this.height,
  });

  /// Espaçamento pequeno
  factory FormSpacing.small() {
    return FormSpacing(height: GasometerDesignTokens.spacingSm);
  }

  /// Espaçamento médio
  factory FormSpacing.medium() {
    return FormSpacing(height: GasometerDesignTokens.spacingMd);
  }

  /// Espaçamento grande
  factory FormSpacing.large() {
    return FormSpacing(height: GasometerDesignTokens.spacingLg);
  }

  /// Espaçamento entre seções
  factory FormSpacing.section() {
    return FormSpacing(height: GasometerDesignTokens.spacingSectionSpacing);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

/// Widget para botões de ação em formulários
class FormActionButtons extends StatelessWidget {
  /// Botão primário (ex: Salvar)
  final Widget primaryButton;
  
  /// Botão secundário opcional (ex: Cancelar)
  final Widget? secondaryButton;
  
  /// Alinhamento dos botões
  final MainAxisAlignment alignment;
  
  /// Espaçamento entre os botões
  final double spacing;

  const FormActionButtons({
    super.key,
    required this.primaryButton,
    this.secondaryButton,
    this.alignment = MainAxisAlignment.end,
    this.spacing = 16.0,
  });

  /// Factory com layout padrão (Cancelar | Salvar)
  factory FormActionButtons.standard({
    required Widget primaryButton,
    Widget? secondaryButton,
  }) {
    return FormActionButtons(
      primaryButton: primaryButton,
      secondaryButton: secondaryButton,
      spacing: GasometerDesignTokens.spacingLg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];
    
    if (secondaryButton != null) {
      buttons.add(Expanded(child: secondaryButton!));
      buttons.add(SizedBox(width: spacing));
    }
    
    buttons.add(
      Expanded(
        flex: secondaryButton != null ? 2 : 1,
        child: primaryButton,
      ),
    );

    return Row(
      mainAxisAlignment: alignment,
      children: buttons,
    );
  }
}
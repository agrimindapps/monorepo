// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../core/style/shadcn_style.dart';

/// Templates base para formulários padronizados
class FormTemplates {
  /// Template base para formulários padrão
  static Widget standardForm({
    required String title,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(24.0),
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Título do formulário
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 16.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Text(
            title,
            style: ShadcnStyle.titleStyle,
          ),
        ),

        // Conteúdo do formulário
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }

  /// Template para formulário em dialog
  static Widget dialogForm({
    required BuildContext context,
    required String title,
    required Widget child,
    List<Widget>? actions,
    EdgeInsets contentPadding = const EdgeInsets.all(24.0),
    double? width,
    double? height,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: width,
        height: height,
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: ShadcnStyle.titleStyle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Conteúdo
            Expanded(
              child: SingleChildScrollView(
                padding: contentPadding,
                child: child,
              ),
            ),

            // Actions
            if (actions != null && actions.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: action,
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Template para formulário em card
  static Widget cardForm({
    required String title,
    required Widget child,
    EdgeInsets margin = const EdgeInsets.all(16.0),
    EdgeInsets padding = const EdgeInsets.all(24.0),
    double? elevation,
  }) {
    return Card(
      margin: margin,
      elevation: elevation ?? 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: standardForm(
        title: title,
        child: child,
        padding: padding,
      ),
    );
  }

  /// Template para seção de formulário
  static Widget section({
    required String title,
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16.0),
    bool showDivider = true,
    IconData? icon,
  }) {
    return Container(
      padding: padding,
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.3),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: ShadcnStyle.primaryColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: ShadcnStyle.subtitleStyle,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Conteúdo da seção
          ...children,
        ],
      ),
    );
  }

  /// Template para campo de formulário
  static Widget fieldGroup({
    required String label,
    required Widget field,
    String? description,
    bool required = false,
    Widget? suffix,
    EdgeInsets margin = const EdgeInsets.only(bottom: 16.0),
  }) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: label,
                  style: ShadcnStyle.labelStyle,
                  children: required
                      ? [
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ]
                      : null,
                ),
              ),
              if (suffix != null) ...[
                const Spacer(),
                suffix,
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Campo
          field,

          // Descrição
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Template para grupo de campos em linha
  static Widget fieldRow({
    required List<Widget> fields,
    List<int>? flexValues,
    double spacing = 16.0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    final children = <Widget>[];

    for (int i = 0; i < fields.length; i++) {
      final flex =
          flexValues != null && i < flexValues.length ? flexValues[i] : 1;

      children.add(
        Expanded(
          flex: flex,
          child: fields[i],
        ),
      );

      if (i < fields.length - 1) {
        children.add(SizedBox(width: spacing));
      }
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  /// Template para botões de ação
  static Widget actionButtons({
    required List<Widget> buttons,
    MainAxisAlignment alignment = MainAxisAlignment.end,
    double spacing = 8.0,
    EdgeInsets padding = const EdgeInsets.only(top: 24.0),
  }) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: buttons
            .map((button) => Padding(
                  padding: EdgeInsets.only(left: spacing),
                  child: button,
                ))
            .toList(),
      ),
    );
  }

  /// Template para botão primário
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ShadcnStyle.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  /// Template para botão secundário
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ShadcnStyle.primaryColor,
          side: const BorderSide(color: ShadcnStyle.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }

  /// Template para espaçamento consistente
  static Widget spacer({
    double? height,
    double? width,
  }) {
    return SizedBox(
      height: height ?? 16.0,
      width: width,
    );
  }
}

/// Configurações de layout responsivo
class ResponsiveConfig {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static double getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      return screenWidth * 0.95;
    } else if (isTablet(context)) {
      return screenWidth * 0.8;
    } else {
      return 600.0;
    }
  }
}

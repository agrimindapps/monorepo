import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Standardized submit button for forms
class FormSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isEnabled;
  final bool isDestructive;
  
  const FormSubmitButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isEnabled = true,
    this.isDestructive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isDestructive 
        ? colorScheme.error 
        : colorScheme.primary;
    final foregroundColor = isDestructive 
        ? colorScheme.onError 
        : colorScheme.onPrimary;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: GasometerDesignTokens.paddingVertical(
            GasometerDesignTokens.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusInput,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: GasometerDesignTokens.fontSizeLg,
                  fontWeight: GasometerDesignTokens.fontWeightSemiBold,
                ),
              ),
      ),
    );
  }
}

/// Standardized cancel button for forms
class FormCancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  
  const FormCancelButton({
    super.key,
    this.onPressed,
    this.text = 'Cancelar',
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          padding: GasometerDesignTokens.paddingVertical(
            GasometerDesignTokens.spacingLg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: GasometerDesignTokens.borderRadius(
              GasometerDesignTokens.radiusInput,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: GasometerDesignTokens.fontSizeLg,
          ),
        ),
      ),
    );
  }
}

/// Container for form action buttons with standard spacing
class FormActionButtons extends StatelessWidget {
  final Widget? primaryButton;
  final Widget? secondaryButton;
  final EdgeInsetsGeometry? padding;
  
  const FormActionButtons({
    super.key,
    this.primaryButton,
    this.secondaryButton,
    this.padding,
  });
  
  /// Standard form action buttons with submit and cancel
  factory FormActionButtons.standard({
    Key? key,
    required VoidCallback? onSubmit,
    required VoidCallback? onCancel,
    String submitText = 'Salvar',
    String cancelText = 'Cancelar',
    bool isLoading = false,
    bool isEnabled = true,
    EdgeInsetsGeometry? padding,
  }) {
    return FormActionButtons(
      key: key,
      padding: padding,
      secondaryButton: FormCancelButton(
        onPressed: onCancel,
        text: cancelText,
      ),
      primaryButton: FormSubmitButton(
        onPressed: onSubmit,
        text: submitText,
        isLoading: isLoading,
        isEnabled: isEnabled,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? 
        GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingLg);
    
    return Padding(
      padding: effectivePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (secondaryButton != null) ...[
            secondaryButton!,
            SizedBox(height: GasometerDesignTokens.spacingMd),
          ],
          if (primaryButton != null) primaryButton!,
        ],
      ),
    );
  }
}

/// Standardized error widget for forms
class FormErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  
  const FormErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusCard,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: GasometerDesignTokens.iconSizeXl,
          ),
          SizedBox(height: GasometerDesignTokens.spacingMd),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontSize: GasometerDesignTokens.fontSizeMd,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: GasometerDesignTokens.spacingMd),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Container for form fields with standard styling
class FormFieldContainer extends StatelessWidget {
  final Widget child;
  final String? label;
  final bool required;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const FormFieldContainer({
    super.key,
    required this.child,
    this.label,
    this.required = false,
    this.padding,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? 
        GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingSm);
    final effectiveMargin = margin ?? 
        GasometerDesignTokens.paddingVertical(GasometerDesignTokens.spacingSm);
    
    return Container(
      margin: effectiveMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeMd,
                    fontWeight: GasometerDesignTokens.fontWeightMedium,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (required) ...[
                  Text(
                    ' *',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: GasometerDesignTokens.fontSizeMd,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: GasometerDesignTokens.spacingSm),
          ],
          Padding(
            padding: effectivePadding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Loading overlay for forms
class FormLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  
  const FormLoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? 
          Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: Center(
        child: Card(
          child: Padding(
            padding: GasometerDesignTokens.paddingAll(
              GasometerDesignTokens.spacingXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  SizedBox(height: GasometerDesignTokens.spacingLg),
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeMd,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header widget for forms with icon and description
class FormHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  
  const FormHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? 
        GasometerDesignTokens.paddingAll(GasometerDesignTokens.spacingXl);
    
    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? 
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: GasometerDesignTokens.borderRadius(
          GasometerDesignTokens.radiusCard,
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: GasometerDesignTokens.paddingAll(
              GasometerDesignTokens.spacingMd,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: GasometerDesignTokens.borderRadius(
                GasometerDesignTokens.radiusInput,
              ),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: GasometerDesignTokens.iconSizeLg,
            ),
          ),
          SizedBox(width: GasometerDesignTokens.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: GasometerDesignTokens.fontSizeXl,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: GasometerDesignTokens.spacingXs),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: GasometerDesignTokens.fontSizeMd,
                      color: Theme.of(context).colorScheme.onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
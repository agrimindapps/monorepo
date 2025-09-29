import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Design System Components
/// Centralized reusable components with consistent styling

// =====================================================================
// ENHANCED CARD COMPONENT
// =====================================================================

/// Enhanced Card with consistent styling and accessibility
class DSCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;

  const DSCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        margin: margin ?? const EdgeInsets.only(bottom: 8),
        elevation: elevation ?? 2,
        color: backgroundColor ?? const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: (borderRadius as BorderRadius?) ?? BorderRadius.circular(12),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              )
            : Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: child,
              ),
      ),
    );
  }
}

// =====================================================================
// MARKET CARD COMPONENT
// =====================================================================

/// Standardized Market Card for market data display
class DSMarketCard extends StatelessWidget {
  final String title;
  final String price;
  final double changeValue;
  final double changePercent;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;
  final String? category;

  const DSMarketCard({
    super.key,
    required this.title,
    required this.price,
    required this.changeValue,
    required this.changePercent,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changeValue > 0;
    final isNegative = changeValue < 0;
    final changeColor = isPositive
        ? const Color(0xFF4CAF50)
        : isNegative
            ? const Color(0xFFD32F2F)
            : const Color(0xFF9E9E9E);

    return DSCard(
      onTap: onTap,
      semanticLabel: 'Market card for $title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and favorite
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),
                    if (category != null)
                      Text(
                        category!,
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
              if (onFavoriteToggle != null)
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFD32F2F) : const Color(0xFF757575),
                    size: 20,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Price and change row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: AppTextStyles.priceDisplay,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.arrow_upward
                          : isNegative
                              ? Icons.arrow_downward
                              : Icons.remove,
                      color: changeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercent.toStringAsFixed(2)}%',
                      style: AppTextStyles.priceChange.copyWith(color: changeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// BUTTON COMPONENTS
// =====================================================================

/// Primary Button with consistent styling
class DSPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const DSPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: const Color(0xFFFFFFFF),
          disabledBackgroundColor: const Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFFFFF),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: AppTextStyles.button),
                ],
              ),
      ),
    );
  }
}

/// Secondary Button with outlined style
class DSSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const DSSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2E7D32),
          side: const BorderSide(color: Color(0xFF2E7D32)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text, style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// INPUT COMPONENTS
// =====================================================================

/// Enhanced Text Field with consistent styling
class DSTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool enabled;
  final int? maxLines;

  const DSTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: const Color(0xFF757575),
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixIconTap,
                icon: Icon(
                  suffixIcon,
                  color: const Color(0xFF757575),
                  size: 20,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

// =====================================================================
// STATUS INDICATOR COMPONENTS
// =====================================================================

/// Status Indicator with color and text
class DSStatusIndicator extends StatelessWidget {
  final String status;
  final String text;
  final bool isCompact;

  const DSStatusIndicator({
    super.key,
    required this.status,
    required this.text,
    this.isCompact = false,
  });

  Color get _getStatusColor {
    switch (status.toLowerCase()) {
      case 'active':
      case 'success':
      case 'completed':
        return const Color(0xFF388E3C);
      case 'error':
      case 'failed':
      case 'inactive':
        return const Color(0xFFD32F2F);
      case 'warning':
      case 'pending':
        return const Color(0xFFF57C00);
      case 'info':
      default:
        return const Color(0xFF1976D2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 16,
        vertical: isCompact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: (isCompact ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                .copyWith(color: statusColor),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SECTION HEADER COMPONENT
// =====================================================================

/// Section Header with consistent styling
class DSSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const DSSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMedium),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// =====================================================================
// LOADING INDICATOR COMPONENTS
// =====================================================================

/// Loading Card Placeholder
class DSLoadingCard extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const DSLoadingCard({
    super.key,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return DSCard(
      margin: margin,
      child: Container(
        height: height ?? 80,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF2E7D32),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// ERROR STATE COMPONENTS
// =====================================================================

/// Error State Display
class DSErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const DSErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 48,
              color: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              DSSecondaryButton(
                text: 'Tentar Novamente',
                onPressed: onRetry,
                icon: Icons.refresh,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
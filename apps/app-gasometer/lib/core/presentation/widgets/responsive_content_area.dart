/// Responsive content container with max-width constraints
/// Provides consistent content layout across different screen sizes
/// Centers content and applies appropriate padding based on screen size
library;

import 'package:flutter/material.dart';
import '../../constants/responsive_constants.dart';

class ResponsiveContentArea extends StatelessWidget {
  
  const ResponsiveContentArea({
    super.key,
    required this.child,
    this.constrainWidth = true,
    this.padding,
    this.applyHorizontalPadding = true,
    this.applyVerticalPadding = true,
  });
  final Widget child;
  final bool constrainWidth;
  final EdgeInsets? padding;
  final bool applyHorizontalPadding;
  final bool applyVerticalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        EdgeInsets effectivePadding;
        
        if (padding != null) {
          effectivePadding = padding!;
        } else {
          // Default responsive padding
          final horizontalPadding = applyHorizontalPadding 
              ? ResponsiveBreakpoints.getHorizontalPadding(screenWidth)
              : 0.0;
          final verticalPadding = applyVerticalPadding ? 16.0 : 0.0;
          
          effectivePadding = EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          );
        }
        
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constrainWidth 
                  ? ResponsiveBreakpoints.maxContentWidth 
                  : double.infinity,
            ),
            child: Container(
              padding: effectivePadding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Specialized content area for dashboard/grid layouts
class ResponsiveGridArea extends StatelessWidget {
  
  const ResponsiveGridArea({
    super.key,
    required this.child,
    this.forceColumns,
    this.childAspectRatio = 1.2,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });
  final Widget child;
  final int? forceColumns;
  final double? childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        
        return ResponsiveContentArea(
          child: child,
        );
      },
    );
  }
}

/// Page header that adapts to desktop/mobile layouts
class ResponsivePageHeader extends StatelessWidget {
  
  const ResponsivePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.actions,
    this.showOnMobile = false,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget>? actions;
  final bool showOnMobile;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    
    // Don't show header on mobile unless explicitly requested
    if (isMobile && !showOnMobile) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AdaptiveSpacing.lg(context)),
      margin: EdgeInsets.only(bottom: AdaptiveSpacing.md(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AdaptiveSpacing.md(context)),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: ResponsiveLayout.isDesktop(context) ? 32 : 24,
            ),
          ),
          SizedBox(width: AdaptiveSpacing.md(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveLayout.isDesktop(context) ? 28 : 24,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: ResponsiveLayout.isDesktop(context) ? 16 : 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...[
            SizedBox(width: AdaptiveSpacing.md(context)),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

/// Responsive card container with adaptive padding and spacing
class ResponsiveCard extends StatelessWidget {
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius,
  });
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? EdgeInsets.all(AdaptiveSpacing.md(context));
    final effectiveElevation = elevation ?? (ResponsiveLayout.isDesktop(context) ? 2.0 : 1.0);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    return Card(
      elevation: effectiveElevation,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}
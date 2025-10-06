import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// **Comprehensive UI Components Library**
/// 
/// A centralized collection of reusable UI components that ensure consistency
/// across the entire PetiVeti application. Built following Material Design 3
/// principles and app-specific design tokens.
/// 
/// ## Design System Components:
/// - **Loading States**: Consistent loading indicators across all features
/// - **Empty States**: Engaging empty states with helpful actions
/// - **Error States**: User-friendly error messages with recovery options
/// - **Loading Overlays**: Full-screen and inline loading states
/// - **State Indicators**: Visual feedback for different states
/// - **Interactive Elements**: Buttons, cards, and form components
/// 
/// ## Benefits:
/// - **Consistency**: Uniform appearance across all features
/// - **Maintainability**: Centralized styling and behavior
/// - **Accessibility**: Built-in semantic support
/// - **Performance**: Optimized widgets with proper disposal
/// - **Developer Experience**: Easy-to-use API with good defaults
/// 
/// @author PetiVeti UX/UI Team
/// @since 1.0.0
class UIComponents {
  UIComponents._();

  /// **Standard Loading Indicator**
  /// 
  /// Primary loading indicator used throughout the app with consistent styling.
  /// Optimized for accessibility with semantic labels and live region updates.
  /// 
  /// **Parameters:**
  /// - [size]: Size of the loading indicator (defaults to 24)
  /// - [color]: Custom color (defaults to theme primary)
  /// - [semanticLabel]: Accessibility label for screen readers
  /// - [strokeWidth]: Thickness of the loading indicator
  /// 
  /// **Usage Example:**
  /// ```dart
  /// UIComponents.loadingIndicator(
  ///   semanticLabel: 'Carregando pets',
  ///   size: 32,
  /// )
  /// ```
  static Widget loadingIndicator({
    double size = 24,
    Color? color,
    String semanticLabel = 'Carregando',
    double strokeWidth = 2.0,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: 'Aguarde enquanto o conteúdo está sendo carregado',
      liveRegion: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: color != null 
              ? AlwaysStoppedAnimation(color)
              : const AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
    );
  }

  /// **Centered Loading State**
  /// 
  /// Full-screen centered loading state with optional message.
  /// Perfect for initial page loads and major state transitions.
  /// 
  /// **Parameters:**
  /// - [message]: Optional loading message
  /// - [size]: Size of the loading indicator
  /// - [showMessage]: Whether to show the loading message
  /// 
  /// **Features:**
  /// - Responsive text sizing
  /// - Proper semantic structure
  /// - Optional message display
  /// - Consistent spacing
  static Widget centeredLoading({
    String? message,
    double size = 32,
    bool showMessage = true,
  }) {
    return Center(
      child: Semantics(
        label: message ?? 'Carregando conteúdo',
        hint: 'Por favor, aguarde',
        liveRegion: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            loadingIndicator(
              size: size,
              semanticLabel: message ?? 'Carregando',
            ),
            if (showMessage && message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// **Loading List Item**
  /// 
  /// Loading indicator specifically designed for list pagination
  /// and infinite scroll implementations.
  /// 
  /// **Features:**
  /// - Compact design for list contexts
  /// - Proper accessibility labels
  /// - Optimized padding
  /// - Visual separation from content
  static Widget loadingListItem({
    String semanticLabel = 'Carregando mais itens',
    double size = 20,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: 'Aguarde enquanto mais conteúdo é carregado',
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: loadingIndicator(
            size: size,
            semanticLabel: semanticLabel,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  /// **Modal Loading Overlay**
  /// 
  /// Full-screen loading overlay that blocks user interaction.
  /// Perfect for critical operations like authentication or data submission.
  /// 
  /// **Parameters:**
  /// - [isLoading]: Whether to show the overlay
  /// - [child]: Widget to overlay
  /// - [message]: Optional loading message
  /// - [barrierDismissible]: Whether user can dismiss by tapping outside
  /// - [backgroundColor]: Custom overlay background color
  /// 
  /// **Features:**
  /// - Blocks user interaction
  /// - Customizable background
  /// - Optional dismissible barrier
  /// - Semantic support for screen readers
  static Widget loadingOverlay({
    required bool isLoading,
    required Widget child,
    String? message,
    bool barrierDismissible = false,
    Color? backgroundColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: backgroundColor ?? AppColors.dialogBarrier,
              child: Center(
                child: Semantics(
                  label: message ?? 'Operação em andamento',
                  hint: 'Por favor, aguarde até a conclusão',
                  liveRegion: true,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          loadingIndicator(
                            size: 32,
                            semanticLabel: message ?? 'Carregando',
                          ),
                          if (message != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// **Enhanced Empty State**
  /// 
  /// Engaging empty state widget with helpful actions and clear guidance.
  /// Designed to reduce user frustration and provide clear next steps.
  /// 
  /// **Parameters:**
  /// - [icon]: Descriptive icon for the empty state
  /// - [title]: Primary message title
  /// - [subtitle]: Descriptive subtitle with guidance
  /// - [actionLabel]: Text for the primary action button
  /// - [onAction]: Callback for the primary action
  /// - [secondaryActionLabel]: Text for optional secondary action
  /// - [onSecondaryAction]: Callback for secondary action
  /// - [illustration]: Optional custom illustration widget
  /// 
  /// **Features:**
  /// - Responsive design
  /// - Dual action support
  /// - Custom illustrations
  /// - Proper semantic structure
  /// - Consistent visual hierarchy
  static Widget emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    Widget? illustration,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Semantics(
          label: title,
          hint: subtitle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              illustration ?? 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              if (actionLabel != null && onAction != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
              
              if (secondaryActionLabel != null && onSecondaryAction != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSecondaryAction,
                    icon: const Icon(Icons.search),
                    label: Text(secondaryActionLabel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// **Search Empty State**
  /// 
  /// Specialized empty state for search results with filter clearing action.
  /// 
  /// **Parameters:**
  /// - [searchTerm]: The search term that returned no results
  /// - [onClearFilters]: Callback to clear search/filters
  /// - [onRetry]: Optional retry callback
  /// 
  /// **Features:**
  /// - Search-specific messaging
  /// - Filter clearing action
  /// - Contextual icons and colors
  static Widget searchEmptyState({
    String? searchTerm,
    VoidCallback? onClearFilters,
    VoidCallback? onRetry,
  }) {
    return emptyState(
      icon: Icons.search_off,
      title: 'Nenhum resultado encontrado',
      subtitle: searchTerm != null
          ? 'Não encontramos resultados para "$searchTerm"\nTente usar outros termos ou limpar os filtros'
          : 'Nenhum item corresponde aos filtros selecionados\nTente ajustar os critérios de busca',
      actionLabel: onClearFilters != null ? 'Limpar Filtros' : null,
      onAction: onClearFilters,
      secondaryActionLabel: onRetry != null ? 'Tentar Novamente' : null,
      onSecondaryAction: onRetry,
    );
  }

  /// **Enhanced Error State**
  /// 
  /// User-friendly error state with recovery options and clear messaging.
  /// Designed to reduce user frustration and provide actionable solutions.
  /// 
  /// **Parameters:**
  /// - [title]: Error title (defaults to generic message)
  /// - [message]: Descriptive error message
  /// - [onRetry]: Primary retry callback
  /// - [onSecondaryAction]: Optional secondary action
  /// - [secondaryActionLabel]: Label for secondary action
  /// - [errorType]: Type of error for icon selection
  /// - [showContactSupport]: Whether to show support contact option
  /// 
  /// **Features:**
  /// - Contextual error icons
  /// - Multiple recovery options
  /// - Support contact integration
  /// - Proper error categorization
  /// - Accessibility optimized
  static Widget errorState({
    String title = 'Ops! Algo deu errado',
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onSecondaryAction,
    String? secondaryActionLabel,
    ErrorType errorType = ErrorType.generic,
    bool showContactSupport = false,
  }) {
    final iconData = _getErrorIcon(errorType);
    final iconColor = _getErrorColor(errorType);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Semantics(
          label: 'Erro: $title',
          hint: message,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  iconData,
                  size: 48,
                  color: iconColor,
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              if (onSecondaryAction != null && secondaryActionLabel != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(secondaryActionLabel),
                  ),
                ),
              ],
              if (showContactSupport) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Entrar em Contato'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// **Network Error State**
  /// 
  /// Specialized error state for network-related issues.
  static Widget networkError({
    VoidCallback? onRetry,
    bool showContactSupport = false,
  }) {
    return errorState(
      title: 'Problema de Conexão',
      message: 'Verifique sua conexão com a internet e tente novamente',
      onRetry: onRetry,
      errorType: ErrorType.network,
      showContactSupport: showContactSupport,
    );
  }

  /// **Permission Error State**
  /// 
  /// Specialized error state for permission-related issues.
  static Widget permissionError({
    required String permissionName,
    VoidCallback? onRetry,
    VoidCallback? onOpenSettings,
  }) {
    return errorState(
      title: 'Permissão Necessária',
      message: 'O app precisa de acesso a $permissionName para funcionar corretamente',
      onRetry: onRetry,
      onSecondaryAction: onOpenSettings,
      secondaryActionLabel: 'Abrir Configurações',
      errorType: ErrorType.permission,
      showContactSupport: false,
    );
  }

  static IconData _getErrorIcon(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.generic:
        return Icons.error_outline;
    }
  }

  static Color _getErrorColor(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.network:
        return AppColors.warning;
      case ErrorType.permission:
        return AppColors.info;
      case ErrorType.notFound:
        return AppColors.textSecondary;
      case ErrorType.server:
        return AppColors.error;
      case ErrorType.generic:
        return AppColors.error;
    }
  }
}

/// **Error Type Enumeration**
/// 
/// Categorizes different types of errors for appropriate
/// visual treatment and user messaging.
enum ErrorType {
  /// Generic application error
  generic,
  
  /// Network connectivity issues
  network,
  
  /// Permission-related errors
  permission,
  
  /// Resource not found errors
  notFound,
  
  /// Server-side errors
  server,
}

/// **Shimmer Loading Effect**
/// 
/// Sophisticated shimmer loading effect for content placeholders.
/// Provides visual feedback during content loading states.
/// 
/// **Usage:**
/// ```dart
/// ShimmerLoading(
///   child: Container(
///     height: 20,
///     color: Colors.white,
///   ),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1 + _animation.value, 0),
              end: Alignment(1 + _animation.value, 0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

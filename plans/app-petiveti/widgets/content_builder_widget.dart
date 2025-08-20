// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../constants/design_tokens.dart';
import '../utils/animation_utils.dart';
import 'empty_state_widget.dart';

/// Enum for different content states
enum ContentState {
  loading,
  empty,
  error,
  success,
}

/// A reusable widget for building content based on different states
class ContentBuilderWidget<T> extends StatelessWidget {
  final ContentState state;
  final T? data;
  final String? errorMessage;
  final Widget Function(T data) successBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final VoidCallback? onRetry;
  final bool animate;

  const ContentBuilderWidget({
    super.key,
    required this.state,
    required this.successBuilder,
    this.data,
    this.errorMessage,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.onRetry,
    this.animate = true,
  });

  /// Factory constructor for list content
  static ContentBuilderWidget<List<T>> listBuilder<T>({
    required List<T> items,
    required Widget Function(List<T> items) listBuilder,
    Widget? loadingWidget,
    Widget? emptyWidget,
    Widget? errorWidget,
    String? errorMessage,
    VoidCallback? onRetry,
    bool isLoading = false,
    bool hasError = false,
    bool animate = true,
  }) {
    ContentState state;
    if (isLoading) {
      state = ContentState.loading;
    } else if (hasError) {
      state = ContentState.error;
    } else if (items.isEmpty) {
      state = ContentState.empty;
    } else {
      state = ContentState.success;
    }

    return ContentBuilderWidget<List<T>>(
      state: state,
      data: items,
      successBuilder: listBuilder,
      loadingWidget: loadingWidget,
      emptyWidget: emptyWidget,
      errorWidget: errorWidget,
      errorMessage: errorMessage,
      onRetry: onRetry,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (state) {
      case ContentState.loading:
        content = _buildLoading();
        break;
      case ContentState.empty:
        content = _buildEmpty();
        break;
      case ContentState.error:
        content = _buildError();
        break;
      case ContentState.success:
        if (data != null) {
          content = successBuilder(data as T);
        } else {
          content = _buildError();
        }
        break;
    }

    if (animate && state != ContentState.loading) {
      content = AnimationUtils.fadeIn(
        duration: DesignTokens.animationNormal,
        child: content,
      );
    }

    return content;
  }

  Widget _buildLoading() {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    return const Center(
      child: LoadingStateWidget(),
    );
  }

  Widget _buildEmpty() {
    if (emptyWidget != null) {
      return emptyWidget!;
    }

    return EmptyStateWidget.noAnimals();
  }

  Widget _buildError() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return EmptyStateWidget.error(
      message: errorMessage,
      onRetry: onRetry,
    );
  }
}

/// Custom loading state widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AnimatedLoadingIndicator(
            size: DesignTokens.iconXL,
          ),
          if (showMessage) ...[
            Spacing.v16,
            Text(
              message ?? 'Carregando...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: DesignTokens.opacityMedium),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Advanced content builder with transitions
class TransitionContentBuilder<T> extends StatefulWidget {
  final ContentState state;
  final T? data;
  final String? errorMessage;
  final Widget Function(T data) successBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final VoidCallback? onRetry;
  final Duration transitionDuration;

  const TransitionContentBuilder({
    super.key,
    required this.state,
    required this.successBuilder,
    this.data,
    this.errorMessage,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.onRetry,
    this.transitionDuration = DesignTokens.animationNormal,
  });

  @override
  State<TransitionContentBuilder<T>> createState() => _TransitionContentBuilderState<T>();
}

class _TransitionContentBuilderState<T> extends State<TransitionContentBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  ContentState? _previousState;
  Widget? _currentWidget;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: DesignTokens.curveStandard,
    ));

    _updateContent();
    _controller.forward();
  }

  @override
  void didUpdateWidget(TransitionContentBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _transitionToNewState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _transitionToNewState() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _updateContent();
        });
        _controller.forward();
      }
    });
  }

  void _updateContent() {
    _previousState = widget.state;
    
    switch (widget.state) {
      case ContentState.loading:
        _currentWidget = _buildLoading();
        break;
      case ContentState.empty:
        _currentWidget = _buildEmpty();
        break;
      case ContentState.error:
        _currentWidget = _buildError();
        break;
      case ContentState.success:
        if (widget.data != null) {
          _currentWidget = widget.successBuilder(widget.data as T);
        } else {
          _currentWidget = _buildError();
        }
        break;
    }
  }

  Widget _buildLoading() {
    return widget.loadingWidget ?? const LoadingStateWidget();
  }

  Widget _buildEmpty() {
    return widget.emptyWidget ?? EmptyStateWidget.noAnimals();
  }

  Widget _buildError() {
    return widget.errorWidget ?? EmptyStateWidget.error(
      message: widget.errorMessage,
      onRetry: widget.onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _currentWidget,
        );
      },
    );
  }
}

/// Specialized content builder for animal lists
class AnimalListContentBuilder extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<dynamic> animals;
  final Widget Function(List<dynamic> animals) listBuilder;
  final VoidCallback? onRetry;
  final VoidCallback? onAddAnimal;

  const AnimalListContentBuilder({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.animals,
    required this.listBuilder,
    this.errorMessage,
    this.onRetry,
    this.onAddAnimal,
  });

  @override
  Widget build(BuildContext context) {
    return ContentBuilderWidget.listBuilder<dynamic>(
      items: animals,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      listBuilder: listBuilder,
      onRetry: onRetry,
      emptyWidget: EmptyStateWidget.noAnimals(
        onAddPressed: onAddAnimal,
      ),
      loadingWidget: const LoadingStateWidget(
        message: 'Carregando animais...',
      ),
    );
  }
}

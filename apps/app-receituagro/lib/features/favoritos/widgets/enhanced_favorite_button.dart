import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced favorite button with haptic feedback, animations and smart states
class EnhancedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? tooltip;
  final bool enableHapticFeedback;
  final bool enableAnimation;
  final Duration animationDuration;
  final bool showLoadingIndicator;

  const EnhancedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    this.onPressed,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.tooltip,
    this.enableHapticFeedback = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showLoadingIndicator = true,
  });

  @override
  State<EnhancedFavoriteButton> createState() => _EnhancedFavoriteButtonState();
}

class _EnhancedFavoriteButtonState extends State<EnhancedFavoriteButton>
    with TickerProviderStateMixin {
  
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Auto-repeat pulse animation if loading
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(EnhancedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when favorite state changes
    if (oldWidget.isFavorite != widget.isFavorite && widget.enableAnimation) {
      _animateFavoriteChange();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _animateFavoriteChange() {
    if (widget.isFavorite) {
      // Animate scale up when favorited
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      
      // Small rotation for delight
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    }
  }

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;

    // Haptic feedback
    if (widget.enableHapticFeedback) {
      _triggerHapticFeedback();
    }

    // Visual feedback
    setState(() {
      _isPressed = true;
    });

    // Call callback
    widget.onPressed!();

    // Reset press state
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
      }
    });
  }

  void _triggerHapticFeedback() {
    if (widget.isFavorite) {
      // Light impact when removing from favorites
      HapticFeedback.lightImpact();
    } else {
      // Medium impact when adding to favorites
      HapticFeedback.mediumImpact();
    }
  }

  Color get _iconColor {
    final theme = Theme.of(context);
    
    if (widget.isFavorite) {
      return widget.activeColor ?? Colors.red;
    } else {
      return widget.inactiveColor ?? theme.iconTheme.color ?? Colors.grey;
    }
  }

  IconData get _iconData {
    return widget.isFavorite ? Icons.favorite : Icons.favorite_border;
  }

  Widget _buildIcon() {
    Widget icon = Icon(
      _iconData,
      size: widget.size,
      color: _iconColor,
    );

    // Apply animations if enabled
    if (widget.enableAnimation) {
      icon = AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _rotationAnimation,
          if (widget.isLoading) _pulseAnimation,
        ]),
        builder: (context, child) {
          double scale = _scaleAnimation.value;
          
          // Apply pulse if loading
          if (widget.isLoading && widget.showLoadingIndicator) {
            scale *= _pulseAnimation.value;
          }
          
          // Apply press scale
          if (_isPressed) {
            scale *= 0.9;
          }

          return Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: icon,
      );
    }

    return icon;
  }

  Widget _buildLoadingIndicator() {
    if (!widget.isLoading || !widget.showLoadingIndicator) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        width: widget.size * 0.4,
        height: widget.size * 0.4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.25,
            height: widget.size * 0.25,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(widget.size),
      child: Container(
        width: widget.size * 2,
        height: widget.size * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isPressed 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Stack(
          children: [
            Center(child: _buildIcon()),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip,
        child: button,
      );
    }

    return button;
  }
}

/// Specialized favorite button for list items
class FavoriteListButton extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String itemName;

  const FavoriteListButton({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    this.onPressed,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedFavoriteButton(
      isFavorite: isFavorite,
      isLoading: isLoading,
      onPressed: onPressed,
      size: 20,
      tooltip: isFavorite 
          ? 'Remover "$itemName" dos favoritos'
          : 'Adicionar "$itemName" aos favoritos',
    );
  }
}

/// Specialized favorite button for detail pages
class FavoriteDetailButton extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String itemName;

  const FavoriteDetailButton({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    this.onPressed,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedFavoriteButton(
      isFavorite: isFavorite,
      isLoading: isLoading,
      onPressed: onPressed,
      size: 28,
      activeColor: Colors.red.shade600,
      inactiveColor: Colors.grey.shade600,
      tooltip: isFavorite 
          ? 'Remover dos favoritos'
          : 'Adicionar aos favoritos',
      enableAnimation: true,
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Floating action button style for favorites
class FavoriteFAB extends StatelessWidget {
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback? onPressed;
  final String? label;

  const FavoriteFAB({
    super.key,
    required this.isFavorite,
    this.isLoading = false,
    this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: isFavorite ? Colors.red : theme.primaryColor,
        foregroundColor: Colors.white,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        label: Text(label!),
      );
    }

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: isFavorite ? Colors.red : theme.primaryColor,
      foregroundColor: Colors.white,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 28,
            ),
    );
  }
}

/// Success animation overlay for favorite actions
class FavoriteSuccessOverlay extends StatefulWidget {
  final bool show;
  final bool wasAdded;
  final VoidCallback? onComplete;

  const FavoriteSuccessOverlay({
    super.key,
    required this.show,
    required this.wasAdded,
    this.onComplete,
  });

  @override
  State<FavoriteSuccessOverlay> createState() => _FavoriteSuccessOverlayState();
}

class _FavoriteSuccessOverlayState extends State<FavoriteSuccessOverlay>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    if (widget.show) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(FavoriteSuccessOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!oldWidget.show && widget.show) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      widget.onComplete?.call();
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.wasAdded ? Icons.favorite : Icons.heart_broken,
              size: 80,
              color: widget.wasAdded ? Colors.red : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
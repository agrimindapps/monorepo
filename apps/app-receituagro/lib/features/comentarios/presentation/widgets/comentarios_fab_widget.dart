import 'package:flutter/material.dart';

/// **COMENTARIOS FAB WIDGET**
/// 
/// Floating Action Button specifically for adding new comentarios.
/// Handles premium restrictions and loading states.
/// 
/// ## Features:
/// 
/// - **Premium Aware**: Shows lock icon when premium is required
/// - **Loading State**: Disabled during operations
/// - **Visual Feedback**: Clear visual indicators for different states
/// - **Accessibility**: Proper semantic labels

class ComentariosFabWidget extends StatelessWidget {
  final bool isPremium;
  final bool isOperating;
  final VoidCallback? onPressed;

  const ComentariosFabWidget({
    super.key,
    required this.isPremium,
    required this.isOperating,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _shouldEnable() ? onPressed : null,
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getForegroundColor(),
      tooltip: _getTooltip(),
      child: _getIcon(),
    );
  }

  bool _shouldEnable() {
    return !isOperating && isPremium && onPressed != null;
  }

  Color? _getBackgroundColor() {
    if (!isPremium) {
      return Colors.grey;
    }
    
    if (isOperating) {
      return Colors.grey.shade400;
    }
    
    return null; // Use default theme color
  }

  Color? _getForegroundColor() {
    if (!isPremium || isOperating) {
      return Colors.white;
    }
    
    return null; // Use default theme color
  }

  String _getTooltip() {
    if (!isPremium) {
      return 'Premium necessário para adicionar comentários';
    }
    
    if (isOperating) {
      return 'Aguarde a operação atual';
    }
    
    return 'Adicionar comentário';
  }

  Widget _getIcon() {
    if (!isPremium) {
      return const Icon(Icons.lock);
    }
    
    if (isOperating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }
    
    return const Icon(Icons.add);
  }

  /// Factory constructor for premium user
  static ComentariosFabWidget premium({
    required bool isOperating,
    required VoidCallback onPressed,
  }) {
    return ComentariosFabWidget(
      isPremium: true,
      isOperating: isOperating,
      onPressed: onPressed,
    );
  }

  /// Factory constructor for free user
  static ComentariosFabWidget locked({
    VoidCallback? onPremiumRequired,
  }) {
    return ComentariosFabWidget(
      isPremium: false,
      isOperating: false,
      onPressed: onPremiumRequired,
    );
  }

  /// Factory constructor for loading state
  static ComentariosFabWidget loading() {
    return const ComentariosFabWidget(
      isPremium: true,
      isOperating: true,
    );
  }
}
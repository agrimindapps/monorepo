import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// A reusable loading overlay widget specifically designed for registration pages
/// Provides consistent visual feedback during operations across all registration steps
class RegisterLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;
  final Widget child;
  final Color? backgroundColor;
  final Color? cardColor;

  const RegisterLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.message,
    required this.child,
    this.backgroundColor,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          ColoredBox(
            color: backgroundColor ?? Colors.black54,
            child: Center(
              child: Card(
                color: cardColor ?? Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 300,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Loading indicator with plant theme
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: PlantisColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              PlantisColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Loading message
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PlantisColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Por favor, aguarde...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Mixin to provide loading state functionality to registration pages
/// Ensures consistent loading state management across all registration steps
mixin RegisterLoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  String _loadingMessage = 'Carregando...';

  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  /// Shows loading overlay with optional custom message
  void showRegisterLoading({String? message}) {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingMessage = message ?? 'Carregando...';
      });
    }
  }

  /// Hides loading overlay
  void hideRegisterLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Updates loading message while overlay is visible
  void updateRegisterLoadingMessage(String message) {
    if (mounted && _isLoading) {
      setState(() {
        _loadingMessage = message;
      });
    }
  }

  /// Wraps a widget with the register loading overlay
  Widget buildWithRegisterLoading({required Widget child}) {
    return RegisterLoadingOverlay(
      isVisible: _isLoading,
      message: _loadingMessage,
      child: child,
    );
  }
}

/// Enhanced register loading overlay with progress indicator
class RegisterProgressLoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;
  final Widget child;
  final double? progress; // 0.0 to 1.0 for determinate progress
  final int currentStep;
  final int totalSteps;

  const RegisterProgressLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.message,
    required this.child,
    required this.currentStep,
    required this.totalSteps,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          ColoredBox(
            color: Colors.black54,
            child: Center(
              child: Card(
                color: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 250,
                    maxWidth: 350,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress indicator
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: PlantisColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child:
                              progress != null
                                  ? CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 4,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          PlantisColors.primary,
                                        ),
                                    backgroundColor: Colors.grey.shade300,
                                  )
                                  : const CircularProgressIndicator(
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      PlantisColors.primary,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step indicator
                      Text(
                        'Passo $currentStep de $totalSteps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Loading message
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PlantisColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Por favor, aguarde enquanto processamos suas informações...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

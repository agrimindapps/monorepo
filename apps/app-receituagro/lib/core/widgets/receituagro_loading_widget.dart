import 'package:flutter/material.dart';

/// Unified loading widget for ReceitaAgro app
/// Provides consistent loading experience across all screens
/// Branded with green gradient circle and customizable messages
///
/// Usage:
/// ```dart
/// ReceitaAgroLoadingWidget(
///   message: 'Carregando defensivos...',
///   submessage: 'Isso pode levar alguns segundos',
/// )
/// ```
class ReceitaAgroLoadingWidget extends StatelessWidget {
  final String message;
  final String? submessage;
  final double size;
  final bool showGradient;

  const ReceitaAgroLoadingWidget({
    super.key,
    this.message = 'Carregando...',
    this.submessage,
    this.size = 80,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Green gradient circle with spinner
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: showGradient
                  ? const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: showGradient ? null : const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(size * 0.2),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),
          if (submessage != null) ...[
            const SizedBox(height: 8),
            Text(
              submessage!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF616161),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact loading widget for inline usage (e.g., inside search fields)
/// Uses just the spinner without text
class ReceitaAgroLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const ReceitaAgroLoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ??
              (isDark ? Colors.green.shade300 : Colors.green.shade700),
        ),
      ),
    );
  }
}

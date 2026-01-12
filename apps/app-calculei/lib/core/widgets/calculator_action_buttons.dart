import 'package:flutter/material.dart';

/// Standard action buttons for calculator pages
/// Includes a Calculate button and optional Clear button
/// Follows the dark theme design pattern
class CalculatorActionButtons extends StatelessWidget {
  /// Callback when Calculate button is pressed
  final VoidCallback onCalculate;
  
  /// Optional callback when Clear button is pressed
  /// If null, Clear button won't be shown
  final VoidCallback? onClear;
  
  /// The accent color for the Calculate button
  final Color accentColor;
  
  /// Whether the calculator is currently processing
  final bool isLoading;
  
  /// Custom label for the Calculate button (default: 'Calcular')
  final String? calculateLabel;

  const CalculatorActionButtons({
    super.key,
    required this.onCalculate,
    required this.accentColor,
    this.onClear,
    this.isLoading = false,
    this.calculateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Clear button (optional)
        if (onClear != null) ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onClear,
                icon: Icon(
                  Icons.clear_rounded,
                  color: isLoading 
                      ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3)
                      : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                ),
                label: Text(
                  'Limpar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isLoading 
                        ? (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3)
                        : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.7),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: isLoading ? 0.1 : 0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Calculate button
        Expanded(
          flex: onClear != null ? 2 : 1,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onCalculate,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.calculate_rounded),
              label: Text(
                isLoading ? 'Calculando...' : (calculateLabel ?? 'Calcular'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

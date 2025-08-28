import 'package:flutter/material.dart';

/// Widget para botões de login social
/// Segue o princípio da Responsabilidade Única
class SocialLoginButtonsWidget extends StatelessWidget {
  const SocialLoginButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          context: context,
          icon: Icons.g_mobiledata,
          label: 'Google',
          color: Colors.red.shade600,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: null, // Desabilitado por enquanto
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          context: context,
          icon: Icons.apple,
          label: 'Apple',
          color: isDark ? Colors.white : Colors.black,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: null, // Desabilitado por enquanto
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          context: context,
          icon: Icons.window,
          label: 'Microsoft',
          color: Colors.blue.shade600,
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          onPressed: null, // Desabilitado por enquanto
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback? onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Login com $label (Em breve)',
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: onPressed != null ? color : color.withOpacity(0.5),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: onPressed != null
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.grey[500] : Colors.grey[600]),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// **COMENTARIOS PREMIUM WIDGET**
/// 
/// Displays premium restriction message when user is not subscribed.
/// Provides clear call-to-action for premium upgrade.
/// 
/// ## Features:
/// 
/// - **Clear Messaging**: Explains premium requirement
/// - **Visual Appeal**: Attractive design with premium branding
/// - **Action Button**: Direct link to premium upgrade
/// - **Consistent Design**: Matches app-receituagro design system

class ComentariosPremiumWidget extends StatelessWidget {
  final VoidCallback onUpgradePressed;

  const ComentariosPremiumWidget({
    super.key,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFB74D),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildDescription(),
            const SizedBox(height: 28),
            _buildUpgradeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.diamond,
        size: 48,
        color: Color(0xFFFF9800),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Comentários Premium',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE65100),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Salve suas anotações pessoais sobre pragas, doenças e defensivos com a assinatura premium.',
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFFBF360C),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onUpgradePressed,
        icon: const Icon(
          Icons.rocket_launch,
          color: Colors.white,
          size: 20,
        ),
        label: const Text(
          'Desbloquear Agora',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: const Color(0xFFFF9800).withValues(alpha: 0.3),
        ),
      ),
    );
  }

  /// Factory constructor for compact display
  static ComentariosPremiumWidget compact({
    required VoidCallback onUpgradePressed,
  }) {
    return ComentariosPremiumWidget(
      onUpgradePressed: onUpgradePressed,
    );
  }
}

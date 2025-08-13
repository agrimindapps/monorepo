// Flutter imports:
import 'package:flutter/material.dart';

/// Widget para exibir mensagens premium ou informativos
class PremiumMessageWidget extends StatelessWidget {
  final String message;

  const PremiumMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

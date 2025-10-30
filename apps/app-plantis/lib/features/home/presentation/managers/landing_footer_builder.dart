import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

/// Builds footer UI for landing page
/// Isolates footer construction logic from main page
class LandingFooterBuilder {
  /// Builds the footer section
  static Widget buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildBrand(),
          const SizedBox(height: 16),
          _buildTagline(),
          const SizedBox(height: 24),
          _buildCopyright(),
        ],
      ),
    );
  }

  static Widget _buildBrand() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.eco, size: 24, color: PlantisColors.primary),
        SizedBox(width: 8),
        Text(
          'Plantis',
          style: TextStyle(
            color: PlantisColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static Widget _buildTagline() {
    return const Text(
      'Cuidando das suas plantas com tecnologia e carinho.',
      textAlign: TextAlign.center,
      style: TextStyle(color: PlantisColors.textSecondary, fontSize: 14),
    );
  }

  static Widget _buildCopyright() {
    return Text(
      '© 2025 Plantis - Todos os direitos reservados',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
    );
  }
}

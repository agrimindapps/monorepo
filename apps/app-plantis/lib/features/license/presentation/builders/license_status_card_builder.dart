import 'package:flutter/material.dart';

import '../../../../core/theme/plantis_colors.dart';

/// Builder estático para a seção de status da licença
/// SRP: Isolates license status card UI construction
class LicenseStatusCardBuilder {
  static Widget buildStatusCard({
    required BuildContext context,
    required bool hasValidLicense,
    required String statusText,
    required String typeText,
    required String remainingText,
    required bool isTrialActive,
    required String licenseId,
    required String startDate,
    required String expirationDate,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              hasValidLicense ? PlantisColors.primary : Colors.orange,
              hasValidLicense
                  ? PlantisColors.primaryDark
                  : Colors.orange.shade700,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasValidLicense ? Icons.verified : Icons.schedule,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          typeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Status', statusText, Icons.info),
              const SizedBox(height: 12),
              if (isTrialActive) ...[
                _buildDetailRow(
                  'Tempo restante',
                  remainingText,
                  Icons.access_time,
                ),
                const SizedBox(height: 12),
              ],
              _buildDetailRow('ID da Licença', licenseId, Icons.tag),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Data de início',
                startDate,
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Data de expiração', expirationDate, Icons.event),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

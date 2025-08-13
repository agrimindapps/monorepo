// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para exibir um item de configuração de cuidado
/// Responsável pela apresentação e configuração de um tipo específico de cuidado
class CareConfigItemWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final String careType;
  final Map<String, dynamic> config;

  const CareConfigItemWidget({
    super.key,
    required this.controller,
    required this.careType,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'fundoCard': PlantasColors.surfaceColor,
        'fundoDesabilitado': PlantasColors.backgroundColor,
        'texto': PlantasColors.textColor,
        'textoSecundario': PlantasColors.textSecondaryColor,
        'textoDesabilitado':
            PlantasColors.textSecondaryColor.withValues(alpha: 0.6),
        'borda': PlantasColors.borderColor,
        'bordaDesabilitada': PlantasColors.borderColor.withValues(alpha: 0.5),
        'primaria': PlantasColors.primaryColor,
      };

      final estilos = {
        'careTitle': TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: cores['texto'],
        ),
        'careSubtitle': TextStyle(
          fontSize: 12.0,
          color: cores['textoSecundario'],
        ),
        'careDisabled': TextStyle(
          fontSize: 12.0,
          color: cores['textoDesabilitado'],
        ),
        'careFrequency': TextStyle(
          fontSize: 12.0,
          color: cores['textoSecundario'],
        ),
        'careLastDate': TextStyle(
          fontSize: 11.0,
          color: cores['textoSecundario'],
        ),
      };

      final isActive = config['ativo'] == true;
      final frequency = config['frequencia'] ?? 7;
      final lastCare = config['ultimoCuidado'] as DateTime?;

      return Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isActive ? cores['fundoCard'] : cores['fundoDesabilitado'],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isActive ? cores['borda']! : cores['bordaDesabilitada']!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCareIcon(cores, isActive),
            const SizedBox(width: 12.0),
            Expanded(
              child:
                  _buildCareInfo(estilos, cores, isActive, frequency, lastCare),
            ),
            _buildStatusIndicator(cores, isActive),
          ],
        ),
      );
    });
  }

  Widget _buildCareIcon(
    Map<String, Color> cores,
    bool isActive,
  ) {
    final careColor = _getCareColor();

    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: isActive
            ? careColor.withValues(alpha: 0.1)
            : cores['fundoDesabilitado'],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        _getCareIcon(),
        color: isActive ? careColor : cores['textoDesabilitado'],
        size: 20.0,
      ),
    );
  }

  Widget _buildCareInfo(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
    bool isActive,
    int frequency,
    DateTime? lastCare,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCareTitle(),
          style: estilos['careTitle']?.copyWith(
            color: isActive ? cores['texto'] : cores['textoDesabilitado'],
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          isActive ? 'A cada $frequency dias' : 'Desabilitado',
          style: estilos['careFrequency']?.copyWith(
            color: isActive
                ? cores['textoSecundario']
                : cores['textoDesabilitado'],
          ),
        ),
        if (isActive && lastCare != null) ...[
          const SizedBox(height: 4.0),
          Text(
            'Último: ${_formatLastCareDate(lastCare)}',
            style: estilos['careLastDate']?.copyWith(
              color: cores['textoSecundario'],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator(Map<String, Color> cores, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isActive
            ? cores['primaria']!.withValues(alpha: 0.1)
            : cores['textoDesabilitado']!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isActive ? cores['primaria']! : cores['textoDesabilitado']!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isActive ? cores['primaria'] : cores['textoDesabilitado'],
          ),
          const SizedBox(width: 6.0),
          Text(
            isActive ? 'Ativo' : 'Inativo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? cores['primaria'] : cores['textoDesabilitado'],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCareColor() {
    // Cores por tipo de cuidado
    switch (careType.toLowerCase()) {
      case 'agua':
        return const Color(0xFF2196F3);
      case 'adubo':
        return const Color(0xFF4CAF50);
      case 'banho_sol':
        return const Color(0xFFFF9800);
      case 'pragas':
        return const Color(0xFFF44336);
      case 'poda':
        return const Color(0xFF9C27B0);
      case 'replante':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF607D8B);
    }
  }

  IconData _getCareIcon() {
    switch (careType.toLowerCase()) {
      case 'agua':
        return Icons.water_drop_outlined;
      case 'adubo':
        return Icons.eco_outlined;
      case 'banho_sol':
        return Icons.wb_sunny_outlined;
      case 'pragas':
        return Icons.bug_report_outlined;
      case 'poda':
        return Icons.content_cut_outlined;
      case 'replante':
        return Icons.grass_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  String _getCareTitle() {
    switch (careType.toLowerCase()) {
      case 'agua':
        return 'Rega';
      case 'adubo':
        return 'Adubação';
      case 'banho_sol':
        return 'Banho de Sol';
      case 'pragas':
        return 'Controle de Pragas';
      case 'poda':
        return 'Poda';
      case 'replante':
        return 'Replante';
      default:
        return 'Cuidado';
    }
  }

  String _formatLastCareDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference <= 7) {
      return 'Há $difference dias';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../controller/planta_detalhes_controller.dart';
import 'care_config_item_widget.dart';

/// Widget especializado para a seção de configurações de cuidados
/// Responsável pela apresentação e edição das configurações de cuidados da planta
class ConfiguracoesSectionWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final Map<String, dynamic> configuracoes;

  const ConfiguracoesSectionWidget({
    super.key,
    required this.controller,
    required this.configuracoes,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'primaria': PlantasColors.primaryColor,
        'fundoCard': PlantasColors.surfaceColor,
        'texto': PlantasColors.textColor,
        'textoSecundario': PlantasColors.textSecondaryColor,
        'textoClaro': PlantasColors.surfaceColor,
        'borda': PlantasColors.borderColor,
        'sucesso': Colors.green,
        'sucessoClaro': Colors.green.withValues(alpha: 0.1),
        'aviso': Colors.orange,
        'avisoClaro': Colors.orange.withValues(alpha: 0.1),
        'shadow': PlantasColors.shadowColor,
      };

      final estilos = {
        'cardTitle': TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: cores['texto'],
        ),
        'statusText': const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
        ),
      };

      final decoracao = BoxDecoration(
        color: cores['fundoCard'],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: cores['shadow']!,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      );

      return Container(
        width: double.infinity,
        decoration: decoracao,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(estilos, cores),
            const SizedBox(height: 16.0),
            _buildConfigurationsList(cores),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Row(
      children: [
        Icon(
          Icons.settings,
          color: cores['primaria'],
          size: 24,
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            'Configurações de Cuidados',
            style: estilos['cardTitle'],
          ),
        ),
        _buildStatusIndicator(estilos, cores),
      ],
    );
  }

  Widget _buildStatusIndicator(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    final activeCares = _getActiveCareCount();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: activeCares > 0 ? cores['sucessoClaro'] : cores['avisoClaro'],
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: activeCares > 0 ? cores['sucesso']! : cores['aviso']!,
          width: 1,
        ),
      ),
      child: Text(
        '$activeCares ativos',
        style: estilos['statusText']?.copyWith(
          color: activeCares > 0 ? cores['sucesso'] : cores['aviso'],
        ),
      ),
    );
  }

  Widget _buildConfigurationsList(
    Map<String, Color> cores,
  ) {
    final careTypes = [
      'agua',
      'adubo',
      'banho_sol',
      'pragas',
      'poda',
      'replante'
    ];

    return Column(
      children: careTypes.map((careType) {
        final config = Map<String, dynamic>.from(configuracoes[careType] ?? {});

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: CareConfigItemWidget(
            controller: controller,
            careType: careType,
            config: config,
          ),
        );
      }).toList(),
    );
  }

  int _getActiveCareCount() {
    int count = 0;
    final careTypes = [
      'agua',
      'adubo',
      'banho_sol',
      'pragas',
      'poda',
      'replante'
    ];

    for (final careType in careTypes) {
      final config = configuracoes[careType];
      if (config != null && config is Map && config['ativo'] == true) {
        count++;
      }
    }

    return count;
  }
}

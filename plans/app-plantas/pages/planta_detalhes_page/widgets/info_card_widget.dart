// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../constants/plantas_colors.dart';
import '../../../database/planta_model.dart';
import '../controller/planta_detalhes_controller.dart';

/// Widget especializado para exibir informações gerais da planta
/// Responsável pela apresentação dos dados básicos em formato de card
class InfoCardWidget extends StatelessWidget {
  final PlantaDetalhesController controller;
  final PlantaModel planta;

  const InfoCardWidget({
    super.key,
    required this.controller,
    required this.planta,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cores = {
        'primaria': PlantasColors.primaryColor,
        'fundoCard': PlantasColors.surfaceColor,
        'texto': PlantasColors.textColor,
        'textoSecundario': PlantasColors.textSecondaryColor,
        'observationBackground': PlantasColors.backgroundColor,
        'observationBorder': PlantasColors.borderColor,
        'shadow': PlantasColors.shadowColor,
      };

      final estilos = {
        'cardTitle': TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: cores['texto'],
        ),
        'infoLabel': TextStyle(
          fontSize: 12.0,
          color: cores['textoSecundario'],
        ),
        'infoValue': TextStyle(
          fontSize: 14.0,
          color: cores['texto'],
        ),
        'sectionTitle': TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: cores['texto'],
        ),
        'observationText': TextStyle(
          fontSize: 14.0,
          color: cores['texto'],
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
            _buildCardHeader(estilos, cores),
            const SizedBox(height: 16.0),
            _buildInfoRows(estilos, cores),
            if (planta.observacoes?.isNotEmpty == true) ...[
              const SizedBox(height: 16.0),
              _buildObservationsSection(estilos, cores),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCardHeader(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: cores['primaria'],
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Informações da Planta',
          style: estilos['cardTitle'],
        ),
      ],
    );
  }

  Widget _buildInfoRows(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Column(
      children: [
        _buildInfoRow(
          'Nome',
          planta.nome ?? 'Não informado',
          Icons.label_outline,
          estilos,
          cores,
        ),
        if (planta.especie?.isNotEmpty == true)
          _buildInfoRow(
            'Espécie',
            planta.especie!,
            Icons.eco_outlined,
            estilos,
            cores,
          ),
        _buildInfoRow(
          'Espaço',
          _getEspacoNome(),
          Icons.location_on_outlined,
          estilos,
          cores,
        ),
        _buildInfoRow(
          'Cadastrada em',
          _formatDate(planta.dataCadastro ??
              DateTime.fromMillisecondsSinceEpoch(planta.createdAt)),
          Icons.calendar_today_outlined,
          estilos,
          cores,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: cores['primaria']!.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: cores['primaria'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: estilos['infoLabel'],
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: estilos['infoValue'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsSection(
    Map<String, TextStyle> estilos,
    Map<String, Color> cores,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note_outlined,
              color: cores['primaria'],
              size: 20,
            ),
            const SizedBox(width: 8.0),
            Text(
              'Observações',
              style: estilos['sectionTitle'],
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: cores['observationBackground'],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: cores['observationBorder']!,
              width: 1,
            ),
          ),
          child: Text(
            planta.observacoes!,
            style: estilos['observationText'],
          ),
        ),
      ],
    );
  }

  String _getEspacoNome() {
    if (planta.espacoId == null || planta.espacoId!.isEmpty) {
      return 'Nenhum espaço definido';
    }

    // Buscar o nome do espaço através do controller
    final espaco = controller.espaco.value;

    return espaco?.nome ?? 'Espaço não encontrado';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

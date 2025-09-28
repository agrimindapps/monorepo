import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../../../core/widgets/praga_image_widget.dart';

class DiagnosticoInfoWidget extends StatelessWidget {
  final String nomePraga;
  final String nomeDefensivo;
  final String cultura;
  final Map<String, String> diagnosticoData;

  const DiagnosticoInfoWidget({
    super.key,
    required this.nomePraga,
    required this.nomeDefensivo,
    required this.cultura,
    required this.diagnosticoData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(context),
        const SizedBox(height: 24),
        _buildGeneralInfoSection(context),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagem do Diagnóstico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calcula altura baseada na largura disponível (proporção 16:9)
                  // Subtrai o padding lateral do container (40px = 20px de cada lado)
                  final availableWidth = constraints.maxWidth - 40;
                  final imageHeight = availableWidth * 0.56;
                  
                  return PragaImageWidget(
                    nomeCientifico: nomePraga,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    errorWidget: Container(
                      width: double.infinity,
                      height: imageHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.image,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                nomePraga,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$nomeDefensivo - $cultura',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Gerais',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCards(context),
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final infoItems = [
      {'label': 'Ingrediente Ativo', 'value': diagnosticoData['ingredienteAtivo'] ?? 'N/A', 'icon': Icons.science},
      {'label': 'Classificação Toxicológica', 'value': diagnosticoData['toxico'] ?? 'N/A', 'icon': Icons.warning},
      {'label': 'Classificação Ambiental', 'value': diagnosticoData['classAmbiental'] ?? 'N/A', 'icon': Icons.eco},
      {'label': 'Classe Agronômica', 'value': diagnosticoData['classeAgronomica'] ?? 'N/A', 'icon': Icons.agriculture},
    ];

    return Column(
      children: infoItems.map((item) => _buildInfoCard(
        context,
        item['label'] as String,
        item['value'] as String,
        item['icon'] as IconData,
      )).toList(),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
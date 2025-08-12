// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/especie_model.dart';
import '../../utils/racas_lista_constants.dart';
import '../../utils/racas_lista_helpers.dart';

class EspecieHeaderWidget extends StatelessWidget {
  final Especie especie;
  final int totalRacasFiltradas;

  const EspecieHeaderWidget({
    super.key,
    required this.especie,
    required this.totalRacasFiltradas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (especie.imagemHeader.isNotEmpty) _buildHeaderImage(),
        _buildInfoSection(),
      ],
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: RacasListaConstants.headerImageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(especie.imagemHeader),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Raças de ${especie.nome}',
          style: RacasListaConstants.headerTitleStyle,
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: RacasListaConstants.especieHeaderBackground,
        boxShadow: [RacasListaConstants.especieHeaderShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  especie.imagemPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      especie.nome,
                      style: RacasListaHelpers.getEspecieTitleStyle(
                        Colors.blue[900],
                      ),
                    ),
                    Text(
                      RacasListaHelpers.formatTotalRacas(totalRacasFiltradas),
                      style: RacasListaHelpers.getEspecieSubtitleStyle(
                        Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            especie.descricao,
            style: RacasListaConstants.especieSubtitleStyle.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

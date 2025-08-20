// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_constants.dart';

class RacaHeaderImageWidget extends StatelessWidget {
  final RacaDetalhes raca;

  const RacaHeaderImageWidget({
    super.key,
    required this.raca,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: RacasDetalhesConstants.expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'raca_image_${raca.nome}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                raca.imagemPrincipal,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          raca.nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RacasDetalhesConstants.imageGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

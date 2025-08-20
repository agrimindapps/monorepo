// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/racas_detalhes_controller.dart';
import '../../models/raca_detalhes_model.dart';
import '../../utils/racas_detalhes_constants.dart';
import '../../utils/racas_detalhes_helpers.dart';

class RacaImageGalleryWidget extends StatelessWidget {
  final RacaDetalhes raca;
  final RacasDetalhesController controller;

  const RacaImageGalleryWidget({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (raca.galeria.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Icon(
                RacasDetalhesHelpers.getSectionIcon('galeria'),
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              const Text(
                'Galeria de Fotos',
                style: RacasDetalhesConstants.galleryTitleStyle,
              ),
              const Spacer(),
              TextButton(
                onPressed: () => controller.showImageGallery(context),
                child: const Text('Ver todas'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: RacasDetalhesConstants.galleryHeight,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: raca.galeria.length,
            itemBuilder: (context, index) {
              return RacasDetalhesHelpers.buildGalleryItem(
                raca.galeria[index],
                () {
                  controller.updateImageIndex(index);
                  controller.showImageGallery(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

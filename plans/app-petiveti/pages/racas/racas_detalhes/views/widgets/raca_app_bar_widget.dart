// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../widgets/page_header_widget.dart';
import '../../controllers/racas_detalhes_controller.dart';
import '../../models/raca_detalhes_model.dart';

class RacaAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final RacaDetalhes raca;
  final RacasDetalhesController controller;

  const RacaAppBarWidget({
    super.key,
    required this.raca,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: PageHeaderWidget(
          title: raca.nome,
          subtitle: 'Informações detalhadas da raça',
          icon: Icons.pets,
          showBackButton: true,
          actions: [
            IconButton(
              icon: Icon(
                controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: controller.isFavorite ? Colors.red : null,
              ),
              tooltip: controller.isFavorite 
                  ? 'Remover dos favoritos' 
                  : 'Adicionar aos favoritos',
              onPressed: () {
                controller.toggleFavorite();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      controller.isFavorite
                          ? 'Adicionado aos favoritos!'
                          : 'Removido dos favoritos!',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartilhar',
              onPressed: () => controller.shareRaca(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}

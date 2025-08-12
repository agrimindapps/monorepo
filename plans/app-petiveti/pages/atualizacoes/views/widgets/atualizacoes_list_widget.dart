// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../controllers/atualizacoes_controller.dart';
import '../../utils/atualizacoes_constants.dart';
import '../../utils/atualizacoes_helpers.dart';
import 'atualizacao_card_widget.dart';

class AtualizacoesListWidget extends StatelessWidget {
  final AtualizacoesController controller;

  const AtualizacoesListWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.atualizacoes.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.atualizacoes.length,
      separatorBuilder: (context, index) => const SizedBox(
        height: AtualizacoesConstants.listItemSpacing,
      ),
      itemBuilder: (context, index) {
        final atualizacao = controller.atualizacoes[index];
        
        return AnimatedContainer(
          duration: AtualizacoesHelpers.getAnimationDuration(),
          curve: AtualizacoesHelpers.getAnimationCurve(),
          child: AtualizacaoCardWidget(
            atualizacao: atualizacao,
            controller: controller,
          ),
        );
      },
    );
  }
}

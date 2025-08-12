// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/especie_seletor_model.dart';
import '../../utils/racas_seletor_helpers.dart';

class EspecieFallbackWidget extends StatelessWidget {
  final EspecieSeletor especie;

  const EspecieFallbackWidget({
    super.key,
    required this.especie,
  });

  @override
  Widget build(BuildContext context) {
    return RacasSeletorHelpers.buildFallbackContent(
      especie.nome,
      especie.icone,
      context,
    );
  }
}

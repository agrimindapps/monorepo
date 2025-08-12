// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../utils/racas_detalhes_helpers.dart';

class RacaInfoSectionWidget extends StatelessWidget {
  final String title;
  final String content;
  final String sectionKey;

  const RacaInfoSectionWidget({
    super.key,
    required this.title,
    required this.content,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: RacasDetalhesHelpers.getCardMargin(),
      decoration: RacasDetalhesHelpers.getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: RacasDetalhesHelpers.getCardPadding(),
            decoration: RacasDetalhesHelpers.getSectionHeaderDecoration(sectionKey),
            child: RacasDetalhesHelpers.buildSectionHeader(title, sectionKey),
          ),
          Padding(
            padding: RacasDetalhesHelpers.getCardPadding(),
            child: Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

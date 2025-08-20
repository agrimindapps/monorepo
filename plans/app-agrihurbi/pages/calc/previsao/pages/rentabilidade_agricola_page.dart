// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../widgets/rentabilidade_agricola_widget.dart';

class RentabilidadeAgricolaPage extends StatelessWidget {
  const RentabilidadeAgricolaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: RentabilidadeAgricolaWidget(),
    );
  }
}

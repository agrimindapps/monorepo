// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'noticias_base_page.dart';

class NoticiasAgricolassPage extends StatelessWidget {
  const NoticiasAgricolassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticiasBasePage(
      type: NoticiasType.agricultura,
      title: 'Notícias Agrícolas',
      subtitle: 'Últimas notícias do setor',
      icon: Icons.agriculture,
    );
  }
}

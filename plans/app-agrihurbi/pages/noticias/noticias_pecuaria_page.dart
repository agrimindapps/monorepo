// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'noticias_base_page.dart';

class NoticiasPecuariasPage extends StatelessWidget {
  const NoticiasPecuariasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticiasBasePage(
      type: NoticiasType.pecuaria,
      title: 'Notícias Pecuárias',
      subtitle: 'Últimas notícias do setor',
      icon: Icons.pets,
    );
  }
}

import 'package:flutter/material.dart';

import 'presentation/pages/home_pragas_clean_page.dart';

/// Wrapper de compatibilidade para HomePragasPage
/// 
/// Este arquivo mantém a compatibilidade com o código existente,
/// redirecionando para a implementação clean em:
/// presentation/pages/home_pragas_clean_page.dart
/// 
/// Refatoração realizada seguindo Clean Architecture:
/// - 1.016 linhas → ~100 linhas (90% redução)
/// - Provider pattern implementado
/// - Widgets componentizados
/// - Responsabilidades bem definidas
/// 
/// Estrutura da refatoração:
/// - HomePragasProvider: Gerenciamento de estado
/// - HomePragasCleanPage: Página principal
/// - HomePragasStatsWidget: Grid de categorias
/// - HomePragasSuggestionsWidget: Carrossel de sugestões  
/// - HomePragasRecentWidget: Lista de últimos acessados
/// - HomePragasErrorWidget: Estados de erro
class HomePragasPage extends StatelessWidget {
  const HomePragasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePragasCleanPage();
  }
}
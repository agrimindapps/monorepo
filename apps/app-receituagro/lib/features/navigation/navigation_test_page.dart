import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_navigation_provider.dart';

/// Página de teste para demonstrar o novo sistema de navegação
/// 
/// Esta página mostra como usar o AppNavigationProvider para navegar
/// entre páginas mantendo o bottomNavigationBar sempre visível
class NavigationTestPage extends StatelessWidget {
  const NavigationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Navegação'),
        leading: Consumer<AppNavigationProvider>(
          builder: (context, navigationProvider, child) {
            return navigationProvider.isInDetailPage
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => navigationProvider.goBack(),
                  )
                : const SizedBox();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sistema de Navegação Interna',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Este sistema mantém o bottomNavigationBar sempre visível, '
                      'mesmo ao navegar para páginas de detalhes.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Teste as navegações:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Lista de Pragas - Insetos',
              Icons.bug_report,
              () => context.read<AppNavigationProvider>()
                  .navigateToListaPragas(pragaType: '1'),
            ),
            const SizedBox(height: 8),
            _buildNavigationButton(
              context,
              'Lista de Pragas - Doenças',
              Icons.healing,
              () => context.read<AppNavigationProvider>()
                  .navigateToListaPragas(pragaType: '2'),
            ),
            const SizedBox(height: 8),
            _buildNavigationButton(
              context,
              'Lista de Defensivos',
              Icons.shield,
              () => context.read<AppNavigationProvider>()
                  .navigateToListaDefensivos(),
            ),
            const SizedBox(height: 8),
            _buildNavigationButton(
              context,
              'Lista de Culturas',
              Icons.agriculture,
              () => context.read<AppNavigationProvider>()
                  .navigateToListaCulturas(),
            ),
            const SizedBox(height: 24),
            Consumer<AppNavigationProvider>(
              builder: (context, navigationProvider, child) {
                if (navigationProvider.isInDetailPage) {
                  return Column(
                    children: [
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Você está em uma página de detalhe!\n'
                                  'Página atual: ${navigationProvider.currentPageTitle ?? "Sem título"}',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => navigationProvider.goBack(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Voltar'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => navigationProvider.goBackToMain(),
                        icon: const Icon(Icons.home),
                        label: const Text('Voltar para página principal'),
                      ),
                    ],
                  );
                } else {
                  return Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Você está em uma página principal!\n'
                              'O bottomNavigationBar está sempre visível.',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}
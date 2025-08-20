/// Exemplo de uso do RouteManager
/// Este arquivo demonstra como usar o RouteManager para navegação consistente
/// 
/// ANTES - Usando Navigator tradicional:
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(builder: (context) => MinhaPage()));
/// Navigator.of(context).pop();
/// ```
/// 
/// DEPOIS - Usando RouteManager:
/// ```dart
/// RouteManager.instance.to(MinhaPage());
/// RouteManager.instance.back();
/// ```
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../core/navigation/route_manager.dart';

class NavigationExampleWidget extends StatelessWidget {
  const NavigationExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Navegação básica
        ElevatedButton(
          onPressed: () {
            // Navegar para página
            RouteManager.instance.to(const ExampleDestinationPage());
          },
          child: const Text('Navegar com RouteManager'),
        ),
        
        // Navegação com verificação de auth
        ElevatedButton(
          onPressed: () {
            // Navegar apenas se autenticado
            RouteManager.instance.toWithAuth(
              AppRoutes.animalPage,
              requiresPremium: false,
            );
          },
          child: const Text('Navegar (requer login)'),
        ),
        
        // Navegação com verificação de premium
        ElevatedButton(
          onPressed: () {
            // Navegar apenas se premium
            RouteManager.instance.toWithAuth(
              AppRoutes.premium,
              requiresPremium: true,
            );
          },
          child: const Text('Navegar (requer premium)'),
        ),
        
        // Métodos de conveniência
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.toAnimalPage();
          },
          child: const Text('Ir para Animais'),
        ),
        
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.toCalculadoras();
          },
          child: const Text('Ir para Calculadoras'),
        ),
        
        // Voltar
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.back();
          },
          child: const Text('Voltar'),
        ),
        
        // Mostrar dialog
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.showDialog(
              AlertDialog(
                title: const Text('Exemplo'),
                content: const Text('Dialog usando RouteManager'),
                actions: [
                  TextButton(
                    onPressed: () => RouteManager.instance.back(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Mostrar Dialog'),
        ),
        
        // Mostrar snackbar
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.showSnackbar(
              'Sucesso',
              'Operação realizada com sucesso!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          child: const Text('Mostrar Snackbar'),
        ),
      ],
    );
  }
}

class ExampleDestinationPage extends StatelessWidget {
  const ExampleDestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo de Destino'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => RouteManager.instance.back(),
        ),
      ),
      body: const Center(
        child: Text('Página navegada com RouteManager!'),
      ),
    );
  }
}

/// Exemplo de migração de código existente:

class ExemploMigracaoNavegacao extends StatelessWidget {
  const ExemploMigracaoNavegacao({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ANTES ❌
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ExampleDestinationPage(),
              ),
            );
          },
          child: const Text('Navegação Antiga (não use)'),
        ),
        
        // DEPOIS ✅
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.to(const ExampleDestinationPage());
          },
          child: const Text('Navegação Nova (use esta)'),
        ),
        
        // ANTES ❌
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Voltar Antigo (não use)'),
        ),
        
        // DEPOIS ✅
        ElevatedButton(
          onPressed: () {
            RouteManager.instance.back();
          },
          child: const Text('Voltar Novo (use este)'),
        ),
      ],
    );
  }
}

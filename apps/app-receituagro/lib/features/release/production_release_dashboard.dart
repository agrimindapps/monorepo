import 'package:flutter/material.dart';

/// DEPRECATED: ProductionReleaseDashboard foi removido
/// 
/// Razão: Dependência em BetaTestingService (legacy stub service) que foi removido
/// Arquivo original: Continha ~700 linhas altamente acopladas a um serviço descontinuado
/// 
/// Se este componente é necessário, considere:
/// 1. Implementar um novo sistema de release management
/// 2. Usar um serviço real ao invés de stub
/// 3. Simplificar a interface de release tracking
@Deprecated('BetaTestingService foi removido. Use novo sistema de release management.')
class ProductionReleaseDashboard extends StatefulWidget {
  const ProductionReleaseDashboard({super.key});

  @override
  State<ProductionReleaseDashboard> createState() => _ProductionReleaseDashboardState();
}

class _ProductionReleaseDashboardState extends State<ProductionReleaseDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release Dashboard (Deprecated)'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'ProductionReleaseDashboard foi removido\n\n'
                'Razão: Dependência em BetaTestingService (legacy stub service)\n\n'
                'Este componente precisa ser refatorado com um novo sistema '
                'de release management.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/culturas/presentation/pages/cultura_cadastro_page.dart';
import '../../features/culturas/presentation/pages/culturas_list_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/defensivos/presentation/pages/defensivo_cadastro_page.dart';
import '../../features/defensivos/presentation/pages/defensivos_list_page.dart';
import '../../features/export/presentation/pages/export_page.dart';
import '../../features/pragas/presentation/pages/praga_cadastro_page.dart';
import '../../features/pragas/presentation/pages/praga_detalhes_page.dart';
import '../../features/pragas/presentation/pages/pragas_list_page.dart';
import '../../features/public_consultation/presentation/pages/public_defensivo_details_page.dart';
import '../../features/public_consultation/presentation/pages/public_defensivos_list_page.dart';
import 'route_guard.dart';

/// Application router
class AppRouter {
  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ========== PUBLIC ROUTES (No authentication required) ==========

      case '/':
      case '/home':
        // Public - Página inicial do site público
        return MaterialPageRoute(
          builder: (_) => const PublicDefensivosListPage(),
        );

      case '/defensivo':
        // Public - Detalhes do defensivo (qualquer pessoa pode ver)
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID do defensivo é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => PublicDefensivoDetailsPage(id: args['id'] as String),
        );

      case '/login':
        // Public - Login page
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

      // ========== PROTECTED ROUTES (Authentication required) ==========

      case '/dashboard':
        // PROTECTED - Dashboard interno (Authenticated users)
        return MaterialPageRoute(
          builder: (_) => const DashboardPage().requireAuth(),
        );

      // Defensivos routes
      case '/defensivos':
        // PROTECTED - Lista de defensivos (área interna)
        return MaterialPageRoute(
          builder: (_) => const DefensivosListPage().requireAuth(),
        );

      case '/defensivo/new':
        // PROTECTED - Criar novo defensivo (Editor + Admin)
        return MaterialPageRoute(
          builder: (_) => const DefensivoCadastroPage().requireWrite(),
        );

      case '/defensivo/edit':
        // PROTECTED - Editar defensivo (Editor + Admin)
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID do defensivo é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => DefensivoCadastroPage(
            defensivoId: args['id'] as String,
          ).requireWrite(),
        );

      // Culturas routes
      case '/culturas':
        // PROTECTED - Lista de culturas (Authenticated users)
        return MaterialPageRoute(
          builder: (_) => const CulturasListPage().requireAuth(),
        );

      case '/culturas/details':
        // PROTECTED - Detalhes da cultura
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID da cultura é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => _CulturaDetailsPlaceholder(
            id: args['id'] as String,
          ).requireAuth(),
        );

      case '/culturas/new':
        // PROTECTED - Criar nova cultura (Editor + Admin)
        return MaterialPageRoute(
          builder: (_) => const CulturaCadastroPage().requireWrite(),
        );

      case '/culturas/edit':
        // PROTECTED - Editar cultura (Editor + Admin)
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID da cultura é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => CulturaCadastroPage(
            culturaId: args['id'] as String,
          ).requireWrite(),
        );

      // Pragas routes
      case '/pragas':
        // PROTECTED - Lista de pragas (Authenticated users)
        return MaterialPageRoute(
          builder: (_) => const PragasListPage().requireAuth(),
        );

      case '/pragas/details':
        // PROTECTED - Detalhes da praga
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID da praga é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => PragaDetalhesPage(
            pragaId: args['id'] as String,
          ).requireAuth(),
        );

      case '/pragas/new':
        // PROTECTED - Criar nova praga (Editor + Admin)
        return MaterialPageRoute(
          builder: (_) => const PragaCadastroPage().requireWrite(),
        );

      case '/pragas/edit':
        // PROTECTED - Editar praga (Editor + Admin)
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('id')) {
          return _buildErrorRoute('ID da praga é obrigatório');
        }
        return MaterialPageRoute(
          builder: (_) => PragaCadastroPage(
            pragaId: args['id'] as String,
          ).requireWrite(),
        );

      // Admin routes
      case '/admin':
        // PROTECTED - Painel admin (Admin only)
        return MaterialPageRoute(
          builder: (_) => const _AdminPlaceholder().requireAdmin(),
        );

      case '/users':
        // PROTECTED - Gerenciar usuários (Admin only)
        return MaterialPageRoute(
          builder: (_) => const _UsersPlaceholder().requireAdmin(),
        );

      case '/exportar':
        // PROTECTED - Exportar dados (Editor + Admin)
        return MaterialPageRoute(
          builder: (_) => const ExportPage().requireWrite(),
        );

      // ========== ERROR ROUTE ==========

      default:
        return _buildErrorRoute('Rota desconhecida: ${settings.name}');
    }
  }

  /// Build error route
  static MaterialPageRoute _buildErrorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Go back or to home
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder widgets (to be implemented)
class _AdminPlaceholder extends StatelessWidget {
  const _AdminPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel Admin')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64),
            SizedBox(height: 16),
            Text('Painel Administrativo', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _UsersPlaceholder extends StatelessWidget {
  const _UsersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Usuários')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64),
            SizedBox(height: 16),
            Text('Gerenciar Usuários', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _EditPlaceholder extends StatelessWidget {
  const _EditPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 64),
            SizedBox(height: 16),
            Text('Modo Edição', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

// ========== CULTURAS PLACEHOLDERS ==========

class _CulturaDetailsPlaceholder extends StatelessWidget {
  final String? id;

  const _CulturaDetailsPlaceholder({this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Cultura ${id ?? ''}')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grass, size: 64, color: Colors.lightGreen),
            SizedBox(height: 16),
            Text('Detalhes da Cultura', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _CreateCulturaPlaceholder extends StatelessWidget {
  const _CreateCulturaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Cultura')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: Colors.lightGreen),
            SizedBox(height: 16),
            Text('Criar Nova Cultura', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _EditCulturaPlaceholder extends StatelessWidget {
  final String? id;

  const _EditCulturaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Cultura ${id ?? ''}')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 64, color: Colors.lightGreen),
            SizedBox(height: 16),
            Text('Editar Cultura', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

// ========== PRAGAS PLACEHOLDERS ==========

class _PragaDetailsPlaceholder extends StatelessWidget {
  final String? id;

  const _PragaDetailsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da Praga ${id ?? ''}')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Detalhes da Praga', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _CreatePragaPlaceholder extends StatelessWidget {
  const _CreatePragaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Praga')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Criar Nova Praga', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

class _EditPragaPlaceholder extends StatelessWidget {
  final String? id;

  const _EditPragaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Praga ${id ?? ''}')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Editar Praga', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text('Em desenvolvimento...'),
          ],
        ),
      ),
    );
  }
}

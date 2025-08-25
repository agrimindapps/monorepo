import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bindings/favoritos_binding.dart';
import 'favoritos_page.dart';

/// Exemplo de como usar a FavoritosPage com Provider
/// 
/// Para usar em sua aplicação:
/// 1. Adicione os providers do FavoritosProviders no seu MaterialApp
/// 2. Navegue para a FavoritosPage
/// 
/// Exemplo de uso:
/// ```dart
/// MaterialApp(
///   home: MultiProvider(
///     providers: FavoritosProviders.providers,
///     child: const FavoritosPage(),
///   ),
/// )
/// ```
class FavoritosExampleApp extends StatelessWidget {
  const FavoritosExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favoritos Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: FavoritosProviders.providers,
        child: const FavoritosPage(),
      ),
    );
  }
}

void main() {
  runApp(const FavoritosExampleApp());
}
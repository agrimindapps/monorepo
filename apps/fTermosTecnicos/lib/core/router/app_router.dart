import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/termos/presentation/pages/home_page.dart';
import '../../pages/termos_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/tts_settings_page.dart' as settings_tts;
import '../../features/comentarios/presentation/pages/comentarios_page.dart';
import '../../features/premium/presentation/pages/premium_page.dart';
import '../pages/sobre.dart';
import '../pages/atualizacao.dart';

/// Global navigator key for app-wide navigation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration using go_router
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/categorias',
      name: 'categorias',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/termos',
      name: 'termos',
      builder: (context, state) => const TermosPage(favoritePage: false),
    ),
    GoRoute(
      path: '/favoritos',
      name: 'favoritos',
      builder: (context, state) => const TermosPage(favoritePage: true),
    ),
    GoRoute(
      path: '/comentarios',
      name: 'comentarios',
      builder: (context, state) => const ComentariosPage(),
    ),
    GoRoute(
      path: '/config',
      name: 'config',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/config/tts',
      name: 'tts-settings',
      builder: (context, state) => const settings_tts.TtsSettingsPage(),
    ),
    GoRoute(
      path: '/sobre',
      name: 'sobre',
      builder: (context, state) => const SobrePage(),
    ),
    GoRoute(
      path: '/atualizacao',
      name: 'atualizacao',
      builder: (context, state) => const AtualizacaoPage(),
    ),
    GoRoute(
      path: '/premium',
      name: 'premium',
      builder: (context, state) => const PremiumPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Erro')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Página não encontrada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Voltar para Início'),
          ),
        ],
      ),
    ),
  ),
);

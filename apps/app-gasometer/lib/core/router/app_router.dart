import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_details_page.dart';
import '../../features/odometer/presentation/pages/odometer_page.dart';
import '../../features/fuel/presentation/pages/fuel_page.dart';
import '../../features/fuel/presentation/pages/add_fuel_page.dart';
import '../../features/maintenance/presentation/pages/maintenance_page.dart';
import '../../features/maintenance/presentation/pages/add_maintenance_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/promo/presentation/pages/privacy_policy_page.dart';
import '../../features/promo/presentation/pages/terms_conditions_page.dart';
import '../../shared/widgets/main_navigation.dart';
import '../services/platform_service.dart';

class AppRouter {
  static String _getInitialLocation(AuthProvider authProvider, PlatformService platformService) {
    // Se já está autenticado (incluindo anônimo), vai direto para o app
    if (authProvider.isAuthenticated) {
      return '/';
    }
    
    // Se é web e não está autenticado, vai para promo
    if (platformService.isWeb) {
      return '/promo';
    }
    
    // Para mobile, vai direto para o app (será criado login anônimo automaticamente)
    return '/';
  }
  
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final platformService = PlatformService();
    
    return GoRouter(
      initialLocation: _getInitialLocation(authProvider, platformService),
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';
        final isPromoRoute = state.matchedLocation == '/promo';
        final isPrivacyRoute = state.matchedLocation == '/privacy';
        final isTermsRoute = state.matchedLocation == '/terms';
        
        // Se usuário está autenticado (incluindo anônimo) e tenta acessar promo/login
        if (isAuthenticated && (isPromoRoute || isLoginRoute)) {
          return '/';
        }
        
        // Permitir acesso às páginas de políticas sempre
        if (isPrivacyRoute || isTermsRoute) {
          return null;
        }
        
        // Para web
        if (platformService.isWeb) {
          // Se autenticado (incluindo anônimo), permitir acesso a todas as rotas do app
          if (isAuthenticated) {
            return null;
          }
          
          // Se não autenticado e não está em promo/login, redirecionar para promo
          if (!isAuthenticated && !isLoginRoute && !isPromoRoute) {
            return '/promo';
          }
        }
        
        // Para mobile, permitir acesso direto às funcionalidades (modo anônimo)
        if (platformService.isMobile) {
          // Se não autenticado e tentando acessar login, permitir
          if (!isAuthenticated && isLoginRoute) {
            return null;
          }
          
          // Para mobile, permitir acesso a todas as rotas mesmo sem autenticação
          return null;
        }
        
        // Lógica padrão para outras plataformas
        if (!isAuthenticated && !isLoginRoute && !isPromoRoute) {
          return '/login';
        }
        
        return null;
      },
      routes: [
        // Promo Routes (Landing Page and Policies)
        GoRoute(
          path: '/promo',
          name: 'promo',
          builder: (context, state) => const PromoPage(),
        ),
        
        // Privacy Policy Route
        GoRoute(
          path: '/privacy',
          name: 'privacy',
          builder: (context, state) => const PrivacyPolicyPage(),
        ),
        
        // Terms & Conditions Route
        GoRoute(
          path: '/terms',
          name: 'terms',
          builder: (context, state) => const TermsConditionsPage(),
        ),
        
        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        
        
        // Main Shell Route
        ShellRoute(
          builder: (context, state, child) => MainNavigation(child: child),
          routes: [
            // Home - Vehicles
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const VehiclesPage(),
            ),
            
            // Vehicle Details (sub-route of home)
            GoRoute(
              path: '/vehicle-details/:vehicleId',
              name: 'vehicle_details',
              builder: (context, state) {
                final vehicleId = state.pathParameters['vehicleId']!;
                return VehicleDetailsPage(vehicleId: vehicleId);
              },
            ),
            
            // Odometer
            GoRoute(
              path: '/odometer',
              name: 'odometer',
              builder: (context, state) => const OdometerPage(),
            ),
            
            // Fuel
            GoRoute(
              path: '/fuel',
              name: 'fuel',
              builder: (context, state) => const FuelPage(),
              routes: [
                GoRoute(
                  path: '/add',
                  name: 'add_fuel',
                  builder: (context, state) => const AddFuelPage(),
                ),
              ],
            ),
            
            // Maintenance
            GoRoute(
              path: '/maintenance',
              name: 'maintenance',
              builder: (context, state) => const MaintenancePage(),
              routes: [
                GoRoute(
                  path: '/add',
                  name: 'add_maintenance',
                  builder: (context, state) => const AddMaintenancePage(),
                ),
              ],
            ),
            
            // Reports
            GoRoute(
              path: '/reports',
              name: 'reports',
              builder: (context, state) => const ReportsPage(),
            ),
            
            // Settings
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
            
            // Profile
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Página não encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'A página "${state.matchedLocation}" não existe.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
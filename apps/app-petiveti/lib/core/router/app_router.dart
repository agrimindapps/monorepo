import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/animals/presentation/pages/animals_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/appointments/presentation/widgets/add_appointment_form.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/calculators/presentation/pages/animal_age_page.dart';
import '../../features/calculators/presentation/pages/body_condition_page.dart';
import '../../features/calculators/presentation/pages/calculators_main_page.dart';
import '../../features/calculators/presentation/pages/calorie_page.dart';
import '../../features/calculators/presentation/pages/ideal_weight_page.dart';
import '../../features/calculators/presentation/pages/medication_dosage_page.dart';
import '../../features/calculators/presentation/pages/pregnancy_page.dart';
import '../../features/calculators/presentation/pages/exercise_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/medications/presentation/pages/medications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/promo/presentation/pages/promo_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/vaccines/presentation/pages/vaccines_page.dart';
import '../../features/weight/presentation/pages/weight_page.dart';
import '../navigation/bottom_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  // Determine initial route based on auth state
  final initialRoute = authState.isAuthenticated ? '/' : '/promo';
  
  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthPage = state.matchedLocation.startsWith('/login') || 
                           state.matchedLocation.startsWith('/register');
      final isOnSplash = state.matchedLocation == '/splash';
      final isOnPromo = state.matchedLocation == '/promo';
      
      // If authenticated, redirect to home (except splash)
      if (isAuthenticated && (isOnPromo || isOnAuthPage)) {
        return '/';
      }

      // If not authenticated and trying to access protected pages, redirect to promo
      if (!isAuthenticated && !isOnAuthPage && !isOnSplash && !isOnPromo) {
        return '/promo';
      }

      return null; // No redirect needed
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavShell(
            state: state,
            child: child,
          );
        },
        routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/animals',
        name: 'animals',
        builder: (context, state) => const AnimalsPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-animal',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Animal Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/appointments',
        name: 'appointments',
        builder: (context, state) => const AppointmentsPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-appointment',
            builder: (context, state) => const AddAppointmentForm(),
          ),
          GoRoute(
            path: '/:id',
            name: 'appointment-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Scaffold(
                body: Center(
                  child: Text('Appointment Details: $id - Coming Soon'),
                ),
              );
            },
            routes: [
              GoRoute(
                path: '/edit',
                name: 'edit-appointment',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Scaffold(
                    body: Center(
                      child: Text('Edit Appointment: $id - Coming Soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/vaccines',
        name: 'vaccines',
        builder: (context, state) => const VaccinesPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-vaccine',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Vaccine Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/medications',
        name: 'medications',
        builder: (context, state) => const MedicationsPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-medication',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Medication Page - Coming Soon'),
              ),
            ),
          ),
          GoRoute(
            path: '/:id',
            name: 'medication-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Scaffold(
                body: Center(
                  child: Text('Medication Details: $id - Coming Soon'),
                ),
              );
            },
            routes: [
              GoRoute(
                path: '/edit',
                name: 'edit-medication',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return Scaffold(
                    body: Center(
                      child: Text('Edit Medication: $id - Coming Soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/weight',
        name: 'weight',
        builder: (context, state) => const WeightPage(),
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-weight',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Weight Record Page - Coming Soon'),
              ),
            ),
          ),
          GoRoute(
            path: '/history/:animalId',
            name: 'weight-history',
            builder: (context, state) {
              final animalId = state.pathParameters['animalId']!;
              return Scaffold(
                body: Center(
                  child: Text('Weight History for Animal: $animalId - Coming Soon'),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const RemindersPage(userId: 'temp_user_id'), // TODO: Get from auth service
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-reminder',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Reminder Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/expenses',
        name: 'expenses',
        builder: (context, state) => const ExpensesPage(userId: 'temp_user_id'), // TODO: Get from auth service
        routes: [
          GoRoute(
            path: '/add',
            name: 'add-expense',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Add Expense Page - Coming Soon'),
              ),
            ),
          ),
          GoRoute(
            path: '/summary',
            name: 'expenses-summary',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Expenses Summary Page - Coming Soon'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/calculators',
        name: 'calculators',
        builder: (context, state) => const CalculatorsMainPage(),
        routes: [
          GoRoute(
            path: '/body-condition',
            name: 'body-condition-calculator',
            builder: (context, state) => const BodyConditionPage(),
          ),
          GoRoute(
            path: '/calorie',
            name: 'calorie-calculator',
            builder: (context, state) => const CaloriePage(),
          ),
          GoRoute(
            path: '/medication-dosage',
            name: 'medication-dosage-calculator',
            builder: (context, state) => const MedicationDosagePage(),
          ),
          GoRoute(
            path: '/animal-age',
            name: 'animal-age-calculator',
            builder: (context, state) => const AnimalAgePage(),
          ),
          GoRoute(
            path: '/ideal-weight',
            name: 'ideal-weight-calculator',
            builder: (context, state) => const IdealWeightPage(),
          ),
          GoRoute(
            path: '/fluid-therapy',
            name: 'fluid-therapy-calculator',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Calculadora de Fluidoterapia')),
              body: const Center(child: Text('Calculadora de Fluidoterapia - Em desenvolvimento')),
            ),
          ),
          GoRoute(
            path: '/hydration',
            name: 'hydration-calculator', 
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Calculadora de Hidratação')),
              body: const Center(child: Text('Calculadora de Hidratação - Em desenvolvimento')),
            ),
          ),
          GoRoute(
            path: '/pregnancy',
            name: 'pregnancy-calculator',
            builder: (context, state) => const PregnancyPage(),
          ),
          GoRoute(
            path: '/exercise',
            name: 'exercise-calculator',
            builder: (context, state) => const ExercisePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(userId: 'temp_user_id'), // TODO: Get from auth service
      ),
        ],
      ),
      
      // Rotas fora do shell (sem bottom navigation)
      GoRoute(
        path: '/promo',
        name: 'promo',
        builder: (context, state) => const PromoPage(),
      ),
      
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
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
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
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
});
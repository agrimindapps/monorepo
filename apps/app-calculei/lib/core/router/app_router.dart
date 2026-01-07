import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive_shell.dart';
import '../../features/cash_vs_installment_calculator/presentation/pages/cash_vs_installment_calculator_page.dart';
// Construction Calculators
import '../../features/construction_calculator/presentation/pages/brick_calculator_page.dart';
import '../../features/construction_calculator/presentation/pages/concrete_calculator_page.dart';
import '../../features/construction_calculator/presentation/pages/construction_selection_page.dart';
import '../../features/construction_calculator/presentation/pages/flooring_calculator_page.dart';
import '../../features/construction_calculator/presentation/pages/paint_calculator_page.dart';
import '../../features/emergency_reserve_calculator/presentation/pages/emergency_reserve_calculator_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/net_salary_calculator/presentation/pages/net_salary_calculator_page.dart';
import '../../features/overtime_calculator/presentation/pages/overtime_calculator_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
// Financial Calculators
import '../../features/thirteenth_salary_calculator/presentation/pages/thirteenth_salary_calculator_page.dart';
import '../../features/unemployment_insurance_calculator/presentation/pages/unemployment_insurance_calculator_page.dart';
import '../../features/vacation_calculator/presentation/pages/vacation_calculator_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveShell(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        // Branch 1: Calculators
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calculators',
              builder: (context, state) => const HomePage(),
            ),
            // Financial
            GoRoute(
              path: '/calculators/financial/thirteenth-salary',
              builder: (context, state) =>
                  const ThirteenthSalaryCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/vacation',
              builder: (context, state) => const VacationCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/net-salary',
              builder: (context, state) => const NetSalaryCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/overtime',
              builder: (context, state) => const OvertimeCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/emergency-reserve',
              builder: (context, state) =>
                  const EmergencyReserveCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/cash-vs-installment',
              builder: (context, state) =>
                  const CashVsInstallmentCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/financial/unemployment-insurance',
              builder: (context, state) =>
                  const UnemploymentInsuranceCalculatorPage(),
            ),
            // Construction Calculators
            GoRoute(
              path: '/calculators/construction/selection',
              builder: (context, state) =>
                  const ConstructionCalculatorSelectionPage(),
            ),
            GoRoute(
              path: '/calculators/construction/concrete',
              builder: (context, state) => const ConcreteCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/construction/paint',
              builder: (context, state) => const PaintCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/construction/flooring',
              builder: (context, state) => const FlooringCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/construction/brick',
              builder: (context, state) => const BrickCalculatorPage(),
            ),
          ],
        ),

        // Branch 2: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Erro'),
    ),
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
            state.uri.path,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('Voltar para Home'),
          ),
        ],
      ),
    ),
  ),
);

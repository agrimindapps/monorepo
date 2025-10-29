import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:app_calculei/features/home/presentation/pages/home_page.dart';
import 'package:app_calculei/features/thirteenth_salary_calculator/presentation/pages/thirteenth_salary_calculator_page.dart';
import 'package:app_calculei/features/vacation_calculator/presentation/pages/vacation_calculator_page.dart';
import 'package:app_calculei/features/net_salary_calculator/presentation/pages/net_salary_calculator_page.dart';
import 'package:app_calculei/features/overtime_calculator/presentation/pages/overtime_calculator_page.dart';
import 'package:app_calculei/features/emergency_reserve_calculator/presentation/pages/emergency_reserve_calculator_page.dart';
import 'package:app_calculei/features/cash_vs_installment_calculator/presentation/pages/cash_vs_installment_calculator_page.dart';
import 'package:app_calculei/features/unemployment_insurance_calculator/presentation/pages/unemployment_insurance_calculator_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/construction_calculator_selection_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/materials_quantity_calculator_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/cost_per_sqm_calculator_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/paint_consumption_calculator_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/flooring_calculator_page.dart';
import 'package:app_calculei/features/construction_calculator/presentation/pages/concrete_calculator_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

// App router configuration
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Home
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    // ========== FINANCIAL CALCULATORS GROUP ==========
    GoRoute(
      path: '/financial/thirteenth-salary',
      builder: (context, state) => const ThirteenthSalaryCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/vacation',
      builder: (context, state) => const VacationCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/net-salary',
      builder: (context, state) => const NetSalaryCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/overtime',
      builder: (context, state) => const OvertimeCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/emergency-reserve',
      builder: (context, state) => const EmergencyReserveCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/cash-vs-installment',
      builder: (context, state) => const CashVsInstallmentCalculatorPage(),
    ),
    GoRoute(
      path: '/financial/unemployment-insurance',
      builder: (context, state) => const UnemploymentInsuranceCalculatorPage(),
    ),

    // ========== CONSTRUCTION CALCULATORS GROUP ==========
    GoRoute(
      path: '/construction/selection',
      builder: (context, state) => const ConstructionCalculatorSelectionPage(),
    ),
    GoRoute(
      path: '/construction/materials-quantity',
      builder: (context, state) => const MaterialsQuantityCalculatorPage(),
    ),
    GoRoute(
      path: '/construction/cost-per-sqm',
      builder: (context, state) => const CostPerSqmCalculatorPage(),
    ),
    GoRoute(
      path: '/construction/paint-consumption',
      builder: (context, state) => const PaintConsumptionCalculatorPage(),
    ),
    GoRoute(
      path: '/construction/flooring',
      builder: (context, state) => const FlooringCalculatorPage(),
    ),
    GoRoute(
      path: '/construction/concrete',
      builder: (context, state) => const ConcreteCalculatorPage(),
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
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
            label: const Text('Voltar para Home'),
          ),
        ],
      ),
    ),
  ),
);

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

    // Implemented calculators
    GoRoute(
      path: '/calc/thirteenth-salary',
      builder: (context, state) => const ThirteenthSalaryCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/vacation',
      builder: (context, state) => const VacationCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/net-salary',
      builder: (context, state) => const NetSalaryCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/overtime',
      builder: (context, state) => const OvertimeCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/emergency-reserve',
      builder: (context, state) => const EmergencyReserveCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/cash-vs-installment',
      builder: (context, state) => const CashVsInstallmentCalculatorPage(),
    ),
    GoRoute(
      path: '/calc/unemployment-insurance',
      builder: (context, state) => const UnemploymentInsuranceCalculatorPage(),
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

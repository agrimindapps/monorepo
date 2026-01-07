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
// Health Calculators
import '../../features/health_calculator/presentation/pages/alcool_sangue_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/bmi_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/bmr_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/body_fat_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/calorias_exercicio_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/cintura_quadril_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/deficit_superavit_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/health_selection_page.dart';
import '../../features/health_calculator/presentation/pages/ideal_weight_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/macronutrients_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/proteinas_diarias_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/volume_sanguineo_calculator_page.dart';
import '../../features/health_calculator/presentation/pages/water_intake_calculator_page.dart';
import '../../features/emergency_reserve_calculator/presentation/pages/emergency_reserve_calculator_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/net_salary_calculator/presentation/pages/net_salary_calculator_page.dart';
import '../../features/overtime_calculator/presentation/pages/overtime_calculator_page.dart';
// Pet Calculators
import '../../features/pet_calculator/presentation/pages/animal_age_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/body_condition_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/caloric_needs_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/fluid_therapy_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/medication_dosage_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/pet_ideal_weight_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/pet_selection_page.dart';
import '../../features/pet_calculator/presentation/pages/pregnancy_calculator_page.dart';
import '../../features/pet_calculator/presentation/pages/unit_conversion_calculator_page.dart';
// Agriculture Calculators
import '../../features/agriculture_calculator/presentation/pages/agriculture_selection_page.dart';
import '../../features/agriculture_calculator/presentation/pages/irrigation_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/npk_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/seed_rate_calculator_page.dart';
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
            // Health Calculators
            GoRoute(
              path: '/calculators/health/selection',
              builder: (context, state) => const HealthSelectionPage(),
            ),
            GoRoute(
              path: '/calculators/health/bmi',
              builder: (context, state) => const BmiCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/bmr',
              builder: (context, state) => const BmrCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/water',
              builder: (context, state) => const WaterIntakeCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/ideal-weight',
              builder: (context, state) => const IdealWeightCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/body-fat',
              builder: (context, state) => const BodyFatCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/macros',
              builder: (context, state) => const MacronutrientsCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/protein',
              builder: (context, state) =>
                  const ProteinasDiariasCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/exercise-calories',
              builder: (context, state) =>
                  const CaloriasExercicioCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/waist-hip',
              builder: (context, state) =>
                  const CinturaQuadrilCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/blood-alcohol',
              builder: (context, state) =>
                  const AlcoolSangueCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/blood-volume',
              builder: (context, state) =>
                  const VolumeSanguineoCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/health/caloric-deficit',
              builder: (context, state) =>
                  const DeficitSuperavitCalculatorPage(),
            ),
            // Pet Calculators
            GoRoute(
              path: '/calculators/pet/selection',
              builder: (context, state) => const PetSelectionPage(),
            ),
            GoRoute(
              path: '/calculators/pet/age',
              builder: (context, state) => const AnimalAgeCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/pregnancy',
              builder: (context, state) => const PregnancyCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/body-condition',
              builder: (context, state) =>
                  const BodyConditionCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/caloric-needs',
              builder: (context, state) =>
                  const CaloricNeedsCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/medication',
              builder: (context, state) =>
                  const MedicationDosageCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/fluid-therapy',
              builder: (context, state) =>
                  const FluidTherapyCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/ideal-weight',
              builder: (context, state) =>
                  const PetIdealWeightCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/pet/unit-conversion',
              builder: (context, state) =>
                  const UnitConversionCalculatorPage(),
            ),
            // Agriculture Calculators
            GoRoute(
              path: '/calculators/agriculture/selection',
              builder: (context, state) => const AgricultureSelectionPage(),
            ),
            GoRoute(
              path: '/calculators/agriculture/npk',
              builder: (context, state) => const NpkCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/agriculture/seed-rate',
              builder: (context, state) => const SeedRateCalculatorPage(),
            ),
            GoRoute(
              path: '/calculators/agriculture/irrigation',
              builder: (context, state) => const IrrigationCalculatorPage(),
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

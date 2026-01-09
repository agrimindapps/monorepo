import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../core/layout/responsive_shell.dart';
import 'page_transitions.dart';
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
import '../../features/agriculture_calculator/presentation/pages/breeding_cycle_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/evapotranspiration_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/feed_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/fertilizer_dosing_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/irrigation_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/npk_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/planting_density_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/seed_rate_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/soil_ph_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/weight_gain_calculator_page.dart';
import '../../features/agriculture_calculator/presentation/pages/yield_prediction_calculator_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
// Financial Calculators
import '../../features/thirteenth_salary_calculator/presentation/pages/thirteenth_salary_calculator_page.dart';
import '../../features/unemployment_insurance_calculator/presentation/pages/unemployment_insurance_calculator_page.dart';
import '../../features/vacation_calculator/presentation/pages/vacation_calculator_page.dart';
import '../../features/financial_calculator/presentation/pages/financial_selection_page.dart';

// Global navigator key
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider para o GoRouter com Analytics integrado
final appRouterProvider = Provider<GoRouter>((ref) {
  final analyticsObserver = ref.watch(
    analyticsRouteObserverFamilyProvider('calculei_'),
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    observers: [analyticsObserver],
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
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const HomePage(),
                state: state,
              ),
            ),
          ],
        ),

        // Branch 1: Calculators
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calculators',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const HomePage(),
                state: state,
              ),
            ),
            // Financial
            GoRoute(
              path: '/calculators/financial/selection',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const FinancialSelectionPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/thirteenth-salary',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const ThirteenthSalaryCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/vacation',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const VacationCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/net-salary',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const NetSalaryCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/overtime',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const OvertimeCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/emergency-reserve',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const EmergencyReserveCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/cash-vs-installment',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const CashVsInstallmentCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/financial/unemployment-insurance',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const UnemploymentInsuranceCalculatorPage(),
                state: state,
              ),
            ),
            // Construction Calculators
            GoRoute(
              path: '/calculators/construction/selection',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const ConstructionCalculatorSelectionPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/construction/concrete',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const ConcreteCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/construction/paint',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const PaintCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/construction/flooring',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const FlooringCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/construction/brick',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BrickCalculatorPage(),
                state: state,
              ),
            ),
            // Health Calculators
            GoRoute(
              path: '/calculators/health/selection',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const HealthSelectionPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/bmi',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BmiCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/bmr',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BmrCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/water',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const WaterIntakeCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/ideal-weight',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const IdealWeightCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/body-fat',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BodyFatCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/macros',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const MacronutrientsCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/protein',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const ProteinasDiariasCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/exercise-calories',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const CaloriasExercicioCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/waist-hip',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const CinturaQuadrilCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/blood-alcohol',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const AlcoolSangueCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/blood-volume',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const VolumeSanguineoCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/health/caloric-deficit',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const DeficitSuperavitCalculatorPage(),
                state: state,
              ),
            ),
            // Pet Calculators
            GoRoute(
              path: '/calculators/pet/selection',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const PetSelectionPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/age',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const AnimalAgeCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/pregnancy',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const PregnancyCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/body-condition',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BodyConditionCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/caloric-needs',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const CaloricNeedsCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/medication',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const MedicationDosageCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/fluid-therapy',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const FluidTherapyCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/ideal-weight',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const PetIdealWeightCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/pet/unit-conversion',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const UnitConversionCalculatorPage(),
                state: state,
              ),
            ),
            // Agriculture Calculators
            GoRoute(
              path: '/calculators/agriculture/selection',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const AgricultureSelectionPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/npk',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const NpkCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/seed-rate',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const SeedRateCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/irrigation',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const IrrigationCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/fertilizer-dosing',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const FertilizerDosingCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/soil-ph',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const SoilPhCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/planting-density',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const PlantingDensityCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/yield-prediction',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const YieldPredictionCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/feed',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const FeedCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/weight-gain',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const WeightGainCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/breeding-cycle',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const BreedingCycleCalculatorPage(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/calculators/agriculture/evapotranspiration',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const EvapotranspirationCalculatorPage(),
                state: state,
              ),
            ),
          ],
        ),

        // Branch 2: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => fadeTransitionPage(
                child: const SettingsPage(),
                state: state,
              ),
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
});

/// Mantido para compatibilidade - usar appRouterProvider quando possível
/// @deprecated Use appRouterProvider em Consumer widgets
GoRouter get appRouter => throw UnsupportedError(
      'Use appRouterProvider com ref.watch/read dentro de Consumer widgets',
    );

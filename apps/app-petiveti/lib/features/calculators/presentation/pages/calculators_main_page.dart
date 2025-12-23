import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../../shared/widgets/petiveti_page_header.dart';
import '../../domain/entities/calculator.dart';

import '../providers/calculators_providers.dart';

/// Página principal de calculadoras veterinárias
class CalculatorsMainPage extends ConsumerWidget {
  const CalculatorsMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatorsAsync = ref.watch(calculatorsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PetivetiPageHeader(
              icon: Icons.calculate,
              title: 'Calculadoras',
              subtitle: 'Ferramentas veterinárias',
              showBackButton: false,
            ),
            Expanded(
              child: calculatorsAsync.when(
                data: (calculators) =>
                    _CalculatorsGrid(calculators: calculators),
                loading: () => const _LoadingState(),
                error: (error, stack) => _ErrorState(error: error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid de calculadoras
class _CalculatorsGrid extends StatelessWidget {
  const _CalculatorsGrid({required this.calculators});

  final List<Calculator> calculators;

  @override
  Widget build(BuildContext context) {
    final categorizedCalculators = <CalculatorCategory, List<Calculator>>{};
    for (final calc in calculators) {
      categorizedCalculators.putIfAbsent(calc.category, () => []).add(calc);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeHeader(),
              const SizedBox(height: 24),
              ...categorizedCalculators.entries.map(
                (entry) => _CategorySection(
                  category: entry.key,
                  calculators: entry.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho de boas-vindas
class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ferramentas Veterinárias',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Calculadoras profissionais para auxiliar na prática veterinária. '
            'Desenvolvidas com base em protocolos científicos atualizados.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seção de categoria de calculadoras
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.calculators});

  final CalculatorCategory category;
  final List<Calculator> calculators;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getCategoryName(category),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = switch (width) {
              >= 1024 => 4,
              >= 720 => 3,
              >= 420 => 2,
              _ => 1,
            };

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: calculators.length,
              itemBuilder: (context, index) =>
                  _CalculatorCard(calculator: calculators[index]),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _getCategoryIcon(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.health:
        return Icons.health_and_safety;
      case CalculatorCategory.nutrition:
        return Icons.restaurant;
      case CalculatorCategory.medication:
        return Icons.medication;
      default:
        return Icons.calculate;
    }
  }

  String _getCategoryName(CalculatorCategory category) {
    switch (category) {
      case CalculatorCategory.health:
        return 'Saúde';
      case CalculatorCategory.nutrition:
        return 'Nutrição';
      case CalculatorCategory.medication:
        return 'Medicamentos';
      default:
        return 'Outros';
    }
  }
}

/// Card de calculadora individual
class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({required this.calculator});

  final Calculator calculator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToCalculator(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCalculatorIcon(calculator.iconName),
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                calculator.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  calculator.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCalculatorIcon(String iconName) {
    switch (iconName) {
      case 'monitor_weight':
        return Icons.monitor_weight;
      case 'restaurant':
        return Icons.restaurant;
      case 'medication':
        return Icons.medication;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'cake':
        return Icons.cake;
      case 'water_drop':
        return Icons.water_drop;
      case 'pregnant_woman':
        return Icons.pregnant_woman;
      case 'baby_changing_station':
        return Icons.baby_changing_station;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'science':
        return Icons.science;
      default:
        return Icons.calculate;
    }
  }

  void _navigateToCalculator(BuildContext context) {
    String routeName;
    switch (calculator.id) {
      case 'body_condition':
        routeName = 'body-condition-calculator';
        break;
      case 'calorie':
        routeName = 'calorie-calculator';
        break;
      case 'medication_dosage':
        routeName = 'medication-dosage-calculator';
        break;
      case 'animal_age':
        routeName = 'animal-age-calculator';
        break;
      case 'anesthesia':
        routeName = 'anesthesia-calculator';
        break;
      case 'diabetes_insulin':
        routeName = 'diabetes-insulin-calculator';
        break;
      case 'ideal_weight':
        routeName = 'ideal-weight-calculator';
        break;
      case 'fluid_therapy':
        routeName = 'fluid-therapy-calculator';
        break;
      case 'hydration':
        routeName = 'hydration-calculator';
        break;
      case 'pregnancy_gestacao':
        routeName = 'pregnancy-calculator';
        break;
      case 'exercise':
        routeName = 'exercise-calculator';
        break;
      default:
        _showComingSoonDialog(context);
        return;
    }

    context.pushNamed(routeName);
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em breve'),
        content: Text(
          'A calculadora "${calculator.name}" estará disponível em breve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Estado de carregamento
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando calculadoras...'),
        ],
      ),
    );
  }
}

/// Estado de erro
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar calculadoras',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed('calculators'),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

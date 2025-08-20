// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../controllers/dashboard_controller.dart';
import '../utils/dashboard_constants.dart';
import '../utils/dashboard_helpers.dart';
import 'widgets/active_medications_widget.dart';
import 'widgets/consultation_history_widget.dart';
import 'widgets/expenses_chart_widget.dart';
import 'widgets/health_insights_widget.dart';
import 'widgets/pet_selector_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/summary_cards_widget.dart';
import 'widgets/vaccination_control_widget.dart';
import 'widgets/weight_chart_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Scaffold(
          body: _buildBody(context),
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return DashboardHelpers.buildLoadingIndicator();
    }

    if (_controller.hasError) {
      return DashboardHelpers.buildErrorWidget(
        _controller.errorMessage!,
        _controller.refresh,
      );
    }

    if (!_controller.hasPets) {
      return DashboardHelpers.buildEmptyState(
        icon: Icons.pets,
        title: 'Nenhum pet cadastrado',
        subtitle: 'Adicione um pet para começar a usar o dashboard',
      );
    }

    return SingleChildScrollView(
      padding: DashboardHelpers.getDefaultPadding(),
      child: Center(
        child: SizedBox(
          width: DashboardConstants.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PetSelectorWidget(controller: _controller),
              const SizedBox(height: 24),
              SummaryCardsWidget(controller: _controller),
              const SizedBox(height: 24),
              _buildChartsSection(context),
              const SizedBox(height: 24),
              _buildDataSection(context),
              const SizedBox(height: 24),
              VaccinationControlWidget(controller: _controller),
              const SizedBox(height: 24),
              ActiveMedicationsWidget(controller: _controller),
              const SizedBox(height: 24),
              QuickActionsWidget(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    final isSmallScreen = DashboardHelpers.isSmallScreen(context);

    if (isSmallScreen) {
      return Column(
        children: [
          WeightChartWidget(controller: _controller),
          const SizedBox(height: 24),
          HealthInsightsWidget(controller: _controller),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: WeightChartWidget(controller: _controller)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: HealthInsightsWidget(controller: _controller)),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    final isSmallScreen = DashboardHelpers.isSmallScreen(context);

    if (isSmallScreen) {
      return Column(
        children: [
          ExpensesChartWidget(controller: _controller),
          const SizedBox(height: 24),
          ConsultationHistoryWidget(controller: _controller),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: ExpensesChartWidget(controller: _controller)),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: ConsultationHistoryWidget(controller: _controller)),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddOptionsBottomSheet(context),
      tooltip: 'Adicionar registro',
      child: const Icon(Icons.add),
    );
  }

  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adicionar Registro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBottomSheetOption(
              context,
              Icons.monitor_weight,
              'Registrar Peso',
              () => _controller.navigateToWeightRegistration(context),
            ),
            _buildBottomSheetOption(
              context,
              Icons.medical_services,
              'Nova Consulta',
              () => _controller.navigateToConsultationRegistration(context),
            ),
            _buildBottomSheetOption(
              context,
              Icons.vaccines,
              'Registrar Vacina',
              () => _controller.navigateToVaccinationRegistration(context),
            ),
            _buildBottomSheetOption(
              context,
              Icons.medication,
              'Medicamento',
              () => _controller.navigateToMedicationRegistration(context),
            ),
            _buildBottomSheetOption(
              context,
              Icons.receipt_long,
              'Nova Despesa',
              () => _controller.navigateToExpenseRegistration(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

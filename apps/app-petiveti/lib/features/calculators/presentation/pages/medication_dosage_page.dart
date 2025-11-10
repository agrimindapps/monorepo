import 'package:core/core.dart' hide Column;
import 'package:flutter/material.dart';

import '../../domain/entities/medication_dosage_output.dart';
import '../../domain/services/dosage_validation_service.dart';
import '../providers/medication_dosage_provider.dart';
import '../widgets/critical_dose_confirmation_dialog.dart';
import '../widgets/medication_dosage_input_form.dart';
import '../widgets/medication_dosage_result_card.dart';
import '../widgets/medication_selector_widget.dart';
import '../widgets/prescription_export_widget.dart';
import '../widgets/safety_alerts_widget.dart';

/// Página principal da Calculadora de Dosagem de Medicamentos
class MedicationDosagePage extends ConsumerStatefulWidget {
  const MedicationDosagePage({super.key});

  @override
  ConsumerState<MedicationDosagePage> createState() =>
      _MedicationDosagePageState();
}

class _MedicationDosagePageState extends ConsumerState<MedicationDosagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosagem de Medicamentos'),
        elevation: 2,
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade800,
        actions: [
          Builder(
            builder: (context) {
              final provider = ref.watch(medicationDosageProviderProvider);
              return IconButton(
                icon: Icon(
                  provider.output != null
                      ? Icons.medical_services
                      : Icons.medical_services_outlined,
                  color: provider.output != null ? Colors.green : Colors.grey,
                ),
                onPressed: provider.output != null
                    ? () => _showPrescriptionExport(context, provider)
                    : null,
                tooltip: 'Exportar Prescrição',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryBottomSheet(context),
            tooltip: 'Histórico',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Limpar Tudo'),
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Ajuda'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.red.shade800,
          indicatorColor: Colors.red.shade600,
          tabs: const [
            Tab(icon: Icon(Icons.input), text: 'Entrada'),
            Tab(icon: Icon(Icons.calculate), text: 'Resultado'),
            Tab(icon: Icon(Icons.warning), text: 'Alertas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildInputTab(), _buildResultTab(), _buildAlertsTab()],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final provider = ref.watch(medicationDosageProviderProvider);
          if (!provider.hasValidInput) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: provider.isCalculating
                ? null
                : () => _handleCalculateWithSafetyCheck(provider),
            backgroundColor: Colors.red.shade600,
            icon: provider.isCalculating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.calculate),
            label: Text(
              provider.isCalculating ? 'Calculando...' : 'Calcular Dosagem',
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSafetyHeader(),
          const SizedBox(height: 16),
          const MedicationSelectorWidget(),
          const SizedBox(height: 16),
          const MedicationDosageInputForm(),
          const SizedBox(height: 80), // Espaço para FAB
        ],
      ),
    );
  }

  Widget _buildResultTab() {
    final provider = ref.watch(medicationDosageProviderProvider);

    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    if (provider.output == null) {
      return _buildEmptyResultState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MedicationDosageResultCard(output: provider.output!),
          const SizedBox(height: 16),
          if (provider.output!.monitoringInfo != null) ...[
            _buildMonitoringCard(provider.output!),
            const SizedBox(height: 16),
          ],
          _buildAdministrationInstructionsCard(provider.output!),
        ],
      ),
    );
  }

  Widget _buildAlertsTab() {
    final provider = ref.watch(medicationDosageProviderProvider);

    if (provider.output?.alerts.isEmpty ?? true) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum alerta disponível',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Realize um cálculo para ver alertas de segurança',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SafetyAlertsWidget(alerts: provider.output!.alerts),
    );
  }

  Widget _buildSafetyHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATENÇÃO - Uso Veterinário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta calculadora é uma ferramenta auxiliar. Sempre consulte um veterinário antes de administrar medicamentos.',
                  style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Erro no Cálculo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(medicationDosageProviderProvider).clearAll();
                _tabController.animateTo(0);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResultState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Resultado do Cálculo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preencha os dados na aba "Entrada" e pressione o botão calcular',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCard(MedicationDosageOutput output) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Monitoramento Necessário',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Parâmetros',
              output.monitoringInfo!.parametersToMonitor.join(', '),
            ),
            _buildInfoRow('Frequência', output.monitoringInfo!.frequency),
            _buildInfoRow('Duração', output.monitoringInfo!.duration),
            if (output.monitoringInfo!.warningSignsToWatch.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sinais de Alerta:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 4),
              ...output.monitoringInfo!.warningSignsToWatch.map(
                (sign) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(sign)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdministrationInstructionsCard(MedicationDosageOutput output) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Instruções de Administração',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Via de Administração', output.instructions.route),
            _buildInfoRow('Timing', output.instructions.timing),
            if (output.instructions.dilution != null)
              _buildInfoRow('Preparo', output.instructions.dilution!),
            if (output.instructions.storage != null)
              _buildInfoRow('Armazenamento', output.instructions.storage!),
            if (output.instructions.sideEffects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Efeitos Adversos Possíveis:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                output.instructions.sideEffects.join(', '),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Implementa confirmação dupla para doses críticas
  Future<void> _handleCalculateWithSafetyCheck(
    MedicationDosageProvider provider,
  ) async {
    final preValidation = DosageValidationService.preValidate(provider.input);

    if (preValidation.requiresDoubleConfirmation) {
      final confirmed = await _showCriticalDoseConfirmation(
        preValidation.warnings,
      );
      if (!confirmed) return;
    }
    await provider.calculateDosage();
    if (provider.output != null && provider.selectedMedication != null) {
      final postValidation = DosageValidationService.validateCalculation(
        provider.input,
        provider.output!,
        provider.selectedMedication!,
      );
      if (postValidation.isCritical && !postValidation.isValid) {
        final confirmed = await _showCriticalDoseConfirmation(
          postValidation.criticalErrors + postValidation.warnings,
          medicationName: provider.output!.medicationName,
          calculatedDose: provider.output!.dosagePerKg,
          unit: provider.output!.unit,
          recommendedAction: postValidation.recommendedAction,
        );

        if (!confirmed) {
          provider.clearAll();
          return;
        }
      }
    }
    _tabController.animateTo(1);
  }

  /// Mostra dialog de confirmação crítica
  Future<bool> _showCriticalDoseConfirmation(
    List<String> warnings, {
    String? medicationName,
    double? calculatedDose,
    String? unit,
    String? recommendedAction,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticalDoseConfirmationDialog(
        warnings: warnings,
        medicationName: medicationName ?? 'Medicamento',
        calculatedDose: calculatedDose ?? 0.0,
        unit: unit ?? 'mg/kg',
        recommendedAction: recommendedAction,
      ),
    ).then((value) => value ?? false);
  }

  void _showPrescriptionExport(
    BuildContext context,
    MedicationDosageProvider provider,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => PrescriptionExportWidget(
          output: provider.output!,
          input: provider.input,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          final provider = ref.watch(medicationDosageProviderProvider);
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Histórico de Cálculos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (provider.calculationHistory.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          provider.clearHistory();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Limpar'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.calculationHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum cálculo no histórico',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: provider.calculationHistory.length,
                          itemBuilder: (context, index) {
                            final result = provider.calculationHistory[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: result.isSafeToAdminister
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  child: Icon(
                                    result.isSafeToAdminister
                                        ? Icons.check
                                        : Icons.warning,
                                    color: result.isSafeToAdminister
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                title: Text(result.medicationName),
                                subtitle: Text(
                                  '${result.dosePerAdministration.toStringAsFixed(2)} ${result.unit} - ${result.administrationsPerDay}x/dia',
                                ),
                                trailing: Text(
                                  '${result.calculatedAt?.day ?? DateTime.now().day}/${result.calculatedAt?.month ?? DateTime.now().month}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  provider.loadFromHistory(index);
                                  Navigator.pop(context);
                                  _tabController.animateTo(1);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = ref.read(medicationDosageProviderProvider);

    switch (action) {
      case 'clear':
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Limpar Todos os Dados'),
            content: const Text(
              'Tem certeza que deseja limpar todos os dados inseridos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  provider.clearAll();
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Limpar'),
              ),
            ],
          ),
        );
        break;
      case 'help':
        _showHelpDialog(context);
        break;
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda - Calculadora de Dosagem'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Como usar:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Selecione o medicamento desejado'),
              Text('2. Informe os dados do animal (espécie, peso, idade)'),
              Text('3. Configure a frequência de administração'),
              Text('4. Adicione condições especiais se aplicável'),
              Text('5. Pressione "Calcular Dosagem"'),
              SizedBox(height: 16),
              Text(
                'Importante:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text('• Esta ferramenta é apenas auxiliar'),
              Text('• Sempre consulte um veterinário'),
              Text('• Observe alertas de segurança'),
              Text('• Monitore o animal durante tratamento'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

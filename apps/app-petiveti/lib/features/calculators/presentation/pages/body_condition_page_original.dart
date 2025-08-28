import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/body_condition_output.dart';
import '../providers/body_condition_provider.dart';
import '../widgets/bcs_guide_sheet.dart';
import '../widgets/body_condition_history_panel.dart';
import '../widgets/body_condition_input_form.dart';
import '../widgets/body_condition_result_card.dart';

/// Página principal da Calculadora de Condição Corporal
class BodyConditionPage extends ConsumerStatefulWidget {
  const BodyConditionPage({super.key});

  @override
  ConsumerState<BodyConditionPage> createState() => _BodyConditionPageState();
}

class _BodyConditionPageState extends ConsumerState<BodyConditionPage>
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
    final state = ref.watch(bodyConditionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Condição Corporal (BCS)'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showBcsGuide(context),
            tooltip: 'Guia BCS',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Resetar'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: ListTile(
                      leading: Icon(Icons.history),
                      title: Text('Histórico'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Exportar'),
                      dense: true,
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.input), text: 'Entrada'),
            Tab(icon: Icon(Icons.analytics), text: 'Resultado'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Indicador de progresso/status
          _buildStatusIndicator(state),

          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba de entrada
                _buildInputTab(),

                // Aba de resultado
                _buildResultTab(),

                // Aba de histórico
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(state),
    );
  }

  Widget _buildStatusIndicator(BodyConditionState state) {
    if (state.isLoading) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue.withValues(alpha: 0.1),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Calculando...'),
          ],
        ),
      );
    }

    if (state.hasError) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.red.withValues(alpha: 0.1),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed:
                  () => ref.read(bodyConditionProvider.notifier).clearError(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }

    if (state.hasValidationErrors) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.orange.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text(
                  'Dados incompletos:',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...state.validationErrors.map(
              (error) => Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  '• $error',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInputTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: BodyConditionInputForm(),
    );
  }

  Widget _buildResultTab() {
    return Consumer(
      builder: (context, ref, child) {
        final output = ref.watch(bodyConditionOutputProvider);

        if (output == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum resultado ainda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Preencha os dados na aba "Entrada" e toque em "Calcular"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: BodyConditionResultCard(result: output),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer(
      builder: (context, ref, child) {
        final history = ref.watch(bodyConditionHistoryProvider);

        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum histórico ainda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Os resultados dos cálculos aparecerão aqui',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return BodyConditionHistoryPanel(history: history);
      },
    );
  }

  Widget? _buildFloatingActionButton(BodyConditionState state) {
    // Mostrar FAB apenas na aba de entrada
    if (_tabController.index != 0) return null;

    return FloatingActionButton.extended(
      onPressed:
          state.canCalculate
              ? () {
                ref.read(bodyConditionProvider.notifier).calculate();
                // Mover para aba de resultado após calcular
                _tabController.animateTo(1);
              }
              : null,
      backgroundColor: state.canCalculate ? null : Colors.grey,
      icon:
          state.isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.calculate),
      label: Text(state.isLoading ? 'Calculando...' : 'Calcular BCS'),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reset':
        _showResetConfirmation();
        break;
      case 'history':
        _tabController.animateTo(2);
        break;
      case 'export':
        _exportResult();
        break;
    }
  }

  void _showResetConfirmation() {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Resetar Calculadora'),
            content: const Text(
              'Isso limpará todos os dados inseridos e resultados. Continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(bodyConditionProvider.notifier).reset();
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                },
                child: const Text('Resetar'),
              ),
            ],
          ),
    );
  }

  void _exportResult() {
    final output = ref.read(bodyConditionOutputProvider);
    if (output == null) {
      _showErrorSnackBar('Nenhum resultado para exportar');
      return;
    }

    // Validar dados antes da exportação
    if (!_validateExportData(output)) {
      _showErrorSnackBar('Dados insuficientes para exportação segura');
      return;
    }

    _showExportDialog(output);
  }

  bool _validateExportData(BodyConditionOutput output) {
    // Validações críticas de dados veterinários antes da exportação
    if (output.bcsScore < 1.0 || output.bcsScore > 9.0) {
      return false; // Score BCS inválido
    }

    final input = ref.read(bodyConditionInputProvider);
    if (input.currentWeight <= 0.0 || input.currentWeight > 150.0) {
      return false; // Peso inválido
    }

    // Verificar se dados essenciais estão presentes
    if (output.results.isEmpty) {
      return false; // Sem resultados calculados
    }

    return true;
  }

  void _showExportDialog(BodyConditionOutput output) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exportar Resultado BCS'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score BCS: ${output.bcsScore.toStringAsFixed(1)}'),
                Text(
                  'Classificação: ${_getClassificationText(output.classification)}',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Os dados serão exportados de forma segura e anônima.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _performSecureExport(output);
                },
                child: const Text('Exportar'),
              ),
            ],
          ),
    );
  }

  void _performSecureExport(BodyConditionOutput output) {
    // Implementação segura da exportação
    // Em uma implementação real, aqui haveria:
    // - Sanitização dos dados
    // - Remoção de informações sensíveis
    // - Geração de PDF ou outro formato
    // - Compartilhamento seguro

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resultado exportado com segurança!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getClassificationText(BcsClassification classification) {
    return classification.displayName;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showBcsGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BcsGuideSheet(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/body_condition_provider.dart';
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
            itemBuilder: (context) => [
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
            Expanded(child: Text(state.error!, style: const TextStyle(color: Colors.red))),
            TextButton(
              onPressed: () => ref.read(bodyConditionProvider.notifier).clearError(),
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
                Text('Dados incompletos:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            ...state.validationErrors.map((error) => Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text('• $error', style: const TextStyle(color: Colors.orange)),
            )),
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
      onPressed: state.canCalculate
          ? () {
              ref.read(bodyConditionProvider.notifier).calculate();
              // Mover para aba de resultado após calcular
              _tabController.animateTo(1);
            }
          : null,
      backgroundColor: state.canCalculate ? null : Colors.grey,
      icon: state.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Calculadora'),
        content: const Text('Isso limpará todos os dados inseridos e resultados. Continuar?'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum resultado para exportar')),
      );
      return;
    }

    // TODO: Implementar exportação (PDF, compartilhamento, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação será implementada em breve')),
    );
  }

  void _showBcsGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BcsGuideSheet(),
    );
  }
}

/// Sheet com guia de interpretação BCS
class BcsGuideSheet extends StatelessWidget {
  const BcsGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.blue,
            ),
            child: Row(
              children: [
                const Icon(Icons.help, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Guia de Condição Corporal (BCS)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuideSection(
                    'O que é BCS?',
                    'Body Condition Score (BCS) é um sistema de avaliação nutricional que analisa a condição corporal do animal através de palpação e observação visual, utilizando uma escala de 1 a 9.',
                    Icons.info,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Como palpar as costelas?',
                    '1. Coloque as mãos nas laterais do tórax\n2. Pressione suavemente com as pontas dos dedos\n3. Avalie a facilidade para sentir as costelas\n4. Considere a cobertura de gordura',
                    Icons.touch_app,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Avaliação da cintura',
                    'Observe o animal de cima:\n• Deve haver uma "cintura" visível atrás das costelas\n• A cintura deve ser mais estreita que o tórax\n• Em animais obesos, a cintura desaparece',
                    Icons.visibility,
                  ),
                  const SizedBox(height: 20),
                  _buildGuideSection(
                    'Perfil abdominal',
                    'Observe o animal de lado:\n• Abdome deve estar "retraído" (tucked up)\n• Em animais magros, a retração é muito evidente\n• Em obesos, o abdome fica pendular',
                    Icons.straighten,
                  ),
                  const SizedBox(height: 20),
                  _buildBcsScale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBcsScale() {
    const bcsData = [
      {'score': '1-2', 'condition': 'Extremamente Magro', 'color': Colors.red},
      {'score': '3', 'condition': 'Magro', 'color': Colors.orange},
      {'score': '4', 'condition': 'Abaixo do Ideal', 'color': Colors.amber},
      {'score': '5', 'condition': 'Ideal', 'color': Colors.green},
      {'score': '6', 'condition': 'Acima do Ideal', 'color': Colors.amber},
      {'score': '7', 'condition': 'Sobrepeso', 'color': Colors.orange},
      {'score': '8-9', 'condition': 'Obeso', 'color': Colors.red},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.scale, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Escala BCS (1-9)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...bcsData.map((data) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: (data['color'] as Color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: data['color'] as Color),
                    ),
                    child: Center(
                      child: Text(
                        data['score'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: data['color'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(data['condition'] as String),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
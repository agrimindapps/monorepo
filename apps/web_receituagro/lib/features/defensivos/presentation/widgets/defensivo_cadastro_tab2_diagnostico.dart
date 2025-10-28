import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../culturas/presentation/providers/culturas_providers.dart';
import '../../../pragas/presentation/providers/pragas_providers.dart';
import '../../domain/entities/diagnostico.dart';
import '../providers/defensivo_cadastro_provider.dart';
import 'diagnostico_add_dialog.dart';

/// Tab 2: Diagnóstico (Dosagem e Aplicação)
/// COMPLETE DataTable com:
/// - Grouping por cultura
/// - Inline editing
/// - Batch editing por cultura
/// - "Refletir dados" (copiar primeiro valor do grupo para todos)
class DefensivoCadastroTab2Diagnostico extends ConsumerStatefulWidget {
  const DefensivoCadastroTab2Diagnostico({super.key});

  @override
  ConsumerState<DefensivoCadastroTab2Diagnostico> createState() =>
      _DefensivoCadastroTab2DiagnosticoState();
}

class _DefensivoCadastroTab2DiagnosticoState
    extends ConsumerState<DefensivoCadastroTab2Diagnostico> {
  // Batch editing controllers per cultura
  final Map<String, Map<String, TextEditingController>> _batchControllers = {};

  @override
  void dispose() {
    // Dispose all batch controllers
    for (final culturaControllers in _batchControllers.values) {
      for (final controller in culturaControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(defensivoCadastroProvider);
    final culturasAsync = ref.watch(culturasListProvider);
    final pragasAsync = ref.watch(pragasListProvider);
    final diagnosticos = state.diagnosticos;

    // Group diagnosticos by cultura
    final groupedDiagnosticos = groupBy(diagnosticos, (d) => d.culturaId);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagnóstico',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: state.defensivo == null
                    ? null
                    : () => _showAddDiagnosticoDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info message if defensivo not saved yet
          if (state.defensivo == null)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Salve as informações básicas (Tab 1) antes de adicionar diagnósticos.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // DataTable with grouping
          Expanded(
            child: diagnosticos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum diagnóstico adicionado.\nClique em "Adicionar" para incluir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: groupedDiagnosticos.entries.map((entry) {
                        final culturaId = entry.key;
                        final culturaDiagnosticos = entry.value;

                        return culturasAsync.when(
                          data: (culturas) {
                            final cultura = culturas.firstWhereOrNull(
                              (c) => c.id == culturaId,
                            );
                            final culturaNome =
                                cultura?.nomeComum ?? 'Cultura desconhecida';

                            return _buildCulturaGroup(
                              culturaNome,
                              culturaId,
                              culturaDiagnosticos,
                              pragasAsync,
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const Text('Erro ao carregar'),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Build grouped section for a cultura
  Widget _buildCulturaGroup(
    String culturaNome,
    String culturaId,
    List<Diagnostico> diagnosticos,
    AsyncValue pragasAsync,
  ) {
    // Initialize batch controllers for this cultura if not exists
    if (!_batchControllers.containsKey(culturaId)) {
      _batchControllers[culturaId] = {
        'dsMin': TextEditingController(),
        'dsMax': TextEditingController(),
        'um': TextEditingController(),
        'minAplicacaoT': TextEditingController(),
        'maxAplicacaoT': TextEditingController(),
        'umT': TextEditingController(),
        'minAplicacaoA': TextEditingController(),
        'maxAplicacaoA': TextEditingController(),
        'umA': TextEditingController(),
        'intervalo': TextEditingController(),
      };
    }

    final batchControllers = _batchControllers[culturaId]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cultura header with batch editing fields
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      culturaNome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        // Refletir dados button
                        ElevatedButton.icon(
                          onPressed: diagnosticos.isEmpty
                              ? null
                              : () => _refletirDados(culturaId, diagnosticos),
                          icon: const Icon(Icons.copy_all, size: 16),
                          label: const Text('Refletir Dados'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Apply batch button
                        ElevatedButton.icon(
                          onPressed: () =>
                              _applyBatchEdit(culturaId, diagnosticos),
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text('Aplicar a Todos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Batch editing fields
                const Text(
                  'Edição em lote (aplica a todos desta cultura):',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBatchField('Dose Mín', batchControllers['dsMin']!),
                      _buildBatchField('Dose Máx', batchControllers['dsMax']!),
                      _buildBatchField('UM', batchControllers['um']!),
                      _buildBatchField(
                        'Terr Mín',
                        batchControllers['minAplicacaoT']!,
                      ),
                      _buildBatchField(
                        'Terr Máx',
                        batchControllers['maxAplicacaoT']!,
                      ),
                      _buildBatchField('UM T', batchControllers['umT']!),
                      _buildBatchField(
                        'Aér Mín',
                        batchControllers['minAplicacaoA']!,
                      ),
                      _buildBatchField(
                        'Aér Máx',
                        batchControllers['maxAplicacaoA']!,
                      ),
                      _buildBatchField('UM A', batchControllers['umA']!),
                      _buildBatchField(
                        'Intervalo',
                        batchControllers['intervalo']!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // DataTable for this cultura's diagnosticos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: pragasAsync.when(
              data: (pragas) => DataTable(
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade200,
                ),
                columnSpacing: 12,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('Praga', style: TextStyle(fontSize: 12))),
                  DataColumn(label: Text('Dose\nMín', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Dose\nMáx', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('UM', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Terr\nMín', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Terr\nMáx', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('UM', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Aér\nMín', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Aér\nMáx', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('UM', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Intervalo', style: TextStyle(fontSize: 11))),
                  DataColumn(label: Text('Ações', style: TextStyle(fontSize: 11))),
                ],
                rows: diagnosticos.asMap().entries.map((entry) {
                  final globalIndex = ref
                      .read(defensivoCadastroProvider)
                      .diagnosticos
                      .indexOf(entry.value);
                  final diagnostico = entry.value;
                  final praga = pragas.firstWhereOrNull(
                    (p) => p.id == diagnostico.pragaId,
                  );

                  return DataRow(
                    cells: [
                      DataCell(Text(
                        praga?.nomeComum ?? 'Desconhecida',
                        style: const TextStyle(fontSize: 11),
                      )),
                      _buildEditableCell(diagnostico.dsMin ?? '', globalIndex,
                          'dsMin'),
                      _buildEditableCell(diagnostico.dsMax ?? '', globalIndex,
                          'dsMax'),
                      _buildEditableCell(
                          diagnostico.um ?? '', globalIndex, 'um'),
                      _buildEditableCell(
                          diagnostico.minAplicacaoT ?? '', globalIndex, 'minAplicacaoT'),
                      _buildEditableCell(
                          diagnostico.maxAplicacaoT ?? '', globalIndex, 'maxAplicacaoT'),
                      _buildEditableCell(
                          diagnostico.umT ?? '', globalIndex, 'umT'),
                      _buildEditableCell(
                          diagnostico.minAplicacaoA ?? '', globalIndex, 'minAplicacaoA'),
                      _buildEditableCell(
                          diagnostico.maxAplicacaoA ?? '', globalIndex, 'maxAplicacaoA'),
                      _buildEditableCell(
                          diagnostico.umA ?? '', globalIndex, 'umA'),
                      _buildEditableCell(
                          diagnostico.intervalo ?? '', globalIndex, 'intervalo'),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              onPressed: () => _editDiagnostico(globalIndex),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 16, color: Colors.red),
                              onPressed: () => _deleteDiagnostico(globalIndex),
                              tooltip: 'Excluir',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build editable cell with inline editing
  DataCell _buildEditableCell(String value, int index, String field) {
    return DataCell(
      InkWell(
        onTap: () => _editCellValue(index, field, value),
        child: Container(
          constraints: const BoxConstraints(minWidth: 50),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 11,
              color: value.isEmpty ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// Build batch editing field
  Widget _buildBatchField(String label, TextEditingController controller) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  /// Edit cell value inline
  void _editCellValue(int index, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $field'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final diagnostico =
                  ref.read(defensivoCadastroProvider).diagnosticos[index];

              final Map<String, String?> updates = {
                field: controller.text.isEmpty ? null : controller.text,
              };

              final updated = _copyDiagnosticoWithUpdates(diagnostico, updates);

              ref
                  .read(defensivoCadastroProvider.notifier)
                  .updateDiagnostico(index, updated);

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  /// Copy diagnostico with field updates
  Diagnostico _copyDiagnosticoWithUpdates(
    Diagnostico diagnostico,
    Map<String, String?> updates,
  ) {
    return diagnostico.copyWith(
      dsMin: updates.containsKey('dsMin') ? updates['dsMin'] : diagnostico.dsMin,
      dsMax: updates.containsKey('dsMax') ? updates['dsMax'] : diagnostico.dsMax,
      um: updates.containsKey('um') ? updates['um'] : diagnostico.um,
      minAplicacaoT: updates.containsKey('minAplicacaoT')
          ? updates['minAplicacaoT']
          : diagnostico.minAplicacaoT,
      maxAplicacaoT: updates.containsKey('maxAplicacaoT')
          ? updates['maxAplicacaoT']
          : diagnostico.maxAplicacaoT,
      umT: updates.containsKey('umT') ? updates['umT'] : diagnostico.umT,
      minAplicacaoA: updates.containsKey('minAplicacaoA')
          ? updates['minAplicacaoA']
          : diagnostico.minAplicacaoA,
      maxAplicacaoA: updates.containsKey('maxAplicacaoA')
          ? updates['maxAplicacaoA']
          : diagnostico.maxAplicacaoA,
      umA: updates.containsKey('umA') ? updates['umA'] : diagnostico.umA,
      intervalo: updates.containsKey('intervalo')
          ? updates['intervalo']
          : diagnostico.intervalo,
    );
  }

  /// Refletir dados - copy first row values to all rows in group
  void _refletirDados(String culturaId, List<Diagnostico> diagnosticos) {
    if (diagnosticos.isEmpty) return;

    final first = diagnosticos.first;
    final allDiagnosticos = ref.read(defensivoCadastroProvider).diagnosticos;

    for (final diagnostico in diagnosticos) {
      final index = allDiagnosticos.indexOf(diagnostico);
      if (index != -1 && index != allDiagnosticos.indexOf(first)) {
        final updated = diagnostico.copyWith(
          dsMin: first.dsMin,
          dsMax: first.dsMax,
          um: first.um,
          minAplicacaoT: first.minAplicacaoT,
          maxAplicacaoT: first.maxAplicacaoT,
          umT: first.umT,
          minAplicacaoA: first.minAplicacaoA,
          maxAplicacaoA: first.maxAplicacaoA,
          umA: first.umA,
          intervalo: first.intervalo,
        );

        ref
            .read(defensivoCadastroProvider.notifier)
            .updateDiagnostico(index, updated);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados refletidos com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Apply batch edit to all rows in group
  void _applyBatchEdit(String culturaId, List<Diagnostico> diagnosticos) {
    final controllers = _batchControllers[culturaId]!;
    final allDiagnosticos = ref.read(defensivoCadastroProvider).diagnosticos;

    for (final diagnostico in diagnosticos) {
      final index = allDiagnosticos.indexOf(diagnostico);
      if (index != -1) {
        final updated = diagnostico.copyWith(
          dsMin: controllers['dsMin']!.text.isNotEmpty
              ? controllers['dsMin']!.text
              : diagnostico.dsMin,
          dsMax: controllers['dsMax']!.text.isNotEmpty
              ? controllers['dsMax']!.text
              : diagnostico.dsMax,
          um: controllers['um']!.text.isNotEmpty
              ? controllers['um']!.text
              : diagnostico.um,
          minAplicacaoT: controllers['minAplicacaoT']!.text.isNotEmpty
              ? controllers['minAplicacaoT']!.text
              : diagnostico.minAplicacaoT,
          maxAplicacaoT: controllers['maxAplicacaoT']!.text.isNotEmpty
              ? controllers['maxAplicacaoT']!.text
              : diagnostico.maxAplicacaoT,
          umT: controllers['umT']!.text.isNotEmpty
              ? controllers['umT']!.text
              : diagnostico.umT,
          minAplicacaoA: controllers['minAplicacaoA']!.text.isNotEmpty
              ? controllers['minAplicacaoA']!.text
              : diagnostico.minAplicacaoA,
          maxAplicacaoA: controllers['maxAplicacaoA']!.text.isNotEmpty
              ? controllers['maxAplicacaoA']!.text
              : diagnostico.maxAplicacaoA,
          umA: controllers['umA']!.text.isNotEmpty
              ? controllers['umA']!.text
              : diagnostico.umA,
          intervalo: controllers['intervalo']!.text.isNotEmpty
              ? controllers['intervalo']!.text
              : diagnostico.intervalo,
        );

        ref
            .read(defensivoCadastroProvider.notifier)
            .updateDiagnostico(index, updated);
      }
    }

    // Clear batch fields
    for (final controller in controllers.values) {
      controller.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição em lote aplicada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show add diagnostico dialog
  Future<void> _showAddDiagnosticoDialog() async {
    final result = await showDialog<Diagnostico>(
      context: context,
      builder: (context) => DiagnosticoAddDialog(
        defensivoId: ref.read(defensivoCadastroProvider).defensivo?.id,
      ),
    );

    if (result != null) {
      ref.read(defensivoCadastroProvider.notifier).addDiagnostico(result);
    }
  }

  /// Edit diagnostico
  Future<void> _editDiagnostico(int index) async {
    final diagnostico = ref.read(defensivoCadastroProvider).diagnosticos[index];

    final result = await showDialog<Diagnostico>(
      context: context,
      builder: (context) => DiagnosticoAddDialog(
        diagnostico: diagnostico,
        defensivoId: ref.read(defensivoCadastroProvider).defensivo?.id,
      ),
    );

    if (result != null) {
      ref
          .read(defensivoCadastroProvider.notifier)
          .updateDiagnostico(index, result);
    }
  }

  /// Delete diagnostico
  void _deleteDiagnostico(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este diagnóstico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(defensivoCadastroProvider.notifier)
                  .removeDiagnostico(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

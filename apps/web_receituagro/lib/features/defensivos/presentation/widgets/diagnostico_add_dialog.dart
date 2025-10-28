import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../culturas/domain/entities/cultura.dart';
import '../../../culturas/presentation/providers/culturas_providers.dart';
import '../../../pragas/domain/entities/praga.dart';
import '../../../pragas/presentation/providers/pragas_providers.dart';
import '../../domain/entities/diagnostico.dart';

/// Dialog para adicionar ou editar um diagnóstico
class DiagnosticoAddDialog extends ConsumerStatefulWidget {
  final Diagnostico? diagnostico; // null = new, preenchido = edit
  final String? defensivoId;

  const DiagnosticoAddDialog({
    super.key,
    this.diagnostico,
    this.defensivoId,
  });

  @override
  ConsumerState<DiagnosticoAddDialog> createState() =>
      _DiagnosticoAddDialogState();
}

class _DiagnosticoAddDialogState extends ConsumerState<DiagnosticoAddDialog> {
  final _formKey = GlobalKey<FormState>();

  // Selected IDs
  String? _selectedCulturaId;
  String? _selectedPragaId;

  // Controllers for all fields
  late final TextEditingController _dsMinController;
  late final TextEditingController _dsMaxController;
  late final TextEditingController _umController;
  late final TextEditingController _minAplicacaoTController;
  late final TextEditingController _maxAplicacaoTController;
  late final TextEditingController _umTController;
  late final TextEditingController _minAplicacaoAController;
  late final TextEditingController _maxAplicacaoAController;
  late final TextEditingController _umAController;
  late final TextEditingController _intervaloController;
  late final TextEditingController _intervalo2Controller;
  late final TextEditingController _epocaAplicacaoController;

  @override
  void initState() {
    super.initState();

    // Initialize with existing data if editing
    final diagnostico = widget.diagnostico;
    _selectedCulturaId = diagnostico?.culturaId;
    _selectedPragaId = diagnostico?.pragaId;

    _dsMinController = TextEditingController(text: diagnostico?.dsMin ?? '');
    _dsMaxController = TextEditingController(text: diagnostico?.dsMax ?? '');
    _umController = TextEditingController(text: diagnostico?.um ?? '');
    _minAplicacaoTController =
        TextEditingController(text: diagnostico?.minAplicacaoT ?? '');
    _maxAplicacaoTController =
        TextEditingController(text: diagnostico?.maxAplicacaoT ?? '');
    _umTController = TextEditingController(text: diagnostico?.umT ?? '');
    _minAplicacaoAController =
        TextEditingController(text: diagnostico?.minAplicacaoA ?? '');
    _maxAplicacaoAController =
        TextEditingController(text: diagnostico?.maxAplicacaoA ?? '');
    _umAController = TextEditingController(text: diagnostico?.umA ?? '');
    _intervaloController =
        TextEditingController(text: diagnostico?.intervalo ?? '');
    _intervalo2Controller =
        TextEditingController(text: diagnostico?.intervalo2 ?? '');
    _epocaAplicacaoController =
        TextEditingController(text: diagnostico?.epocaAplicacao ?? '');
  }

  @override
  void dispose() {
    _dsMinController.dispose();
    _dsMaxController.dispose();
    _umController.dispose();
    _minAplicacaoTController.dispose();
    _maxAplicacaoTController.dispose();
    _umTController.dispose();
    _minAplicacaoAController.dispose();
    _maxAplicacaoAController.dispose();
    _umAController.dispose();
    _intervaloController.dispose();
    _intervalo2Controller.dispose();
    _epocaAplicacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final culturasAsync = ref.watch(culturasListProvider);
    final pragasAsync = ref.watch(pragasListProvider);

    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.diagnostico == null
                      ? 'Adicionar Diagnóstico'
                      : 'Editar Diagnóstico',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Cultura and Praga selection
                Row(
                  children: [
                    Expanded(
                      child: culturasAsync.when(
                        data: (culturas) => DropdownButtonFormField<String>(
                          value: _selectedCulturaId,
                          decoration: const InputDecoration(
                            labelText: 'Cultura *',
                            border: OutlineInputBorder(),
                          ),
                          items: culturas
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nomeComum),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCulturaId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione uma cultura';
                            }
                            return null;
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const Text('Erro ao carregar culturas'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: pragasAsync.when(
                        data: (pragas) => DropdownButtonFormField<String>(
                          value: _selectedPragaId,
                          decoration: const InputDecoration(
                            labelText: 'Praga *',
                            border: OutlineInputBorder(),
                          ),
                          items: pragas
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.nomeComum),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPragaId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione uma praga';
                            }
                            return null;
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const Text('Erro ao carregar pragas'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dosage section
                const Text(
                  'Dosagem',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dsMinController,
                        decoration: const InputDecoration(
                          labelText: 'Mín',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _dsMaxController,
                        decoration: const InputDecoration(
                          labelText: 'Máx',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _umController,
                        decoration: const InputDecoration(
                          labelText: 'UM (L/ha, kg/ha)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Terrestrial Application
                const Text(
                  'Aplicação Terrestre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minAplicacaoTController,
                        decoration: const InputDecoration(
                          labelText: 'Mín (L/ha)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _maxAplicacaoTController,
                        decoration: const InputDecoration(
                          labelText: 'Máx (L/ha)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _umTController,
                        decoration: const InputDecoration(
                          labelText: 'UM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Aerial Application
                const Text(
                  'Aplicação Aérea',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minAplicacaoAController,
                        decoration: const InputDecoration(
                          labelText: 'Mín (L/ha)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _maxAplicacaoAController,
                        decoration: const InputDecoration(
                          labelText: 'Máx (L/ha)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _umAController,
                        decoration: const InputDecoration(
                          labelText: 'UM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Intervals
                const Text(
                  'Intervalos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _intervaloController,
                        decoration: const InputDecoration(
                          labelText: 'Intervalo Segurança (dias)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _intervalo2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Intervalo Reentrada',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _epocaAplicacaoController,
                        decoration: const InputDecoration(
                          labelText: 'Época Aplicação',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveDiagnostico,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveDiagnostico() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final diagnostico = Diagnostico(
      id: widget.diagnostico?.id ?? const Uuid().v4(),
      defensivoId: widget.defensivoId ?? '',
      culturaId: _selectedCulturaId!,
      pragaId: _selectedPragaId!,
      dsMin: _dsMinController.text.isNotEmpty ? _dsMinController.text : null,
      dsMax: _dsMaxController.text.isNotEmpty ? _dsMaxController.text : null,
      um: _umController.text.isNotEmpty ? _umController.text : null,
      minAplicacaoT: _minAplicacaoTController.text.isNotEmpty
          ? _minAplicacaoTController.text
          : null,
      maxAplicacaoT: _maxAplicacaoTController.text.isNotEmpty
          ? _maxAplicacaoTController.text
          : null,
      umT: _umTController.text.isNotEmpty ? _umTController.text : null,
      minAplicacaoA: _minAplicacaoAController.text.isNotEmpty
          ? _minAplicacaoAController.text
          : null,
      maxAplicacaoA: _maxAplicacaoAController.text.isNotEmpty
          ? _maxAplicacaoAController.text
          : null,
      umA: _umAController.text.isNotEmpty ? _umAController.text : null,
      intervalo: _intervaloController.text.isNotEmpty
          ? _intervaloController.text
          : null,
      intervalo2: _intervalo2Controller.text.isNotEmpty
          ? _intervalo2Controller.text
          : null,
      epocaAplicacao: _epocaAplicacaoController.text.isNotEmpty
          ? _epocaAplicacaoController.text
          : null,
      createdAt: widget.diagnostico?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(diagnostico);
  }
}

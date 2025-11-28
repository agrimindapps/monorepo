import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/praga_info.dart';

/// Form widget for PragaInfo (Insects and Diseases)
class PragaInfoForm extends ConsumerStatefulWidget {
  final PragaInfo? initialInfo;
  final String pragaId;
  final void Function(PragaInfo info)? onSave;
  final bool readOnly;

  const PragaInfoForm({
    super.key,
    this.initialInfo,
    required this.pragaId,
    this.onSave,
    this.readOnly = false,
  });

  @override
  ConsumerState<PragaInfoForm> createState() => _PragaInfoFormState();
}

class _PragaInfoFormState extends ConsumerState<PragaInfoForm> {
  late final TextEditingController _descricaoController;
  late final TextEditingController _sintomasController;
  late final TextEditingController _bioecologiaController;
  late final TextEditingController _controleController;

  @override
  void initState() {
    super.initState();
    _descricaoController =
        TextEditingController(text: widget.initialInfo?.descricao ?? '');
    _sintomasController =
        TextEditingController(text: widget.initialInfo?.sintomas ?? '');
    _bioecologiaController =
        TextEditingController(text: widget.initialInfo?.bioecologia ?? '');
    _controleController =
        TextEditingController(text: widget.initialInfo?.controle ?? '');
  }

  @override
  void didUpdateWidget(PragaInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialInfo != oldWidget.initialInfo) {
      _descricaoController.text = widget.initialInfo?.descricao ?? '';
      _sintomasController.text = widget.initialInfo?.sintomas ?? '';
      _bioecologiaController.text = widget.initialInfo?.bioecologia ?? '';
      _controleController.text = widget.initialInfo?.controle ?? '';
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _sintomasController.dispose();
    _bioecologiaController.dispose();
    _controleController.dispose();
    super.dispose();
  }

  PragaInfo _buildInfo() {
    final now = DateTime.now();
    return PragaInfo(
      id: widget.initialInfo?.id ?? '',
      pragaId: widget.pragaId,
      descricao: _descricaoController.text.isNotEmpty
          ? _descricaoController.text
          : null,
      sintomas: _sintomasController.text.isNotEmpty
          ? _sintomasController.text
          : null,
      bioecologia: _bioecologiaController.text.isNotEmpty
          ? _bioecologiaController.text
          : null,
      controle: _controleController.text.isNotEmpty
          ? _controleController.text
          : null,
      createdAt: widget.initialInfo?.createdAt ?? now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações da Praga',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Campos específicos para insetos e doenças',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),

        // Descrição
        TextFormField(
          controller: _descricaoController,
          readOnly: widget.readOnly,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descrição',
            border: OutlineInputBorder(),
            helperText: 'Descrição geral da praga, características principais',
          ),
        ),
        const SizedBox(height: 16),

        // Sintomas
        TextFormField(
          controller: _sintomasController,
          readOnly: widget.readOnly,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Sintomas',
            border: OutlineInputBorder(),
            helperText: 'Sintomas observados nas plantas afetadas',
          ),
        ),
        const SizedBox(height: 16),

        // Bioecologia
        TextFormField(
          controller: _bioecologiaController,
          readOnly: widget.readOnly,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Bioecologia',
            border: OutlineInputBorder(),
            helperText: 'Ciclo de vida, comportamento, condições favoráveis',
          ),
        ),
        const SizedBox(height: 16),

        // Controle
        TextFormField(
          controller: _controleController,
          readOnly: widget.readOnly,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Métodos de Controle',
            border: OutlineInputBorder(),
            helperText: 'Controle químico, biológico, cultural, manejo integrado',
          ),
        ),

        // Save button
        if (!widget.readOnly && widget.onSave != null) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onSave!(_buildInfo());
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar Informações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// fitossanitario_dialog.dart
import 'package:flutter/material.dart';

import '../classes/fitossanitario_class.dart';
import '../repository/fitossanitarios_repository.dart';

class FitossanitarioDialog extends StatefulWidget {
  final FitossanitarioRepository repository;
  final Fitossanitario? fitossanitario;

  const FitossanitarioDialog({
    super.key,
    required this.repository,
    this.fitossanitario,
  });

  @override
  State<FitossanitarioDialog> createState() => _FitossanitarioDialogState();
}

class _FitossanitarioDialogState extends State<FitossanitarioDialog> {
  final _formKey = GlobalKey<FormState>();
  late Fitossanitario _fitossanitario;

  @override
  void initState() {
    super.initState();
    _fitossanitario = widget.fitossanitario ?? Fitossanitario();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.fitossanitario == null ? 'Adicionar' : 'Editar'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _fitossanitario.nomeComum,
              decoration: const InputDecoration(labelText: 'Nome Comum'),
              onChanged: (value) => _fitossanitario.nomeComum = value,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              initialValue: _fitossanitario.fabricante,
              decoration: const InputDecoration(labelText: 'Fabricante'),
              onChanged: (value) => _fitossanitario.fabricante = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (widget.fitossanitario == null) {
                await widget.repository.add(_fitossanitario);
              } else {
                await widget.repository.update(_fitossanitario);
              }
              if (!mounted) return;
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop(_fitossanitario);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../repository/database.dart';
import '../models/beber_agua_model.dart';

class AguaCadastroWidget extends StatefulWidget {
  final BeberAgua? registro;
  final Function(BeberAgua) onSave;

  const AguaCadastroWidget({
    super.key,
    this.registro,
    required this.onSave,
  });

  @override
  State<AguaCadastroWidget> createState() => _AguaCadastroWidgetState();
}

class _AguaCadastroWidgetState extends State<AguaCadastroWidget> {
  final _formKey = GlobalKey<FormState>();
  late BeberAgua _registro;
  final List<double> presetValues = [
    100.0,
    200.0,
    250.0,
    300.0,
    500.0,
    750.0,
    1000.0
  ];
  double _selectedQuantidade = 0.0;

  @override
  void initState() {
    super.initState();
    _registro = widget.registro ??
        BeberAgua(
          id: DatabaseRepository.generateIdReg(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dataRegistro: DateTime.now().millisecondsSinceEpoch,
          quantidade: 0,
          fkIdPerfil: '',
        );

    _selectedQuantidade = _registro.quantidade;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Atualizar o valor da quantidade
      _registro.quantidade = _selectedQuantidade;

      // Chamar a função de salvamento
      widget.onSave(_registro);

      // Fechar o diálogo
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.registro == null
                    ? 'Novo Registro de Água'
                    : 'Editar Registro de Água',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Selecione a quantidade: ${_selectedQuantidade.toInt()} ml',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Slider para ajuste fino
              Slider(
                value: _selectedQuantidade,
                min: 0,
                max: 1000,
                divisions: 20,
                label: _selectedQuantidade.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _selectedQuantidade = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              // Chips para valores predefinidos
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: presetValues.map((value) {
                  return ActionChip(
                    label: Text('${value.toInt()} ml'),
                    backgroundColor: _selectedQuantidade == value
                        ? Colors.blue[100]
                        : Colors.grey[200],
                    onPressed: () {
                      setState(() {
                        _selectedQuantidade = value;
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

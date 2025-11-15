// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../repository/database.dart';
import 'controllers/agua_controller.dart';
import 'models/beber_agua_model.dart';

Future<bool?> beberAguaCadastro(
  BuildContext context,
  BeberAgua? beberAgua,
) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  const Expanded(
                    child: Text(
                      'Beber Água',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 100),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: BeberAguaFormWidget(registro: beberAgua),
        ),
      );
    },
  );
}

class BeberAguaFormWidget extends ConsumerStatefulWidget {
  final BeberAgua? registro;

  const BeberAguaFormWidget({super.key, this.registro});

  @override
  ConsumerState<BeberAguaFormWidget> createState() =>
      _BeberAguaFormWidgetState();
}

class _BeberAguaFormWidgetState extends ConsumerState<BeberAguaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late BeberAgua _registro;

  @override
  void initState() {
    super.initState();
    _registro =
        widget.registro ??
        BeberAgua(
          id: DatabaseRepository.generateIdReg(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dataRegistro: DateTime.now().millisecondsSinceEpoch,
          quantidade: 0,
          fkIdPerfil: '',
        );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Salvar o registro usando o Riverpod controller
        if (widget.registro != null) {
          await ref
              .read(aguaNotifierProvider.notifier)
              .updateRegistro(_registro);
        } else {
          await ref.read(aguaNotifierProvider.notifier).addRegistro(_registro);
        }

        // Verificar se atingiu a meta diária
        final aguaState = await ref.read(aguaNotifierProvider.future);
        if (aguaState.todayProgress >= aguaState.dailyWaterGoal) {
          if (context.mounted) {
            _showCongratulations(context);
          }
        }

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCongratulations(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content: const Text(
          'Você atingiu sua meta diária de água! Continue assim!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateQuantidade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a quantidade';
    }
    if (double.tryParse(value) == null) {
      return 'Por favor, insira um número válido';
    }
    return null;
  }

  void _onSavedQuantidade(String? value) {
    setState(() {
      _registro = _registro.copyWith(quantidade: double.parse(value!));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.fromMillisecondsSinceEpoch(_registro.dataRegistro),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null &&
        pickedDate.millisecondsSinceEpoch != _registro.dataRegistro) {
      setState(() {
        _registro = _registro.copyWith(
          dataRegistro: pickedDate.millisecondsSinceEpoch,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildQuantidadeField(),
              const SizedBox(height: 20),
              _buildDataField(context),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 20),
              // _buildProgressPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantidadeField() {
    return Column(
      children: [
        TextFormField(
          initialValue: _registro.quantidade.toString(),
          decoration: const InputDecoration(labelText: 'Quantidade (ml)'),
          keyboardType: TextInputType.number,
          validator: _validateQuantidade,
          onSaved: _onSavedQuantidade,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _quickAddButton(200, '🥤 200ml'),
            _quickAddButton(300, '🥤 300ml'),
            _quickAddButton(500, '🍶 500ml'),
            _quickAddButton(1000, '🏺 1L'),
          ],
        ),
      ],
    );
  }

  Widget _quickAddButton(double amount, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _registro = _registro.copyWith(quantidade: amount);
          _formKey.currentState?.save();
        });
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
      child: Text(label),
    );
  }

  Widget _buildDataField(BuildContext context) {
    return TextFormField(
      initialValue: DateTime.fromMillisecondsSinceEpoch(
        _registro.dataRegistro,
      ).toLocal().toString().split(' ')[0],
      decoration: const InputDecoration(labelText: 'Data'),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(onPressed: _saveForm, child: const Text('Salvar'));
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../repository/database.dart';
import 'models/beber_agua_model.dart';
import 'repository/agua_repository.dart';

Future<bool?> beberAguaCadastro(
    BuildContext context, BeberAgua? beberAgua) async {
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
            const Divider()
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

class BeberAguaFormWidget extends StatefulWidget {
  final BeberAgua? registro;

  const BeberAguaFormWidget({super.key, this.registro});

  @override
  State<BeberAguaFormWidget> createState() => _BeberAguaFormWidgetState();
}

class _BeberAguaFormWidgetState extends State<BeberAguaFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late BeberAgua _registro;
  final AguaRepository _repository = AguaRepository();

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
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Salvar o registro
      if (widget.registro != null) {
        await _repository.updated(_registro);
      } else {
        await _repository.add(_registro);
      }

      // Atualizar o progresso diário
      await _repository.updateTodayProgress(_registro.quantidade);

      // Verificar se atingiu a meta diária
      final dailyGoal = await _repository.getDailyGoal();
      final todayProgress = await _repository.getTodayProgress();

      // Mostrar mensagem de parabéns se atingiu a meta
      if (todayProgress >= dailyGoal) {
        if (context.mounted) {
          _showCongratulations(context);
        }
      }

      Get.back();
    }
  }

  void _showCongratulations(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('Parabéns!'),
          ],
        ),
        content:
            const Text('Você atingiu sua meta diária de água! Continue assim!'),
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
    _registro.quantidade = double.parse(value!);
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
        _registro.dataRegistro = pickedDate.millisecondsSinceEpoch;
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
          _registro.quantidade = amount;
          _formKey.currentState?.save();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
      ),
      child: Text(label),
    );
  }

  Widget _buildDataField(BuildContext context) {
    return TextFormField(
      initialValue: DateTime.fromMillisecondsSinceEpoch(_registro.dataRegistro)
          .toLocal()
          .toString()
          .split(' ')[0],
      decoration: const InputDecoration(labelText: 'Data'),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveForm,
      child: const Text('Salvar'),
    );
  }

  Future<Widget> _buildProgressPreview() async {
    final todayProgress = await _repository.getTodayProgress();
    final dailyGoal = await _repository.getDailyGoal();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
                'Progresso Hoje: ${todayProgress.toInt()}ml / ${dailyGoal.toInt()}ml'),
            LinearProgressIndicator(
              value: todayProgress / dailyGoal,
              backgroundColor: Colors.blue[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

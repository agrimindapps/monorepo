// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../repository/database.dart';
import '../models/peso_model.dart';

class PesoFormPage extends StatefulWidget {
  final PesoModel? registro;
  final Function(PesoModel) onSave;

  const PesoFormPage({
    super.key,
    this.registro,
    required this.onSave,
  });

  @override
  State<PesoFormPage> createState() => _PesoFormPageState();
}

class _PesoFormPageState extends State<PesoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late PesoModel _localRegistro;

  @override
  void initState() {
    super.initState();
    _localRegistro = widget.registro ??
        PesoModel(
          id: DatabaseRepository.generateIdReg(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          dataRegistro: DateTime.now().millisecondsSinceEpoch,
          peso: 0.0,
          fkIdPerfil: '',
        );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Atualizar o timestamp se for um novo registro
      if (widget.registro == null) {
        _localRegistro.createdAt = DateTime.now().millisecondsSinceEpoch;
      }

      _localRegistro.updatedAt = DateTime.now().millisecondsSinceEpoch;

      widget.onSave(_localRegistro);
      Get.back();
    }
  }

  String? _validatePeso(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o peso';
    }
    if (double.tryParse(value) == null) {
      return 'Por favor, insira um número válido';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate:
          DateTime.fromMillisecondsSinceEpoch(_localRegistro.dataRegistro),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null &&
        pickedDate !=
            DateTime.fromMillisecondsSinceEpoch(_localRegistro.dataRegistro)) {
      setState(() {
        _localRegistro.dataRegistro = pickedDate.millisecondsSinceEpoch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.registro == null
                    ? 'Adicionar novo registro de peso'
                    : 'Editar registro de peso',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPesoField(),
              const SizedBox(height: 20),
              _buildDataField(context),
              const SizedBox(height: 20),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPesoField() {
    return TextFormField(
      initialValue:
          _localRegistro.peso > 0 ? _localRegistro.peso.toString() : '',
      decoration: const InputDecoration(
        labelText: 'Peso (kg)',
        hintText: 'Ex: 75.5',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validatePeso,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          _localRegistro.peso = double.parse(value);
        }
      },
    );
  }

  Widget _buildDataField(BuildContext context) {
    String formattedDate = '';
    if (_localRegistro.dataRegistro > 0) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(_localRegistro.dataRegistro);
      formattedDate = "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: formattedDate),
      decoration: const InputDecoration(
        labelText: 'Data',
        hintText: 'Selecione uma data',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

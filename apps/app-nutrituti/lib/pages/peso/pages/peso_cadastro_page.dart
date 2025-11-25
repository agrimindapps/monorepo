// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../repository/database.dart';
import '../controllers/peso_controller.dart';
import '../models/peso_model.dart';

class PesoFormWidget extends ConsumerStatefulWidget {
  final PesoModel? registro;

  const PesoFormWidget({super.key, this.registro});

  @override
  ConsumerState<PesoFormWidget> createState() => _PesoFormWidgetState();
}

class _PesoFormWidgetState extends ConsumerState<PesoFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late PesoModel _localRegistro;
  final _pesoController = TextEditingController();
  final _dataController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _initializeLocalRegistro();
    _setupControllers();
  }

  void _initializeLocalRegistro() {
    _localRegistro = widget.registro ??
        PesoModel(
          id: DatabaseRepository.generateIdReg(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          dataRegistro: DateTime.now().millisecondsSinceEpoch,
          peso: 0.0,
          fkIdPerfil: '', // Aqui você poderia obter o ID do perfil logado
        );
  }

  void _setupControllers() {
    _pesoController.text =
        _localRegistro.peso > 0 ? _localRegistro.peso.toString() : '';

    _dataController.text = _dateFormat.format(
        DateTime.fromMillisecondsSinceEpoch(_localRegistro.dataRegistro));
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (widget.registro != null) {
          await ref
              .read(pesoProvider.notifier)
              .updateRegistro(_localRegistro);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Registro de peso atualizado com sucesso!'),
                backgroundColor: Colors.green[100],
              ),
            );
            Navigator.pop(context);
          }
        } else {
          await ref
              .read(pesoProvider.notifier)
              .addRegistro(_localRegistro);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    const Text('Novo registro de peso adicionado com sucesso!'),
                backgroundColor: Colors.green[100],
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ocorreu um erro ao salvar os dados: ${e.toString()}'),
              backgroundColor: Colors.red[100],
            ),
          );
        }
      }
    }
  }

  String? _validatePeso(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o peso';
    }

    final peso = double.tryParse(value.replaceAll(',', '.'));
    if (peso == null) {
      return 'Por favor, insira um número válido';
    }

    if (peso <= 0 || peso > 500) {
      return 'Por favor, insira um peso válido (entre 0 e 500 kg)';
    }

    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate =
        DateTime.fromMillisecondsSinceEpoch(_localRegistro.dataRegistro);

    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('pt', 'BR'),
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Limita a data até o dia atual
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        _localRegistro.dataRegistro = pickedDate.millisecondsSinceEpoch;
        _dataController.text = _dateFormat.format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.registro != null
                    ? 'Editar Registro de Peso'
                    : 'Novo Registro de Peso',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildPesoField(),
              const SizedBox(height: 20),
              _buildDataField(context),
              const SizedBox(height: 24),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPesoField() {
    return TextFormField(
      controller: _pesoController,
      decoration: const InputDecoration(
        labelText: 'Peso (kg)',
        prefixIcon: Icon(Icons.fitness_center),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validatePeso,
      onSaved: (value) {
        if (value != null) {
          _localRegistro.peso = double.parse(value.replaceAll(',', '.'));
        }
      },
    );
  }

  Widget _buildDataField(BuildContext context) {
    return TextFormField(
      controller: _dataController,
      decoration: const InputDecoration(
        labelText: 'Data do Registro',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.cancel),
          label: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _saveForm,
        ),
      ],
    );
  }
}

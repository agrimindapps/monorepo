// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/22_despesas_model.dart';
import '../../../../repository/despesas_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../models/despesas_cadastro_form_model.dart';

class DespesaCadastroFormController extends GetxController {
  // Repositories
  final DespesasRepository _despesasRepository = DespesasRepository();
  final VeiculosRepository _veiculosRepository = VeiculosRepository();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Estados reativos
  final Rx<DespesaCadastroFormModel> _formModel =
      DespesaCadastroFormModel.initial(
    selectedVeiculoId: '',
  ).obs;

  final RxString veiculoId = ''.obs;
  final RxString tipo = ''.obs;
  final RxString descricao = ''.obs;
  final RxDouble odometro = 0.0.obs;
  final RxDouble valor = 0.0.obs;
  final RxInt data = 0.obs;
  final RxBool isLoading = false.obs;
  final Rx<VeiculoCar?> veiculo = Rx<VeiculoCar?>(null);

  DespesaCar? _originalDespesa;

  // Getters
  DespesaCadastroFormModel get formModel => _formModel.value;
  bool get isEditing => _originalDespesa != null;
  bool get hasVeiculo => veiculo.value != null;
  bool get isInitialized => veiculoId.value.isNotEmpty || veiculo.value != null;

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  void _initializeForm() {
    final selectedVeiculoId = _veiculosRepository.selectedVeiculoId;
    veiculoId.value = selectedVeiculoId;
    data.value = DateTime.now().millisecondsSinceEpoch;

    if (selectedVeiculoId.isNotEmpty) {
      carregarVeiculo(selectedVeiculoId);
    }
  }

  void initializeWithDespesa(DespesaCar? despesa) {
    if (despesa != null) {
      _originalDespesa = despesa;
      veiculoId.value = despesa.veiculoId;
      tipo.value = despesa.tipo;
      descricao.value = despesa.descricao;
      odometro.value = despesa.odometro;
      valor.value = despesa.valor;
      data.value = despesa.data;

      carregarVeiculo(despesa.veiculoId);
    }
    _updateFormModel();
  }

  void _updateFormModel() {
    _formModel.value = DespesaCadastroFormModel(
      veiculoId: veiculoId.value,
      tipo: tipo.value,
      descricao: descricao.value,
      odometro: odometro.value,
      valor: valor.value,
      data: data.value,
      isLoading: isLoading.value,
      veiculo: veiculo.value,
      originalDespesa: _originalDespesa,
    );
  }

  Future<void> carregarVeiculo(String veiculoId) async {
    final veiculoData = await _veiculosRepository.getVeiculoById(veiculoId);
    if (veiculoData != null) {
      veiculo.value = veiculoData;
      _updateFormModel();
    }
  }

  void setTipo(String novoTipo) {
    tipo.value = novoTipo;
    _updateFormModel();
  }

  void setDescricao(String novaDescricao) {
    descricao.value = novaDescricao;
    _updateFormModel();
  }

  void setOdometro(double novoOdometro) {
    odometro.value = novoOdometro;
    _updateFormModel();
  }

  void setValor(double novoValor) {
    valor.value = novoValor;
    _updateFormModel();
  }

  void setData(int novaData) {
    data.value = novaData;
    _updateFormModel();
  }

  void clearDescricao() {
    descricao.value = '';
    _updateFormModel();
  }

  void clearOdometro() {
    odometro.value = 0.0;
    _updateFormModel();
  }

  void clearValor() {
    valor.value = 0.0;
    _updateFormModel();
  }

  // Formatação
  String formatCurrency(double value) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    return value > 0 ? currencyFormat.format(value) : '';
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(date);
  }

  // Validações
  String? validateTipo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateValor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return 'Valor inválido';
    }

    if (number <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  String? validateOdometro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return 'Valor inválido';
    }

    if (number <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  // Date/Time pickers
  Future<void> pickDate(BuildContext context) async {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(data.value);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      helpText: 'Selecione a data',
      currentDate: DateTime.now(),
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      initialDatePickerMode: DatePickerMode.day,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      final newDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        currentDate.hour,
        currentDate.minute,
      );
      setData(newDateTime.millisecondsSinceEpoch);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final currentDate = DateTime.fromMillisecondsSinceEpoch(data.value);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      helpText: 'Selecione a hora',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      initialTime: TimeOfDay(
        hour: currentDate.hour,
        minute: currentDate.minute,
      ),
    );

    if (pickedTime != null) {
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setData(newDateTime.millisecondsSinceEpoch);
    }
  }

  // Submit
  Future<bool> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (isLoading.value) return false;

    isLoading.value = true;
    _updateFormModel();

    try {
      formKey.currentState!.save();

      final newDespesa = formModel.toDespesaCar();

      // Validar e atualizar odômetro se necessário
      final erroOdometro = await validarEAtualizarOdometro(
        veiculoId.value,
        odometro.value,
      );

      if (erroOdometro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erroOdometro)),
        );
        return false;
      }

      if (isEditing) {
        await updateDespesa(newDespesa);
      } else {
        await addDespesa(newDespesa);
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
      return false;
    } finally {
      isLoading.value = false;
      _updateFormModel();
    }
  }

  void parseAndSetValor(String value) {
    if (value.isNotEmpty) {
      final cleanValue = value.replaceAll('.', '').replaceAll(',', '.');
      setValor(double.tryParse(cleanValue) ?? 0.0);
    } else {
      setValor(0.0);
    }
  }

  void parseAndSetOdometro(String value) {
    if (value.isNotEmpty) {
      final cleanValue = value.replaceAll(',', '.');
      setOdometro(double.tryParse(cleanValue) ?? 0.0);
    } else {
      setOdometro(0.0);
    }
  }

  // ===================================
  // MIGRATED METHODS FROM EXTERNAL CONTROLLER
  // ===================================

  Future<String?> validarEAtualizarOdometro(
      String veiculoId, double novoOdometro) async {
    try {
      final veiculo = await _veiculosRepository.getVeiculoById(veiculoId);
      if (veiculo == null) return 'Veículo não encontrado';

      if (novoOdometro < veiculo.odometroAtual) {
        return 'O odômetro não pode ser menor que ${veiculo.odometroAtual.toStringAsFixed(1).replaceAll('.', ',')} km';
      }

      if (novoOdometro > veiculo.odometroAtual) {
        await _veiculosRepository.updateOdometroAtual(veiculoId, novoOdometro);
      }

      return null;
    } catch (e) {
      debugPrint('Controller Error: validarEAtualizarOdometro - $e');
      return 'Erro ao validar odômetro: $e';
    }
  }

  Future<DespesaCar?> getDespesaById(String id) async {
    try {
      return await _despesasRepository.getDespesaById(id);
    } catch (e) {
      debugPrint('Controller Error: getDespesaById - $e');
      return null;
    }
  }

  Future<bool> addDespesa(DespesaCar despesa) async {
    try {
      return await _despesasRepository.addDespesa(despesa);
    } catch (e) {
      debugPrint('Controller Error: addDespesa - $e');
      return false;
    }
  }

  Future<bool> updateDespesa(DespesaCar despesa) async {
    try {
      return await _despesasRepository.updateDespesa(despesa);
    } catch (e) {
      debugPrint('Controller Error: updateDespesa - $e');
      return false;
    }
  }

  Future<bool> deleteDespesa(DespesaCar despesa) async {
    try {
      return await _despesasRepository.deleteDespesa(despesa);
    } catch (e) {
      debugPrint('Controller Error: deleteDespesa - $e');
      return false;
    }
  }
}

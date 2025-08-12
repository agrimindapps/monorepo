// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/25_manutencao_model.dart';
import '../../../../repository/manutecoes_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../../../../services/maintenance_notification_manager.dart';
import '../models/manutencoes_cadastro_form_model.dart';

class ManutencoesCadastroFormController extends GetxController {
  final ManutencoesRepository _manutencoesRepository = ManutencoesRepository();
  final VeiculosRepository _veiculosRepository = VeiculosRepository();
  final MaintenanceNotificationManager _notificationManager =
      MaintenanceNotificationManager();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Estados reativos
  final Rx<ManutencoesCadastroFormModel> _formModel =
      ManutencoesCadastroFormModel.initial(
    selectedVeiculoId: '',
  ).obs;

  final RxString veiculoId = ''.obs;
  final RxString tipo = 'Preventiva'.obs;
  final RxString descricao = ''.obs;
  final RxDouble valor = 0.0.obs;
  final RxInt data = 0.obs;
  final RxInt odometro = 0.obs;
  final Rx<int?> proximaRevisao = Rx<int?>(null);
  final RxBool concluida = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<VeiculoCar?> veiculo = Rx<VeiculoCar?>(null);

  ManutencaoCar? _originalManutencao;

  // Getters
  ManutencoesCadastroFormModel get formModel => _formModel.value;
  bool get isEditing => _originalManutencao != null;
  bool get hasVeiculo => veiculo.value != null;

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

  void initializeWithManutencao(ManutencaoCar? manutencao) {
    if (manutencao != null) {
      _originalManutencao = manutencao;
      veiculoId.value = manutencao.veiculoId;
      tipo.value = manutencao.tipo;
      descricao.value = manutencao.descricao;
      valor.value = manutencao.valor;
      data.value = manutencao.data;
      odometro.value = manutencao.odometro;
      proximaRevisao.value = manutencao.proximaRevisao;
      concluida.value = manutencao.concluida;

      carregarVeiculo(manutencao.veiculoId);
    }
    _updateFormModel();
  }

  void _updateFormModel() {
    _formModel.value = ManutencoesCadastroFormModel(
      veiculoId: veiculoId.value,
      tipo: tipo.value,
      descricao: descricao.value,
      valor: valor.value,
      data: data.value,
      odometro: odometro.value,
      proximaRevisao: proximaRevisao.value,
      concluida: concluida.value,
      isLoading: isLoading.value,
      veiculo: veiculo.value,
      originalManutencao: _originalManutencao,
    );
  }

  Future<void> carregarVeiculo(String veiculoId) async {
    final veiculoData = await _veiculosRepository.getVeiculoById(veiculoId);
    if (veiculoData != null) {
      veiculo.value = veiculoData;
      _updateFormModel();
    }
  }

  // Setters
  void setTipo(String novoTipo) {
    tipo.value = novoTipo;
    _updateFormModel();
  }

  void setDescricao(String novaDescricao) {
    descricao.value = novaDescricao;
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

  void setOdometro(int novoOdometro) {
    odometro.value = novoOdometro;
    _updateFormModel();
  }

  void setProximaRevisao(int? novaProximaRevisao) {
    proximaRevisao.value = novaProximaRevisao;
    _updateFormModel();
  }

  void setConcluida(bool novaConcluida) {
    concluida.value = novaConcluida;
    _updateFormModel();
  }

  // Clear methods
  void clearDescricao() {
    descricao.value = '';
    _updateFormModel();
  }

  void clearValor() {
    valor.value = 0.0;
    _updateFormModel();
  }

  void clearOdometro() {
    odometro.value = 0;
    _updateFormModel();
  }

  void clearProximaRevisao() {
    proximaRevisao.value = null;
    _updateFormModel();
  }

  // Formatação
  String formatCurrency(double value) {
    return value > 0 ? value.toStringAsFixed(2).replaceAll('.', ',') : '';
  }

  String formatOdometro(int value) {
    return value > 0 ? value.toStringAsFixed(1).replaceAll('.', ',') : '';
  }

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(date);
  }

  String formatProximaRevisao(int? timestamp) {
    if (timestamp == null) return 'Não definida';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy').format(date);
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

  String? validateOdometro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final cleanValue = value.replaceAll(',', '.');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return 'Digite um número válido';
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

  Future<void> pickProximaRevisao(BuildContext context) async {
    DateTime? localData = proximaRevisao.value != null
        ? DateTime.fromMillisecondsSinceEpoch(proximaRevisao.value!)
        : null;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: localData ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      helpText: 'Selecione a data',
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setProximaRevisao(picked.millisecondsSinceEpoch);
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

      final success = await saveManutencao(
        id: _originalManutencao?.id,
        veiculoId: veiculoId.value,
        tipo: tipo.value,
        descricao: descricao.value,
        valor: valor.value,
        data: data.value,
        odometro: odometro.value,
        proximaRevisao: proximaRevisao.value,
        concluida: concluida.value,
      );

      if (!success) {
        throw Exception('Falha ao salvar a manutenção');
      }

      return true;
    } catch (e) {
      debugPrint('Erro ao salvar manutenção: $e');
      return false;
    } finally {
      isLoading.value = false;
      _updateFormModel();
    }
  }

  // Parse methods
  void parseAndSetValor(String value) {
    if (value.isNotEmpty) {
      final cleanValue = value.replaceAll(',', '.');
      setValor(double.tryParse(cleanValue) ?? 0.0);
    } else {
      setValor(0.0);
    }
  }

  void parseAndSetOdometro(String value) {
    if (value.isNotEmpty) {
      final cleanValue = value.replaceAll(',', '.');
      setOdometro((double.tryParse(cleanValue) ?? 0).round());
    } else {
      setOdometro(0);
    }
  }

  // Métodos migrados do ManutencoesCadastroController
  Future<ManutencaoCar?> getManutencaoById(String id) async {
    try {
      return await _manutencoesRepository.getManutencaoById(id);
    } catch (e) {
      debugPrint('Controller Error: getManutencaoById - $e');
      return null;
    }
  }

  Future<bool> saveManutencao({
    required String? id,
    required String veiculoId,
    required String tipo,
    required String descricao,
    required double valor,
    required int data,
    required int odometro,
    required int? proximaRevisao,
    required bool concluida,
  }) async {
    try {
      final manutencao = ManutencaoCar(
        id: id ?? const Uuid().v4(),
        createdAt: id == null
            ? DateTime.now().millisecondsSinceEpoch
            : _originalManutencao?.createdAt ??
                DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        veiculoId: veiculoId,
        tipo: tipo,
        descricao: descricao,
        valor: valor,
        data: data,
        odometro: odometro,
        proximaRevisao: proximaRevisao,
        concluida: concluida,
      );

      bool success;
      if (id != null) {
        success = await updateManutencao(manutencao);
      } else {
        success = await addManutencao(manutencao);
      }

      if (success) {
        await _gerenciarNotificacoesManutencao(manutencao);
      }

      return success;
    } catch (e) {
      debugPrint('Controller Error: saveManutencao - $e');
      return false;
    }
  }

  Future<bool> addManutencao(ManutencaoCar manutencao) async {
    try {
      return await _manutencoesRepository.addManutencao(manutencao);
    } catch (e) {
      debugPrint('Controller Error: addManutencao - $e');
      return false;
    }
  }

  Future<bool> updateManutencao(ManutencaoCar manutencao) async {
    try {
      return await _manutencoesRepository.updateManutencao(manutencao);
    } catch (e) {
      debugPrint('Controller Error: updateManutencao - $e');
      return false;
    }
  }

  Future<bool> deleteManutencao(ManutencaoCar manutencao) async {
    try {
      return await _manutencoesRepository.deleteManutencao(manutencao);
    } catch (e) {
      debugPrint('Controller Error: deleteManutencao - $e');
      return false;
    }
  }

  Future<void> _gerenciarNotificacoesManutencao(
      ManutencaoCar manutencao) async {
    try {
      if (manutencao.proximaRevisao != null) {
        await _notificationManager.agendarNotificacoesManutencao(manutencao);
      } else {
        await _notificationManager
            .cancelarNotificacoesManutencao(manutencao.id);
      }
    } catch (e) {
      debugPrint('Controller Error: _gerenciarNotificacoesManutencao - $e');
    }
  }
}

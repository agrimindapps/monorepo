// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/15_medicamento_model.dart';
import '../../../../repository/medicamento_repository.dart';
import '../../../../widgets/success_dialog_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/medicamento_cadastro_model.dart';

class MedicamentoCadastroController extends GetxController {
  final MedicamentoRepository _repository;
  final _animalController = Get.find<AnimalPageController>();
  final _model = MedicamentoCadastroModel.empty('').obs;
  final _isRepositoryLoading = false.obs;

  MedicamentoCadastroController({MedicamentoRepository? repository})
      : _repository = repository ?? MedicamentoRepository();

  static Future<MedicamentoCadastroController> initialize() async {
    await MedicamentoRepository.initialize();
    final controller = MedicamentoCadastroController();
    Get.put(controller);
    return controller;
  }

  MedicamentoCadastroModel get model => _model.value;
  bool get isRepositoryLoading => _isRepositoryLoading.value;
  bool get isLoading => model.isLoading;
  String? get errorMessage => model.errorMessage;
  bool get hasError => model.hasError;
  bool get isValid => model.isValid;

  void initializeForEditing(MedicamentoVet medicamento) {
    _model.value = MedicamentoCadastroModel.fromMedicamento(medicamento);
  }

  void initializeForCreation() {
    _model.value =
        MedicamentoCadastroModel.empty(_animalController.selectedAnimalId);
  }

  void setAnimalId(String value) {
    _model.update((model) {
      model?.setAnimalId(value);
    });
  }

  void setNomeMedicamento(String value) {
    _model.update((model) {
      model?.setNomeMedicamento(value);
    });
  }

  void setDosagem(String value) {
    _model.update((model) {
      model?.setDosagem(value);
    });
  }

  void setFrequencia(String value) {
    _model.update((model) {
      model?.setFrequencia(value);
    });
  }

  void setDuracao(String value) {
    _model.update((model) {
      model?.setDuracao(value);
    });
  }

  void setInicioTratamento(DateTime date) {
    _model.update((model) {
      model?.setInicioTratamento(date.millisecondsSinceEpoch);
    });
  }

  void setFimTratamento(DateTime date) {
    _model.update((model) {
      model?.setFimTratamento(date.millisecondsSinceEpoch);
    });
  }

  void setObservacoes(String? value) {
    _model.update((model) {
      model?.setObservacoes(value);
    });
  }

  void setLoading(bool value) {
    _model.update((model) {
      model?.setLoading(value);
    });
  }

  void setError(String? value) {
    _model.update((model) {
      model?.setError(value);
    });
  }

  void clearError() {
    _model.update((model) {
      model?.clearError();
    });
  }

  String? validateFrequencia(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 3) {
      return 'Frequência muito curta';
    }
    return null;
  }

  String? validateNomeMedicamento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    if (value.length < 2) {
      return 'Nome muito curto';
    }
    return null;
  }

  String? validateDosagem(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validateDuracao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  bool validateDateRange(DateTime inicio, DateTime fim) {
    return inicio.isBefore(fim) || inicio.isAtSameMomentAs(fim);
  }

  DateTime getDefaultEndDate(DateTime startDate) {
    return startDate.add(const Duration(days: 7));
  }

  DateTime getDefaultStartDate() {
    return DateTime.now();
  }

  Future<bool> addMedicamento(MedicamentoVet medicamento) async {
    _isRepositoryLoading.value = true;
    try {
      final result = await _repository.addMedicamento(medicamento);
      return result;
    } catch (e) {
      debugPrint('Error adding medicamento: $e');
      return false;
    } finally {
      _isRepositoryLoading.value = false;
    }
  }

  Future<bool> updateMedicamento(MedicamentoVet medicamento) async {
    _isRepositoryLoading.value = true;
    try {
      final result = await _repository.updateMedicamento(medicamento);
      return result;
    } catch (e) {
      debugPrint('Error updating medicamento: $e');
      return false;
    } finally {
      _isRepositoryLoading.value = false;
    }
  }

  Future<MedicamentoVet?> getMedicamentoById(String id) async {
    try {
      return await _repository.getMedicamentoById(id);
    } catch (e) {
      debugPrint('Error getting medicamento by ID: $e');
      return null;
    }
  }

  DateTime get inicioTratamentoDate =>
      DateTime.fromMillisecondsSinceEpoch(model.inicioTratamento);

  DateTime get fimTratamentoDate =>
      DateTime.fromMillisecondsSinceEpoch(model.fimTratamento);

  Future<bool> submitForm(
      BuildContext context, MedicamentoVet? originalMedicamento) async {
    if (!isValid) {
      setError('Por favor, preencha todos os campos obrigatórios');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final medicamento = _createMedicamento(originalMedicamento);
      bool result;

      if (originalMedicamento != null) {
        result = await updateMedicamento(medicamento);
      } else {
        result = await addMedicamento(medicamento);
      }

      if (!result) {
        throw Exception('Não foi possível salvar o medicamento');
      }

      if (context.mounted) {
        await _showSuccessDialog(context);
      }
      return true;
    } catch (e) {
      setError('Erro ao salvar: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  MedicamentoVet _createMedicamento(MedicamentoVet? originalMedicamento) {
    return MedicamentoVet(
      id: originalMedicamento?.id ?? const Uuid().v4(),
      createdAt: originalMedicamento?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: false,
      needsSync: originalMedicamento?.needsSync ?? true,
      version: originalMedicamento == null ? 1 : originalMedicamento.version + 1,
      lastSyncAt: originalMedicamento?.lastSyncAt,
      animalId: model.animalId,
      nomeMedicamento: model.nomeMedicamento,
      dosagem: model.dosagem,
      frequencia: model.frequencia,
      duracao: model.duracao,
      inicioTratamento: model.inicioTratamento,
      fimTratamento: model.fimTratamento,
      observacoes: model.observacoes,
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await SuccessDialog.show(
      context: context,
      message: 'Medicamento salvo com sucesso!',
      onClosed: () => Navigator.of(context).pop(true),
    );
  }

  void showErrorSnackBar(BuildContext context) {
    if (hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

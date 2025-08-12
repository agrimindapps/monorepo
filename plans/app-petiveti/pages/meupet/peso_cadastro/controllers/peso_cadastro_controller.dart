// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../core/navigation/route_manager.dart';
import '../../../../models/17_peso_model.dart';
import '../../../../repository/peso_repository.dart';
import '../../../../widgets/success_dialog_widget.dart';
import '../../animal_page/controllers/animal_page_controller.dart';
import '../models/peso_cadastro_model.dart';

class PesoCadastroController extends GetxController {
  final PesoRepository _repository;
  final _animalController = Get.find<AnimalPageController>();
  final _model = PesoCadastroModel.empty('').obs;
  final Function(PesoAnimal)? onPesoSaved;

  PesoCadastroController({
    PesoRepository? repository,
    this.onPesoSaved,
  }) : _repository = repository ?? PesoRepository();

  static Future<PesoCadastroController> initialize({
    Function(PesoAnimal)? onPesoSaved,
  }) async {
    await PesoRepository.initialize();
    final controller = PesoCadastroController(onPesoSaved: onPesoSaved);
    Get.put(controller);
    return controller;
  }

  PesoCadastroModel get model => _model.value;
  String get animalId => model.animalId;
  int get dataPesagem => model.dataPesagem;
  double get peso => model.peso;
  String get observacoes => model.observacoes;
  bool get isLoading => model.isLoading;
  String? get errorMessage => model.errorMessage;
  bool get hasError => model.hasError;
  bool get isValid => model.isValid;
  DateTime get dataPesagemDate => model.dataPesagemDate;
  String get selectedAnimalId => _animalController.selectedAnimalId;

  void initializeForEditing(PesoAnimal peso) {
    _model.value = PesoCadastroModel.fromPeso(peso);
  }

  void initializeForCreation() {
    _model.value = PesoCadastroModel.empty(selectedAnimalId);
  }

  void resetForm() {
    _model.update((model) {
      model?.resetForm(selectedAnimalId);
    });
  }

  void loadFromPeso(PesoAnimal peso) {
    _model.update((model) {
      model?.loadFromPeso(peso);
    });
  }

  void setAnimalId(String value) {
    _model.update((model) {
      model?.setAnimalId(value);
    });
  }

  void setDataPesagem(int value) {
    _model.update((model) {
      model?.setDataPesagem(value);
    });
  }

  void setPeso(double value) {
    _model.update((model) {
      model?.setPeso(value);
    });
  }

  void setObservacoes(String value) {
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

  String? validatePesoInput(double? value) {
    return model.validatePesoInput(value);
  }

  Future<bool> savePeso(BuildContext context,
      {PesoAnimal? existingPeso}) async {
    if (!isValid) {
      setError('Por favor, preencha todos os campos obrigatórios');
      return false;
    }

    setLoading(true);
    clearError();

    try {
      final newPeso = PesoAnimal(
        id: existingPeso?.id ?? const Uuid().v4(),
        createdAt:
            existingPeso?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
        needsSync: existingPeso?.needsSync ?? true,
        version: existingPeso == null ? 1 : existingPeso.version + 1,
        lastSyncAt: existingPeso?.lastSyncAt,
        animalId: selectedAnimalId,
        peso: model.peso,
        dataPesagem: model.dataPesagem,
        observacoes: model.observacoes.isEmpty ? null : model.observacoes,
      );

      bool result;
      if (existingPeso == null) {
        result = await _repository.addPeso(newPeso);
      } else {
        result = await _repository.updatePeso(newPeso);
      }

      if (!result) {
        throw Exception('Não foi possível salvar o registro de peso');
      }

      if (onPesoSaved != null) {
        onPesoSaved!(newPeso);
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

  Future<void> _showSuccessDialog(BuildContext context) async {
    await SuccessDialog.show(
      context: context,
      message: 'Registro de peso salvo com sucesso!',
      onClosed: () => RouteManager.instance.back(result: true),
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

  String formatDateToString(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  bool isValidPeso(double peso) {
    return peso > 0 && peso <= 500;
  }

  bool validateForm() {
    if (selectedAnimalId.isEmpty) {
      debugPrint('Erro: Nenhum animal selecionado');
      return false;
    }
    if (model.peso <= 0) {
      debugPrint('Erro: Peso deve ser maior que zero');
      return false;
    }
    if (model.peso > 500) {
      debugPrint('Erro: Peso parece muito alto');
      return false;
    }
    return true;
  }

}

// Project imports:
import '../../../../models/17_peso_model.dart';

class PesoCadastroModel {
  String animalId;
  int dataPesagem;
  double peso;
  String observacoes;
  bool isLoading;
  String? errorMessage;

  PesoCadastroModel({
    this.animalId = '',
    required this.dataPesagem,
    this.peso = 0.0,
    this.observacoes = '',
    this.isLoading = false,
    this.errorMessage,
  });

  PesoCadastroModel.fromPeso(PesoAnimal pesoAnimal)
      : animalId = pesoAnimal.animalId,
        dataPesagem = pesoAnimal.dataPesagem,
        peso = pesoAnimal.peso,
        observacoes = pesoAnimal.observacoes ?? '',
        isLoading = false,
        errorMessage = null;

  PesoCadastroModel.empty(String selectedAnimalId)
      : animalId = selectedAnimalId,
        dataPesagem = DateTime.now().millisecondsSinceEpoch,
        peso = 0.0,
        observacoes = '',
        isLoading = false,
        errorMessage = null;

  PesoCadastroModel copyWith({
    String? animalId,
    int? dataPesagem,
    double? peso,
    String? observacoes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PesoCadastroModel(
      animalId: animalId ?? this.animalId,
      dataPesagem: dataPesagem ?? this.dataPesagem,
      peso: peso ?? this.peso,
      observacoes: observacoes ?? this.observacoes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  void setAnimalId(String value) {
    animalId = value;
  }

  void setDataPesagem(int value) {
    dataPesagem = value;
  }

  void setPeso(double value) {
    peso = value;
  }

  void setObservacoes(String value) {
    observacoes = value;
  }

  void setLoading(bool value) {
    isLoading = value;
  }

  void setError(String? value) {
    errorMessage = value;
  }

  void clearError() {
    errorMessage = null;
  }

  void resetForm(String selectedAnimalId) {
    animalId = selectedAnimalId;
    dataPesagem = DateTime.now().millisecondsSinceEpoch;
    peso = 0.0;
    observacoes = '';
    isLoading = false;
    errorMessage = null;
  }

  void loadFromPeso(PesoAnimal pesoAnimal) {
    animalId = pesoAnimal.animalId;
    dataPesagem = pesoAnimal.dataPesagem;
    peso = pesoAnimal.peso;
    observacoes = pesoAnimal.observacoes ?? '';
    isLoading = false;
    errorMessage = null;
  }

  bool get hasError => errorMessage != null;
  
  bool get isValid => 
      animalId.isNotEmpty &&
      peso > 0;

  DateTime get dataPesagemDate => DateTime.fromMillisecondsSinceEpoch(dataPesagem);

  String? validatePesoInput(double? value) {
    if (value == null || value <= 0) {
      return 'O peso deve ser maior que zero';
    }
    if (value > 500) {
      return 'O peso deve ser menor que 500kg';
    }
    return null;
  }
}

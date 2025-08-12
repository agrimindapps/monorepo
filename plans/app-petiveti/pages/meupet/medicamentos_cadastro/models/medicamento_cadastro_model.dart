// Project imports:
import '../../../../models/15_medicamento_model.dart';

class MedicamentoCadastroModel {
  String animalId;
  String nomeMedicamento;
  String dosagem;
  String frequencia;
  String duracao;
  int inicioTratamento;
  int fimTratamento;
  String? observacoes;
  bool isLoading;
  String? errorMessage;

  MedicamentoCadastroModel({
    this.animalId = '',
    this.nomeMedicamento = '',
    this.dosagem = '',
    this.frequencia = '',
    this.duracao = '',
    required this.inicioTratamento,
    required this.fimTratamento,
    this.observacoes,
    this.isLoading = false,
    this.errorMessage,
  });

  MedicamentoCadastroModel.fromMedicamento(MedicamentoVet medicamento)
      : animalId = medicamento.animalId,
        nomeMedicamento = medicamento.nomeMedicamento,
        dosagem = medicamento.dosagem,
        frequencia = medicamento.frequencia,
        duracao = medicamento.duracao,
        inicioTratamento = medicamento.inicioTratamento,
        fimTratamento = medicamento.fimTratamento,
        observacoes = medicamento.observacoes,
        isLoading = false,
        errorMessage = null;

  MedicamentoCadastroModel.empty(String selectedAnimalId)
      : animalId = selectedAnimalId,
        nomeMedicamento = '',
        dosagem = '',
        frequencia = '',
        duracao = '',
        inicioTratamento = DateTime.now().millisecondsSinceEpoch,
        fimTratamento = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        observacoes = '',
        isLoading = false,
        errorMessage = null;

  MedicamentoCadastroModel copyWith({
    String? animalId,
    String? nomeMedicamento,
    String? dosagem,
    String? frequencia,
    String? duracao,
    int? inicioTratamento,
    int? fimTratamento,
    String? observacoes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MedicamentoCadastroModel(
      animalId: animalId ?? this.animalId,
      nomeMedicamento: nomeMedicamento ?? this.nomeMedicamento,
      dosagem: dosagem ?? this.dosagem,
      frequencia: frequencia ?? this.frequencia,
      duracao: duracao ?? this.duracao,
      inicioTratamento: inicioTratamento ?? this.inicioTratamento,
      fimTratamento: fimTratamento ?? this.fimTratamento,
      observacoes: observacoes ?? this.observacoes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  void setAnimalId(String value) {
    animalId = value;
  }

  void setNomeMedicamento(String value) {
    nomeMedicamento = value;
  }

  void setDosagem(String value) {
    dosagem = value;
  }

  void setFrequencia(String value) {
    frequencia = value;
  }

  void setDuracao(String value) {
    duracao = value;
  }

  void setInicioTratamento(int value) {
    inicioTratamento = value;
    if (inicioTratamento > fimTratamento) {
      fimTratamento = inicioTratamento;
    }
  }

  void setFimTratamento(int value) {
    fimTratamento = value;
  }

  void setObservacoes(String? value) {
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

  bool get hasError => errorMessage != null;
  
  bool get isValid => 
      animalId.isNotEmpty &&
      nomeMedicamento.isNotEmpty &&
      dosagem.isNotEmpty &&
      frequencia.isNotEmpty &&
      duracao.isNotEmpty;
}

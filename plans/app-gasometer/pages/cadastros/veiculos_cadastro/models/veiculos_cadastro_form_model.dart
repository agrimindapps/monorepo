// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/enums.dart';

/// Model responsável pelo gerenciamento dos dados do formulário de cadastro
///
/// Centraliza o estado reativo do formulário e fornece métodos para
/// manipulação e validação dos dados de entrada.
class VeiculosCadastroFormModel {
  final RxString _marca = ''.obs;
  final RxString _modelo = ''.obs;
  final RxInt _ano = 0.obs;
  final RxString _placa = ''.obs;
  final RxDouble _odometroInicial = 0.0.obs;
  final RxString _cor = ''.obs;
  final RxInt _combustivel = 0.obs;
  final RxString _renavam = ''.obs;
  final RxString _chassi = ''.obs;
  final Rx<TipoCombustivel> _tipoCombustivel =
      TipoCombustivel.biCombustivel.obs;
  final RxString _unidade = TipoCombustivel.biCombustivel.unidade.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _possuiLancamentos = false.obs;
  final RxString _foto = ''.obs;

  // Getters para acessar os valores
  String get marca => _marca.value;
  String get modelo => _modelo.value;
  int get ano => _ano.value;
  String get placa => _placa.value;
  double get odometroInicial => _odometroInicial.value;
  String get cor => _cor.value;
  int get combustivel => _combustivel.value;
  String get renavam => _renavam.value;
  String get chassi => _chassi.value;
  TipoCombustivel get tipoCombustivel => _tipoCombustivel.value;
  String get unidade => _unidade.value;
  bool get isLoading => _isLoading.value;
  bool get possuiLancamentos => _possuiLancamentos.value;
  String get foto => _foto.value;

  // Getters reativos para binding na UI
  RxString get marcaRx => _marca;
  RxString get modeloRx => _modelo;
  RxInt get anoRx => _ano;
  RxString get placaRx => _placa;
  RxDouble get odometroInicialRx => _odometroInicial;
  RxString get corRx => _cor;
  RxInt get combustivelRx => _combustivel;
  RxString get renavamRx => _renavam;
  RxString get chassiRx => _chassi;
  Rx<TipoCombustivel> get tipoCombustivelRx => _tipoCombustivel;
  RxString get unidadeRx => _unidade;
  RxBool get isLoadingRx => _isLoading;
  RxBool get possuiLancamentosRx => _possuiLancamentos;
  RxString get fotoRx => _foto;

  // Setters para atualizar os valores
  void setMarca(String value) => _marca.value = value;
  void setModelo(String value) => _modelo.value = value;
  void setAno(int value) => _ano.value = value;
  void setPlaca(String value) => _placa.value = value.toUpperCase();
  void setOdometroInicial(double value) => _odometroInicial.value = value;
  void setCor(String value) => _cor.value = value;
  void setCombustivel(int value) => _combustivel.value = value;
  void setRenavam(String value) => _renavam.value = value;
  void setChassi(String value) => _chassi.value = value.toUpperCase();

  void setTipoCombustivel(TipoCombustivel value) {
    _tipoCombustivel.value = value;
    _combustivel.value = value.index;
    _unidade.value = value.unidade;
  }

  void setIsLoading(bool value) => _isLoading.value = value;
  void setPossuiLancamentos(bool value) => _possuiLancamentos.value = value;
  void setFoto(String? value) => _foto.value = value ?? '';

  // Inicializa formulário com dados de veículo existente
  void initializeFromVeiculo(VeiculoCar veiculo) {
    _marca.value = veiculo.marca;
    _modelo.value = veiculo.modelo;
    _ano.value = veiculo.ano;
    _placa.value = veiculo.placa;
    _odometroInicial.value = veiculo.odometroInicial;
    _cor.value = veiculo.cor;
    _combustivel.value = veiculo.combustivel;
    _renavam.value = veiculo.renavan;
    _chassi.value = veiculo.chassi;
    _foto.value = veiculo.foto ?? '';
    _tipoCombustivel.value = TipoCombustivel.values[_combustivel.value];
    _unidade.value = _tipoCombustivel.value.unidade;
  }

  // Reseta formulário para estado inicial
  void resetForm() {
    _marca.value = '';
    _modelo.value = '';
    _ano.value = 0;
    _placa.value = '';
    _odometroInicial.value = 0.0;
    _cor.value = '';
    _combustivel.value = 0;
    _renavam.value = '';
    _chassi.value = '';
    _tipoCombustivel.value = TipoCombustivel.biCombustivel;
    _unidade.value = TipoCombustivel.biCombustivel.unidade;
    _isLoading.value = false;
    _possuiLancamentos.value = false;
    _foto.value = '';
  }

  // Create VeiculoCar object from form data
  VeiculoCar toVeiculoCar({
    String? id,
    int? createdAt,
    int? updatedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return VeiculoCar(
      id: id ?? '',
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      marca: _marca.value,
      modelo: _modelo.value,
      ano: _ano.value,
      placa: _placa.value,
      odometroInicial: _odometroInicial.value,
      cor: _cor.value,
      combustivel: _combustivel.value,
      renavan: _renavam.value,
      chassi: _chassi.value,
      foto: _foto.value.isEmpty ? null : _foto.value,
    );
  }

  // Verifica se o formulário é válido (validação básica)
  bool get isValid {
    return _marca.value.isNotEmpty &&
        _modelo.value.isNotEmpty &&
        _ano.value > 0 &&
        _cor.value.isNotEmpty;
  }

  // Converte dados do formulário para Map (debug ou serialização)
  Map<String, dynamic> toMap() {
    return {
      'marca': _marca.value,
      'modelo': _modelo.value,
      'ano': _ano.value,
      'placa': _placa.value,
      'odometroInicial': _odometroInicial.value,
      'cor': _cor.value,
      'combustivel': _combustivel.value,
      'renavam': _renavam.value,
      'chassi': _chassi.value,
      'tipoCombustivel': _tipoCombustivel.value.toString(),
      'unidade': _unidade.value,
      'isLoading': _isLoading.value,
      'possuiLancamentos': _possuiLancamentos.value,
      'foto': _foto.value,
    };
  }
}

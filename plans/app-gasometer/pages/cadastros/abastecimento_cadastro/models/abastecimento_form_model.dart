// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/23_abastecimento_model.dart';
import '../../../../database/enums.dart';

class AbastecimentoFormModel {
  String veiculoId;
  double litros;
  double valorPorLitro;
  double valorTotal;
  int odometro;
  int data;
  bool tanqueCheio;
  String posto;
  String observacao;
  TipoCombustivel tipoCombustivel;
  String unidade;
  bool isLoading;
  VeiculoCar? veiculo;

  AbastecimentoFormModel({
    required this.veiculoId,
    this.litros = 0.0,
    this.valorPorLitro = 0.0,
    this.valorTotal = 0.0,
    this.odometro = 0,
    required this.data,
    this.tanqueCheio = false,
    this.posto = '',
    this.observacao = '',
    this.tipoCombustivel = TipoCombustivel.biCombustivel,
    required this.unidade,
    this.isLoading = false,
    this.veiculo,
  });

  factory AbastecimentoFormModel.fromAbastecimento(
      AbastecimentoCar abastecimento) {
    return AbastecimentoFormModel(
      veiculoId: abastecimento.veiculoId,
      litros: abastecimento.litros,
      valorPorLitro: abastecimento.precoPorLitro,
      valorTotal: abastecimento.valorTotal,
      odometro: abastecimento.odometro.toInt(),
      data: abastecimento.data,
      tanqueCheio: abastecimento.tanqueCheio ?? false,
      posto: abastecimento.posto ?? '',
      observacao: abastecimento.observacao ?? '',
      tipoCombustivel:
          TipoCombustivel.values[abastecimento.tipoCombustivel ?? 0],
      unidade:
          TipoCombustivel.values[abastecimento.tipoCombustivel ?? 0].unidade,
    );
  }

  factory AbastecimentoFormModel.initial(String selectedVeiculoId) {
    return AbastecimentoFormModel(
      veiculoId: selectedVeiculoId,
      data: DateTime.now().millisecondsSinceEpoch,
      tipoCombustivel: TipoCombustivel.biCombustivel,
      unidade: TipoCombustivel.biCombustivel.unidade,
    );
  }

  AbastecimentoFormModel copyWith({
    String? veiculoId,
    double? litros,
    double? valorPorLitro,
    double? valorTotal,
    int? odometro,
    int? data,
    bool? tanqueCheio,
    String? posto,
    String? observacao,
    TipoCombustivel? tipoCombustivel,
    String? unidade,
    bool? isLoading,
    VeiculoCar? veiculo,
  }) {
    return AbastecimentoFormModel(
      veiculoId: veiculoId ?? this.veiculoId,
      litros: litros ?? this.litros,
      valorPorLitro: valorPorLitro ?? this.valorPorLitro,
      valorTotal: valorTotal ?? this.valorTotal,
      odometro: odometro ?? this.odometro,
      data: data ?? this.data,
      tanqueCheio: tanqueCheio ?? this.tanqueCheio,
      posto: posto ?? this.posto,
      observacao: observacao ?? this.observacao,
      tipoCombustivel: tipoCombustivel ?? this.tipoCombustivel,
      unidade: unidade ?? this.unidade,
      isLoading: isLoading ?? this.isLoading,
      veiculo: veiculo ?? this.veiculo,
    );
  }

  bool get isValid {
    return veiculoId.isNotEmpty &&
        litros > 0 &&
        valorPorLitro > 0 &&
        odometro > 0 &&
        data > 0;
  }
}

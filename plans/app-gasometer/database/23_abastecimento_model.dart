// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../core/models/base_model.dart';

part '23_abastecimento_model.g.dart';

@HiveType(typeId: 23)
class AbastecimentoCar extends BaseModel {
  @HiveField(7)
  String veiculoId;

  @HiveField(8)
  int data;

  @HiveField(9)
  double odometro;

  @HiveField(10)
  double litros;

  @HiveField(11)
  double valorTotal;

  @HiveField(12)
  bool? tanqueCheio;

  @HiveField(13)
  double precoPorLitro;

  @HiveField(14)
  String? posto;

  @HiveField(15)
  String? observacao;

  @HiveField(16)
  int tipoCombustivel;

  AbastecimentoCar({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.needsSync,
    super.lastSyncAt,
    super.version,
    required this.veiculoId,
    required this.data,
    required this.odometro,
    required this.litros,
    required this.valorTotal,
    this.tanqueCheio,
    required this.precoPorLitro,
    this.posto,
    this.observacao,
    required this.tipoCombustivel,
  });

  /// Converte o objeto para um mapa
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()
      ..addAll({
        'veiculoId': veiculoId,
        'data': data,
        'odometro': odometro,
        'litros': litros,
        'valorTotal': valorTotal,
        'tanqueCheio': tanqueCheio,
        'precoPorLitro': precoPorLitro,
        'posto': posto,
        'observacao': observacao,
        'tipoCombustivel': tipoCombustivel,
      });
  }

  /// Cria uma instância de `AbastecimentoCar` a partir de um mapa
  factory AbastecimentoCar.fromMap(Map<String, dynamic> map) {
    return AbastecimentoCar(
      id: map['id'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      veiculoId: map['veiculoId'] ?? '',
      data: map['data'] ?? 0,
      odometro: map['odometro'] ?? 0.0,
      litros: map['litros'] ?? 0.0,
      valorTotal: map['valorTotal'] ?? 0.0,
      tanqueCheio: map['tanqueCheio'] ?? false,
      precoPorLitro: map['precoPorLitro'] ?? 0.0,
      posto: map['posto'] ?? '',
      observacao: map['observacao'] ?? '',
      tipoCombustivel: map['tipoCombustivel'] ?? 0,
    );
  }

  // Metodo toJson
  Map<String, dynamic> toJson() => toMap();

  /// Calcula o consumo médio em km/l
  /// 
  /// NOTA: Este método não pode calcular consumo real pois precisa do odômetro anterior.
  /// Use ConsumptionCalculatorService.calculateConsumptionKmL() para cálculos corretos.
  /// 
  /// @deprecated Use ConsumptionCalculatorService para cálculos precisos
  @Deprecated('Use ConsumptionCalculatorService.calculateConsumptionKmL() com odômetro anterior')
  double calcularConsumoMedio() {
    // PROBLEMA: Esta fórmula está INCORRETA matematicamente
    // Fórmula errada: odometro_atual / litros
    // Fórmula correta: (odometro_atual - odometro_anterior) / litros
    
    // Retorna 0 para indicar que precisa ser calculado externamente
    return 0.0;
  }
  
  /// Calcula consumo correto em km/L com odômetro anterior
  /// 
  /// Fórmula correta: distância percorrida / litros abastecidos
  double calcularConsumoCorreto(double odometroAnterior) {
    if (litros <= 0) return 0.0;
    
    final distanciaPercorrida = odometro - odometroAnterior;
    if (distanciaPercorrida <= 0) return 0.0;
    
    return distanciaPercorrida / litros;
  }
  
  /// Calcula consumo em L/100km (padrão europeu)
  double calcularConsumoL100km(double odometroAnterior) {
    final consumoKmL = calcularConsumoCorreto(odometroAnterior);
    if (consumoKmL <= 0) return 0.0;
    
    return 100 / consumoKmL;
  }

  /// Calcula o preço médio por litro
  double calcularPrecoPorLitro() {
    return litros > 0 ? valorTotal / litros : 0.0;
  }

  /// Retorna uma string com informações resumidas do abastecimento
  // String resumoAbastecimento() {
  //   return "Veículo: $veiculoId, Data: ${data.day}/${data.month}/${data.year}, "
  //       "Quilometragem: $odometro km, Litros: $litros L, Valor: R\$ $valorTotal";
  // }

  /// Verifica se o abastecimento pertence a um veículo específico
  bool pertenceAoVeiculo(int idVeiculo) {
    return veiculoId.toString() == idVeiculo.toString();
  }

  // Compara a data de dois abastecimentos
  // bool isDataPosterior(DateTime outraData) {
  //   return data.isAfter(outraData);
  // }

  /// Verifica se os valores são válidos (litros e valorTotal não podem ser negativos)
  /// 
  /// NOTA: Esta é uma validação básica. Para validação completa com business rules,
  /// use AbastecimentoBusinessValidator.validateComplete()
  /// 
  /// @deprecated Use AbastecimentoBusinessValidator para validação completa
  @Deprecated('Use AbastecimentoBusinessValidator.validateComplete() para validação robusta')
  bool validarAbastecimento() {
    return litros > 0 && valorTotal > 0 && odometro > 0;
  }
  
  /// Validação básica dos campos obrigatórios
  bool validarCamposBasicos() {
    return veiculoId.isNotEmpty && 
           data > 0 && 
           litros > 0 && 
           valorTotal > 0 && 
           odometro > 0 &&
           precoPorLitro > 0;
  }
  
  /// Valida consistência financeira (valor total vs preço por litro)
  bool validarConsistenciaFinanceira({double toleranciaPercentual = 5.0}) {
    if (litros <= 0 || precoPorLitro <= 0) return false;
    
    final valorCalculado = precoPorLitro * litros;
    final diferenca = (valorTotal - valorCalculado).abs();
    final percentualDiferenca = (diferenca / valorTotal) * 100;
    
    return percentualDiferenca <= toleranciaPercentual;
  }

  /// Atualiza o valor total do abastecimento e recalcula propriedades relacionadas
  void atualizarValorTotal(double novoValor) {
    valorTotal = novoValor;
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  /// Clona o objeto atual
  AbastecimentoCar clone() {
    return AbastecimentoCar(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      needsSync: needsSync,
      lastSyncAt: lastSyncAt,
      version: version,
      veiculoId: veiculoId,
      data: data,
      odometro: odometro,
      litros: litros,
      valorTotal: valorTotal,
      tanqueCheio: tanqueCheio,
      precoPorLitro: precoPorLitro,
      posto: posto,
      observacao: observacao,
      tipoCombustivel: tipoCombustivel,
    );
  }

  /// Sobrescreve o operador de igualdade para comparar IDs
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AbastecimentoCar && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

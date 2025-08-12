// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/25_manutencao_model.dart';

class ManutencoesCadastroFormModel {
  final String veiculoId;
  final String tipo;
  final String descricao;
  final double valor;
  final int data;
  final int odometro;
  final int? proximaRevisao;
  final bool concluida;
  final bool isLoading;
  final VeiculoCar? veiculo;
  final ManutencaoCar? originalManutencao;

  const ManutencoesCadastroFormModel({
    required this.veiculoId,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.odometro,
    this.proximaRevisao,
    required this.concluida,
    this.isLoading = false,
    this.veiculo,
    this.originalManutencao,
  });

  factory ManutencoesCadastroFormModel.initial({
    required String selectedVeiculoId,
    ManutencaoCar? manutencao,
  }) {
    if (manutencao != null) {
      return ManutencoesCadastroFormModel(
        veiculoId: manutencao.veiculoId,
        tipo: manutencao.tipo,
        descricao: manutencao.descricao,
        valor: manutencao.valor,
        data: manutencao.data,
        odometro: manutencao.odometro,
        proximaRevisao: manutencao.proximaRevisao,
        concluida: manutencao.concluida,
        originalManutencao: manutencao,
      );
    } else {
      return ManutencoesCadastroFormModel(
        veiculoId: selectedVeiculoId,
        tipo: 'Preventiva',
        descricao: '',
        valor: 0.0,
        data: DateTime.now().millisecondsSinceEpoch,
        odometro: 0,
        concluida: false,
      );
    }
  }

  ManutencoesCadastroFormModel copyWith({
    String? veiculoId,
    String? tipo,
    String? descricao,
    double? valor,
    int? data,
    int? odometro,
    int? proximaRevisao,
    bool? concluida,
    bool? isLoading,
    VeiculoCar? veiculo,
    ManutencaoCar? originalManutencao,
    bool clearProximaRevisao = false,
  }) {
    return ManutencoesCadastroFormModel(
      veiculoId: veiculoId ?? this.veiculoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      proximaRevisao:
          clearProximaRevisao ? null : (proximaRevisao ?? this.proximaRevisao),
      concluida: concluida ?? this.concluida,
      isLoading: isLoading ?? this.isLoading,
      veiculo: veiculo ?? this.veiculo,
      originalManutencao: originalManutencao ?? this.originalManutencao,
    );
  }

  bool get isEditing => originalManutencao != null;

  bool get isValid {
    return veiculoId.isNotEmpty &&
        tipo.isNotEmpty &&
        descricao.trim().isNotEmpty &&
        valor > 0 &&
        odometro > 0;
  }

  bool get hasVeiculo => veiculo != null;

  ManutencaoCar toManutencaoCar() {
    return ManutencaoCar(
      id: originalManutencao?.id ?? const Uuid().v4(),
      createdAt: originalManutencao?.createdAt ??
          DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      veiculoId: veiculoId,
      tipo: tipo,
      descricao: descricao.trim(),
      valor: valor,
      data: data,
      odometro: odometro,
      proximaRevisao: proximaRevisao,
      concluida: concluida,
    );
  }

  Map<String, String?> validate() {
    final errors = <String, String?>{};

    if (veiculoId.isEmpty) {
      errors['veiculoId'] = 'Veículo é obrigatório';
    }

    if (tipo.isEmpty) {
      errors['tipo'] = 'Tipo é obrigatório';
    }

    if (descricao.trim().isEmpty) {
      errors['descricao'] = 'Descrição é obrigatória';
    }

    if (valor <= 0) {
      errors['valor'] = 'Valor deve ser maior que zero';
    }

    if (odometro <= 0) {
      errors['odometro'] = 'Odômetro deve ser maior que zero';
    }

    return errors;
  }

  // Métodos para formatação
  String get formattedData {
    return DateTime.fromMillisecondsSinceEpoch(data).toString();
  }

  String get formattedProximaRevisao {
    if (proximaRevisao == null) return 'Não definida';
    return DateTime.fromMillisecondsSinceEpoch(proximaRevisao!).toString();
  }

  String get formattedValor {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  String get formattedOdometro {
    return odometro.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ManutencoesCadastroFormModel &&
        other.veiculoId == veiculoId &&
        other.tipo == tipo &&
        other.descricao == descricao &&
        other.valor == valor &&
        other.data == data &&
        other.odometro == odometro &&
        other.proximaRevisao == proximaRevisao &&
        other.concluida == concluida &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return veiculoId.hashCode ^
        tipo.hashCode ^
        descricao.hashCode ^
        valor.hashCode ^
        data.hashCode ^
        odometro.hashCode ^
        proximaRevisao.hashCode ^
        concluida.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() {
    return 'ManutencoesCadastroFormModel('
        'veiculoId: $veiculoId, '
        'tipo: $tipo, '
        'valor: $valor, '
        'concluida: $concluida, '
        'isEditing: $isEditing'
        ')';
  }
}

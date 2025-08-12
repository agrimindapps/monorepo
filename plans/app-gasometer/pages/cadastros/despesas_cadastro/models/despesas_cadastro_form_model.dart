// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../database/21_veiculos_model.dart';
import '../../../../database/22_despesas_model.dart';

class DespesaCadastroFormModel {
  final String veiculoId;
  final String tipo;
  final String descricao;
  final double odometro;
  final double valor;
  final int data;
  final bool isLoading;
  final VeiculoCar? veiculo;
  final DespesaCar? originalDespesa;

  const DespesaCadastroFormModel({
    required this.veiculoId,
    required this.tipo,
    required this.descricao,
    required this.odometro,
    required this.valor,
    required this.data,
    this.isLoading = false,
    this.veiculo,
    this.originalDespesa,
  });

  factory DespesaCadastroFormModel.initial({
    required String selectedVeiculoId,
    DespesaCar? despesa,
  }) {
    if (despesa != null) {
      return DespesaCadastroFormModel(
        veiculoId: despesa.veiculoId,
        tipo: despesa.tipo,
        descricao: despesa.descricao,
        odometro: despesa.odometro,
        valor: despesa.valor,
        data: despesa.data,
        originalDespesa: despesa,
      );
    } else {
      return DespesaCadastroFormModel(
        veiculoId: selectedVeiculoId,
        tipo: '',
        descricao: '',
        odometro: 0.0,
        valor: 0.0,
        data: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  DespesaCadastroFormModel copyWith({
    String? veiculoId,
    String? tipo,
    String? descricao,
    double? odometro,
    double? valor,
    int? data,
    bool? isLoading,
    VeiculoCar? veiculo,
    DespesaCar? originalDespesa,
  }) {
    return DespesaCadastroFormModel(
      veiculoId: veiculoId ?? this.veiculoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      odometro: odometro ?? this.odometro,
      valor: valor ?? this.valor,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      veiculo: veiculo ?? this.veiculo,
      originalDespesa: originalDespesa ?? this.originalDespesa,
    );
  }

  bool get isEditing => originalDespesa != null;

  bool get isValid {
    return veiculoId.isNotEmpty &&
        tipo.isNotEmpty &&
        descricao.trim().isNotEmpty &&
        valor > 0 &&
        odometro > 0;
  }

  DespesaCar toDespesaCar() {
    return DespesaCar(
      id: originalDespesa?.id ?? const Uuid().v4(),
      createdAt:
          originalDespesa?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      veiculoId: veiculoId,
      tipo: tipo,
      descricao: descricao.trim(),
      valor: valor,
      data: data,
      odometro: odometro,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DespesaCadastroFormModel &&
        other.veiculoId == veiculoId &&
        other.tipo == tipo &&
        other.descricao == descricao &&
        other.odometro == odometro &&
        other.valor == valor &&
        other.data == data &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return veiculoId.hashCode ^
        tipo.hashCode ^
        descricao.hashCode ^
        odometro.hashCode ^
        valor.hashCode ^
        data.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() {
    return 'DespesaCadastroFormModel(veiculoId: $veiculoId, tipo: $tipo, valor: $valor, isEditing: $isEditing)';
  }
}

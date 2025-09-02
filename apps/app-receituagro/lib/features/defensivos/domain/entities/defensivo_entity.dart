import 'package:equatable/equatable.dart';

/// Entity para Defensivo seguindo princípios Clean Architecture
/// Representa um defensivo agrícola no domínio da aplicação
class DefensivoEntity extends Equatable {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String? nomeComum;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;
  final bool isActive;
  final DateTime? lastUpdated;

  const DefensivoEntity({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    this.nomeComum,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
    this.isActive = true,
    this.lastUpdated,
  });

  /// Nome para exibição (prioriza nomeComum)
  String get displayName => nomeComum ?? nome;
  
  /// Ingrediente ativo para exibição
  String get displayIngredient => ingredienteAtivo;
  
  /// Classe agronômica para exibição
  String get displayClass => classeAgronomica ?? 'Não especificado';
  
  /// Fabricante para exibição
  String get displayFabricante => fabricante ?? 'Não informado';
  
  /// Modo de ação para exibição
  String get displayModoAcao => modoAcao ?? 'Não especificado';

  @override
  List<Object?> get props => [
        id,
        nome,
        ingredienteAtivo,
        nomeComum,
        classeAgronomica,
        fabricante,
        modoAcao,
        isActive,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'DefensivoEntity(id: $id, nome: $nome, ingredienteAtivo: $ingredienteAtivo)';
  }
}
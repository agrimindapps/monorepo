import 'package:core/core.dart';

/// Entity unificada para Defensivo seguindo princípios Clean Architecture
/// Representa um defensivo agrícola no domínio da aplicação
/// Consolidando funcionalidades de DefensivoEntity + DefensivoAgrupadoItemModel + DefensivoModel
class DefensivoEntity extends Equatable {
  final String id;
  final String nome;
  final String ingredienteAtivo;
  final String? nomeComum;
  final String? classeAgronomica;
  final String? fabricante;
  final String? modoAcao;
  final String? categoria;
  final String? toxico;
  final int? quantidadeDiagnosticos;
  final int? nivelPrioridade;
  final bool isActive;
  final bool isComercializado;
  final bool isElegivel;
  final DateTime? lastUpdated;
  final String? line1;
  final String? line2;
  final String? count;

  const DefensivoEntity({
    required this.id,
    required this.nome,
    required this.ingredienteAtivo,
    this.nomeComum,
    this.classeAgronomica,
    this.fabricante,
    this.modoAcao,
    this.categoria,
    this.toxico,
    this.quantidadeDiagnosticos,
    this.nivelPrioridade,
    this.isActive = true,
    this.isComercializado = true,
    this.isElegivel = false,
    this.lastUpdated,
    this.line1,
    this.line2,
    this.count,
  });

  /// Nome para exibição (prioriza nomeComum > line1 > nome)
  String get displayName => nomeComum ?? line1 ?? nome;
  
  /// Ingrediente ativo para exibição (prioriza ingredienteAtivo > line2)
  String get displayIngredient => ingredienteAtivo.isNotEmpty 
      ? ingredienteAtivo 
      : line2 ?? 'Sem ingrediente ativo';
  
  /// Classe agronômica para exibição
  String get displayClass => classeAgronomica ?? 'Não especificado';
  
  /// Fabricante para exibição
  String get displayFabricante => fabricante ?? 'Não informado';
  
  /// Modo de ação para exibição
  String get displayModoAcao => modoAcao ?? 'Não especificado';
  
  /// Categoria para exibição
  String get displayCategoria => categoria ?? 'Sem categoria';
  
  /// Toxicidade para exibição
  String get displayToxico => toxico ?? 'Não informado';
  bool get isDefensivo => ingredienteAtivo.isNotEmpty && (line2?.isNotEmpty ?? true);
  bool get isGroup => !isDefensivo;
  int get itemCount => int.tryParse(count ?? '0') ?? 0;
  bool get hasCount => count != null && count!.isNotEmpty;
  bool get hasIngredienteAtivo => ingredienteAtivo.isNotEmpty;
  
  /// Título para exibição
  String get displayTitle => displayName.isNotEmpty ? displayName : 'Item sem nome';
  
  /// Subtitle para exibição
  String get displaySubtitle => displayIngredient.isNotEmpty ? displayIngredient : '';
  
  /// Count para exibição
  String get displayCount => count ?? '';

  /// Factory para criar a partir de diferentes modelos
  factory DefensivoEntity.fromModel({
    required String idReg,
    required String nome,
    required String ingredienteAtivo,
    String? nomeComum,
    String? classeAgronomica,
    String? fabricante,
    String? modoAcao,
    String? categoria,
    String? toxico,
    String? line1,
    String? line2,
    String? count,
    int? quantidadeDiagnosticos,
    int? nivelPrioridade,
    bool? isComercializado,
    bool? isElegivel,
  }) {
    return DefensivoEntity(
      id: idReg,
      nome: nome,
      ingredienteAtivo: ingredienteAtivo,
      nomeComum: nomeComum,
      classeAgronomica: classeAgronomica,
      fabricante: fabricante,
      modoAcao: modoAcao,
      categoria: categoria,
      toxico: toxico,
      line1: line1,
      line2: line2,
      count: count,
      quantidadeDiagnosticos: quantidadeDiagnosticos ?? 0,
      nivelPrioridade: nivelPrioridade ?? 0,
      isComercializado: isComercializado ?? true,
      isElegivel: isElegivel ?? false,
      lastUpdated: DateTime.now(),
    );
  }

  /// CopyWith method para atualizações
  DefensivoEntity copyWith({
    String? id,
    String? nome,
    String? ingredienteAtivo,
    String? nomeComum,
    String? classeAgronomica,
    String? fabricante,
    String? modoAcao,
    String? categoria,
    String? toxico,
    String? line1,
    String? line2,
    String? count,
    int? quantidadeDiagnosticos,
    int? nivelPrioridade,
    bool? isActive,
    bool? isComercializado,
    bool? isElegivel,
    DateTime? lastUpdated,
  }) {
    return DefensivoEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      ingredienteAtivo: ingredienteAtivo ?? this.ingredienteAtivo,
      nomeComum: nomeComum ?? this.nomeComum,
      classeAgronomica: classeAgronomica ?? this.classeAgronomica,
      fabricante: fabricante ?? this.fabricante,
      modoAcao: modoAcao ?? this.modoAcao,
      categoria: categoria ?? this.categoria,
      toxico: toxico ?? this.toxico,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      count: count ?? this.count,
      quantidadeDiagnosticos: quantidadeDiagnosticos ?? this.quantidadeDiagnosticos,
      nivelPrioridade: nivelPrioridade ?? this.nivelPrioridade,
      isActive: isActive ?? this.isActive,
      isComercializado: isComercializado ?? this.isComercializado,
      isElegivel: isElegivel ?? this.isElegivel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        ingredienteAtivo,
        nomeComum,
        classeAgronomica,
        fabricante,
        modoAcao,
        categoria,
        toxico,
        line1,
        line2,
        count,
        quantidadeDiagnosticos,
        nivelPrioridade,
        isActive,
        isComercializado,
        isElegivel,
        lastUpdated,
      ];

  @override
  String toString() {
    return 'DefensivoEntity(id: $id, nome: $nome, ingredienteAtivo: $ingredienteAtivo, isDefensivo: $isDefensivo)';
  }
}

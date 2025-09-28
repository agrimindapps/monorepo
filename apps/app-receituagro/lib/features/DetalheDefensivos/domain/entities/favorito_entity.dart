import 'package:core/core.dart';

/// Entidade de domínio que representa um favorito
/// 
/// Esta entidade representa um item favoritado pelo usuário,
/// seguindo os princípios de Clean Architecture
class FavoritoEntity extends Equatable {
  final String id;
  final String itemId;
  final String tipo; // 'defensivo', 'diagnostico', 'praga'
  final String nome;
  final String? fabricante;
  final String? cultura;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FavoritoEntity({
    required this.id,
    required this.itemId,
    required this.tipo,
    required this.nome,
    this.fabricante,
    this.cultura,
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
  });

  /// Getters computados
  bool get isDefensivo => tipo == 'defensivo';
  bool get isDiagnostico => tipo == 'diagnostico';
  bool get isPraga => tipo == 'praga';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }

  String get subtitle {
    if (isDefensivo && fabricante != null) return fabricante!;
    if (isDiagnostico && cultura != null) return cultura!;
    if (isPraga && cultura != null) return cultura!;
    return '';
  }

  /// Método para criar uma nova instância com valores alterados
  FavoritoEntity copyWith({
    String? id,
    String? itemId,
    String? tipo,
    String? nome,
    String? fabricante,
    String? cultura,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FavoritoEntity(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      tipo: tipo ?? this.tipo,
      nome: nome ?? this.nome,
      fabricante: fabricante ?? this.fabricante,
      cultura: cultura ?? this.cultura,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        tipo,
        nome,
        fabricante,
        cultura,
        metadata,
        createdAt,
        updatedAt,
      ];
}
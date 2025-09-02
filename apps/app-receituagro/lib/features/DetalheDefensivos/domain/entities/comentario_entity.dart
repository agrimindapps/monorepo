import 'package:equatable/equatable.dart';

/// Entidade de domínio que representa um comentário
/// 
/// Esta entidade representa um comentário sobre um defensivo,
/// seguindo os princípios de Clean Architecture
class ComentarioEntity extends Equatable {
  final String id;
  final String idReg;
  final String titulo;
  final String conteudo;
  final String ferramenta;
  final String pkIdentificador;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComentarioEntity({
    required this.id,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Getters computados
  bool get isActive => status;
  
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

  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;

  /// Validação de conteúdo
  bool get hasValidContent => 
      conteudo.trim().length >= 5 && conteudo.trim().length <= 300;

  /// Método para criar uma nova instância com valores alterados
  ComentarioEntity copyWith({
    String? id,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComentarioEntity(
      id: id ?? this.id,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        idReg,
        titulo,
        conteudo,
        ferramenta,
        pkIdentificador,
        status,
        createdAt,
        updatedAt,
      ];
}
// Package imports:
import 'package:hive/hive.dart';

part 'comentarios_models.g.dart';

@HiveType(typeId: 2)
class Comentarios extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime updatedAt;

  @HiveField(3)
  bool status;

  @HiveField(4)
  String idReg;

  @HiveField(5)
  String titulo;

  @HiveField(6)
  String conteudo;

  @HiveField(7)
  String ferramenta;

  @HiveField(8)
  String pkIdentificador;

  Comentarios({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  }) {
    // Validação de campos essenciais apenas se não for construção interna do Hive
    _validateFields();
  }

  // Construtor privado usado pelo Hive sem validações
  Comentarios._internal({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.idReg,
    required this.titulo,
    required this.conteudo,
    required this.ferramenta,
    required this.pkIdentificador,
  });

  void _validateFields() {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }
    if (conteudo.trim().length < 5) {
      throw ArgumentError('Conteúdo deve ter pelo menos 5 caracteres');
    }
    if (conteudo.trim().length > 200) {
      throw ArgumentError('Conteúdo não pode exceder 200 caracteres');
    }
    if (ferramenta.trim().isEmpty) {
      throw ArgumentError('Ferramenta não pode ser vazia');
    }
  }

  // Factory para criar comentário com valores padrão
  factory Comentarios.create({
    required String conteudo,
    required String ferramenta,
    String? pkIdentificador,
    String? titulo,
    bool? status,
  }) {
    final now = DateTime.now();
    return Comentarios(
      id: now.millisecondsSinceEpoch.toString(),
      createdAt: now,
      updatedAt: now,
      status: status ?? true,
      idReg: _generateIdReg(),
      titulo: titulo ?? '',
      conteudo: conteudo.trim(),
      ferramenta: ferramenta.trim(),
      pkIdentificador: pkIdentificador ?? '',
    );
  }

  // Método para gerar ID único
  static String _generateIdReg() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Serialização para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
      'idReg': idReg,
      'titulo': titulo,
      'conteudo': conteudo,
      'ferramenta': ferramenta,
      'pkIdentificador': pkIdentificador,
    };
  }

  // Deserialização de JSON
  factory Comentarios.fromJson(Map<String, dynamic> json) {
    return Comentarios(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: json['status'] as bool,
      idReg: json['idReg'] as String,
      titulo: json['titulo'] as String,
      conteudo: json['conteudo'] as String,
      ferramenta: json['ferramenta'] as String,
      pkIdentificador: json['pkIdentificador'] as String,
    );
  }

  // Método para criar cópia com alterações
  Comentarios copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? status,
    String? idReg,
    String? titulo,
    String? conteudo,
    String? ferramenta,
    String? pkIdentificador,
  }) {
    return Comentarios(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      idReg: idReg ?? this.idReg,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      ferramenta: ferramenta ?? this.ferramenta,
      pkIdentificador: pkIdentificador ?? this.pkIdentificador,
    );
  }

  // Métodos de comparação para ordenação
  static int compareByDate(Comentarios a, Comentarios b) {
    return b.createdAt.compareTo(a.createdAt); // Mais recente primeiro
  }

  static int compareByContent(Comentarios a, Comentarios b) {
    return a.conteudo.toLowerCase().compareTo(b.conteudo.toLowerCase());
  }

  static int compareByTool(Comentarios a, Comentarios b) {
    return a.ferramenta.toLowerCase().compareTo(b.ferramenta.toLowerCase());
  }

  // Métodos utilitários para data
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''} atrás';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }

  // Validações
  bool get isValid {
    return id.trim().isNotEmpty &&
        conteudo.trim().length >= 5 &&
        conteudo.trim().length <= 200 &&
        ferramenta.trim().isNotEmpty;
  }

  bool get isContentValid {
    final trimmed = conteudo.trim();
    return trimmed.length >= 5 && trimmed.length <= 200;
  }

  // Métodos de busca e filtro
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return conteudo.toLowerCase().contains(lowerQuery) ||
        titulo.toLowerCase().contains(lowerQuery) ||
        ferramenta.toLowerCase().contains(lowerQuery);
  }

  bool belongsToTool(String toolName) {
    return ferramenta.toLowerCase() == toolName.toLowerCase();
  }

  bool belongsToIdentifier(String identifier) {
    return pkIdentificador == identifier;
  }

  // Override dos métodos padrão
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Comentarios) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Comentarios(id: $id, conteudo: ${conteudo.substring(0, conteudo.length > 20 ? 20 : conteudo.length)}..., ferramenta: $ferramenta)';
  }
}

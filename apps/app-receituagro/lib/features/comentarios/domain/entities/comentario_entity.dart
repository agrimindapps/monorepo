/// Domain entity representing a comment/note in the ReceitaAgro app.
/// 
/// This is the core business entity that encapsulates all business rules 
/// and logic related to comments in the agricultural content context.
///
/// ## Business Rules Overview:
/// 
/// ### Validation Rules:
/// - Content must have minimum 5 characters when trimmed (ComentariosDesignTokens.minCommentLength)
/// - Title cannot be empty when trimmed  
/// - Tool/ferramenta identifier cannot be empty
/// - All required fields must be present for creation
/// 
/// ### Editing Rules:
/// - Comments can only be edited if status is active (true)
/// - Comments cannot be edited after 30 days from creation
/// - Editing updates the updatedAt timestamp automatically
/// 
/// ### Display Rules:
/// - Content over 50 characters is truncated with ellipsis for summary
/// - Age categorization: today, yesterday, week, month, older
/// - Tool name determines visual categorization and grouping
/// 
/// ### Data Integrity Rules:
/// - Each comment has unique ID and belongs to a specific registry (idReg)
/// - pkIdentificador links comment to specific agricultural content
/// - Status field controls active/inactive state
/// - Timestamps track creation and modification history
/// 
/// ### Agricultural Domain Context:
/// - ferramenta: Agricultural tool/method being commented on
/// - idReg: Registry identifier for agricultural content
/// - pkIdentificador: Primary key linking to specific pest/disease/defensive
/// - Comments provide user annotations for agricultural decision-making
library;

import '../../constants/comentarios_design_tokens.dart';

class ComentarioEntity {
  /// Unique identifier for the comment
  final String id;
  
  /// Registry identifier linking to agricultural content database
  final String idReg;
  
  /// Title/heading of the comment (business rule: cannot be empty)
  final String titulo;
  
  /// Main content of the comment (business rule: minimum 5 characters per ComentariosDesignTokens.minCommentLength)
  final String conteudo;
  
  /// Agricultural tool/method identifier (business rule: cannot be empty)
  final String ferramenta;
  
  /// Primary key identifier for the associated agricultural entity
  /// (pest, disease, defensive product, etc.)
  final String pkIdentificador;
  
  /// Active status flag (business rule: affects editing capability)
  final bool status;
  
  /// Creation timestamp (business rule: used for edit time limit validation)
  final DateTime createdAt;
  
  /// Last update timestamp (automatically updated on modifications)
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

  /// Creates a copy of this entity with the given fields replaced.
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

  /// **BUSINESS RULE: Comment Validation**
  /// 
  /// Validates if a comment meets all requirements for saving to storage.
  /// 
  /// **Requirements:**
  /// - Content must have at least 5 characters when trimmed (ComentariosDesignTokens.minCommentLength)
  /// - Title must not be empty when trimmed (required for identification)
  /// - Tool identifier must not be empty (required for categorization)
  /// 
  /// **Usage:** Call before attempting to save comment to prevent invalid data
  /// 
  /// **Returns:** `true` if all validation rules pass, `false` otherwise
  bool get isValid {
    return conteudo.trim().length >= ComentariosDesignTokens.minCommentLength &&
           titulo.trim().isNotEmpty &&
           ferramenta.trim().isNotEmpty;
  }

  /// **BUSINESS RULE: Edit Permission**
  /// 
  /// Determines if a comment can be modified by the user.
  /// 
  /// **Requirements:**
  /// - Comment must have active status (not soft-deleted)
  /// - Comment must be created within last 30 days (prevents old data corruption)
  /// 
  /// **Rationale:** 
  /// - Time limit prevents accidental modification of historical data
  /// - Status check ensures deleted comments cannot be edited
  /// 
  /// **Returns:** `true` if comment can be edited, `false` otherwise
  bool get canBeEdited {
    return status && 
           DateTime.now().difference(createdAt).inDays <= 30;
  }

  /// **BUSINESS RULE: Age Categorization**
  /// 
  /// Categorizes comments by age for display grouping and filtering.
  /// 
  /// **Categories:**
  /// - `today`: Created today (0 days old)
  /// - `yesterday`: Created yesterday (1 day old)  
  /// - `week`: Created within last 7 days
  /// - `month`: Created within last 30 days
  /// - `older`: Created more than 30 days ago
  /// 
  /// **Usage:** Use for UI grouping, sorting, and filtering logic
  String get ageCategory {
    final daysSince = DateTime.now().difference(createdAt).inDays;
    if (daysSince == 0) return 'today';
    if (daysSince == 1) return 'yesterday';
    if (daysSince <= 7) return 'week';
    if (daysSince <= 30) return 'month';
    return 'older';
  }

  /// **BUSINESS RULE: Summary Generation**
  /// 
  /// Creates truncated summary of comment content for list display.
  /// 
  /// **Logic:**
  /// - If content <= 50 characters: return full content
  /// - If content > 50 characters: truncate to 47 chars + "..."
  /// 
  /// **Rationale:**
  /// - Maintains consistent UI layout in comment lists
  /// - Provides preview while indicating more content available
  /// - 47+3 ellipsis = 50 total characters for visual consistency
  String get summary {
    if (conteudo.length <= 50) return conteudo;
    return '${conteudo.substring(0, 47)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComentarioEntity &&
        other.id == id &&
        other.conteudo == conteudo &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => id.hashCode ^ conteudo.hashCode ^ updatedAt.hashCode;

  @override
  String toString() {
    return 'ComentarioEntity(id: $id, titulo: $titulo, ferramenta: $ferramenta)';
  }
}
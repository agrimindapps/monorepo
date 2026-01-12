import 'package:equatable/equatable.dart';

/// Tipos de feedback que o usuário pode enviar
enum FeedbackType {
  bug,
  suggestion,
  comment,
  other;

  String get displayName {
    switch (this) {
      case FeedbackType.bug:
        return 'Bug / Erro';
      case FeedbackType.suggestion:
        return 'Sugestão';
      case FeedbackType.comment:
        return 'Comentário';
      case FeedbackType.other:
        return 'Outro';
    }
  }

  String get emoji {
    switch (this) {
      case FeedbackType.bug:
        return '🐛';
      case FeedbackType.suggestion:
        return '💡';
      case FeedbackType.comment:
        return '💬';
      case FeedbackType.other:
        return '📝';
    }
  }
}

/// Status do feedback para gerenciamento admin
enum FeedbackStatus {
  pending,
  reviewed,
  resolved,
  archived;

  String get displayName {
    switch (this) {
      case FeedbackStatus.pending:
        return 'Pendente';
      case FeedbackStatus.reviewed:
        return 'Revisado';
      case FeedbackStatus.resolved:
        return 'Resolvido';
      case FeedbackStatus.archived:
        return 'Arquivado';
    }
  }
}

/// Entidade de Feedback do usuário
/// 
/// Representa um feedback enviado por um usuário do aplicativo,
/// podendo ser um bug report, sugestão, comentário ou outro.
class FeedbackEntity extends Equatable {
  const FeedbackEntity({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    this.calculatorId,
    this.calculatorName,
    this.rating,
    this.userAgent,
    this.appVersion,
    this.platform,
    this.status = FeedbackStatus.pending,
    this.reviewedAt,
    this.adminNotes,
    this.userEmail,
  });

  /// ID único do feedback (gerado pelo Firestore)
  final String id;

  /// Tipo do feedback (bug, sugestão, comentário, outro)
  final FeedbackType type;

  /// Mensagem/conteúdo do feedback
  final String message;

  /// ID da calculadora onde o feedback foi enviado (opcional)
  final String? calculatorId;

  /// Nome da calculadora onde o feedback foi enviado (opcional)
  final String? calculatorName;

  /// Rating opcional (1-5 estrelas)
  final double? rating;

  /// User agent / informações do dispositivo
  final String? userAgent;

  /// Versão do aplicativo
  final String? appVersion;

  /// Plataforma (android, ios, web)
  final String? platform;

  /// Status do feedback (para gerenciamento)
  final FeedbackStatus status;

  /// Data de criação
  final DateTime createdAt;

  /// Data de revisão pelo admin
  final DateTime? reviewedAt;

  /// Notas do admin sobre o feedback
  final String? adminNotes;

  /// Email do usuário (opcional, se quiser resposta)
  final String? userEmail;

  /// Cria uma instância vazia para formulários
  factory FeedbackEntity.empty() {
    return FeedbackEntity(
      id: '',
      type: FeedbackType.comment,
      message: '',
      createdAt: DateTime.now(),
    );
  }

  /// Cria a partir de um Map (Firestore)
  factory FeedbackEntity.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackEntity(
      id: id,
      type: FeedbackType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FeedbackType.other,
      ),
      message: map['message'] as String? ?? '',
      calculatorId: map['calculatorId'] as String?,
      calculatorName: map['calculatorName'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      userAgent: map['userAgent'] as String?,
      appVersion: map['appVersion'] as String?,
      platform: map['platform'] as String?,
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['reviewedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      adminNotes: map['adminNotes'] as String?,
      userEmail: map['userEmail'] as String?,
    );
  }

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': message,
      'calculatorId': calculatorId,
      'calculatorName': calculatorName,
      'rating': rating,
      'userAgent': userAgent,
      'appVersion': appVersion,
      'platform': platform,
      'status': status.name,
      'createdAt': createdAt,
      'reviewedAt': reviewedAt,
      'adminNotes': adminNotes,
      'userEmail': userEmail,
    };
  }

  FeedbackEntity copyWith({
    String? id,
    FeedbackType? type,
    String? message,
    String? calculatorId,
    String? calculatorName,
    double? rating,
    String? userAgent,
    String? appVersion,
    String? platform,
    FeedbackStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? adminNotes,
    String? userEmail,
  }) {
    return FeedbackEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      rating: rating ?? this.rating,
      userAgent: userAgent ?? this.userAgent,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        message,
        calculatorId,
        calculatorName,
        rating,
        userAgent,
        appVersion,
        platform,
        status,
        createdAt,
        reviewedAt,
        adminNotes,
        userEmail,
      ];
}

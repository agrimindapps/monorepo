import 'package:equatable/equatable.dart';
import '../../shared/enums/error_severity.dart';

/// Tipos de erro que podem ser capturados
enum ErrorType {
  exception,
  assertion,
  network,
  timeout,
  parsing,
  render,
  state,
  navigation,
  other;

  String get displayName {
    switch (this) {
      case ErrorType.exception:
        return 'Exceção';
      case ErrorType.assertion:
        return 'Assertion';
      case ErrorType.network:
        return 'Rede';
      case ErrorType.timeout:
        return 'Timeout';
      case ErrorType.parsing:
        return 'Parsing';
      case ErrorType.render:
        return 'Renderização';
      case ErrorType.state:
        return 'Estado';
      case ErrorType.navigation:
        return 'Navegação';
      case ErrorType.other:
        return 'Outro';
    }
  }

  String get emoji {
    switch (this) {
      case ErrorType.exception:
        return '💥';
      case ErrorType.assertion:
        return '⚠️';
      case ErrorType.network:
        return '🌐';
      case ErrorType.timeout:
        return '⏱️';
      case ErrorType.parsing:
        return '📄';
      case ErrorType.render:
        return '🖼️';
      case ErrorType.state:
        return '🔄';
      case ErrorType.navigation:
        return '🧭';
      case ErrorType.other:
        return '❓';
    }
  }
}

/// Status do erro para gerenciamento admin
enum ErrorStatus {
  newError,
  investigating,
  fixed,
  ignored,
  wontFix;

  String get displayName {
    switch (this) {
      case ErrorStatus.newError:
        return 'Novo';
      case ErrorStatus.investigating:
        return 'Investigando';
      case ErrorStatus.fixed:
        return 'Corrigido';
      case ErrorStatus.ignored:
        return 'Ignorado';
      case ErrorStatus.wontFix:
        return 'Não será corrigido';
    }
  }

  /// Nome usado no Firestore (sem camelCase para compatibilidade)
  String get firestoreName {
    switch (this) {
      case ErrorStatus.newError:
        return 'new';
      case ErrorStatus.investigating:
        return 'investigating';
      case ErrorStatus.fixed:
        return 'fixed';
      case ErrorStatus.ignored:
        return 'ignored';
      case ErrorStatus.wontFix:
        return 'wont_fix';
    }
  }

  static ErrorStatus fromFirestore(String? value) {
    switch (value) {
      case 'new':
        return ErrorStatus.newError;
      case 'investigating':
        return ErrorStatus.investigating;
      case 'fixed':
        return ErrorStatus.fixed;
      case 'ignored':
        return ErrorStatus.ignored;
      case 'wont_fix':
        return ErrorStatus.wontFix;
      default:
        return ErrorStatus.newError;
    }
  }
}

/// Entidade de Log de Erro
///
/// Representa um erro capturado em produção web,
/// armazenado no Firestore para análise e gestão.
class ErrorLogEntity extends Equatable {
  const ErrorLogEntity({
    required this.id,
    required this.errorType,
    required this.message,
    required this.createdAt,
    this.stackTrace,
    this.url,
    this.calculatorId,
    this.calculatorName,
    this.userAgent,
    this.appVersion,
    this.platform = 'web',
    this.browserInfo,
    this.screenSize,
    this.severity = ErrorSeverity.medium,
    this.status = ErrorStatus.newError,
    this.resolvedAt,
    this.adminNotes,
    this.occurrences = 1,
    this.lastOccurrence,
    this.errorHash,
    this.sessionId,
  });

  /// ID único do erro (gerado pelo Firestore)
  final String id;

  /// Tipo do erro
  final ErrorType errorType;

  /// Mensagem de erro
  final String message;

  /// Stack trace do erro (pode ser longo)
  final String? stackTrace;

  /// URL/rota onde o erro ocorreu
  final String? url;

  /// ID da calculadora onde o erro ocorreu (opcional)
  final String? calculatorId;

  /// Nome da calculadora onde o erro ocorreu (opcional)
  final String? calculatorName;

  /// User agent do navegador
  final String? userAgent;

  /// Versão do aplicativo
  final String? appVersion;

  /// Plataforma (sempre 'web' para este serviço)
  final String platform;

  /// Informações do navegador (ex: Chrome 120)
  final String? browserInfo;

  /// Tamanho da tela (ex: 1920x1080)
  final String? screenSize;

  /// Severidade do erro
  final ErrorSeverity severity;

  /// Status do erro (para gerenciamento)
  final ErrorStatus status;

  /// Data de criação (primeiro registro)
  final DateTime createdAt;

  /// Data de resolução pelo admin
  final DateTime? resolvedAt;

  /// Notas do admin sobre o erro
  final String? adminNotes;

  /// Número de ocorrências (para deduplicação)
  final int occurrences;

  /// Data da última ocorrência
  final DateTime? lastOccurrence;

  /// Hash único para deduplicação (message + stackTrace resumido)
  final String? errorHash;

  /// ID da sessão do usuário (anônimo)
  final String? sessionId;

  /// Cria uma instância vazia
  factory ErrorLogEntity.empty() {
    return ErrorLogEntity(
      id: '',
      errorType: ErrorType.other,
      message: '',
      createdAt: DateTime.now(),
    );
  }

  /// Cria a partir de um Map (Firestore)
  factory ErrorLogEntity.fromMap(Map<String, dynamic> map, String id) {
    return ErrorLogEntity(
      id: id,
      errorType: ErrorType.values.firstWhere(
        (e) => e.name == map['errorType'],
        orElse: () => ErrorType.other,
      ),
      message: map['message'] as String? ?? '',
      stackTrace: map['stackTrace'] as String?,
      url: map['url'] as String?,
      calculatorId: map['calculatorId'] as String?,
      calculatorName: map['calculatorName'] as String?,
      userAgent: map['userAgent'] as String?,
      appVersion: map['appVersion'] as String?,
      platform: map['platform'] as String? ?? 'web',
      browserInfo: map['browserInfo'] as String?,
      screenSize: map['screenSize'] as String?,
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
      status: ErrorStatus.fromFirestore(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['createdAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : DateTime.now(),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['resolvedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      adminNotes: map['adminNotes'] as String?,
      occurrences: map['occurrences'] as int? ?? 1,
      lastOccurrence: map['lastOccurrence'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['lastOccurrence'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      errorHash: map['errorHash'] as String?,
      sessionId: map['sessionId'] as String?,
    );
  }

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'errorType': errorType.name,
      'message': message,
      'stackTrace': stackTrace,
      'url': url,
      'calculatorId': calculatorId,
      'calculatorName': calculatorName,
      'userAgent': userAgent,
      'appVersion': appVersion,
      'platform': platform,
      'browserInfo': browserInfo,
      'screenSize': screenSize,
      'severity': severity.name,
      'status': status.firestoreName,
      'createdAt': createdAt,
      'resolvedAt': resolvedAt,
      'adminNotes': adminNotes,
      'occurrences': occurrences,
      'lastOccurrence': lastOccurrence,
      'errorHash': errorHash,
      'sessionId': sessionId,
    };
  }

  ErrorLogEntity copyWith({
    String? id,
    ErrorType? errorType,
    String? message,
    String? stackTrace,
    String? url,
    String? calculatorId,
    String? calculatorName,
    String? userAgent,
    String? appVersion,
    String? platform,
    String? browserInfo,
    String? screenSize,
    ErrorSeverity? severity,
    ErrorStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? adminNotes,
    int? occurrences,
    DateTime? lastOccurrence,
    String? errorHash,
    String? sessionId,
  }) {
    return ErrorLogEntity(
      id: id ?? this.id,
      errorType: errorType ?? this.errorType,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      url: url ?? this.url,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      userAgent: userAgent ?? this.userAgent,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      browserInfo: browserInfo ?? this.browserInfo,
      screenSize: screenSize ?? this.screenSize,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      occurrences: occurrences ?? this.occurrences,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
      errorHash: errorHash ?? this.errorHash,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    errorType,
    message,
    stackTrace,
    url,
    calculatorId,
    calculatorName,
    userAgent,
    appVersion,
    platform,
    browserInfo,
    screenSize,
    severity,
    status,
    createdAt,
    resolvedAt,
    adminNotes,
    occurrences,
    lastOccurrence,
    errorHash,
    sessionId,
  ];
}

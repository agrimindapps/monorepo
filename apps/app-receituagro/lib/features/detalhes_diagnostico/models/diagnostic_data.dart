/// Comprehensive data model for diagnostic information
/// Following Single Responsibility Principle (SOLID)
class DiagnosticData {
  final String id;
  final String name;
  final String category;
  final DiagnosticType type;
  final DiagnosticSeverity severity;
  final Map<String, dynamic> parameters;
  final List<DiagnosticResult> results;
  final DiagnosticMetrics metrics;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const DiagnosticData({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.severity,
    required this.parameters,
    required this.results,
    required this.metrics,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory DiagnosticData.fromJson(Map<String, dynamic> json) {
    return DiagnosticData(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      type: DiagnosticType.fromString(json['type'] as String),
      severity: DiagnosticSeverity.fromString(json['severity'] as String),
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      results: (json['results'] as List)
          .map((e) => DiagnosticResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      metrics: DiagnosticMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'type': type.value,
      'severity': severity.value,
      'parameters': parameters,
      'results': results.map((e) => e.toJson()).toList(),
      'metrics': metrics.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  DiagnosticData copyWith({
    String? id,
    String? name,
    String? category,
    DiagnosticType? type,
    DiagnosticSeverity? severity,
    Map<String, dynamic>? parameters,
    List<DiagnosticResult>? results,
    DiagnosticMetrics? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return DiagnosticData(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      parameters: parameters ?? this.parameters,
      results: results ?? this.results,
      metrics: metrics ?? this.metrics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enumeration for diagnostic types
enum DiagnosticType {
  performance('performance'),
  security('security'),
  compatibility('compatibility'),
  functionality('functionality'),
  usability('usability'),
  accessibility('accessibility');

  const DiagnosticType(this.value);
  final String value;

  static DiagnosticType fromString(String value) {
    return DiagnosticType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => DiagnosticType.functionality,
    );
  }
}

/// Enumeration for diagnostic severity levels
enum DiagnosticSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const DiagnosticSeverity(this.value);
  final String value;

  static DiagnosticSeverity fromString(String value) {
    return DiagnosticSeverity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => DiagnosticSeverity.medium,
    );
  }
}

/// Model for diagnostic results
class DiagnosticResult {
  final String id;
  final String name;
  final dynamic value;
  final String unit;
  final DiagnosticResultStatus status;
  final String? description;
  final DateTime timestamp;

  const DiagnosticResult({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    this.description,
    required this.timestamp,
  });

  factory DiagnosticResult.fromJson(Map<String, dynamic> json) {
    return DiagnosticResult(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'],
      unit: json['unit'] as String,
      status: DiagnosticResultStatus.fromString(json['status'] as String),
      description: json['description'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'unit': unit,
      'status': status.value,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosticResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enumeration for diagnostic result status
enum DiagnosticResultStatus {
  passed('passed'),
  failed('failed'),
  warning('warning'),
  skipped('skipped'),
  pending('pending');

  const DiagnosticResultStatus(this.value);
  final String value;

  static DiagnosticResultStatus fromString(String value) {
    return DiagnosticResultStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DiagnosticResultStatus.pending,
    );
  }
}

/// Model for diagnostic metrics
class DiagnosticMetrics {
  final double executionTime;
  final int totalChecks;
  final int passedChecks;
  final int failedChecks;
  final int warningChecks;
  final double accuracy;
  final Map<String, dynamic> additionalMetrics;

  const DiagnosticMetrics({
    required this.executionTime,
    required this.totalChecks,
    required this.passedChecks,
    required this.failedChecks,
    required this.warningChecks,
    required this.accuracy,
    required this.additionalMetrics,
  });

  factory DiagnosticMetrics.fromJson(Map<String, dynamic> json) {
    return DiagnosticMetrics(
      executionTime: (json['executionTime'] as num).toDouble(),
      totalChecks: json['totalChecks'] as int,
      passedChecks: json['passedChecks'] as int,
      failedChecks: json['failedChecks'] as int,
      warningChecks: json['warningChecks'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      additionalMetrics: Map<String, dynamic>.from(json['additionalMetrics'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executionTime': executionTime,
      'totalChecks': totalChecks,
      'passedChecks': passedChecks,
      'failedChecks': failedChecks,
      'warningChecks': warningChecks,
      'accuracy': accuracy,
      'additionalMetrics': additionalMetrics,
    };
  }

  /// Calculate success rate
  double get successRate {
    if (totalChecks == 0) return 0.0;
    return passedChecks / totalChecks;
  }

  /// Calculate failure rate
  double get failureRate {
    if (totalChecks == 0) return 0.0;
    return failedChecks / totalChecks;
  }

  /// Calculate warning rate
  double get warningRate {
    if (totalChecks == 0) return 0.0;
    return warningChecks / totalChecks;
  }

  /// Check if all checks passed
  bool get allPassed => failedChecks == 0 && warningChecks == 0;

  /// Check if any checks failed
  bool get hasFailed => failedChecks > 0;

  /// Check if has warnings
  bool get hasWarnings => warningChecks > 0;
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/enums/log_level.dart';
import 'base_entity.dart';

/// Modelo para entrada de log
class LogEntry extends BaseEntity {
  const LogEntry({
    required super.id,
    required this.descricao,
    required this.hora,
    required this.level,
    this.context,
    super.createdAt,
    super.updatedAt,
  });

  /// Descrição/mensagem do log
  final String descricao;
  
  /// Hora em que o log foi criado
  final DateTime hora;
  
  /// Nível do log
  final LogLevel level;
  
  /// Contexto opcional para categorização
  final String? context;

  /// Cor associada ao nível do log
  Color get logColor {
    switch (level) {
      case LogLevel.trace:
        return Colors.grey.shade300;
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.critical:
        return Colors.red.shade900;
    }
  }

  /// Ícone associado ao nível do log
  IconData get logIcon {
    switch (level) {
      case LogLevel.trace:
        return Icons.code;
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warning:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
      case LogLevel.critical:
        return Icons.dangerous;
    }
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descricao': descricao,
      'hora': hora.millisecondsSinceEpoch,
      'level': level.name,
      'context': context,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Cria LogEntry a partir de Map
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      descricao: json['descricao'] as String,
      hora: DateTime.fromMillisecondsSinceEpoch(json['hora'] as int),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      context: json['context'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : null,
    );
  }

  /// Cria uma cópia com modificações
  @override
  LogEntry copyWith({
    String? id,
    String? descricao,
    DateTime? hora,
    LogLevel? level,
    String? context,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LogEntry(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      hora: hora ?? this.hora,
      level: level ?? this.level,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formata o log como string para exportação
  String toFormattedString() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss.SSS');
    final timestamp = dateFormat.format(hora);
    final levelStr = level.name.toUpperCase();
    final contextStr = context != null ? '[$context] ' : '';
    
    return '$levelStr [$timestamp] $contextStr$descricao';
  }

  @override
  List<Object?> get props => [
        id,
        descricao,
        hora,
        level,
        context,
        createdAt,
        updatedAt,
      ];
}
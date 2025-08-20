// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/14_lembrete_model.dart';
import '../config/lembrete_form_config.dart';
import '../utils/lembrete_form_utils.dart';

// Classe LembreteConstants removida - funcionalidade movida para LembreteFormConfig

class LembreteFormModel {
  String titulo;
  String descricao;
  DateTime dataLembrete;
  TimeOfDay horaLembrete;
  String tipo;
  String repetir;
  bool concluido;
  String animalId;

  LembreteFormModel({
    this.titulo = '',
    this.descricao = '',
    DateTime? dataLembrete,
    TimeOfDay? horaLembrete,
    this.tipo = 'Consulta',
    this.repetir = 'Sem repetição',
    this.concluido = false,
    this.animalId = '',
  }) : dataLembrete = dataLembrete ?? DateTime.now(),
       horaLembrete = horaLembrete ?? TimeOfDay.now();

  factory LembreteFormModel.fromLembrete(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    return LembreteFormModel(
      titulo: lembrete.titulo,
      descricao: lembrete.descricao,
      dataLembrete: dataHora,
      horaLembrete: TimeOfDay.fromDateTime(dataHora),
      tipo: lembrete.tipo,
      repetir: lembrete.repetir,
      concluido: lembrete.concluido,
      animalId: lembrete.animalId,
    );
  }

  factory LembreteFormModel.withAnimalId(String selectedAnimalId) {
    final now = DateTime.now();
    final futureDateTime = now.add(const Duration(hours: 1));
    
    return LembreteFormModel(
      animalId: selectedAnimalId,
      dataLembrete: futureDateTime,
      horaLembrete: TimeOfDay.fromDateTime(futureDateTime),
    );
  }

  LembreteFormModel copyWith({
    String? titulo,
    String? descricao,
    DateTime? dataLembrete,
    TimeOfDay? horaLembrete,
    String? tipo,
    String? repetir,
    bool? concluido,
    String? animalId,
  }) {
    return LembreteFormModel(
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataLembrete: dataLembrete ?? this.dataLembrete,
      horaLembrete: horaLembrete ?? this.horaLembrete,
      tipo: tipo ?? this.tipo,
      repetir: repetir ?? this.repetir,
      concluido: concluido ?? this.concluido,
      animalId: animalId ?? this.animalId,
    );
  }

  LembreteVet toLembrete({
    String? id,
    int? createdAt,
    int? version,
    int? lastSyncAt,
  }) {
    return LembreteVet(
      id: id ?? '',
      createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: false,
      needsSync: true,
      version: version ?? 1,
      lastSyncAt: lastSyncAt,
      titulo: titulo,
      descricao: descricao,
      dataHora: combinedDateTime.millisecondsSinceEpoch,
      tipo: tipo,
      repetir: repetir,
      concluido: concluido,
      animalId: animalId,
    );
  }

  void updateFromLembrete(LembreteVet lembrete) {
    final dataHora = DateTime.fromMillisecondsSinceEpoch(lembrete.dataHora);
    titulo = lembrete.titulo;
    descricao = lembrete.descricao;
    dataLembrete = dataHora;
    horaLembrete = TimeOfDay.fromDateTime(dataHora);
    tipo = lembrete.tipo;
    repetir = lembrete.repetir;
    concluido = lembrete.concluido;
    animalId = lembrete.animalId;
  }

  void reset({String? selectedAnimalId}) {
    final now = DateTime.now();
    final futureDateTime = now.add(const Duration(hours: 1));
    
    titulo = '';
    descricao = '';
    dataLembrete = futureDateTime;
    horaLembrete = TimeOfDay.fromDateTime(futureDateTime);
    tipo = 'Consulta';
    repetir = 'Sem repetição';
    concluido = false;
    animalId = selectedAnimalId ?? '';
  }

  bool get isValid {
    return _isValidTitulo() &&
           _isValidDescricao() &&
           _isValidAnimalId() &&
           _isValidDateTime();
  }

  bool _isValidTitulo() => LembreteFormConfig.isValidTitulo(titulo);

  bool _isValidDescricao() => LembreteFormConfig.isValidDescricao(descricao);

  bool _isValidAnimalId() => LembreteFormConfig.isValidAnimalId(animalId);

  bool _isValidDateTime() => LembreteFormConfig.isValidDataHora(combinedDateTime);

  DateTime get combinedDateTime => LembreteFormUtils.combineDateTime(dataLembrete, horaLembrete);

  String get formattedDate => LembreteFormUtils.formatDate(dataLembrete);

  String get formattedTime => LembreteFormUtils.formatTime(horaLembrete);

  String get formattedDateTime => LembreteFormUtils.formatDateTime(dataLembrete, horaLembrete);

  bool get isPastDue => LembreteFormUtils.isPastDue(combinedDateTime) && !concluido;

  bool get isToday => LembreteFormUtils.isToday(dataLembrete);

  bool get isTomorrow => LembreteFormUtils.isTomorrow(dataLembrete);

  String get relativeTimeDescription => LembreteFormUtils.getRelativeTimeDescription(combinedDateTime);

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataLembrete': dataLembrete.toIso8601String(),
      'horaLembrete': '${horaLembrete.hour}:${horaLembrete.minute}',
      'tipo': tipo,
      'repetir': repetir,
      'concluido': concluido,
      'animalId': animalId,
    };
  }

  factory LembreteFormModel.fromJson(Map<String, dynamic> json) {
    final dataLembrete = DateTime.parse(json['dataLembrete']);
    final timeParts = json['horaLembrete'].split(':');
    final horaLembrete = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    return LembreteFormModel(
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      dataLembrete: dataLembrete,
      horaLembrete: horaLembrete,
      tipo: json['tipo'] ?? 'Consulta',
      repetir: json['repetir'] ?? 'Sem repetição',
      concluido: json['concluido'] ?? false,
      animalId: json['animalId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LembreteFormModel(titulo: $titulo, descricao: $descricao, '
           'dataHora: $formattedDateTime, tipo: $tipo, repetir: $repetir, '
           'concluido: $concluido, animalId: $animalId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LembreteFormModel &&
        other.titulo == titulo &&
        other.descricao == descricao &&
        other.dataLembrete == dataLembrete &&
        other.horaLembrete == horaLembrete &&
        other.tipo == tipo &&
        other.repetir == repetir &&
        other.concluido == concluido &&
        other.animalId == animalId;
  }

  @override
  int get hashCode {
    return titulo.hashCode ^
        descricao.hashCode ^
        dataLembrete.hashCode ^
        horaLembrete.hashCode ^
        tipo.hashCode ^
        repetir.hashCode ^
        concluido.hashCode ^
        animalId.hashCode;
  }
}

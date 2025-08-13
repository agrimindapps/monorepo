/// Base class para todos os eventos de domínio
///
/// Domain Events seguem padrão Event-Driven Architecture para comunicação
/// desacoplada entre diferentes partes do sistema
abstract class DomainEvent {
  /// Timestamp quando o evento foi criado
  final DateTime timestamp;

  /// ID único do evento
  final String eventId;

  /// Tipo do evento (usado para routing e filtering)
  String get eventType;

  /// Payload do evento (dados específicos)
  Map<String, dynamic> get payload;

  /// Metadados opcionais
  final Map<String, dynamic> metadata;

  DomainEvent({
    DateTime? timestamp,
    String? eventId,
    this.metadata = const {},
  })  : timestamp = timestamp ?? DateTime.now(),
        eventId = eventId ?? _generateEventId();

  /// Gera ID único para o evento
  static String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  /// Serializa evento para JSON (útil para logging/audit)
  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return '$eventType(id: $eventId, timestamp: $timestamp)';
  }
}

/// Eventos específicos do domínio de Espaços
abstract class EspacoEvent extends DomainEvent {
  final String espacoId;

  EspacoEvent({
    required this.espacoId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  Map<String, dynamic> get payload => {
        'espacoId': espacoId,
        ...specificPayload,
      };

  /// Payload específico de cada tipo de evento
  Map<String, dynamic> get specificPayload;
}

class EspacoCriado extends EspacoEvent {
  final String nome;
  final String? descricao;

  EspacoCriado({
    required super.espacoId,
    required this.nome,
    this.descricao,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'EspacoCriado';

  @override
  Map<String, dynamic> get specificPayload => {
        'nome': nome,
        'descricao': descricao,
      };
}

class EspacoAtualizado extends EspacoEvent {
  final String nome;
  final String? descricao;
  final bool ativo;

  EspacoAtualizado({
    required super.espacoId,
    required this.nome,
    this.descricao,
    required this.ativo,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'EspacoAtualizado';

  @override
  Map<String, dynamic> get specificPayload => {
        'nome': nome,
        'descricao': descricao,
        'ativo': ativo,
      };
}

class EspacoRemovido extends EspacoEvent {
  EspacoRemovido({
    required super.espacoId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'EspacoRemovido';

  @override
  Map<String, dynamic> get specificPayload => {};
}

class EspacoStatusAlterado extends EspacoEvent {
  final bool ativo;

  EspacoStatusAlterado({
    required super.espacoId,
    required this.ativo,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'EspacoStatusAlterado';

  @override
  Map<String, dynamic> get specificPayload => {
        'ativo': ativo,
      };
}

/// Eventos específicos do domínio de Plantas
abstract class PlantaEvent extends DomainEvent {
  final String plantaId;

  PlantaEvent({
    required this.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  Map<String, dynamic> get payload => {
        'plantaId': plantaId,
        ...specificPayload,
      };

  Map<String, dynamic> get specificPayload;
}

class PlantaCriada extends PlantaEvent {
  final String nome;
  final String espacoId;
  final String? especie;

  PlantaCriada({
    required super.plantaId,
    required this.nome,
    required this.espacoId,
    this.especie,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaCriada';

  @override
  Map<String, dynamic> get specificPayload => {
        'nome': nome,
        'espacoId': espacoId,
        'especie': especie,
      };
}

class PlantaAtualizada extends PlantaEvent {
  final String nome;
  final String espacoId;
  final String? especie;

  PlantaAtualizada({
    required super.plantaId,
    required this.nome,
    required this.espacoId,
    this.especie,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaAtualizada';

  @override
  Map<String, dynamic> get specificPayload => {
        'nome': nome,
        'espacoId': espacoId,
        'especie': especie,
      };
}

class PlantaRemovida extends PlantaEvent {
  PlantaRemovida({
    required super.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaRemovida';

  @override
  Map<String, dynamic> get specificPayload => {};
}

class PlantaMovida extends PlantaEvent {
  final String espacoAnteriorId;
  final String novoEspacoId;

  PlantaMovida({
    required super.plantaId,
    required this.espacoAnteriorId,
    required this.novoEspacoId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaMovida';

  @override
  Map<String, dynamic> get specificPayload => {
        'espacoAnteriorId': espacoAnteriorId,
        'novoEspacoId': novoEspacoId,
      };
}

/// Eventos específicos do domínio de Tarefas
abstract class TarefaEvent extends DomainEvent {
  final String tarefaId;

  TarefaEvent({
    required this.tarefaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  Map<String, dynamic> get payload => {
        'tarefaId': tarefaId,
        ...specificPayload,
      };

  Map<String, dynamic> get specificPayload;
}

class TarefaCriada extends TarefaEvent {
  final String plantaId;
  final String tipoCuidado;
  final DateTime dataExecucao;

  TarefaCriada({
    required super.tarefaId,
    required this.plantaId,
    required this.tipoCuidado,
    required this.dataExecucao,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'TarefaCriada';

  @override
  Map<String, dynamic> get specificPayload => {
        'plantaId': plantaId,
        'tipoCuidado': tipoCuidado,
        'dataExecucao': dataExecucao.toIso8601String(),
      };
}

class TarefaConcluida extends TarefaEvent {
  final String plantaId;
  final String tipoCuidado;
  final DateTime dataConclusao;
  final String? observacoes;

  TarefaConcluida({
    required super.tarefaId,
    required this.plantaId,
    required this.tipoCuidado,
    required this.dataConclusao,
    this.observacoes,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'TarefaConcluida';

  @override
  Map<String, dynamic> get specificPayload => {
        'plantaId': plantaId,
        'tipoCuidado': tipoCuidado,
        'dataConclusao': dataConclusao.toIso8601String(),
        'observacoes': observacoes,
      };
}

class TarefaRemovida extends TarefaEvent {
  final String plantaId;

  TarefaRemovida({
    required super.tarefaId,
    required this.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'TarefaRemovida';

  @override
  Map<String, dynamic> get specificPayload => {
        'plantaId': plantaId,
      };
}

/// Eventos específicos do domínio de Configurações
abstract class PlantaConfigEvent extends DomainEvent {
  final String configId;
  final String plantaId;

  PlantaConfigEvent({
    required this.configId,
    required this.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  Map<String, dynamic> get payload => {
        'configId': configId,
        'plantaId': plantaId,
        ...specificPayload,
      };

  Map<String, dynamic> get specificPayload;
}

class PlantaConfigCriada extends PlantaConfigEvent {
  PlantaConfigCriada({
    required super.configId,
    required super.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaConfigCriada';

  @override
  Map<String, dynamic> get specificPayload => {};
}

class TipoCuidadoAlterado extends PlantaConfigEvent {
  final String tipoCuidado;
  final bool ativo;
  final int? intervaloDias;

  TipoCuidadoAlterado({
    required super.configId,
    required super.plantaId,
    required this.tipoCuidado,
    required this.ativo,
    this.intervaloDias,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'TipoCuidadoAlterado';

  @override
  Map<String, dynamic> get specificPayload => {
        'tipoCuidado': tipoCuidado,
        'ativo': ativo,
        'intervaloDias': intervaloDias,
      };
}

class PlantaConfigRemovida extends PlantaConfigEvent {
  PlantaConfigRemovida({
    required super.configId,
    required super.plantaId,
    super.timestamp,
    super.eventId,
    super.metadata,
  });

  @override
  String get eventType => 'PlantaConfigRemovida';

  @override
  Map<String, dynamic> get specificPayload => {};
}

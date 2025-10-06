import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../shared/utils/failure.dart';
import 'i_sync_service.dart';

/// Interface para orquestração centralizada de sincronização.
///
/// Implementações gerenciam o ciclo de vida dos serviços de sincronização
/// registrados, expõem streams de progresso/eventos e permitem executar
/// operações de sincronização de forma coordenada.
abstract class ISyncOrchestrator {
  /// Registra um serviço de sincronização para que o orquestrador passe a gerenciá-lo.
  ///
  /// O [service] deve implementar [ISyncService] e possuir um identificador
  /// único para permitir chamadas direcionadas (por exemplo, `syncSpecific`).
  Future<void> registerService(ISyncService service);

  /// Remove o serviço identificado por [serviceId] do orquestrador.
  ///
  /// Após a remoção, o serviço não será mais incluído em chamadas como
  /// [syncAll] nem aparecerá em [registeredServices].
  Future<void> unregisterService(String serviceId);

  /// Executa a sincronização de todos os serviços registrados.
  ///
  /// Retorna [Either]<[Failure], void> permitindo propagar falhas
  /// agrupadas ou um sucesso vazio em caso de conclusão sem erros.
  Future<Either<Failure, void>> syncAll();

  /// Executa a sincronização de um serviço específico identificado por [serviceId].
  ///
  /// Útil para forçar a sincronização de um serviço individual sem impactar os
  /// demais registrados.
  Future<Either<Failure, void>> syncSpecific(String serviceId);

  /// Lista os ids dos serviços atualmente registrados no orquestrador.
  List<String> get registeredServices;

  /// Verifica se um serviço identificado por [serviceId] está registrado.
  bool isServiceRegistered(String serviceId);

  /// Stream que emite atualizações de progresso ([SyncProgress]) para as sincronizações em andamento.
  ///
  /// Emissões ajudam UIs e logs a apresentar progresso agregado/por-serviço.
  Stream<SyncProgress> get progressStream;

  /// Stream que emite eventos discretos de sincronização ([SyncEvent]).
  ///
  /// Inclui eventos como início, conclusão, falha e cancelamento.
  Stream<SyncEvent> get eventStream;

  /// Retorna o status atual do serviço identificado por [serviceId].
  ///
  /// Pode lançar ou retornar um valor padrão caso o serviço não exista,
  /// dependendo da implementação concreta.
  SyncServiceStatus getServiceStatus(String serviceId);

  /// Retorna um objeto agregando o status de todos os serviços gerenciados.
  GlobalSyncStatus get globalStatus;

  /// Limpa os dados locais mantidos pelos serviços registrados.
  ///
  /// Usado, por exemplo, em cenários de reset de conta ou limpeza forçada.
  Future<Either<Failure, void>> clearAllData();

  /// Força a parada de todas as sincronizações em andamento.
  ///
  /// Deve interromper operações sem deixar o sistema em um estado inconsistente.
  Future<void> stopAllSync();

  /// Libera recursos utilizados pelo orquestrador (streams, timers, etc.).
  Future<void> dispose();
}

/// Representa o progresso de uma operação de sincronização para um serviço.
///
/// - [current]: unidades concluídas até o momento.
/// - [total]: total de unidades a processar (pode ser 0 se desconhecido).
/// - [serviceId]: identificador do serviço associado.
/// - [operation]: texto opcional descrevendo a operação atual.
class SyncProgress {
  /// Unidades concluídas até o momento.
  final int current;

  /// Total de unidades a processar. Se desconhecido, pode ser 0.
  final int total;

  /// Identificador do serviço a que este progresso se refere.
  final String serviceId;

  /// Operação opcional sendo executada (ex.: 'fetch', 'upload').
  final String? operation;

  /// Timestamp da atualização de progresso.
  final DateTime timestamp;

  /// Cria uma instância de [SyncProgress].
  SyncProgress({
    required this.current,
    required this.total,
    required this.serviceId,
    this.operation,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Percentual concluído (0-100). Retorna 0 quando [total] é 0.
  double get percentage => total > 0 ? (current / total) * 100 : 0;

  /// Indica se a operação está completa (current >= total).
  bool get isCompleted => current >= total;

  @override
  String toString() => 'SyncProgress($current/$total for $serviceId)';
}

/// Evento discreto ocorrido durante a sincronização de um serviço.
///
/// Use [type] para distinguir eventos (início, progresso, conclusão, falha, etc.).
class SyncEvent {
  /// Identificador do serviço que originou o evento.
  final String serviceId;

  /// Tipo do evento (started, progress, completed, failed, ...).
  final SyncEventType type;

  /// Mensagem opcional com contexto humano-legível sobre o evento.
  final String? message;

  /// Dados adicionais associados ao evento (por exemplo, erro ou payload).
  final dynamic data;

  /// Timestamp do evento.
  final DateTime timestamp;

  /// Cria um [SyncEvent].
  SyncEvent({
    required this.serviceId,
    required this.type,
    this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'SyncEvent($type for $serviceId: $message)';
}

/// Tipos de eventos emitidos pelo sistema de sincronização.
///
/// Cada valor indica uma fase ou mudança no ciclo de vida de uma sincronização.
enum SyncEventType {
  /// Sincronização iniciada.
  started,

  /// Atualização de progresso.
  progress,

  /// Sincronização concluída com sucesso.
  completed,

  /// Sincronização falhou.
  failed,

  /// Sincronização pausada.
  paused,

  /// Sincronização retomada após pausa.
  resumed,

  /// Sincronização foi cancelada.
  cancelled,
}

/// Agregado contendo o status atual de todos os serviços de sincronização.
class GlobalSyncStatus {
  /// Map imutável com os statuses por serviço ([serviceId] -> [SyncServiceStatus]).
  final Map<String, SyncServiceStatus> serviceStatuses;

  /// Indica se ao menos um serviço está em sincronização ativa.
  final bool isAnyServiceSyncing;

  /// Indica se todos os serviços estão concluídos (e há ao menos um serviço).
  final bool areAllServicesCompleted;

  /// Total de serviços gerenciados.
  final int totalServices;

  /// Quantidade de serviços concluídos.
  final int completedServices;

  /// Quantidade de serviços que falharam.
  final int failedServices;

  const GlobalSyncStatus({
    required this.serviceStatuses,
    required this.isAnyServiceSyncing,
    required this.areAllServicesCompleted,
    required this.totalServices,
    required this.completedServices,
    required this.failedServices,
  });

  /// Constrói um [GlobalSyncStatus] a partir do mapa de [services].
  factory GlobalSyncStatus.fromServices(
    Map<String, SyncServiceStatus> services,
  ) {
    final total = services.length;
    final completed =
        services.values.where((s) => s == SyncServiceStatus.completed).length;
    final failed =
        services.values.where((s) => s == SyncServiceStatus.failed).length;
    final syncing =
        services.values.where((s) => s == SyncServiceStatus.syncing).length;

    return GlobalSyncStatus(
      serviceStatuses: Map.unmodifiable(services),
      isAnyServiceSyncing: syncing > 0,
      areAllServicesCompleted: completed == total && total > 0,
      totalServices: total,
      completedServices: completed,
      failedServices: failed,
    );
  }

  @override
  String toString() =>
      'GlobalSyncStatus($completedServices/$totalServices completed, $failedServices failed)';
}

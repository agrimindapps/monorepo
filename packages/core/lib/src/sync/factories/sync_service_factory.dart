import 'dart:developer' as developer;
import '../interfaces/i_sync_service.dart';

/// Factory para criação e gerenciamento de serviços de sincronização.
///
/// Fornece registro, criação e introspecção de serviços implementando
/// o padrão factory. Suporta registro individual, em lote, validação de
/// dependências e geração de ordens de criação respeitando dependências.
///
/// Uso:
/// ```dart
/// SyncServiceFactory.instance.register('myService', () => MyService());
/// final svc = SyncServiceFactory.instance.create('myService');
/// ```
///
/// Esta classe é um singleton (acessível via [SyncServiceFactory.instance]).
class SyncServiceFactory {
  static final SyncServiceFactory _instance = SyncServiceFactory._internal();
  static SyncServiceFactory get instance => _instance;

  SyncServiceFactory._internal();
  final Map<String, ISyncService Function()> _creators = {};
  final Map<String, ServiceMetadata> _metadata = {};

  /// Registra um criador de serviço identificado por [serviceId].
  ///
  /// - [creator]: função que instancia o serviço quando solicitado.
  /// - [displayName]: nome legível para exibição de UI/ logs.
  /// - [description]: descrição curta do serviço.
  /// - [version]: versão semântica do serviço (ex: '1.0.0').
  /// - [dependencies]: lista de outros serviceIds que este serviço depende.
  void register(
    String serviceId,
    ISyncService Function() creator, {
    String? displayName,
    String? description,
    String version = '1.0.0',
    List<String> dependencies = const [],
  }) {
    if (_creators.containsKey(serviceId)) {
      developer.log(
        'Service $serviceId already registered, replacing',
        name: 'SyncServiceFactory',
      );
    }

    _creators[serviceId] = creator;
    _metadata[serviceId] = ServiceMetadata(
      serviceId: serviceId,
      displayName: displayName ?? serviceId,
      description: description ?? 'Sync service for $serviceId',
      version: version,
      dependencies: dependencies,
    );

    developer.log(
      'Registered sync service: $serviceId (v$version)',
      name: 'SyncServiceFactory',
    );
  }

  /// Remove o registro (registro + metadados) para o serviço indicado.
  void unregister(String serviceId) {
    if (_creators.remove(serviceId) != null) {
      _metadata.remove(serviceId);
      developer.log(
        'Unregistered sync service: $serviceId',
        name: 'SyncServiceFactory',
      );
    }
  }

  /// Cria (instancia) o serviço registrado sob [serviceId].
  ///
  /// Retorna a instância de [ISyncService] quando disponível ou `null` se
  /// não houver criador registrado ou ocorrer erro durante a criação.
  ISyncService? create(String serviceId) {
    final creator = _creators[serviceId];
    if (creator == null) {
      developer.log(
        'No creator found for service: $serviceId',
        name: 'SyncServiceFactory',
      );
      return null;
    }

    try {
      final service = creator();
      developer.log(
        'Created sync service instance: $serviceId',
        name: 'SyncServiceFactory',
      );
      return service;
    } catch (e) {
      developer.log(
        'Error creating service $serviceId: $e',
        name: 'SyncServiceFactory',
      );
      return null;
    }
  }

  /// Retorna `true` se um criador para [serviceId] está registrado.
  bool supports(String serviceId) => _creators.containsKey(serviceId);

  /// Lista os IDs de todos os serviços registrados.
  List<String> get availableServices => _creators.keys.toList();

  /// Retorna os [ServiceMetadata] associados a [serviceId], ou `null` se
  /// não existirem metadados registrados.
  ServiceMetadata? getMetadata(String serviceId) => _metadata[serviceId];

  /// Retorna a lista de metadados de todos os serviços registrados.
  List<ServiceMetadata> getAllMetadata() => _metadata.values.toList();

  /// Cria múltiplas instâncias para os [serviceIds] fornecidos e retorna um
  /// mapa com os serviços que foram instanciados com sucesso.
  Map<String, ISyncService> createAll(List<String> serviceIds) {
    final services = <String, ISyncService>{};

    for (final serviceId in serviceIds) {
      final service = create(serviceId);
      if (service != null) {
        services[serviceId] = service;
      }
    }

    developer.log(
      'Created ${services.length}/${serviceIds.length} services',
      name: 'SyncServiceFactory',
    );

    return services;
  }

  /// Valida se todas as dependências declaradas em metadata para
  /// [serviceId] estão registradas.
  ///
  /// Retorna `true` quando todas as dependências estiverem presentes.
  bool validateDependencies(String serviceId) {
    final metadata = _metadata[serviceId];
    if (metadata == null) return false;

    for (final dependency in metadata.dependencies) {
      if (!supports(dependency)) {
        developer.log(
          'Missing dependency $dependency for service $serviceId',
          name: 'SyncServiceFactory',
        );
        return false;
      }
    }

    return true;
  }

  /// Calcula uma ordem de criação (topológica simplificada) para os
  /// [serviceIds] passada, respeitando dependências declaradas em
  /// [ServiceMetadata]. Quando não for possível resolver (ciclo), os
  /// serviços restantes são adicionados no final e um log é emitido.
  List<String> getCreationOrder(List<String> serviceIds) {
    final result = <String>[];
    final remaining = Set<String>.from(serviceIds);

    while (remaining.isNotEmpty) {
      final canCreate =
          remaining.where((serviceId) {
            final metadata = _metadata[serviceId];
            if (metadata == null) return true;
            return metadata.dependencies.every((dep) => result.contains(dep));
          }).toList();

      if (canCreate.isEmpty) {
        developer.log(
          'Cannot resolve dependencies for remaining services: $remaining',
          name: 'SyncServiceFactory',
        );
        result.addAll(remaining); // Adicionar restantes mesmo assim
        break;
      }

      result.addAll(canCreate);
      remaining.removeAll(canCreate);
    }

    return result;
  }

  /// Registra múltiplos serviços a partir de um mapa de [ServiceRegistration].
  ///
  /// Cada entrada do mapa deve fornecer um [ServiceRegistration] que
  /// descreve o criador e metadados opcionais.
  void registerBatch(Map<String, ServiceRegistration> registrations) {
    for (final entry in registrations.entries) {
      final serviceId = entry.key;
      final registration = entry.value;

      register(
        serviceId,
        registration.creator,
        displayName: registration.displayName,
        description: registration.description,
        version: registration.version,
        dependencies: registration.dependencies,
      );
    }

    developer.log(
      'Registered ${registrations.length} services in batch',
      name: 'SyncServiceFactory',
    );
  }

  /// Remove todos os registros e metadados da factory.
  void clear() {
    final count = _creators.length;
    _creators.clear();
    _metadata.clear();

    developer.log(
      'Cleared $count service registrations',
      name: 'SyncServiceFactory',
    );
  }

  /// Retorna um mapa com informações de debug (contagem, metadados e
  /// exemplo de ordem de criação) útil para logs e diagnósticos.
  Map<String, dynamic> getDebugInfo() {
    return {
      'total_services': _creators.length,
      'services': _metadata.values.map((m) => m.toMap()).toList(),
      'creation_order_example': getCreationOrder(availableServices),
    };
  }
}

/// Metadados de um serviço de sincronização.
///
/// Contém informações descritivas e dependências que podem ser utilizadas
/// para ordenação e apresentação em UI/ logs.
class ServiceMetadata {
  final String serviceId;
  final String displayName;
  final String description;
  final String version;
  final List<String> dependencies;
  final DateTime registeredAt;

  ServiceMetadata({
    required this.serviceId,
    required this.displayName,
    required this.description,
    required this.version,
    this.dependencies = const [],
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  /// Serializa os metadados para um mapa (útil para debug/JSON).
  Map<String, dynamic> toMap() {
    return {
      'service_id': serviceId,
      'display_name': displayName,
      'description': description,
      'version': version,
      'dependencies': dependencies,
      'registered_at': registeredAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ServiceMetadata($serviceId v$version)';
}

/// Representa os dados necessários para registro em lote de um serviço.
///
/// Inclui o [creator] (função de criação) e metadados opcionais como
/// [displayName], [description], [version] e [dependencies].
class ServiceRegistration {
  final ISyncService Function() creator;
  final String? displayName;
  final String? description;
  final String version;
  final List<String> dependencies;

  const ServiceRegistration({
    required this.creator,
    this.displayName,
    this.description,
    this.version = '1.0.0',
    this.dependencies = const [],
  });
}

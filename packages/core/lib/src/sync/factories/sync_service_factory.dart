import 'dart:developer' as developer;
import '../interfaces/i_sync_service.dart';

/// Factory para criação dinâmica de serviços de sincronização
/// Implementa Open/Closed Principle permitindo extensão sem modificação
class SyncServiceFactory {
  static final SyncServiceFactory _instance = SyncServiceFactory._internal();
  static SyncServiceFactory get instance => _instance;
  
  SyncServiceFactory._internal();
  
  // Registry de criadores de serviços
  final Map<String, ISyncService Function()> _creators = {};
  final Map<String, ServiceMetadata> _metadata = {};
  
  /// Registra um criador de serviço
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
  
  /// Remove o registro de um serviço
  void unregister(String serviceId) {
    if (_creators.remove(serviceId) != null) {
      _metadata.remove(serviceId);
      developer.log(
        'Unregistered sync service: $serviceId',
        name: 'SyncServiceFactory',
      );
    }
  }
  
  /// Cria uma instância do serviço
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
  
  /// Verifica se um serviço está registrado
  bool supports(String serviceId) => _creators.containsKey(serviceId);
  
  /// Lista todos os serviços disponíveis
  List<String> get availableServices => _creators.keys.toList();
  
  /// Obtém metadados de um serviço
  ServiceMetadata? getMetadata(String serviceId) => _metadata[serviceId];
  
  /// Lista metadados de todos os serviços
  List<ServiceMetadata> getAllMetadata() => _metadata.values.toList();
  
  /// Cria múltiplos serviços de uma vez
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
  
  /// Valida dependências de um serviço
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
  
  /// Obtém ordem de criação respeitando dependências
  List<String> getCreationOrder(List<String> serviceIds) {
    final result = <String>[];
    final remaining = Set<String>.from(serviceIds);
    
    while (remaining.isNotEmpty) {
      final canCreate = remaining.where((serviceId) {
        final metadata = _metadata[serviceId];
        if (metadata == null) return true;
        
        // Verificar se todas as dependências já foram criadas
        return metadata.dependencies.every((dep) => result.contains(dep));
      }).toList();
      
      if (canCreate.isEmpty) {
        // Circular dependency ou dependency não registrada
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
  
  /// Registra serviços em lote com validação
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
  
  /// Limpa todos os registros
  void clear() {
    final count = _creators.length;
    _creators.clear();
    _metadata.clear();
    
    developer.log(
      'Cleared $count service registrations',
      name: 'SyncServiceFactory',
    );
  }
  
  /// Obtém informações de debug
  Map<String, dynamic> getDebugInfo() {
    return {
      'total_services': _creators.length,
      'services': _metadata.values.map((m) => m.toMap()).toList(),
      'creation_order_example': getCreationOrder(availableServices),
    };
  }
}

/// Metadados de um serviço de sincronização
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

/// Registro de um serviço para batch registration
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
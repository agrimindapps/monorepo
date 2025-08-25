import 'package:equatable/equatable.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/maintenance_entity.dart';

/// Model reativo para o formulário de manutenção
class MaintenanceFormModel extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final String title;
  final String description;
  final double cost;
  final DateTime serviceDate;
  final double odometer;
  
  // Informações da oficina
  final String workshopName;
  final String workshopPhone;
  final String workshopAddress;
  
  // Próximo serviço
  final DateTime? nextServiceDate;
  final double? nextServiceOdometer;
  
  // Anexos
  final List<String> photosPaths;
  final List<String> invoicesPaths;
  
  // Peças e informações técnicas
  final Map<String, String> parts;
  final String notes;
  
  // Estado do formulário
  final bool isLoading;
  final bool hasChanges;
  final Map<String, String> errors;
  final String? lastError;

  const MaintenanceFormModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    this.vehicle,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.cost,
    required this.serviceDate,
    required this.odometer,
    required this.workshopName,
    required this.workshopPhone,
    required this.workshopAddress,
    this.nextServiceDate,
    this.nextServiceOdometer,
    this.photosPaths = const [],
    this.invoicesPaths = const [],
    this.parts = const {},
    required this.notes,
    this.isLoading = false,
    this.hasChanges = false,
    this.errors = const {},
    this.lastError,
  });

  /// Cria modelo inicial para nova manutenção
  factory MaintenanceFormModel.initial(String vehicleId, String userId) {
    return MaintenanceFormModel(
      id: '',
      userId: userId,
      vehicleId: vehicleId,
      vehicle: null,
      type: MaintenanceType.preventive,
      status: MaintenanceStatus.completed,
      title: '',
      description: '',
      cost: 0.0,
      serviceDate: DateTime.now(),
      odometer: 0.0,
      workshopName: '',
      workshopPhone: '',
      workshopAddress: '',
      nextServiceDate: null,
      nextServiceOdometer: null,
      photosPaths: const [],
      invoicesPaths: const [],
      parts: const {},
      notes: '',
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  /// Cria modelo a partir de uma manutenção existente para edição
  factory MaintenanceFormModel.fromMaintenanceEntity(MaintenanceEntity maintenance) {
    return MaintenanceFormModel(
      id: maintenance.id,
      userId: maintenance.userId,
      vehicleId: maintenance.vehicleId,
      vehicle: null, // Será carregado separadamente
      type: maintenance.type,
      status: maintenance.status,
      title: maintenance.title,
      description: maintenance.description,
      cost: maintenance.cost,
      serviceDate: maintenance.serviceDate,
      odometer: maintenance.odometer,
      workshopName: maintenance.workshopName ?? '',
      workshopPhone: maintenance.workshopPhone ?? '',
      workshopAddress: maintenance.workshopAddress ?? '',
      nextServiceDate: maintenance.nextServiceDate,
      nextServiceOdometer: maintenance.nextServiceOdometer,
      photosPaths: maintenance.photosPaths,
      invoicesPaths: maintenance.invoicesPaths,
      parts: maintenance.parts,
      notes: maintenance.notes ?? '',
      isLoading: false,
      hasChanges: false,
      errors: const {},
      lastError: null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    vehicle,
    type,
    status,
    title,
    description,
    cost,
    serviceDate,
    odometer,
    workshopName,
    workshopPhone,
    workshopAddress,
    nextServiceDate,
    nextServiceOdometer,
    photosPaths,
    invoicesPaths,
    parts,
    notes,
    isLoading,
    hasChanges,
    errors,
    lastError,
  ];

  /// Cria nova instância com valores atualizados
  MaintenanceFormModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    VehicleEntity? vehicle,
    MaintenanceType? type,
    MaintenanceStatus? status,
    String? title,
    String? description,
    double? cost,
    DateTime? serviceDate,
    double? odometer,
    String? workshopName,
    String? workshopPhone,
    String? workshopAddress,
    DateTime? nextServiceDate,
    double? nextServiceOdometer,
    List<String>? photosPaths,
    List<String>? invoicesPaths,
    Map<String, String>? parts,
    String? notes,
    bool? isLoading,
    bool? hasChanges,
    Map<String, String>? errors,
    String? lastError,
    bool clearWorkshop = false,
    bool clearNextService = false,
    bool clearLastError = false,
  }) {
    return MaintenanceFormModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      workshopName: clearWorkshop ? '' : (workshopName ?? this.workshopName),
      workshopPhone: clearWorkshop ? '' : (workshopPhone ?? this.workshopPhone),
      workshopAddress: clearWorkshop ? '' : (workshopAddress ?? this.workshopAddress),
      nextServiceDate: clearNextService ? null : (nextServiceDate ?? this.nextServiceDate),
      nextServiceOdometer: clearNextService ? null : (nextServiceOdometer ?? this.nextServiceOdometer),
      photosPaths: photosPaths ?? this.photosPaths,
      invoicesPaths: invoicesPaths ?? this.invoicesPaths,
      parts: parts ?? this.parts,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      errors: errors ?? this.errors,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  /// Verifica se o modelo tem dados válidos mínimos
  bool get hasMinimumData => 
      vehicleId.isNotEmpty && 
      title.trim().isNotEmpty && 
      description.trim().isNotEmpty &&
      cost > 0 &&
      odometer >= 0;

  /// Verifica se há erros de validação
  bool get hasErrors => errors.isNotEmpty;

  /// Verifica se o formulário está pronto para ser submetido
  bool get canSubmit => 
      hasMinimumData && 
      !hasErrors && 
      !isLoading;

  /// Verifica se é uma edição (tem ID)
  bool get isEditing => id.isNotEmpty;

  /// Verifica se tem informações da oficina
  bool get hasWorkshopInfo => 
      workshopName.trim().isNotEmpty || 
      workshopPhone.trim().isNotEmpty || 
      workshopAddress.trim().isNotEmpty;

  /// Verifica se tem próximo serviço configurado
  bool get hasNextService => nextServiceDate != null || nextServiceOdometer != null;

  /// Verifica se tem fotos
  bool get hasPhotos => photosPaths.isNotEmpty;

  /// Verifica se tem notas fiscais
  bool get hasInvoices => invoicesPaths.isNotEmpty;

  /// Verifica se tem peças registradas
  bool get hasParts => parts.isNotEmpty;

  /// Verifica se tem observações
  bool get hasNotes => notes.trim().isNotEmpty;

  /// Verifica se é uma manutenção de alto custo
  bool get isHighCost => cost >= 1000.0;

  /// Verifica se é uma manutenção recorrente
  bool get isRecurring => type.isRecurring;

  /// Retorna mensagem de erro para um campo específico
  String? getFieldError(String field) => errors[field];

  /// Verifica se um campo específico tem erro
  bool hasFieldError(String field) => errors.containsKey(field);

  /// Adiciona erro para um campo específico
  MaintenanceFormModel setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(errors);
    newErrors[field] = error;
    return copyWith(errors: newErrors);
  }

  /// Remove erro de um campo específico
  MaintenanceFormModel clearFieldError(String field) {
    if (!errors.containsKey(field)) return this;
    
    final newErrors = Map<String, String>.from(errors);
    newErrors.remove(field);
    return copyWith(errors: newErrors);
  }

  /// Limpa todos os erros
  MaintenanceFormModel clearAllErrors() {
    return copyWith(errors: const {});
  }

  /// Marca o formulário como tendo alterações
  MaintenanceFormModel markAsChanged() {
    return copyWith(hasChanges: true);
  }

  /// Valida todos os campos e retorna mapa de erros
  Map<String, String> validate() {
    final validationErrors = <String, String>{};

    // Validar veículo
    if (vehicleId.isEmpty) {
      validationErrors['vehicleId'] = 'Veículo é obrigatório';
    }

    // Validar título
    if (title.trim().isEmpty) {
      validationErrors['title'] = 'Título é obrigatório';
    } else if (title.trim().length < 3) {
      validationErrors['title'] = 'Título muito curto (mínimo 3 caracteres)';
    } else if (title.trim().length > 100) {
      validationErrors['title'] = 'Título muito longo (máximo 100 caracteres)';
    }

    // Validar descrição
    if (description.trim().isEmpty) {
      validationErrors['description'] = 'Descrição é obrigatória';
    } else if (description.trim().length < 5) {
      validationErrors['description'] = 'Descrição muito curta (mínimo 5 caracteres)';
    } else if (description.trim().length > 500) {
      validationErrors['description'] = 'Descrição muito longa (máximo 500 caracteres)';
    }

    // Validar valor
    if (cost <= 0) {
      validationErrors['cost'] = 'Valor deve ser maior que zero';
    } else if (cost > 999999.99) {
      validationErrors['cost'] = 'Valor muito alto';
    }

    // Validar odômetro
    if (odometer < 0) {
      validationErrors['odometer'] = 'Odômetro não pode ser negativo';
    } else if (odometer > 9999999) {
      validationErrors['odometer'] = 'Valor muito alto';
    }

    // Validar data
    final now = DateTime.now();
    if (serviceDate.isAfter(now)) {
      validationErrors['serviceDate'] = 'Data não pode ser futura';
    }

    // Validar campos opcionais da oficina
    if (workshopName.trim().isNotEmpty && workshopName.trim().length < 2) {
      validationErrors['workshopName'] = 'Nome da oficina muito curto';
    }
    
    if (workshopPhone.trim().isNotEmpty) {
      final cleanPhone = workshopPhone.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPhone.length < 10 || cleanPhone.length > 11) {
        validationErrors['workshopPhone'] = 'Telefone deve ter 10 ou 11 dígitos';
      }
    }

    // Validar próximo serviço
    if (nextServiceDate != null && nextServiceDate!.isBefore(serviceDate)) {
      validationErrors['nextServiceDate'] = 'Data da próxima manutenção deve ser posterior';
    }
    
    if (nextServiceOdometer != null && nextServiceOdometer! <= odometer) {
      validationErrors['nextServiceOdometer'] = 'Odômetro da próxima deve ser maior';
    }

    // Validar observações (opcional)
    if (notes.trim().isNotEmpty && notes.trim().length > 1000) {
      validationErrors['notes'] = 'Observação muito longa (máximo 1000 caracteres)';
    }

    return validationErrors;
  }

  /// Converte para MaintenanceEntity para persistência
  MaintenanceEntity toMaintenanceEntity() {
    final now = DateTime.now();
    
    return MaintenanceEntity(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      userId: userId,
      vehicleId: vehicleId,
      type: type,
      status: status,
      title: title.trim(),
      description: description.trim(),
      cost: cost,
      serviceDate: serviceDate,
      odometer: odometer,
      workshopName: workshopName.trim().isEmpty ? null : workshopName.trim(),
      workshopPhone: workshopPhone.trim().isEmpty ? null : workshopPhone.trim(),
      workshopAddress: workshopAddress.trim().isEmpty ? null : workshopAddress.trim(),
      nextServiceDate: nextServiceDate,
      nextServiceOdometer: nextServiceOdometer,
      photosPaths: photosPaths,
      invoicesPaths: invoicesPaths,
      parts: parts,
      notes: notes.trim().isEmpty ? null : notes.trim(),
      createdAt: id.isEmpty ? now : DateTime.fromMillisecondsSinceEpoch(int.tryParse(id) ?? now.millisecondsSinceEpoch),
      updatedAt: now,
      metadata: const {},
    );
  }

  /// Reseta formulário para estado inicial
  MaintenanceFormModel reset() {
    return MaintenanceFormModel.initial(vehicleId, userId).copyWith(
      vehicle: vehicle,
    );
  }

  /// Cria cópia limpa sem alterações ou erros
  MaintenanceFormModel clean() {
    return copyWith(
      hasChanges: false,
      errors: const {},
      lastError: null,
      clearLastError: true,
    );
  }

  /// Estatísticas do formulário para debug
  Map<String, dynamic> get stats => {
    'isValid': canSubmit,
    'hasErrors': hasErrors,
    'hasChanges': hasChanges,
    'isEditing': isEditing,
    'hasWorkshopInfo': hasWorkshopInfo,
    'hasNextService': hasNextService,
    'hasPhotos': hasPhotos,
    'hasInvoices': hasInvoices,
    'hasParts': hasParts,
    'hasNotes': hasNotes,
    'isHighCost': isHighCost,
    'isRecurring': isRecurring,
    'errorCount': errors.length,
  };

  /// Resumo textual do modelo
  String get summary {
    final parts = <String>[
      type.displayName,
      'R\$ ${cost.toStringAsFixed(2).replaceAll('.', ',')}',
    ];
    
    if (hasWorkshopInfo && workshopName.trim().isNotEmpty) {
      parts.add(workshopName.trim());
    }
    
    return parts.join(' • ');
  }
}
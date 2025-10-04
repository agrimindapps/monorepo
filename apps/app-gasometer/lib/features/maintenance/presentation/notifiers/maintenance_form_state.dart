import 'package:equatable/equatable.dart';

import '../../../vehicles/domain/entities/vehicle_entity.dart';
import '../../domain/entities/maintenance_entity.dart';

/// Estado imutável do formulário de manutenção para Riverpod
class MaintenanceFormState extends Equatable {
  // ==================== Constructors ====================

  const MaintenanceFormState({
    this.id = '',
    this.userId = '',
    this.vehicleId = '',
    this.vehicle,
    this.type = MaintenanceType.preventive,
    this.status = MaintenanceStatus.pending,
    this.title = '',
    this.description = '',
    this.cost = 0.0,
    this.serviceDate,
    this.odometer = 0.0,
    this.workshopName = '',
    this.workshopPhone = '',
    this.workshopAddress = '',
    this.nextServiceDate,
    this.nextServiceOdometer,
    this.photosPaths = const [],
    this.invoicesPaths = const [],
    this.parts = const {},
    this.notes = '',
    this.receiptImagePath,
    this.receiptImageUrl,
    this.isLoading = false,
    this.isUploadingImage = false,
    this.hasChanges = false,
    this.isInitialized = false,
    this.errorMessage,
    this.imageUploadError,
    this.fieldErrors = const {},
  });

  /// Estado inicial para nova manutenção
  factory MaintenanceFormState.initial({
    required String vehicleId,
    required String userId,
  }) {
    return MaintenanceFormState(
      vehicleId: vehicleId,
      userId: userId,
      serviceDate: DateTime.now(),
    );
  }

  /// Estado a partir de manutenção existente (edição)
  factory MaintenanceFormState.fromMaintenance(MaintenanceEntity maintenance) {
    return MaintenanceFormState(
      id: maintenance.id,
      userId: maintenance.userId ?? '',
      vehicleId: maintenance.vehicleId,
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
    );
  }

  // ==================== Fields ====================

  final String id;
  final String userId;
  final String vehicleId;
  final VehicleEntity? vehicle;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final String title;
  final String description;
  final double cost;
  final DateTime? serviceDate;
  final double odometer;

  // Workshop information
  final String workshopName;
  final String workshopPhone;
  final String workshopAddress;

  // Next service
  final DateTime? nextServiceDate;
  final double? nextServiceOdometer;

  // Attachments
  final List<String> photosPaths;
  final List<String> invoicesPaths;

  // Parts and technical information
  final Map<String, String> parts;
  final String notes;

  // Receipt image (single)
  final String? receiptImagePath;
  final String? receiptImageUrl;

  // Form state
  final bool isLoading;
  final bool isUploadingImage;
  final bool hasChanges;
  final bool isInitialized;
  final String? errorMessage;
  final String? imageUploadError;
  final Map<String, String> fieldErrors;

  // ==================== Equatable Props ====================

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
        receiptImagePath,
        receiptImageUrl,
        isLoading,
        isUploadingImage,
        hasChanges,
        isInitialized,
        errorMessage,
        imageUploadError,
        fieldErrors,
      ];

  // ==================== Computed Properties ====================

  /// Verifica se tem comprovante (local ou remoto)
  bool get hasReceiptImage => receiptImagePath != null || receiptImageUrl != null;

  /// Verifica se está em algum estado de loading
  bool get isProcessing => isLoading || isUploadingImage;

  /// Verifica se tem dados mínimos válidos
  bool get hasMinimumData =>
      vehicleId.isNotEmpty &&
      title.trim().isNotEmpty &&
      cost >= 0 &&
      odometer >= 0;

  /// Verifica se tem erros de validação
  bool get hasErrors => fieldErrors.isNotEmpty;

  /// Verifica se o formulário pode ser submetido
  bool get canSubmit => hasMinimumData && !hasErrors && !isProcessing;

  /// Verifica se é edição (tem ID)
  bool get isEditing => id.isNotEmpty;

  /// Verifica se a manutenção está concluída
  bool get isCompleted => status == MaintenanceStatus.completed;

  /// Verifica se a manutenção está pendente
  bool get isPending => status == MaintenanceStatus.pending;

  /// Verifica se a manutenção está em andamento
  bool get isInProgress => status == MaintenanceStatus.inProgress;

  /// Verifica se a manutenção foi cancelada
  bool get isCancelled => status == MaintenanceStatus.cancelled;

  /// Verifica se é manutenção preventiva
  bool get isPreventive => type == MaintenanceType.preventive;

  /// Verifica se é manutenção corretiva
  bool get isCorrective => type == MaintenanceType.corrective;

  /// Verifica se é revisão/inspeção
  bool get isInspection => type == MaintenanceType.inspection;

  /// Verifica se é manutenção emergencial
  bool get isEmergency => type == MaintenanceType.emergency;

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

  /// Retorna mensagem de erro de um campo específico
  String? getFieldError(String field) => fieldErrors[field];

  /// Verifica se um campo específico tem erro
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  // ==================== CopyWith Methods ====================

  MaintenanceFormState copyWith({
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
    String? receiptImagePath,
    String? receiptImageUrl,
    bool? isLoading,
    bool? isUploadingImage,
    bool? hasChanges,
    bool? isInitialized,
    String? Function()? errorMessage,
    String? Function()? imageUploadError,
    Map<String, String>? fieldErrors,
    bool clearWorkshop = false,
    bool clearNextService = false,
    bool clearReceiptImage = false,
    bool clearReceiptUrl = false,
  }) {
    return MaintenanceFormState(
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
      receiptImagePath: clearReceiptImage
          ? null
          : (receiptImagePath ?? this.receiptImagePath),
      receiptImageUrl: clearReceiptUrl
          ? null
          : (receiptImageUrl ?? this.receiptImageUrl),
      isLoading: isLoading ?? this.isLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      hasChanges: hasChanges ?? this.hasChanges,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      imageUploadError: imageUploadError != null ? imageUploadError() : this.imageUploadError,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  /// Limpa erro geral
  MaintenanceFormState clearError() {
    return copyWith(errorMessage: () => null);
  }

  /// Limpa erro de upload de imagem
  MaintenanceFormState clearImageError() {
    return copyWith(imageUploadError: () => null);
  }

  /// Define erro em um campo específico
  MaintenanceFormState setFieldError(String field, String error) {
    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors[field] = error;
    return copyWith(fieldErrors: newErrors);
  }

  /// Remove erro de um campo específico
  MaintenanceFormState clearFieldError(String field) {
    if (!fieldErrors.containsKey(field)) return this;

    final newErrors = Map<String, String>.from(fieldErrors);
    newErrors.remove(field);
    return copyWith(fieldErrors: newErrors);
  }

  /// Limpa todos os erros de campos
  MaintenanceFormState clearAllFieldErrors() {
    return copyWith(fieldErrors: const {});
  }

  /// Marca formulário como alterado
  MaintenanceFormState markAsChanged() {
    return copyWith(hasChanges: true);
  }
}

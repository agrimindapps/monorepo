enum AppPlatform {
  android('android', 'Android', 'Google Play'),
  ios('ios', 'iOS', 'App Store');

  const AppPlatform(this.id, this.displayName, this.storeName);
  final String id;
  final String displayName;
  final String storeName;
}

enum RegistrationStatus {
  pending('pending', 'Pendente'),
  confirmed('confirmed', 'Confirmado'),
  notified('notified', 'Notificado'),
  cancelled('cancelled', 'Cancelado');

  const RegistrationStatus(this.id, this.displayName);
  final String id;
  final String displayName;
}

class PreRegisterData {
  final String name;
  final String email;
  final AppPlatform platform;
  final DateTime registrationDate;
  final RegistrationStatus status;
  final String? confirmationToken;
  final Map<String, dynamic>? metadata;

  const PreRegisterData({
    required this.name,
    required this.email,
    required this.platform,
    required this.registrationDate,
    this.status = RegistrationStatus.pending,
    this.confirmationToken,
    this.metadata,
  });

  PreRegisterData copyWith({
    String? name,
    String? email,
    AppPlatform? platform,
    DateTime? registrationDate,
    RegistrationStatus? status,
    String? confirmationToken,
    Map<String, dynamic>? metadata,
  }) {
    return PreRegisterData(
      name: name ?? this.name,
      email: email ?? this.email,
      platform: platform ?? this.platform,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      confirmationToken: confirmationToken ?? this.confirmationToken,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isConfirmed => status == RegistrationStatus.confirmed;
  bool get isPending => status == RegistrationStatus.pending;
  bool get isNotified => status == RegistrationStatus.notified;
  bool get isCancelled => status == RegistrationStatus.cancelled;

  String get platformName => platform.displayName;
  String get storeName => platform.storeName;

  Duration get timeSinceRegistration {
    return DateTime.now().difference(registrationDate);
  }

  String get formattedRegistrationDate {
    return '${registrationDate.day}/${registrationDate.month}/${registrationDate.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'platform': platform.id,
      'registrationDate': registrationDate.toIso8601String(),
      'status': status.id,
      'confirmationToken': confirmationToken,
      'metadata': metadata,
    };
  }

  static PreRegisterData fromJson(Map<String, dynamic> json) {
    return PreRegisterData(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      platform: _getAppPlatformById(json['platform'] ?? 'android'),
      registrationDate: DateTime.parse(json['registrationDate'] ?? DateTime.now().toIso8601String()),
      status: _getRegistrationStatusById(json['status'] ?? 'pending'),
      confirmationToken: json['confirmationToken'],
      metadata: json['metadata'],
    );
  }

  static AppPlatform _getAppPlatformById(String id) {
    return AppPlatform.values.firstWhere(
      (platform) => platform.id == id,
      orElse: () => AppPlatform.android,
    );
  }

  static RegistrationStatus _getRegistrationStatusById(String id) {
    return RegistrationStatus.values.firstWhere(
      (status) => status.id == id,
      orElse: () => RegistrationStatus.pending,
    );
  }

  @override
  String toString() {
    return 'PreRegisterData(name: $name, email: $email, platform: ${platform.id}, status: ${status.id})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreRegisterData &&
        other.email == email &&
        other.platform == platform;
  }

  @override
  int get hashCode {
    return Object.hash(email, platform);
  }
}

class PreRegisterForm {
  final String name;
  final String email;
  final AppPlatform? selectedPlatform;
  final Map<String, String> errors;
  final bool isValid;
  final bool isSubmitting;

  const PreRegisterForm({
    this.name = '',
    this.email = '',
    this.selectedPlatform,
    this.errors = const {},
    this.isValid = false,
    this.isSubmitting = false,
  });

  PreRegisterForm copyWith({
    String? name,
    String? email,
    AppPlatform? selectedPlatform,
    Map<String, String>? errors,
    bool? isValid,
    bool? isSubmitting,
  }) {
    return PreRegisterForm(
      name: name ?? this.name,
      email: email ?? this.email,
      selectedPlatform: selectedPlatform ?? this.selectedPlatform,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasNameError => errors.containsKey('name');
  bool get hasEmailError => errors.containsKey('email');
  bool get hasPlatformError => errors.containsKey('platform');

  String? getError(String field) => errors[field];

  bool get canSubmit => isValid && !isSubmitting && selectedPlatform != null;

  PreRegisterData toRegistrationData() {
    if (!canSubmit) {
      throw StateError('Form is not valid for submission');
    }

    return PreRegisterData(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      platform: selectedPlatform!,
      registrationDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'selectedPlatform': selectedPlatform?.id,
      'errors': errors,
      'isValid': isValid,
      'isSubmitting': isSubmitting,
    };
  }

  @override
  String toString() {
    return 'PreRegisterForm(name: $name, email: $email, platform: ${selectedPlatform?.id}, isValid: $isValid)';
  }
}

class NotificationPreferences {
  final bool enableEmailNotifications;
  final bool enableLaunchNotification;
  final bool enableUpdatesNotification;
  final bool enablePromotionalEmails;
  final String? preferredLanguage;

  const NotificationPreferences({
    this.enableEmailNotifications = true,
    this.enableLaunchNotification = true,
    this.enableUpdatesNotification = false,
    this.enablePromotionalEmails = false,
    this.preferredLanguage,
  });

  NotificationPreferences copyWith({
    bool? enableEmailNotifications,
    bool? enableLaunchNotification,
    bool? enableUpdatesNotification,
    bool? enablePromotionalEmails,
    String? preferredLanguage,
  }) {
    return NotificationPreferences(
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      enableLaunchNotification: enableLaunchNotification ?? this.enableLaunchNotification,
      enableUpdatesNotification: enableUpdatesNotification ?? this.enableUpdatesNotification,
      enablePromotionalEmails: enablePromotionalEmails ?? this.enablePromotionalEmails,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  bool get hasAnyNotificationEnabled {
    return enableEmailNotifications || enableLaunchNotification || enableUpdatesNotification;
  }

  Map<String, dynamic> toJson() {
    return {
      'enableEmailNotifications': enableEmailNotifications,
      'enableLaunchNotification': enableLaunchNotification,
      'enableUpdatesNotification': enableUpdatesNotification,
      'enablePromotionalEmails': enablePromotionalEmails,
      'preferredLanguage': preferredLanguage,
    };
  }

  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enableEmailNotifications: json['enableEmailNotifications'] ?? true,
      enableLaunchNotification: json['enableLaunchNotification'] ?? true,
      enableUpdatesNotification: json['enableUpdatesNotification'] ?? false,
      enablePromotionalEmails: json['enablePromotionalEmails'] ?? false,
      preferredLanguage: json['preferredLanguage'],
    );
  }

  @override
  String toString() {
    return 'NotificationPreferences(enableEmailNotifications: $enableEmailNotifications, enableLaunchNotification: $enableLaunchNotification)';
  }
}

class PreRegisterStatistics {
  final int totalRegistrations;
  final Map<String, int> registrationsByPlatform;
  final Map<String, int> registrationsByStatus;
  final DateTime? firstRegistration;
  final DateTime? lastRegistration;
  final double averageRegistrationsPerDay;

  const PreRegisterStatistics({
    this.totalRegistrations = 0,
    this.registrationsByPlatform = const {},
    this.registrationsByStatus = const {},
    this.firstRegistration,
    this.lastRegistration,
    this.averageRegistrationsPerDay = 0.0,
  });

  PreRegisterStatistics copyWith({
    int? totalRegistrations,
    Map<String, int>? registrationsByPlatform,
    Map<String, int>? registrationsByStatus,
    DateTime? firstRegistration,
    DateTime? lastRegistration,
    double? averageRegistrationsPerDay,
  }) {
    return PreRegisterStatistics(
      totalRegistrations: totalRegistrations ?? this.totalRegistrations,
      registrationsByPlatform: registrationsByPlatform ?? this.registrationsByPlatform,
      registrationsByStatus: registrationsByStatus ?? this.registrationsByStatus,
      firstRegistration: firstRegistration ?? this.firstRegistration,
      lastRegistration: lastRegistration ?? this.lastRegistration,
      averageRegistrationsPerDay: averageRegistrationsPerDay ?? this.averageRegistrationsPerDay,
    );
  }

  int getRegistrationsForPlatform(AppPlatform platform) {
    return registrationsByPlatform[platform.id] ?? 0;
  }

  int getRegistrationsForStatus(RegistrationStatus status) {
    return registrationsByStatus[status.id] ?? 0;
  }

  double get androidPercentage {
    if (totalRegistrations == 0) return 0.0;
    return (getRegistrationsForPlatform(AppPlatform.android) / totalRegistrations) * 100;
  }

  double get iosPercentage {
    if (totalRegistrations == 0) return 0.0;
    return (getRegistrationsForPlatform(AppPlatform.ios) / totalRegistrations) * 100;
  }

  Duration? get registrationPeriod {
    if (firstRegistration == null || lastRegistration == null) return null;
    return lastRegistration!.difference(firstRegistration!);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRegistrations': totalRegistrations,
      'registrationsByPlatform': registrationsByPlatform,
      'registrationsByStatus': registrationsByStatus,
      'firstRegistration': firstRegistration?.toIso8601String(),
      'lastRegistration': lastRegistration?.toIso8601String(),
      'averageRegistrationsPerDay': averageRegistrationsPerDay,
    };
  }

  static PreRegisterStatistics fromJson(Map<String, dynamic> json) {
    return PreRegisterStatistics(
      totalRegistrations: json['totalRegistrations'] ?? 0,
      registrationsByPlatform: Map<String, int>.from(json['registrationsByPlatform'] ?? {}),
      registrationsByStatus: Map<String, int>.from(json['registrationsByStatus'] ?? {}),
      firstRegistration: json['firstRegistration'] != null 
          ? DateTime.parse(json['firstRegistration'])
          : null,
      lastRegistration: json['lastRegistration'] != null 
          ? DateTime.parse(json['lastRegistration'])
          : null,
      averageRegistrationsPerDay: (json['averageRegistrationsPerDay'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'PreRegisterStatistics(totalRegistrations: $totalRegistrations, androidPercentage: ${androidPercentage.toStringAsFixed(1)}%, iosPercentage: ${iosPercentage.toStringAsFixed(1)}%)';
  }
}

class PreRegisterRepository {
  static List<AppPlatform> getAvailablePlatforms() {
    return AppPlatform.values;
  }

  static List<RegistrationStatus> getAvailableStatuses() {
    return RegistrationStatus.values;
  }

  static AppPlatform? getPlatformById(String id) {
    try {
      return AppPlatform.values.firstWhere((platform) => platform.id == id);
    } catch (e) {
      return null;
    }
  }

  static RegistrationStatus? getStatusById(String id) {
    try {
      return RegistrationStatus.values.firstWhere((status) => status.id == id);
    } catch (e) {
      return null;
    }
  }

  static Map<String, String> validateForm(PreRegisterForm form) {
    final errors = <String, String>{};

    // Validate name
    if (form.name.trim().isEmpty) {
      errors['name'] = 'Nome é obrigatório';
    } else if (form.name.trim().length < 2) {
      errors['name'] = 'Nome deve ter pelo menos 2 caracteres';
    }

    // Validate email
    if (form.email.trim().isEmpty) {
      errors['email'] = 'Email é obrigatório';
    } else if (!_isValidEmail(form.email.trim())) {
      errors['email'] = 'Email inválido';
    }

    // Validate platform
    if (form.selectedPlatform == null) {
      errors['platform'] = 'Selecione uma plataforma';
    }

    return errors;
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static PreRegisterForm validateAndUpdateForm(PreRegisterForm form) {
    final errors = validateForm(form);
    final isValid = errors.isEmpty;

    return form.copyWith(
      errors: errors,
      isValid: isValid,
    );
  }

  static NotificationPreferences getDefaultPreferences() {
    return const NotificationPreferences(
      enableEmailNotifications: true,
      enableLaunchNotification: true,
      enableUpdatesNotification: false,
      enablePromotionalEmails: false,
    );
  }

  static PreRegisterStatistics getMockStatistics() {
    return PreRegisterStatistics(
      totalRegistrations: 1250,
      registrationsByPlatform: {
        'android': 750,
        'ios': 500,
      },
      registrationsByStatus: {
        'pending': 100,
        'confirmed': 1100,
        'notified': 45,
        'cancelled': 5,
      },
      firstRegistration: DateTime.now().subtract(const Duration(days: 90)),
      lastRegistration: DateTime.now().subtract(const Duration(hours: 2)),
      averageRegistrationsPerDay: 13.9,
    );
  }

  static String getPlatformStoreName(AppPlatform platform) {
    return platform.storeName;
  }

  static String getPlatformDisplayName(AppPlatform platform) {
    return platform.displayName;
  }

  static String getStatusDisplayName(RegistrationStatus status) {
    return status.displayName;
  }

  static Map<String, String> getPlatformStoreUrls() {
    return {
      'android': 'https://play.google.com/store/apps/details?id=com.petiveti',
      'ios': 'https://apps.apple.com/app/petiveti/id123456789',
    };
  }

  static String? getStoreUrlForPlatform(AppPlatform platform) {
    final urls = getPlatformStoreUrls();
    return urls[platform.id];
  }

  static String generateConfirmationToken() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'token_$timestamp';
  }

  static PreRegisterData createRegistrationData({
    required String name,
    required String email,
    required AppPlatform platform,
  }) {
    return PreRegisterData(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      platform: platform,
      registrationDate: DateTime.now(),
      status: RegistrationStatus.pending,
      confirmationToken: generateConfirmationToken(),
    );
  }

  static bool canRegisterEmail(String email, List<PreRegisterData> existingRegistrations) {
    final normalizedEmail = email.trim().toLowerCase();
    return !existingRegistrations.any((reg) => reg.email == normalizedEmail);
  }

  static List<PreRegisterData> filterByPlatform(List<PreRegisterData> registrations, AppPlatform platform) {
    return registrations.where((reg) => reg.platform == platform).toList();
  }

  static List<PreRegisterData> filterByStatus(List<PreRegisterData> registrations, RegistrationStatus status) {
    return registrations.where((reg) => reg.status == status).toList();
  }

  static PreRegisterStatistics calculateStatistics(List<PreRegisterData> registrations) {
    if (registrations.isEmpty) {
      return const PreRegisterStatistics();
    }

    final platformCounts = <String, int>{};
    final statusCounts = <String, int>{};
    DateTime? firstReg, lastReg;

    for (final reg in registrations) {
      platformCounts[reg.platform.id] = (platformCounts[reg.platform.id] ?? 0) + 1;
      statusCounts[reg.status.id] = (statusCounts[reg.status.id] ?? 0) + 1;

      if (firstReg == null || reg.registrationDate.isBefore(firstReg)) {
        firstReg = reg.registrationDate;
      }
      if (lastReg == null || reg.registrationDate.isAfter(lastReg)) {
        lastReg = reg.registrationDate;
      }
    }

    double averagePerDay = 0.0;
    if (firstReg != null && lastReg != null) {
      final days = lastReg.difference(firstReg).inDays + 1;
      averagePerDay = registrations.length / days;
    }

    return PreRegisterStatistics(
      totalRegistrations: registrations.length,
      registrationsByPlatform: platformCounts,
      registrationsByStatus: statusCounts,
      firstRegistration: firstReg,
      lastRegistration: lastReg,
      averageRegistrationsPerDay: averagePerDay,
    );
  }
}
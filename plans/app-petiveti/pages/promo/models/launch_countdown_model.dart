
enum LaunchStatus {
  preAnnouncement('pre_announcement', 'Pré-anúncio'),
  countdown('countdown', 'Contagem Regressiva'),
  launched('launched', 'Lançado'),
  postLaunch('post_launch', 'Pós-lançamento');

  const LaunchStatus(this.id, this.displayName);
  final String id;
  final String displayName;
}

class LaunchCountdown {
  final DateTime launchDate;
  final DateTime currentDate;
  final LaunchStatus status;
  final String? customMessage;

  const LaunchCountdown({
    required this.launchDate,
    required this.currentDate,
    required this.status,
    this.customMessage,
  });

  LaunchCountdown copyWith({
    DateTime? launchDate,
    DateTime? currentDate,
    LaunchStatus? status,
    String? customMessage,
  }) {
    return LaunchCountdown(
      launchDate: launchDate ?? this.launchDate,
      currentDate: currentDate ?? this.currentDate,
      status: status ?? this.status,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  Duration get timeRemaining {
    if (launchDate.isBefore(currentDate)) {
      return Duration.zero;
    }
    return launchDate.difference(currentDate);
  }

  bool get isLaunched => currentDate.isAfter(launchDate);
  bool get isCountdownActive => !isLaunched && timeRemaining.inDays <= 365;

  int get daysRemaining => timeRemaining.inDays;
  int get hoursRemaining => timeRemaining.inHours.remainder(24);
  int get minutesRemaining => timeRemaining.inMinutes.remainder(60);
  int get secondsRemaining => timeRemaining.inSeconds.remainder(60);

  String get formattedLaunchDate {
    return '${launchDate.day}/${launchDate.month}/${launchDate.year}';
  }

  String get countdownText {
    if (isLaunched) {
      return 'Aplicativo Disponível!';
    }
    
    if (daysRemaining > 0) {
      return 'Faltam apenas $daysRemaining dias';
    } else if (hoursRemaining > 0) {
      return 'Faltam $hoursRemaining horas e $minutesRemaining minutos';
    } else {
      return 'Faltam $minutesRemaining minutos e $secondsRemaining segundos';
    }
  }

  String get statusMessage {
    switch (status) {
      case LaunchStatus.preAnnouncement:
        return 'Em desenvolvimento';
      case LaunchStatus.countdown:
        return 'Lançamento em breve';
      case LaunchStatus.launched:
        return 'Disponível para download';
      case LaunchStatus.postLaunch:
        return 'Baixe agora';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'launchDate': launchDate.toIso8601String(),
      'currentDate': currentDate.toIso8601String(),
      'status': status.id,
      'customMessage': customMessage,
    };
  }

  static LaunchCountdown fromJson(Map<String, dynamic> json) {
    return LaunchCountdown(
      launchDate: DateTime.parse(json['launchDate']),
      currentDate: DateTime.parse(json['currentDate']),
      status: _getLaunchStatusById(json['status'] ?? 'countdown'),
      customMessage: json['customMessage'],
    );
  }

  static LaunchStatus _getLaunchStatusById(String id) {
    return LaunchStatus.values.firstWhere(
      (status) => status.id == id,
      orElse: () => LaunchStatus.countdown,
    );
  }

  @override
  String toString() {
    return 'LaunchCountdown(launchDate: $launchDate, status: ${status.id}, daysRemaining: $daysRemaining)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LaunchCountdown &&
        other.launchDate == launchDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(launchDate, status);
  }
}

class CountdownUnit {
  final String value;
  final String label;
  final CountdownUnitType type;

  const CountdownUnit({
    required this.value,
    required this.label,
    required this.type,
  });

  CountdownUnit copyWith({
    String? value,
    String? label,
    CountdownUnitType? type,
  }) {
    return CountdownUnit(
      value: value ?? this.value,
      label: label ?? this.label,
      type: type ?? this.type,
    );
  }

  String get paddedValue {
    switch (type) {
      case CountdownUnitType.days:
        return value;
      case CountdownUnitType.hours:
      case CountdownUnitType.minutes:
      case CountdownUnitType.seconds:
        return value.padLeft(2, '0');
    }
  }

  @override
  String toString() {
    return 'CountdownUnit(value: $value, label: $label, type: ${type.name})';
  }
}

enum CountdownUnitType {
  days,
  hours,
  minutes,
  seconds,
}

class LaunchInformation {
  final String appName;
  final String version;
  final List<String> platforms;
  final Map<String, String> storeUrls;
  final String? releaseNotes;
  final List<String> newFeatures;

  const LaunchInformation({
    required this.appName,
    required this.version,
    required this.platforms,
    required this.storeUrls,
    this.releaseNotes,
    this.newFeatures = const [],
  });

  LaunchInformation copyWith({
    String? appName,
    String? version,
    List<String>? platforms,
    Map<String, String>? storeUrls,
    String? releaseNotes,
    List<String>? newFeatures,
  }) {
    return LaunchInformation(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      platforms: platforms ?? this.platforms,
      storeUrls: storeUrls ?? this.storeUrls,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      newFeatures: newFeatures ?? this.newFeatures,
    );
  }

  bool get hasMultiplePlatforms => platforms.length > 1;
  bool get hasReleaseNotes => releaseNotes != null && releaseNotes!.isNotEmpty;
  bool get hasNewFeatures => newFeatures.isNotEmpty;

  String? getStoreUrl(String platform) {
    return storeUrls[platform.toLowerCase()];
  }

  List<String> get availablePlatforms => storeUrls.keys.toList();

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'version': version,
      'platforms': platforms,
      'storeUrls': storeUrls,
      'releaseNotes': releaseNotes,
      'newFeatures': newFeatures,
    };
  }

  static LaunchInformation fromJson(Map<String, dynamic> json) {
    return LaunchInformation(
      appName: json['appName'] ?? '',
      version: json['version'] ?? '',
      platforms: List<String>.from(json['platforms'] ?? []),
      storeUrls: Map<String, String>.from(json['storeUrls'] ?? {}),
      releaseNotes: json['releaseNotes'],
      newFeatures: List<String>.from(json['newFeatures'] ?? []),
    );
  }

  @override
  String toString() {
    return 'LaunchInformation(appName: $appName, version: $version, platforms: $platforms)';
  }
}

class LaunchCountdownRepository {
  static LaunchCountdown getCurrentCountdown() {
    // Data de lançamento prevista - 1º de outubro de 2025
    final launchDate = DateTime(2025, 10, 1);
    final currentDate = DateTime.now();
    
    LaunchStatus status;
    if (currentDate.isAfter(launchDate)) {
      status = LaunchStatus.launched;
    } else if (launchDate.difference(currentDate).inDays <= 30) {
      status = LaunchStatus.countdown;
    } else {
      status = LaunchStatus.preAnnouncement;
    }

    return LaunchCountdown(
      launchDate: launchDate,
      currentDate: currentDate,
      status: status,
    );
  }

  static LaunchCountdown getCountdownWithCustomDate(DateTime launchDate) {
    final currentDate = DateTime.now();
    
    LaunchStatus status;
    if (currentDate.isAfter(launchDate)) {
      status = LaunchStatus.launched;
    } else if (launchDate.difference(currentDate).inDays <= 30) {
      status = LaunchStatus.countdown;
    } else {
      status = LaunchStatus.preAnnouncement;
    }

    return LaunchCountdown(
      launchDate: launchDate,
      currentDate: currentDate,
      status: status,
    );
  }

  static List<CountdownUnit> getCountdownUnits(LaunchCountdown countdown) {
    return [
      CountdownUnit(
        value: countdown.daysRemaining.toString(),
        label: 'DIAS',
        type: CountdownUnitType.days,
      ),
      CountdownUnit(
        value: countdown.hoursRemaining.toString().padLeft(2, '0'),
        label: 'HORAS',
        type: CountdownUnitType.hours,
      ),
      CountdownUnit(
        value: countdown.minutesRemaining.toString().padLeft(2, '0'),
        label: 'MINUTOS',
        type: CountdownUnitType.minutes,
      ),
    ];
  }

  static List<CountdownUnit> getDetailedCountdownUnits(LaunchCountdown countdown) {
    return [
      CountdownUnit(
        value: countdown.daysRemaining.toString(),
        label: 'DIAS',
        type: CountdownUnitType.days,
      ),
      CountdownUnit(
        value: countdown.hoursRemaining.toString().padLeft(2, '0'),
        label: 'HORAS',
        type: CountdownUnitType.hours,
      ),
      CountdownUnit(
        value: countdown.minutesRemaining.toString().padLeft(2, '0'),
        label: 'MINUTOS',
        type: CountdownUnitType.minutes,
      ),
      CountdownUnit(
        value: countdown.secondsRemaining.toString().padLeft(2, '0'),
        label: 'SEGUNDOS',
        type: CountdownUnitType.seconds,
      ),
    ];
  }

  static LaunchInformation getLaunchInformation() {
    return const LaunchInformation(
      appName: 'PetiVeti',
      version: '1.0.0',
      platforms: ['Android', 'iOS'],
      storeUrls: {
        'android': 'https://play.google.com/store/apps/details?id=com.petiveti',
        'ios': 'https://apps.apple.com/app/petiveti/id123456789',
      },
      releaseNotes: 'Primeira versão do PetiVeti com recursos completos para cuidado de pets.',
      newFeatures: [
        'Perfis de pets personalizados',
        'Controle de vacinas e medicamentos',
        'Lembretes inteligentes',
        'Gráficos de peso e saúde',
        'Histórico de consultas',
        'Sincronização em nuvem',
      ],
    );
  }

  static bool isCountdownActive() {
    final countdown = getCurrentCountdown();
    return countdown.isCountdownActive && !countdown.isLaunched;
  }

  static bool isLaunched() {
    final countdown = getCurrentCountdown();
    return countdown.isLaunched;
  }

  static Duration getTimeUntilLaunch() {
    final countdown = getCurrentCountdown();
    return countdown.timeRemaining;
  }

  static String getFormattedLaunchDate() {
    final countdown = getCurrentCountdown();
    return countdown.formattedLaunchDate;
  }

  static LaunchStatus getCurrentStatus() {
    final countdown = getCurrentCountdown();
    return countdown.status;
  }

  static Map<String, dynamic> getCountdownStatistics() {
    final countdown = getCurrentCountdown();
    final info = getLaunchInformation();
    
    return {
      'daysRemaining': countdown.daysRemaining,
      'hoursRemaining': countdown.hoursRemaining,
      'minutesRemaining': countdown.minutesRemaining,
      'isLaunched': countdown.isLaunched,
      'isCountdownActive': countdown.isCountdownActive,
      'status': countdown.status.id,
      'launchDate': countdown.formattedLaunchDate,
      'appVersion': info.version,
      'platforms': info.platforms,
      'newFeaturesCount': info.newFeatures.length,
    };
  }

  static String getProgressMessage() {
    final countdown = getCurrentCountdown();
    
    if (countdown.isLaunched) {
      return 'O PetiVeti já está disponível! Baixe agora e comece a cuidar melhor do seu pet.';
    }
    
    if (countdown.daysRemaining <= 7) {
      return 'Últimos dias! O PetiVeti será lançado muito em breve. Prepare-se!';
    }
    
    if (countdown.daysRemaining <= 30) {
      return 'Estamos na reta final! O lançamento do PetiVeti está chegando.';
    }
    
    return 'O PetiVeti está em desenvolvimento. Inscreva-se para ser notificado do lançamento!';
  }

  static List<String> getMilestones() {
    final countdown = getCurrentCountdown();
    final milestones = <String>[];
    
    if (countdown.daysRemaining <= 1) {
      milestones.add('Lançamento iminente!');
    } else if (countdown.daysRemaining <= 7) {
      milestones.add('Última semana antes do lançamento');
    } else if (countdown.daysRemaining <= 30) {
      milestones.add('Último mês antes do lançamento');
    } else if (countdown.daysRemaining <= 90) {
      milestones.add('Faltam menos de 3 meses');
    }
    
    return milestones;
  }
}
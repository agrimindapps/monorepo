/// Entidade que representa uma solicitação de exportação de dados
class ExportRequest {
  final String userId;
  final List<String> includedCategories;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> outputFormats;
  final bool includeAttachments;
  final Map<String, dynamic> customOptions;

  const ExportRequest({
    required this.userId,
    required this.includedCategories,
    this.startDate,
    this.endDate,
    required this.outputFormats,
    this.includeAttachments = true,
    this.customOptions = const {},
  });

  factory ExportRequest.fromJson(Map<String, dynamic> json) => ExportRequest(
    userId: json['user_id'] as String,
    includedCategories: (json['included_categories'] as List).cast<String>(),
    startDate: json['start_date'] != null 
        ? DateTime.parse(json['start_date'] as String) 
        : null,
    endDate: json['end_date'] != null 
        ? DateTime.parse(json['end_date'] as String) 
        : null,
    outputFormats: (json['output_formats'] as List).cast<String>(),
    includeAttachments: json['include_attachments'] as bool? ?? true,
    customOptions: json['custom_options'] as Map<String, dynamic>? ?? {},
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'included_categories': includedCategories,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'output_formats': outputFormats,
    'include_attachments': includeAttachments,
    'custom_options': customOptions,
  };

  ExportRequest copyWith({
    String? userId,
    List<String>? includedCategories,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? outputFormats,
    bool? includeAttachments,
    Map<String, dynamic>? customOptions,
  }) => ExportRequest(
    userId: userId ?? this.userId,
    includedCategories: includedCategories ?? this.includedCategories,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    outputFormats: outputFormats ?? this.outputFormats,
    includeAttachments: includeAttachments ?? this.includeAttachments,
    customOptions: customOptions ?? this.customOptions,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ExportRequest && userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

/// Categorias disponíveis para exportação de dados
enum ExportDataCategory {
  profile('profile', 'Perfil do Usuário'),
  vehicles('vehicles', 'Veículos Cadastrados'),
  fuel('fuel_records', 'Histórico de Abastecimentos'),
  maintenance('maintenance', 'Registros de Manutenção'),
  odometer('odometer', 'Leituras do Odômetro'),
  expenses('expenses', 'Despesas dos Veículos'),
  categories('categories', 'Categorias de Despesas'),
  settings('settings', 'Configurações do Aplicativo');

  const ExportDataCategory(this.key, this.displayName);

  final String key;
  final String displayName;

  static ExportDataCategory fromKey(String key) {
    return values.firstWhere(
      (category) => category.key == key,
      orElse: () => throw ArgumentError('Unknown category key: $key'),
    );
  }

  static List<String> getAllKeys() => values.map((e) => e.key).toList();
}

/// Formatos de saída disponíveis para exportação
enum ExportFormat {
  json('json', 'JSON'),
  csv('csv', 'CSV'),
  zip('zip', 'ZIP Archive');

  const ExportFormat(this.key, this.displayName);

  final String key;
  final String displayName;

  static ExportFormat fromKey(String key) {
    return values.firstWhere(
      (format) => format.key == key,
      orElse: () => throw ArgumentError('Unknown format key: $key'),
    );
  }
}
/// Entidade que representa os metadados de uma exportação LGPD
class ExportMetadata {

  const ExportMetadata({
    required this.id,
    required this.generatedAt,
    required this.version,
    required this.lgpdCompliance,
    required this.dataCategories,
    required this.exportStats,
    required this.format,
    required this.fileSizeMb,
    required this.checksum,
  });

  factory ExportMetadata.fromJson(Map<String, dynamic> json) => ExportMetadata(
    id: json['id'] as String,
    generatedAt: DateTime.parse(json['generated_at'] as String),
    version: json['version'] as String,
    lgpdCompliance: json['lgpd_compliance'] as bool,
    dataCategories: (json['data_categories'] as List).cast<String>(),
    exportStats: json['export_stats'] as Map<String, dynamic>,
    format: json['format'] as String,
    fileSizeMb: json['file_size_mb'] as int,
    checksum: json['checksum'] as String,
  );
  final String id;
  final DateTime generatedAt;
  final String version;
  final bool lgpdCompliance;
  final List<String> dataCategories;
  final Map<String, dynamic> exportStats;
  final String format;
  final int fileSizeMb;
  final String checksum;

  Map<String, dynamic> toJson() => {
    'id': id,
    'generated_at': generatedAt.toIso8601String(),
    'version': version,
    'lgpd_compliance': lgpdCompliance,
    'data_categories': dataCategories,
    'export_stats': exportStats,
    'format': format,
    'file_size_mb': fileSizeMb,
    'checksum': checksum,
  };

  ExportMetadata copyWith({
    String? id,
    DateTime? generatedAt,
    String? version,
    bool? lgpdCompliance,
    List<String>? dataCategories,
    Map<String, dynamic>? exportStats,
    String? format,
    int? fileSizeMb,
    String? checksum,
  }) => ExportMetadata(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    version: version ?? this.version,
    lgpdCompliance: lgpdCompliance ?? this.lgpdCompliance,
    dataCategories: dataCategories ?? this.dataCategories,
    exportStats: exportStats ?? this.exportStats,
    format: format ?? this.format,
    fileSizeMb: fileSizeMb ?? this.fileSizeMb,
    checksum: checksum ?? this.checksum,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ExportMetadata && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

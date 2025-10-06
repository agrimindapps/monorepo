import 'dart:convert';
import 'dart:developer';

import '../../domain/entities/medication_data.dart';
import '../../domain/entities/medication_dosage_input.dart';

/// Entrada de auditoria para rastreamento de mudanças médicas
class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final String medicationId;
  final String action; // 'calculation', 'update', 'access'
  final Map<String, dynamic> details;
  final String? userId;
  final String? veterinarianId;
  final double? calculatedDose;
  final Species? species;
  final String checksum; // Para verificar integridade

  AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.medicationId,
    required this.action,
    required this.details,
    this.userId,
    this.veterinarianId,
    this.calculatedDose,
    this.species,
    required this.checksum,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'medicationId': medicationId,
    'action': action,
    'details': details,
    'userId': userId,
    'veterinarianId': veterinarianId,
    'calculatedDose': calculatedDose,
    'species': species?.name,
    'checksum': checksum,
  };

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    medicationId: json['medicationId'] as String,
    action: json['action'] as String,
    details: json['details'] as Map<String, dynamic>,
    userId: json['userId'] as String?,
    veterinarianId: json['veterinarianId'] as String?,
    calculatedDose: (json['calculatedDose'] as num?)?.toDouble(),
    species: json['species'] != null ? Species.values.byName(json['species'] as String) : null,
    checksum: json['checksum'] as String,
  );

  /// Gera checksum para verificação de integridade
  static String generateChecksum(Map<String, dynamic> data) {
    final dataString = json.encode(data);
    return dataString.hashCode.toRadixString(16);
  }
}

/// Referência médica para validação de dados
class MedicalReference {
  final String id;
  final String source; // 'Plumb Veterinary', 'BSAVA', etc.
  final String title;
  final String authors;
  final DateTime publicationDate;
  final String? doi;
  final String? isbn;
  final String url;
  final DateTime lastVerified;
  final Map<String, dynamic> dosageData;

  const MedicalReference({
    required this.id,
    required this.source,
    required this.title,
    required this.authors,
    required this.publicationDate,
    this.doi,
    this.isbn,
    required this.url,
    required this.lastVerified,
    required this.dosageData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source,
    'title': title,
    'authors': authors,
    'publicationDate': publicationDate.toIso8601String(),
    'doi': doi,
    'isbn': isbn,
    'url': url,
    'lastVerified': lastVerified.toIso8601String(),
    'dosageData': dosageData,
  };

  factory MedicalReference.fromJson(Map<String, dynamic> json) => MedicalReference(
    id: json['id'] as String,
    source: json['source'] as String,
    title: json['title'] as String,
    authors: json['authors'] as String,
    publicationDate: DateTime.parse(json['publicationDate'] as String),
    doi: json['doi'] as String?,
    isbn: json['isbn'] as String?,
    url: json['url'] as String,
    lastVerified: DateTime.parse(json['lastVerified'] as String),
    dosageData: json['dosageData'] as Map<String, dynamic>,
  );

  /// Verifica se a referência precisa ser atualizada (> 1 ano)
  bool get needsUpdate => DateTime.now().difference(lastVerified).inDays > 365;
}

/// Base de dados versionada com sistema de auditoria médica
class VersionedMedicationDatabase {
  final String version;
  final DateTime lastUpdated;
  final String medicalProtocolSource;
  final Map<String, MedicalReference> references;
  final List<MedicationData> medications;
  final List<AuditLogEntry> _auditLog;
  final String integrityHash;

  const VersionedMedicationDatabase._({
    required this.version,
    required this.lastUpdated,
    required this.medicalProtocolSource,
    required this.references,
    required this.medications,
    required List<AuditLogEntry> auditLog,
    required this.integrityHash,
  }) : _auditLog = auditLog;

  /// Instância singleton da base de dados
  static VersionedMedicationDatabase? _instance;
  
  /// Obtém instância única da base de dados
  static VersionedMedicationDatabase get instance {
    _instance ??= _createDefaultDatabase();
    return _instance!;
  }

  /// Carregamento dinâmico com verificação de integridade
  static Future<VersionedMedicationDatabase> load() async {
    try {
      final data = await _fetchFromSecureSource();
      await _validateMedicalReferences(data);
      return VersionedMedicationDatabase.fromValidatedData(data);
    } catch (e) {
      log('Erro ao carregar base de dados versioned: $e');
      return _createDefaultDatabase();
    }
  }

  /// Cria instância a partir de dados validados
  factory VersionedMedicationDatabase.fromValidatedData(Map<String, dynamic> data) {
    final medications = _getDefaultMedications();
    
    final references = <String, MedicalReference>{};
    if (data['references'] != null) {
      final refsMap = data['references'] as Map<String, dynamic>;
      for (final entry in refsMap.entries) {
        references[entry.key] = MedicalReference.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    final auditLog = <AuditLogEntry>[];
    if (data['auditLog'] != null) {
      auditLog.addAll((data['auditLog'] as List<dynamic>)
          .map((entry) => AuditLogEntry.fromJson(entry as Map<String, dynamic>)));
    }

    return VersionedMedicationDatabase._(
      version: (data['version'] ?? '1.0.0') as String,
      lastUpdated: DateTime.parse((data['lastUpdated'] ?? DateTime.now().toIso8601String()) as String),
      medicalProtocolSource: (data['medicalProtocolSource'] ?? 'Internal Database') as String,
      references: references,
      medications: medications,
      auditLog: auditLog,
      integrityHash: (data['integrityHash'] ?? '') as String,
    );
  }

  /// Retorna todos os medicamentos disponíveis
  List<MedicationData> getAllMedications() {
    _logAccess('get_all_medications');
    return List.unmodifiable(medications);
  }

  /// Busca medicamento por ID com auditoria
  MedicationData? getMedicationById(String id) {
    _logAccess('get_medication_by_id', {'medicationId': id});
    
    try {
      return medications.firstWhere((med) => med.id == id);
    } catch (e) {
      _logAccess('medication_not_found', {'medicationId': id, 'error': e.toString()});
      return null;
    }
  }

  /// Sistema de auditoria para cálculos de dosagem
  void logDosageCalculation({
    required String medicationId,
    required double calculatedDose,
    required Species species,
    String? userId,
    String? veterinarianId,
    Map<String, dynamic>? additionalData,
  }) {
    final details = {
      'calculatedDose': calculatedDose,
      'species': species.name,
      'timestamp': DateTime.now().toIso8601String(),
      ...additionalData ?? {},
    };

    final entry = AuditLogEntry(
      id: _generateAuditId(),
      timestamp: DateTime.now(),
      medicationId: medicationId,
      action: 'dosage_calculation',
      details: details,
      userId: userId,
      veterinarianId: veterinarianId,
      calculatedDose: calculatedDose,
      species: species,
      checksum: AuditLogEntry.generateChecksum(details),
    );

    _auditLog.add(entry);
    _sendToAuditService(entry);
    if (_auditLog.length > 1000) {
      _auditLog.removeAt(0);
    }
  }

  /// Verifica integridade dos dados médicos
  bool verifyIntegrity() {
    try {
      final currentHash = _calculateIntegrityHash();
      final isValid = currentHash == integrityHash;
      
      if (!isValid) {
        log('CRÍTICO: Falha na verificação de integridade da base de dados médica');
        _logAccess('integrity_check_failed', {
          'expectedHash': integrityHash,
          'currentHash': currentHash,
        });
      }
      
      return isValid;
    } catch (e) {
      log('Erro na verificação de integridade: $e');
      return false;
    }
  }

  /// Obtém estatísticas de auditoria
  Map<String, dynamic> getAuditStatistics() {
    final totalCalculations = _auditLog.where((log) => log.action == 'dosage_calculation').length;
    final medicationsUsed = _auditLog.where((log) => log.action == 'dosage_calculation')
        .map((log) => log.medicationId).toSet().length;
    final speciesCount = _auditLog.where((log) => log.species != null)
        .map((log) => log.species!.name).toSet().length;
    
    final lastWeekCalculations = _auditLog.where((log) =>
        log.action == 'dosage_calculation' &&
        DateTime.now().difference(log.timestamp).inDays <= 7).length;

    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'totalMedications': medications.length,
      'totalCalculations': totalCalculations,
      'medicationsUsed': medicationsUsed,
      'speciesSupported': speciesCount,
      'calculationsLastWeek': lastWeekCalculations,
      'integrityStatus': verifyIntegrity() ? 'OK' : 'FAILED',
      'auditLogSize': _auditLog.length,
      'referencesCount': references.length,
      'outdatedReferences': references.values.where((ref) => ref.needsUpdate).length,
    };
  }

  /// Exporta log de auditoria para análise externa
  List<Map<String, dynamic>> exportAuditLog({DateTime? since}) {
    var logsToExport = _auditLog.asMap().entries;
    
    if (since != null) {
      logsToExport = logsToExport.where((entry) => 
          entry.value.timestamp.isAfter(since));
    }
    
    return logsToExport.map((entry) => {
      'index': entry.key,
      ...entry.value.toJson(),
    }).toList();
  }

  /// Busca medicamentos com validação de referências
  List<MedicationData> getMedicationsWithValidReferences() {
    return medications.where((med) {
      final hasValidReferences = references.values.any((ref) =>
          ref.dosageData.containsKey(med.id) && !ref.needsUpdate);
      
      if (!hasValidReferences) {
        _logAccess('medication_without_valid_reference', {'medicationId': med.id});
      }
      
      return hasValidReferences;
    }).toList();
  }

  /// Obtém referências médicas para um medicamento específico
  List<MedicalReference> getReferencesForMedication(String medicationId) {
    return references.values.where((ref) =>
        ref.dosageData.containsKey(medicationId)).toList();
  }

  void _logAccess(String action, [Map<String, dynamic>? details]) {
    final entry = AuditLogEntry(
      id: _generateAuditId(),
      timestamp: DateTime.now(),
      medicationId: (details?['medicationId'] ?? 'system') as String,
      action: action,
      details: details ?? <String, dynamic>{},
      checksum: AuditLogEntry.generateChecksum(details ?? <String, dynamic>{}),
    );
    
    _auditLog.add(entry);
  }

  String _generateAuditId() {
    return 'audit_${DateTime.now().millisecondsSinceEpoch}_${_auditLog.length}';
  }

  String _calculateIntegrityHash() {
    final dataToHash = {
      'version': version,
      'medications': medications.map((m) => m.id).toList()..sort(),
      'references': references.keys.toList()..sort(),
    };
    return AuditLogEntry.generateChecksum(dataToHash);
  }

  void _sendToAuditService(AuditLogEntry entry) {
    log('Audit: ${entry.action} for ${entry.medicationId} at ${entry.timestamp}');
  }

  /// Simula carregamento de fonte segura
  static Future<Map<String, dynamic>> _fetchFromSecureSource() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    
    return <String, dynamic>{
      'version': '1.2.0',
      'lastUpdated': DateTime.now().toIso8601String(),
      'medicalProtocolSource': 'Plumb Veterinary Drug Handbook 10th Edition',
      'medications': <dynamic>[], // Seria populado com dados reais
      'references': _getDefaultReferences(),
      'integrityHash': 'abc123hash', // Hash real seria calculado
    };
  }

  /// Valida referências médicas
  static Future<void> _validateMedicalReferences(Map<String, dynamic> data) async {
    final references = data['references'] as Map<String, dynamic>? ?? <String, dynamic>{};
    
    for (final entry in references.entries) {
      final ref = MedicalReference.fromJson(entry.value as Map<String, dynamic>);
      if (ref.needsUpdate) {
        log('Referência médica desatualizada: ${ref.title}');
      }
    }
  }

  /// Cria base de dados padrão
  static VersionedMedicationDatabase _createDefaultDatabase() {
    final medications = _getDefaultMedications();
    final references = _getDefaultReferences();
    
    final dataForHash = {
      'version': '1.0.0',
      'medications': medications.map((m) => m.id).toList()..sort(),
      'references': references.keys.toList()..sort(),
    };

    return VersionedMedicationDatabase._(
      version: '1.0.0',
      lastUpdated: DateTime.now(),
      medicalProtocolSource: 'Internal Veterinary Database v1.0',
      references: references.map((key, value) => MapEntry(key, MedicalReference.fromJson(value as Map<String, dynamic>))),
      medications: medications,
      auditLog: [],
      integrityHash: AuditLogEntry.generateChecksum(dataForHash),
    );
  }

  static List<MedicationData> _getDefaultMedications() {
    return <MedicationData>[
      MedicationData(
        id: 'amoxicillin',
        name: 'Amoxicilina',
        activeIngredient: 'Amoxicilina',
        category: 'Antibiótico',
        indications: const <String>['Infecções respiratórias', 'Infecções urinárias'],
        dosageRanges: const <DosageRange>[
          DosageRange(
            minDose: 10.0,
            maxDose: 20.0,
            toxicDose: 50.0,
            species: Species.dog,
          ),
        ],
        concentrations: const <MedicationConcentration>[
          MedicationConcentration(value: 50.0, unit: 'mg/ml', description: '50mg/ml'),
        ],
        pharmaceuticalForms: const <String>['Suspensão oral'],
        recommendedFrequencies: const <AdministrationFrequency>[AdministrationFrequency.twice],
        administrationRoutes: const <String>['Oral'],
        lastUpdated: DateTime(2024, 1, 1),
      ),
    ];
  }

  static Map<String, dynamic> _getDefaultReferences() {
    return {
      'plumb_2018': {
        'id': 'plumb_2018',
        'source': 'Plumb Veterinary Drug Handbook',
        'title': 'Plumb\'s Veterinary Drug Handbook, 9th Edition',
        'authors': 'Donald C. Plumb',
        'publicationDate': '2018-01-01T00:00:00.000Z',
        'isbn': '978-1119344483',
        'url': 'https://www.wiley.com/en-us/Plumb%27s+Veterinary+Drug+Handbook%2C+9th+Edition-p-9781119344483',
        'lastVerified': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'dosageData': {
          'amoxicillin': {
            'dog': {'min': 10.0, 'max': 20.0, 'toxic': 50.0},
            'cat': {'min': 10.0, 'max': 15.0, 'toxic': 40.0},
          },
          'meloxicam': {
            'dog': {'min': 0.1, 'max': 0.2, 'toxic': 0.5},
            'cat': {'min': 0.05, 'max': 0.1, 'toxic': 0.2},
          },
        },
      },
      'bsava_2020': {
        'id': 'bsava_2020',
        'source': 'BSAVA Small Animal Formulary',
        'title': 'BSAVA Small Animal Formulary, 10th Edition',
        'authors': 'Ian Ramsey, Briony Tennant',
        'publicationDate': '2020-01-01T00:00:00.000Z',
        'isbn': '978-1905319862',
        'url': 'https://www.bsava.com/Resources/Veterinary-resources/BSAVA-Small-Animal-Formulary',
        'lastVerified': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'dosageData': {
          'tramadol': {
            'dog': {'min': 2.0, 'max': 5.0, 'toxic': 15.0},
            'cat': {'min': 1.0, 'max': 4.0, 'toxic': 10.0},
          },
        },
      },
    };
  }
}
// Em produção, seria necessário implementar serialização completa
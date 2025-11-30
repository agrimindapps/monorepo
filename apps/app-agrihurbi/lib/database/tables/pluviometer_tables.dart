import 'package:drift/drift.dart';

/// Tabela de Pluviômetros (Rain Gauges)
///
/// Armazena informações sobre pluviômetros com localização GPS opcional
/// e capacidade de agrupamento.
class RainGauges extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único do pluviômetro (UUID)
  TextColumn get id => text()();

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Flag de atividade (soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // ========== CAMPOS ESPECÍFICOS PLUVIÔMETRO ==========

  /// Descrição/nome do pluviômetro
  TextColumn get description => text()();

  /// Capacidade do pluviômetro (em mm ou unidade específica)
  TextColumn get capacity => text()();

  /// Longitude GPS (opcional)
  TextColumn get longitude => text().nullable()();

  /// Latitude GPS (opcional)
  TextColumn get latitude => text().nullable()();

  /// FK para agrupamento opcional
  TextColumn get groupId => text().nullable()();

  /// Object ID do Firebase (para sincronização)
  TextColumn get objectId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabela de Medições Pluviométricas (Rainfall Measurements)
///
/// Armazena medições de chuva vinculadas a pluviômetros específicos
/// com timestamp e observações opcionais.
class RainfallMeasurements extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único da medição (UUID)
  TextColumn get id => text()();

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Flag de atividade (soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // ========== CAMPOS ESPECÍFICOS MEDIÇÃO ==========

  /// FK para o pluviômetro
  TextColumn get rainGaugeId => text().references(RainGauges, #id)();

  /// Data/hora da medição
  DateTimeColumn get measurementDate => dateTime()();

  /// Quantidade de chuva em mm
  RealColumn get amount => real()();

  /// Observações opcionais
  TextColumn get observations => text().nullable()();

  /// Object ID do Firebase (para sincronização)
  TextColumn get objectId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

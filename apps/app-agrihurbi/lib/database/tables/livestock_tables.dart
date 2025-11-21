import 'package:drift/drift.dart';

/// Tabela de Bovinos (Gado)
///
/// Armazena informações sobre bovinos com rastreamento de características específicas
/// como aptidão (leite, carne, misto), sistema de criação e informações de origem.
class Bovines extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único do bovino (UUID)
  TextColumn get id => text()();

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Flag de atividade (soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// ID de registro único do bovino
  TextColumn get registrationId => text()();

  /// Nome comum do bovino
  TextColumn get commonName => text()();

  /// País de origem
  TextColumn get originCountry => text()();

  /// URLs das imagens (JSON array string)
  TextColumn get imageUrls => text().withDefault(const Constant('[]'))();

  /// URL da imagem em miniatura
  TextColumn get thumbnailUrl => text().nullable()();

  // ========== CAMPOS ESPECÍFICOS BOVINO ==========

  /// Tipo de animal (ex: 'Bovino')
  TextColumn get animalType => text()();

  /// Origem/procedência
  TextColumn get origin => text()();

  /// Características físicas
  TextColumn get characteristics => text()();

  /// Raça do bovino
  TextColumn get breed => text()();

  /// Aptidão: 0=dairy, 1=beef, 2=mixed
  IntColumn get aptitude => integer()();

  /// Tags associadas (JSON array string)
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  /// Sistema de criação: 0=extensive, 1=intensive, 2=semiIntensive
  IntColumn get breedingSystem => integer()();

  /// Propósito/uso do bovino
  TextColumn get purpose => text()();

  /// Notas adicionais
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // Índices para otimizar buscas
  /*
  @override
  List<Index> get indexes => [
    Index('bovines_breed', [breed]),
    Index('bovines_aptitude', [aptitude]),
    Index('bovines_breeding_system', [breedingSystem]),
    Index('bovines_is_active', [isActive]),
  ];
  */
}

/// Tabela de Equinos (Cavalos)
///
/// Armazena informações sobre equinos com rastreamento de características específicas
/// como temperamento, cor do pelame, uso primário e influências genéticas.
class Equines extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único do equino (UUID)
  TextColumn get id => text()();

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Flag de atividade (soft delete)
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// ID de registro único do equino
  TextColumn get registrationId => text()();

  /// Nome comum do equino
  TextColumn get commonName => text()();

  /// País de origem
  TextColumn get originCountry => text()();

  /// URLs das imagens (JSON array string)
  TextColumn get imageUrls => text().withDefault(const Constant('[]'))();

  /// URL da imagem em miniatura
  TextColumn get thumbnailUrl => text().nullable()();

  // ========== CAMPOS ESPECÍFICOS EQUINO ==========

  /// Histórico do equino
  TextColumn get history => text()();

  /// Temperamento: 0=calm, 1=spirited, 2=gentle, 3=energetic, 4=docile
  IntColumn get temperament => integer()();

  /// Cor do pelame: 0=bay, 1=chestnut, 2=black, 3=gray, 4=palomino, 5=pinto, 6=roan
  IntColumn get coat => integer()();

  /// Uso primário: 0=riding, 1=sport, 2=work, 3=breeding, 4=leisure
  IntColumn get primaryUse => integer()();

  /// Influências genéticas
  TextColumn get geneticInfluences => text()();

  /// Altura do equino (em cm ou formato específico)
  TextColumn get height => text()();

  /// Peso do equino (em kg)
  TextColumn get weight => text()();

  @override
  Set<Column> get primaryKey => {id};

  // Índices para otimizar buscas
  /*
  @override
  List<Index> get indexes => [
    Index('equines_temperament', [temperament]),
    Index('equines_coat', [coat]),
    Index('equines_primary_use', [primaryUse]),
    Index('equines_is_active', [isActive]),
  ];
  */
}

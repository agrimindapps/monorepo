import 'package:core/core.dart';

/// Tabela de Veículos
///
/// Armazena todos os veículos cadastrados pelo usuário com informações
/// completas incluindo marca, modelo, placa, odômetro, etc.
class Vehicles extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único do veículo (auto incremento - apenas local)
  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  /// Null = registro ainda não foi sincronizado com Firebase
  TextColumn get firebaseId => text().nullable()();

  /// ID do usuário proprietário (Firebase UID)
  TextColumn get userId => text()();

  /// Nome do módulo (sempre 'gasometer')
  TextColumn get moduleName =>
      text().withDefault(const Constant('gasometer'))();

  // ========== TIMESTAMPS ==========

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Data da última sincronização com Firebase
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  /// Indica se o registro foi modificado localmente e precisa ser sincronizado
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();

  /// Indica se o registro foi deletado (soft delete)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Versão do registro para controle de conflitos
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== DADOS DO VEÍCULO ==========

  /// Marca do veículo (ex: Toyota, Honda, Fiat)
  TextColumn get marca => text().withLength(min: 1, max: 100)();

  /// Modelo do veículo (ex: Corolla, Civic, Uno)
  TextColumn get modelo => text().withLength(min: 1, max: 100)();

  /// Ano de fabricação
  IntColumn get ano => integer()();

  /// Placa do veículo
  TextColumn get placa => text().withLength(min: 1, max: 20)();

  /// Odômetro inicial (quando o veículo foi cadastrado)
  RealColumn get odometroInicial => real().withDefault(const Constant(0.0))();

  /// Odômetro atual
  RealColumn get odometroAtual => real().withDefault(const Constant(0.0))();

  /// Tipo de combustível (índice: 0=Gasolina, 1=Etanol, 2=Diesel, 3=GNV, 4=Flex)
  IntColumn get combustivel => integer().withDefault(const Constant(0))();

  // ========== DOCUMENTAÇÃO ==========

  /// Número do RENAVAN
  TextColumn get renavan => text().withDefault(const Constant(''))();

  /// Número do Chassi
  TextColumn get chassi => text().withDefault(const Constant(''))();

  // ========== CARACTERÍSTICAS ==========

  /// Cor do veículo
  TextColumn get cor => text().withDefault(const Constant(''))();

  /// URL da foto do veículo (Firebase Storage)
  TextColumn get foto => text().nullable()();

  // ========== STATUS DE VENDA ==========

  /// Indica se o veículo foi vendido
  BoolColumn get vendido => boolean().withDefault(const Constant(false))();

  /// Valor de venda (se vendido)
  RealColumn get valorVenda => real().withDefault(const Constant(0.0))();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
    // Garante que não haja placas duplicadas para o mesmo usuário
    {userId, placa},
  ];
}

/// Tabela de Abastecimentos (Fuel Supplies)
///
/// Armazena todos os registros de abastecimento de combustível
class FuelSupplies extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  TextColumn get firebaseId => text().nullable()();

  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('gasometer'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID do veículo (foreign key)
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DO ABASTECIMENTO ==========

  /// Data do abastecimento (timestamp)
  IntColumn get date => integer()();

  /// Odômetro no momento do abastecimento
  RealColumn get odometer => real()();

  /// Quantidade de litros abastecidos
  RealColumn get liters => real()();

  /// Preço por litro
  RealColumn get pricePerLiter => real()();

  /// Valor total pago
  RealColumn get totalPrice => real()();

  /// Indica se o tanque foi completamente cheio
  BoolColumn get fullTank => boolean().nullable()();

  /// Tipo de combustível (índice)
  IntColumn get fuelType => integer().withDefault(const Constant(0))();

  // ========== INFORMAÇÕES ADICIONAIS ==========

  /// Nome do posto de gasolina
  TextColumn get gasStationName => text().nullable()();

  /// Observações adicionais
  TextColumn get notes => text().nullable()();

  /// URL da foto do recibo (Firebase Storage)
  TextColumn get receiptImageUrl => text().nullable()();

  /// Caminho local da foto do recibo
  TextColumn get receiptImagePath => text().nullable()();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// Tabela de Manutenções (Maintenances)
///
/// Armazena todos os registros de manutenção dos veículos
class Maintenances extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  TextColumn get firebaseId => text().nullable()();

  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('gasometer'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID do veículo (foreign key)
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DA MANUTENÇÃO ==========

  /// Tipo de manutenção (ex: "Troca de óleo", "Revisão", "Pneus")
  TextColumn get tipo => text()();

  /// Descrição detalhada da manutenção
  TextColumn get descricao => text()();

  /// Valor pago pela manutenção
  RealColumn get valor => real()();

  /// Data da manutenção (timestamp)
  IntColumn get data => integer()();

  /// Odômetro no momento da manutenção
  IntColumn get odometro => integer()();

  /// Odômetro para a próxima revisão (opcional)
  IntColumn get proximaRevisao => integer().nullable()();

  /// Indica se a manutenção foi concluída
  BoolColumn get concluida => boolean().withDefault(const Constant(false))();

  // ========== COMPROVANTES ==========

  /// URL da foto do recibo (Firebase Storage)
  TextColumn get receiptImageUrl => text().nullable()();

  /// Caminho local da foto do recibo
  TextColumn get receiptImagePath => text().nullable()();
}

/// Tabela de Despesas (Expenses)
///
/// Armazena despesas gerais relacionadas aos veículos
class Expenses extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  TextColumn get firebaseId => text().nullable()();

  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('gasometer'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID do veículo (foreign key)
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DA DESPESA ==========

  /// Categoria da despesa (ex: "IPVA", "Seguro", "Multa", "Estacionamento")
  TextColumn get category => text()();

  /// Descrição da despesa
  TextColumn get description => text()();

  /// Valor da despesa
  RealColumn get amount => real()();

  /// Data da despesa (timestamp)
  IntColumn get date => integer()();

  /// Observações adicionais
  TextColumn get notes => text().nullable()();

  // ========== COMPROVANTES ==========

  /// URL da foto do comprovante (Firebase Storage)
  TextColumn get receiptImageUrl => text().nullable()();

  /// Caminho local da foto do comprovante
  TextColumn get receiptImagePath => text().nullable()();
}

/// Tabela de Leituras de Odômetro (Odometer Readings)
///
/// Armazena leituras periódicas do odômetro para tracking
class OdometerReadings extends Table {
  // ========== CAMPOS BASE ==========

  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  TextColumn get firebaseId => text().nullable()();

  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('gasometer'))();

  // ========== TIMESTAMPS ==========

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== RELACIONAMENTO ==========

  /// ID do veículo (foreign key)
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  // ========== DADOS DA LEITURA ==========

  /// Valor do odômetro
  RealColumn get reading => real()();

  /// Data da leitura (timestamp)
  IntColumn get date => integer()();

  /// Observações
  TextColumn get notes => text().nullable()();
}

/// Tabela de Auditoria Financeira
///
/// Registra todas as operações financeiras para compliance e auditoria
/// Mantém histórico de alterações em despesas, abastecimentos, etc.
class AuditTrail extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único da entrada de auditoria (auto incremento)
  IntColumn get id => integer().autoIncrement()();

  /// ID da entidade auditada (veículo, despesa, abastecimento, etc.)
  TextColumn get entityId => text()();

  /// Tipo da entidade (vehicle, expense, fuel_supply, maintenance)
  TextColumn get entityType => text()();

  /// Tipo do evento (CREATE, UPDATE, DELETE, SYNC, etc.)
  TextColumn get eventType => text()();

  // ========== TIMESTAMPS ==========

  /// Timestamp do evento
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  // ========== DADOS DO EVENTO ==========

  /// ID do usuário que realizou a operação
  TextColumn get userId => text().nullable()();

  /// Estado anterior da entidade (JSON serializado)
  TextColumn get beforeState => text().nullable()();

  /// Estado posterior da entidade (JSON serializado)
  TextColumn get afterState => text().nullable()();

  /// Descrição da operação
  TextColumn get description => text().nullable()();

  /// Valor monetário envolvido na operação
  RealColumn get monetaryValue => real().nullable()();

  /// Metadados adicionais (JSON serializado)
  TextColumn get metadata => text().nullable()();

  /// Fonte da sincronização (local, remote, conflict_resolution)
  TextColumn get syncSource => text().nullable()();
}

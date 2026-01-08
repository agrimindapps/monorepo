import 'package:drift/drift.dart';

/// ========== STATIC DATA TABLES ==========
/// 
/// IMPORTANTE: Tabelas estáticas carregadas de JSON.
/// - Não usam autoIncrement (usam idReg do JSON como referência)
/// - São READ-ONLY (dados de lookup)
/// - FKs são strings que referenciam idReg de outras tabelas

/// Tabela de Diagnósticos (Tabela de Junção/Relacionamento)
///
/// Relaciona defensivos agrícolas com culturas e pragas, definindo
/// dosagens e formas de aplicação recomendadas.
///
/// JSON Source: TBDIAGNOSTICO*.json
/// ⚠️ TABELA ESTÁTICA - Não pertence ao usuário, não sincroniza com Firebase.
class Diagnosticos extends Table {
  // ========== PRIMARY KEY (idReg do JSON) ==========
  /// ID de registro único (IdReg do JSON) - PRIMARY KEY
  TextColumn get idReg => text()();

  // ========== FOREIGN KEYS (strings que referenciam idReg) ==========
  /// FK → Fitossanitarios.idDefensivo (fkIdDefensivo do JSON)
  TextColumn get fkIdDefensivo => text()();

  /// FK → Culturas.idCultura (fkIdCultura do JSON)
  TextColumn get fkIdCultura => text()();

  /// FK → Pragas.idPraga (fkIdPraga do JSON)
  TextColumn get fkIdPraga => text()();

  // ========== BUSINESS FIELDS (do JSON) ==========
  /// Dosagem mínima
  TextColumn get dsMin => text().nullable()();

  /// Dosagem máxima
  TextColumn get dsMax => text().nullable()();

  /// Unidade de medida
  TextColumn get um => text().nullable()();

  /// Aplicação terrestre - mínimo
  TextColumn get minAplicacaoT => text().nullable()();

  /// Aplicação terrestre - máximo
  TextColumn get maxAplicacaoT => text().nullable()();

  /// Unidade de medida terrestre
  TextColumn get umT => text().nullable()();

  /// Aplicação aérea - mínimo
  TextColumn get minAplicacaoA => text().nullable()();

  /// Aplicação aérea - máximo
  TextColumn get maxAplicacaoA => text().nullable()();

  /// Unidade de medida aérea
  TextColumn get umA => text().nullable()();

  /// Intervalo de aplicação
  TextColumn get intervalo => text().nullable()();

  /// Intervalo secundário
  TextColumn get intervalo2 => text().nullable()();

  /// Época de aplicação
  TextColumn get epocaAplicacao => text().nullable()();

  /// Status do registro (do JSON)
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idReg};
}

/// ========== USER-GENERATED DATA TABLES ==========

/// Tabela de Favoritos
///
/// Armazena favoritos multi-tipo do usuário (defensivos, pragas, diagnosticos, culturas)
class Favoritos extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SYNC DIAGNOSTICS ==========
  TextColumn get syncError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// 0=Synced, 1=Pending, 2=Error, 3=Conflict
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  // ========== BUSINESS FIELDS ==========
  /// Tipo do favorito: 'defensivos', 'pragas', 'diagnosticos', 'culturas'
  TextColumn get tipo => text()();

  /// ID do item original
  TextColumn get itemId => text()();

  /// JSON string com dados do item (cache)
  TextColumn get itemData => text()();

  // ========== UNIQUE CONSTRAINTS ==========
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, tipo, itemId}, // Previne favoritar o mesmo item duas vezes
  ];
}

/// Tabela de Comentários
///
/// Armazena comentários dos usuários vinculados a items
class Comentarios extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SYNC DIAGNOSTICS ==========
  TextColumn get syncError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// 0=Synced, 1=Pending, 2=Error, 3=Conflict
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();

  // ========== BUSINESS FIELDS ==========
  /// ID do item comentado
  TextColumn get itemId => text()();

  /// Texto do comentário
  TextColumn get texto => text()();
}

/// Tabela de Assinaturas do Usuário (Cache Local)
///
/// Armazena o estado da assinatura para acesso offline.
/// Atualizado sempre que o RevenueCat/Mock retorna um novo status.
class UserSubscriptions extends Table {
  // ========== PRIMARY KEY ==========
  TextColumn get id => text()(); // ID da assinatura (purchase token ou gerado)

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId =>
      text().nullable()(); // Para sync futuro se necessário
  TextColumn get userId => text()(); // Vínculo com o usuário
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== SUBSCRIPTION DATA ==========
  TextColumn get productId => text()();
  TextColumn get status => text()(); // active, expired, etc.
  TextColumn get tier => text()(); // free, premium, etc.
  TextColumn get store => text()(); // appStore, playStore, etc.

  DateTimeColumn get expirationDate => dateTime().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  DateTimeColumn get originalPurchaseDate => dateTime().nullable()();

  BoolColumn get isSandbox => boolean().withDefault(const Constant(false))();
  BoolColumn get isAutoRenewing =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt =>
      dateTime().nullable()(); // Quando foi validado com a loja

  // ========== SYNC FIELDS ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ========== STATIC DATA TABLES (READ-ONLY) ==========

/// Tabela de Culturas (Dados estáticos - JSON)
/// JSON Source: TBCULTURAS0.json
class Culturas extends Table {
  /// ID da cultura (idReg do JSON) - PRIMARY KEY
  TextColumn get idCultura => text()();

  /// Nome da cultura (cultura do JSON)
  TextColumn get nome => text()();

  /// Status do registro
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {idCultura};
}

/// Tabela de Pragas (Dados estáticos - JSON)
/// JSON Source: TBPRAGAS0.json
class Pragas extends Table {
  /// ID da praga (idReg do JSON) - PRIMARY KEY
  TextColumn get idPraga => text()();

  /// Nome comum (nomeComum do JSON)
  TextColumn get nome => text()();

  /// Nome científico (nomeCientifico do JSON)
  TextColumn get nomeLatino => text().nullable()();

  /// Tipo de praga: '1'=inseto, '2'=doença, '3'=planta daninha (tipoPraga do JSON)
  TextColumn get tipo => text().nullable()();

  /// Status do registro
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  // ========== CAMPOS TAXONOMIA (do JSON) ==========
  TextColumn get dominio => text().nullable()();
  TextColumn get reino => text().nullable()();
  TextColumn get subReino => text().nullable()();
  TextColumn get clado01 => text().nullable()();
  TextColumn get clado02 => text().nullable()();
  TextColumn get clado03 => text().nullable()();
  TextColumn get superDivisao => text().nullable()();
  TextColumn get divisao => text().nullable()();
  TextColumn get subDivisao => text().nullable()();
  TextColumn get classe => text().nullable()();
  TextColumn get subClasse => text().nullable()();
  TextColumn get superOrdem => text().nullable()();
  TextColumn get ordem => text().nullable()();
  TextColumn get subOrdem => text().nullable()();
  TextColumn get infraOrdem => text().nullable()();
  TextColumn get superFamilia => text().nullable()();
  TextColumn get familia => text().nullable()();
  TextColumn get subFamilia => text().nullable()();
  TextColumn get tribo => text().nullable()();
  TextColumn get subTribo => text().nullable()();
  TextColumn get genero => text().nullable()();
  TextColumn get especie => text().nullable()();

  @override
  Set<Column> get primaryKey => {idPraga};
}

/// Tabela de Informações de Pragas (Dados estáticos - JSON)
/// JSON Source: TBPRAGASINF*.json
class PragasInf extends Table {
  /// ID de registro (idReg do JSON) - PRIMARY KEY
  TextColumn get idReg => text()();

  /// FK → Pragas.idPraga (fkIdPraga do JSON)
  TextColumn get fkIdPraga => text()();

  /// Status do registro
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Descrição (descrisao do JSON - note o typo no JSON original)
  TextColumn get descricao => text().nullable()();

  /// Sintomas (sintomas do JSON)
  TextColumn get sintomas => text().nullable()();

  /// Bioecologia (bioecologia do JSON)
  TextColumn get bioecologia => text().nullable()();

  /// Controle (controle do JSON)
  TextColumn get controle => text().nullable()();

  @override
  Set<Column> get primaryKey => {idReg};
}

/// Tabela de Fitossanitários/Defensivos (Dados estáticos - JSON)
/// JSON Source: TBFITOSSANITARIOS*.json
class Fitossanitarios extends Table {
  /// ID do defensivo (idReg do JSON) - PRIMARY KEY
  TextColumn get idDefensivo => text()();

  /// Nome comercial (nomeComum do JSON)
  TextColumn get nome => text()();

  /// Nome técnico (nomeTecnico do JSON)
  TextColumn get nomeTecnico => text().nullable()();

  /// Classe agronômica: Herbicida, Fungicida, Inseticida, etc. (classeAgronomica do JSON)
  TextColumn get classeAgronomica => text().nullable()();

  /// Fabricante (fabricante do JSON)
  TextColumn get fabricante => text().nullable()();

  /// Classe ambiental (classAmbiental do JSON)
  TextColumn get classeAmbiental => text().nullable()();

  /// Se está sendo comercializado (comercializado do JSON)
  IntColumn get comercializado => integer().withDefault(const Constant(1))();

  /// Indicação de corrosividade (corrosivo do JSON)
  TextColumn get corrosivo => text().nullable()();

  /// Indicação de inflamabilidade (inflamavel do JSON)
  TextColumn get inflamavel => text().nullable()();

  /// Formulação do produto (formulacao do JSON)
  TextColumn get formulacao => text().nullable()();

  /// Modo de ação (modoAcao do JSON)
  TextColumn get modoAcao => text().nullable()();

  /// Número de registro no MAPA (mapa do JSON)
  TextColumn get registroMapa => text().nullable()();

  /// Classe toxicológica (toxico do JSON)
  TextColumn get classeToxico => text().nullable()();

  /// Ingrediente ativo (ingredienteAtivo do JSON)
  TextColumn get ingredienteAtivo => text().nullable()();

  /// Quantidade do produto (quantProduto do JSON)
  TextColumn get quantProduto => text().nullable()();

  /// Status do produto (status do JSON)
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Se é elegível para uso (elegivel do JSON)
  BoolColumn get elegivel => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {idDefensivo};
}

/// Tabela de Informações de Fitossanitários (Dados estáticos - JSON)
/// JSON Source: TBFITOSSANITARIOSINFO*.json
/// Contém informações detalhadas como tecnologia de aplicação, precauções, etc.
class FitossanitariosInfo extends Table {
  /// ID de registro (idReg do JSON) - PRIMARY KEY
  TextColumn get idReg => text()();

  /// FK → Fitossanitarios.idDefensivo (fkIdDefensivo do JSON)
  TextColumn get fkIdDefensivo => text()();

  /// Status do registro
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Embalagens disponíveis (embalagens do JSON)
  TextColumn get embalagens => text().nullable()();

  /// Tecnologia de aplicação (tecnologia do JSON)
  TextColumn get tecnologia => text().nullable()();

  /// Precauções para humanos (pHumanas do JSON)
  TextColumn get precaucoesHumanas => text().nullable()();

  /// Precauções ambientais (pAmbiental do JSON)
  TextColumn get precaucoesAmbientais => text().nullable()();

  /// Manejo de resistência (manejoResistencia do JSON)
  TextColumn get manejoResistencia => text().nullable()();

  /// Compatibilidade com outros produtos (compatibilidade do JSON)
  TextColumn get compatibilidade => text().nullable()();

  /// Manejo integrado (manejoIntegrado do JSON)
  TextColumn get manejoIntegrado => text().nullable()();

  @override
  Set<Column> get primaryKey => {idReg};
}

/// Tabela de Informações de Plantas Daninhas (Dados estáticos - JSON)
/// JSON Source: TBPLANTASINF0.json
/// NOTA: PlantasInf contém informações sobre plantas daninhas (pragas tipo 3)
class PlantasInf extends Table {
  /// ID de registro (idReg do JSON) - PRIMARY KEY
  TextColumn get idReg => text()();

  /// FK → Pragas.idPraga (fkIdPraga do JSON - plantas daninhas são pragas tipo 3)
  TextColumn get fkIdPraga => text()();

  /// Status do registro
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Ciclo da planta (ciclo do JSON)
  TextColumn get ciclo => text().nullable()();

  /// Tipo de reprodução (reproducao do JSON)
  TextColumn get reproducao => text().nullable()();

  /// Habitat natural (habitat do JSON)
  TextColumn get habitat => text().nullable()();

  /// Adaptações específicas (adaptacoes do JSON)
  TextColumn get adaptacoes => text().nullable()();

  /// Altura média da planta (altura do JSON)
  TextColumn get altura => text().nullable()();

  /// Filotaxia - arranjo das folhas (filotaxia do JSON)
  TextColumn get filotaxia => text().nullable()();

  /// Forma do limbo foliar (formaLimbo do JSON)
  TextColumn get formaLimbo => text().nullable()();

  /// Superfície das folhas (superficie do JSON)
  TextColumn get superficie => text().nullable()();

  /// Consistência das folhas (consistencia do JSON)
  TextColumn get consistencia => text().nullable()();

  /// Tipo de nervação (nervacao do JSON)
  TextColumn get nervacao => text().nullable()();

  /// Comprimento da nervação (nervacaoComprimento do JSON)
  TextColumn get nervacaoComprimento => text().nullable()();

  /// Tipo de inflorescência (inflorescencia do JSON)
  TextColumn get inflorescencia => text().nullable()();

  /// Perianto (perianto do JSON)
  TextColumn get perianto => text().nullable()();

  /// Tipo de fruto (tipologiaFruto do JSON)
  TextColumn get tipoFruto => text().nullable()();

  /// Observações gerais (observacoes do JSON)
  TextColumn get observacoes => text().nullable()();

  @override
  Set<Column> get primaryKey => {idReg};
}

/// ========== APP SETTINGS TABLES ==========

/// Tabela de Controle de Versão dos Dados Estáticos
///
/// Registra a versão dos dados carregados do JSON para o SQLite.
/// Permite evitar recarregamento desnecessário e força atualização
/// quando a versão do app muda.
class StaticDataVersion extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== VERSION CONTROL ==========
  /// Nome da tabela de dados estáticos
  /// Ex: 'culturas', 'pragas', 'fitossanitarios', 'diagnosticos'
  TextColumn get dataTableName => text().unique()();

  /// Versão dos dados carregados
  TextColumn get dataVersion => text()();

  /// Versão do app quando os dados foram carregados
  TextColumn get appVersion => text()();

  /// Timestamp de quando foi carregado
  DateTimeColumn get loadedAt => dateTime().withDefault(currentDateAndTime)();

  /// Quantidade de registros carregados
  IntColumn get recordCount => integer().withDefault(const Constant(0))();

  /// Checksum/hash dos dados (opcional, para validação)
  TextColumn get checksum => text().nullable()();
}

/// Tabela de Configurações do App
///
/// Armazena configurações específicas do usuário para o aplicativo,
/// como tema, idioma, notificações, etc.
class AppSettings extends Table {
  // ========== PRIMARY KEY ==========
  IntColumn get id => integer().autoIncrement()();

  // ========== FIREBASE SYNC ==========
  TextColumn get firebaseId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get moduleName =>
      text().withDefault(const Constant('receituagro'))();

  // ========== TIMESTAMPS ==========
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== SYNC CONTROL ==========
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== SETTINGS FIELDS ==========
  /// Tema do app ('light', 'dark', 'system')
  TextColumn get theme => text().withDefault(const Constant('system'))();

  /// Idioma do app ('pt', 'en', 'es')
  TextColumn get language => text().withDefault(const Constant('pt'))();

  /// Notificações habilitadas
  BoolColumn get enableNotifications =>
      boolean().withDefault(const Constant(true))();

  /// Sincronização habilitada
  BoolColumn get enableSync => boolean().withDefault(const Constant(true))();

  /// Flags de funcionalidades (JSON)
  TextColumn get featureFlags => text().withDefault(const Constant('{}'))();
}

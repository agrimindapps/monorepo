import 'package:core/core.dart';

/// ========== USER-GENERATED DATA TABLES ==========

/// Tabela de Diagnósticos
///
/// Armazena diagnósticos criados pelo usuário relacionando
/// defensivos, culturas e pragas com dosagens e aplicações.
class Diagnosticos extends Table {
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

  // ========== FOREIGN KEYS (NORMALIZED) ==========
  /// ID do defensivo (FK → Fitossanitarios)
  IntColumn get defenisivoId => integer().references(
    Fitossanitarios,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// ID da cultura (FK → Culturas)
  IntColumn get culturaId =>
      integer().references(Culturas, #id, onDelete: KeyAction.restrict)();

  /// ID da praga (FK → Pragas)
  IntColumn get pragaId =>
      integer().references(Pragas, #id, onDelete: KeyAction.restrict)();

  // ========== BUSINESS FIELDS ==========
  /// ID de registro (legacy - único por usuário)
  TextColumn get idReg => text()();

  /// Dosagem mínima
  TextColumn get dsMin => text().nullable()();

  /// Dosagem máxima
  TextColumn get dsMax => text()();

  /// Unidade de medida
  TextColumn get um => text()();

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

  // ========== UNIQUE CONSTRAINTS ==========
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, idReg}, // idReg único por usuário
  ];
}

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

  // ========== BUSINESS FIELDS ==========
  /// ID do item comentado
  TextColumn get itemId => text()();

  /// Texto do comentário
  TextColumn get texto => text()();
}

/// ========== STATIC DATA TABLES (READ-ONLY) ==========

/// Tabela de Culturas (Dados estáticos - JSON)
class Culturas extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID da cultura (chave do JSON)
  TextColumn get idCultura => text().unique()();

  /// Nome da cultura
  TextColumn get nome => text()();

  /// Nome científico
  TextColumn get nomeLatino => text().nullable()();

  /// Família botânica
  TextColumn get familia => text().nullable()();

  /// URL da imagem
  TextColumn get imagemUrl => text().nullable()();

  /// Descrição
  TextColumn get descricao => text().nullable()();
}

/// Tabela de Pragas (Dados estáticos - JSON)
class Pragas extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID da praga (chave do JSON)
  TextColumn get idPraga => text().unique()();

  /// Nome comum
  TextColumn get nome => text()();

  /// Nome científico
  TextColumn get nomeLatino => text().nullable()();

  /// Tipo: 'inseto', 'fungo', 'bacteria', 'virus', 'nematoide', etc.
  TextColumn get tipo => text().nullable()();

  /// URL da imagem
  TextColumn get imagemUrl => text().nullable()();

  /// Descrição
  TextColumn get descricao => text().nullable()();
}

/// Tabela de Informações de Pragas (Dados estáticos - JSON)
class PragasInf extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID de registro (chave do JSON)
  TextColumn get idReg => text().unique()();

  /// FK → Pragas
  IntColumn get pragaId =>
      integer().references(Pragas, #id, onDelete: KeyAction.restrict)();

  /// Sintomas
  TextColumn get sintomas => text().nullable()();

  /// Controle cultural
  TextColumn get controle => text().nullable()();

  /// Danos causados
  TextColumn get danos => text().nullable()();

  /// Condições favoráveis
  TextColumn get condicoesFavoraveis => text().nullable()();
}

/// Tabela de Fitossanitários/Defensivos (Dados estáticos - JSON)
class Fitossanitarios extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID do defensivo (chave do JSON)
  TextColumn get idDefensivo => text().unique()();

  /// Nome comercial
  TextColumn get nome => text()();

  /// Nome comum (produto comercial)
  TextColumn get nomeComum => text().nullable()();

  /// Fabricante
  TextColumn get fabricante => text().nullable()();

  /// Classe: 'herbicida', 'fungicida', 'inseticida', 'acaricida', etc.
  TextColumn get classe => text().nullable()();

  /// Classe agronômica
  TextColumn get classeAgronomica => text().nullable()();

  /// Ingrediente ativo
  TextColumn get ingredienteAtivo => text().nullable()();

  /// Número de registro no MAPA
  TextColumn get registroMapa => text().nullable()();

  /// Status do produto (ativo/inativo)
  BoolColumn get status => boolean().withDefault(const Constant(true))();

  /// Se está sendo comercializado (0 = não, 1 = sim)
  IntColumn get comercializado => integer().withDefault(const Constant(1))();

  /// Se é elegível para uso
  BoolColumn get elegivel => boolean().withDefault(const Constant(true))();
}

/// Tabela de Informações de Fitossanitários (Dados estáticos - JSON)
class FitossanitariosInfo extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// ID de registro (chave do JSON)
  TextColumn get idReg => text().unique()();

  /// FK → Fitossanitarios
  IntColumn get defensivoId => integer().references(
    Fitossanitarios,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// Modo de ação
  TextColumn get modoAcao => text().nullable()();

  /// Formulação
  TextColumn get formulacao => text().nullable()();

  /// Classe toxicológica
  TextColumn get toxicidade => text().nullable()();

  /// Carência (dias)
  TextColumn get carencia => text().nullable()();

  /// Informações adicionais
  TextColumn get informacoesAdicionais => text().nullable()();
}

/// ========== APP SETTINGS TABLES ==========

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

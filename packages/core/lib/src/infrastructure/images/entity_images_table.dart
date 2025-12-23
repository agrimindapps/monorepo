import 'package:drift/drift.dart';

/// Tabela genérica de imagens para todos os apps do monorepo
///
/// Esta tabela pode ser incluída em qualquer database Drift do monorepo.
/// Armazena imagens em Base64 otimizado (max 600KB) para sincronização
/// com Firestore.
///
/// **Uso:**
/// ```dart
/// @DriftDatabase(tables: [EntityImages, ...])
/// class MyAppDatabase extends _$MyAppDatabase { ... }
/// ```
///
/// **Relacionamento flexível:**
/// Em vez de foreign keys rígidas, usa [entityType] + [entityId] para
/// permitir relacionamento com qualquer tabela do app.
class EntityImages extends Table {
  // ========== CAMPOS BASE ==========

  /// ID único local (auto incremento - apenas local)
  IntColumn get id => integer().autoIncrement()();

  /// ID do documento no Firebase Firestore (UUID)
  /// Null = registro ainda não foi sincronizado
  TextColumn get firebaseId => text().nullable()();

  /// ID do usuário proprietário (Firebase UID)
  TextColumn get userId => text().nullable()();

  /// Nome do módulo/app ('plantis', 'gasometer', 'petiveti', etc.)
  TextColumn get moduleName => text()();

  // ========== RELACIONAMENTO FLEXÍVEL ==========

  /// Tipo da entidade dona da imagem ('plant', 'vehicle', 'pet', 'receipt')
  TextColumn get entityType => text()();

  /// ID da entidade dona (Firebase ID ou ID local como string)
  TextColumn get entityId => text()();

  // ========== DADOS DA IMAGEM ==========

  /// Imagem em Base64 com prefixo data URI
  /// Ex: 'data:image/jpeg;base64,/9j/4AAQ...'
  /// Max ~600KB após compressão
  TextColumn get imageBase64 => text()();

  /// MIME type da imagem
  TextColumn get mimeType =>
      text().withDefault(const Constant('image/jpeg'))();

  /// Tamanho em bytes da imagem comprimida
  IntColumn get sizeBytes => integer()();

  /// Largura em pixels
  IntColumn get width => integer().nullable()();

  /// Altura em pixels
  IntColumn get height => integer().nullable()();

  /// Nome original do arquivo
  TextColumn get fileName => text().nullable()();

  /// Se é a imagem principal da entidade
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  /// Ordem de exibição (para múltiplas imagens)
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  // ========== TIMESTAMPS ==========

  /// Data de criação do registro
  DateTimeColumn get createdAt => dateTime()();

  /// Data da última atualização
  DateTimeColumn get updatedAt => dateTime()();

  /// Data da última sincronização com Firebase
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  // ========== CONTROLE DE SINCRONIZAÇÃO ==========

  /// Indica se foi modificado localmente e precisa ser sincronizado
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  /// Indica se foi deletado (soft delete)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Versão do registro para controle de conflitos
  IntColumn get version => integer().withDefault(const Constant(1))();

  // ========== ÍNDICES ==========

  @override
  List<Set<Column>> get uniqueKeys => [
        {firebaseId}, // Firebase ID único quando não null
      ];
}

/// Extensão com queries úteis para EntityImages
///
/// Pode ser usado como referência para implementação nos repositories dos apps
extension EntityImagesQueries on EntityImages {
  /// Nome da coleção no Firestore
  static const String firestoreCollection = 'entity_images';

  /// Tamanho máximo permitido para Base64 (600KB em bytes, ~800KB em Base64)
  static const int maxBase64Size = 800 * 1024;

  /// Tamanho máximo permitido para imagem em bytes (600KB)
  static const int maxImageBytes = 600 * 1024;
}

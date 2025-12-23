import 'package:drift/drift.dart';

import 'animals_table.dart';

/// ============================================================================
/// ANIMAL IMAGES TABLE - Tabela de imagens dos animais
/// ============================================================================
///
/// Armazena imagens dos animais em Base64 para sincronização com Firestore.
///
/// **PADRÃO ESTABELECIDO (gasometer/plantis):**
/// - Imagens em Base64 DataURI para sync direto com Firestore
/// - Compressão máxima: 600KB por imagem
/// - Suporte a thumbnail para listagens rápidas
/// - Foreign key para Animals
///
/// **CAMPOS:**
/// - id: PK auto-incremento
/// - firebaseId: ID único no Firestore
/// - userId: Dono da imagem
/// - animalId: FK para Animals
/// - imageBase64: Imagem principal em Base64 DataURI
/// - thumbnailBase64: Thumbnail em Base64 (150x150, ~30KB)
/// - fileName: Nome original do arquivo
/// - mimeType: Tipo MIME (image/jpeg, image/png)
/// - sizeBytes: Tamanho em bytes
/// - width/height: Dimensões da imagem
/// - isPrimary: Se é a foto principal do animal
/// - sortOrder: Ordem de exibição
/// - Campos de sync: isDirty, lastSyncAt, version, isDeleted
/// ============================================================================
@DataClassName('AnimalImage')
class AnimalImages extends Table {
  // ========== IDENTIFICAÇÃO ==========
  
  /// ID local auto-incremento
  IntColumn get id => integer().autoIncrement()();
  
  /// ID único no Firestore (para sync)
  TextColumn get firebaseId => text().nullable()();
  
  /// ID do usuário dono da imagem
  TextColumn get userId => text().nullable()();
  
  // ========== RELACIONAMENTO ==========
  
  /// FK para tabela Animals
  IntColumn get animalId => integer().references(Animals, #id)();
  
  // ========== DADOS DA IMAGEM ==========
  
  /// Imagem principal em Base64 DataURI
  /// Formato: data:image/jpeg;base64,/9j/4AAQ...
  /// Tamanho máximo: 600KB após compressão
  TextColumn get imageBase64 => text()();
  
  /// Thumbnail em Base64 DataURI (150x150, ~30KB)
  /// Usado para listagens e grids com muitas imagens
  TextColumn get thumbnailBase64 => text().nullable()();
  
  /// Nome original do arquivo
  TextColumn get fileName => text().nullable()();
  
  /// Tipo MIME da imagem
  TextColumn get mimeType => text().withDefault(const Constant('image/jpeg'))();
  
  /// Tamanho em bytes (da imagem original antes de comprimir)
  IntColumn get sizeBytes => integer().nullable()();
  
  /// Largura da imagem em pixels
  IntColumn get width => integer().nullable()();
  
  /// Altura da imagem em pixels
  IntColumn get height => integer().nullable()();
  
  // ========== METADADOS ==========
  
  /// Se é a imagem principal do animal
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  
  /// Ordem de exibição (0 = primeira)
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  /// Descrição/legenda da imagem
  TextColumn get caption => text().nullable()();
  
  // ========== CAMPOS DE SYNC ==========
  
  /// Data de criação
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// Data de última atualização
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  /// Data da última sincronização
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  
  /// Se tem alterações pendentes de sync
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  
  /// Se foi marcado como deletado (soft delete)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  /// Versão para controle de conflitos
  IntColumn get version => integer().withDefault(const Constant(1))();
}

/// Serviço Drift - Sistema robusto de persistência SQL
///
/// Este módulo fornece uma camada completa de abstração sobre o Drift,
/// incluindo:
/// - Configuração e inicialização de bancos de dados
/// - Mixins e classes base para funcionalidades comuns
/// - Padrão Repository para acesso consistente aos dados
/// - Utilitários para backup, migração e manutenção
///
/// ## Exemplo de Uso Básico
///
/// ### 1. Defina suas tabelas
/// ```dart
/// import 'package:drift/drift.dart';
///
/// class Users extends Table {
///   IntColumn get id => integer().autoIncrement()();
///   TextColumn get name => text().withLength(min: 1, max: 100)();
///   TextColumn get email => text().unique()();
///   DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
/// }
/// ```
///
/// ### 2. Crie seu banco de dados
/// ```dart
/// import 'package:core/services/drift/drift.dart';
///
/// @DriftDatabase(tables: [Users])
/// class AppDatabase extends _$AppDatabase with BaseDriftDatabase {
///   AppDatabase(QueryExecutor e) : super(e);
///
///   @override
///   int get schemaVersion => 1;
///
///   // Factory para criar a instância
///   factory AppDatabase.create() {
///     return AppDatabase(
///       DriftDatabaseConfig.createExecutor(
///         databaseName: 'my_app.db',
///         logStatements: true, // Para debug
///       ),
///     );
///   }
/// }
/// ```
///
/// ### 3. Crie um repositório
/// ```dart
/// class UserRepository extends BaseDriftRepositoryImpl<User, UserData> {
///   UserRepository(this._db);
///
///   final AppDatabase _db;
///
///   @override
///   TableInfo<Users, UserData> get table => _db.users;
///
///   @override
///   GeneratedDatabase get database => _db;
///
///   @override
///   User fromData(UserData data) => User.fromData(data);
///
///   @override
///   Insertable<UserData> toCompanion(User entity) => entity.toCompanion();
///
///   // Métodos customizados
///   Future<List<User>> findByEmail(String email) async {
///     final query = _db.select(_db.users)
///       ..where((tbl) => tbl.email.equals(email));
///     final results = await query.get();
///     return results.map((data) => fromData(data)).toList();
///   }
/// }
/// ```
///
/// ### 4. Use em seu app
/// ```dart
/// void main() async {
///   final db = AppDatabase.create();
///   final userRepo = UserRepository(db);
///
///   // Inserir
///   final userId = await userRepo.insert(User(name: 'João', email: 'joao@example.com'));
///
///   // Buscar
///   final user = await userRepo.findById(userId);
///
///   // Observar mudanças
///   userRepo.watchAll().listen((users) {
///     print('Usuários atualizados: ${users.length}');
///   });
///
///   // Estatísticas
///   final stats = await db.getDatabaseStats();
///   print('Estatísticas: $stats');
///
///   // Backup
///   final backupPath = await DriftDatabaseConfig.backupDatabase('my_app.db');
///   print('Backup criado em: $backupPath');
/// }
/// ```
///
/// ## Funcionalidades Avançadas
///
/// ### Transações
/// ```dart
/// await db.executeTransaction(() async {
///   await userRepo.insert(user1);
///   await userRepo.insert(user2);
/// }, operationName: 'Inserir múltiplos usuários');
/// ```
///
/// ### Operações em Batch
/// ```dart
/// await db.executeBatch((batch) {
///   batch.insertAll(db.users, userCompanions);
/// });
/// ```
///
/// ### Manutenção do Banco
/// ```dart
/// // Verificar integridade
/// final isIntegral = await db.checkIntegrity();
///
/// // Otimizar (VACUUM)
/// await db.vacuum();
///
/// // Limpar todas as tabelas
/// await db.clearAllTables();
/// ```
///
/// ## Migrações
///
/// Para adicionar migrações, sobrescreva o método `migration`:
/// ```dart
/// @override
/// MigrationStrategy get migration => MigrationStrategy(
///   onCreate: (Migrator m) async {
///     await m.createAll();
///   },
///   onUpgrade: (Migrator m, int from, int to) async {
///     if (from < 2) {
///       // Migração da versão 1 para 2
///       await m.addColumn(users, users.phoneNumber);
///     }
///     if (from < 3) {
///       // Migração da versão 2 para 3
///       await m.createTable(posts);
///     }
///   },
/// );
/// ```

library;

export 'base_drift_database.dart';
export 'base_drift_repository.dart';
export 'drift_database_config.dart';

/// Exemplo completo de implementação do Drift Service
///
/// Este arquivo demonstra como criar um banco de dados completo
/// com tabelas, repositórios e uso em uma aplicação Flutter.

library example;

import 'package:core/services/drift/drift.dart';
import 'package:drift/drift.dart';

part 'example_database.g.dart';

// ============================================================================
// TABELAS
// ============================================================================

/// Tabela de Usuários
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  TextColumn get phoneNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Tabela de Veículos
class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get model => text().withLength(min: 1, max: 100)();
  TextColumn get licensePlate => text().withLength(min: 1, max: 20)();
  IntColumn get year => integer()();
  RealColumn get odometer => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tabela de Abastecimentos
class Refuelings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  RealColumn get liters => real()();
  RealColumn get pricePerLiter => real()();
  RealColumn get totalCost => real()();
  RealColumn get odometer => real()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get fullTank => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [Users, Vehicles, Refuelings])
class ExampleDatabase extends _$ExampleDatabase with BaseDriftDatabase {
  ExampleDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  /// Factory para ambiente de produção
  factory ExampleDatabase.production() {
    return ExampleDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'example_app.db',
        logStatements: false,
      ),
    );
  }

  /// Factory para ambiente de desenvolvimento
  factory ExampleDatabase.development() {
    return ExampleDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'example_app_dev.db',
        logStatements: true, // Log habilitado para debug
      ),
    );
  }

  /// Factory para testes
  factory ExampleDatabase.test() {
    return ExampleDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
  }

  /// Migração do banco de dados
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Exemplo de migração
      // if (from < 2) {
      //   await m.addColumn(users, users.phoneNumber);
      // }
    },
  );
}

// ============================================================================
// ENTIDADES DE DOMÍNIO
// ============================================================================

/// Entidade de Usuário (Domain Model)
class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
  });

  factory User.fromData(UserData data) {
    return User(
      id: data.id,
      name: data.name,
      email: data.email,
      phoneNumber: data.phoneNumber,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isActive: data.isActive,
    );
  }

  UsersCompanion toCompanion() {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      phoneNumber: Value(phoneNumber),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ============================================================================
// REPOSITÓRIOS
// ============================================================================

/// Repositório de Usuários
class UserRepository extends BaseDriftRepositoryImpl<User, UserData> {
  UserRepository(this._db);

  final ExampleDatabase _db;

  @override
  TableInfo<Users, UserData> get table => _db.users;

  @override
  GeneratedDatabase get database => _db;

  @override
  User fromData(UserData data) => User.fromData(data);

  @override
  Insertable<UserData> toCompanion(User entity) => entity.toCompanion();

  @override
  Expression<int> idColumn(Users tbl) => tbl.id;

  // Métodos customizados

  /// Busca usuário por email
  Future<User?> findByEmail(String email) async {
    final query = _db.select(_db.users)
      ..where((tbl) => tbl.email.equals(email))
      ..limit(1);

    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }

  /// Busca usuários ativos
  Future<List<User>> findActiveUsers() async {
    final query = _db.select(_db.users)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    final results = await query.get();
    return results.map((data) => fromData(data)).toList();
  }

  /// Observa usuários ativos
  Stream<List<User>> watchActiveUsers() {
    final query = _db.select(_db.users)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }

  /// Desativa um usuário (soft delete)
  Future<bool> deactivateUser(int userId) async {
    final rowsAffected =
        await (_db.update(
          _db.users,
        )..where((tbl) => tbl.id.equals(userId))).write(
          UsersCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// Atualiza informações do usuário
  Future<bool> updateUserInfo({
    required int userId,
    String? name,
    String? email,
    String? phoneNumber,
  }) async {
    final updates = <String, Expression>{};

    if (name != null) {
      updates['name'] = Variable(name);
    }
    if (email != null) {
      updates['email'] = Variable(email);
    }
    if (phoneNumber != null) {
      updates['phone_number'] = Variable(phoneNumber);
    }

    updates['updated_at'] = Variable(DateTime.now());

    if (updates.isEmpty) return false;

    final rowsAffected =
        await (_db.update(
          _db.users,
        )..where((tbl) => tbl.id.equals(userId))).write(
          UsersCompanion(
            name: name != null ? Value(name) : const Value.absent(),
            email: email != null ? Value(email) : const Value.absent(),
            phoneNumber: phoneNumber != null
                ? Value(phoneNumber)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );

    return rowsAffected > 0;
  }
}

// ============================================================================
// USO EM APLICAÇÃO
// ============================================================================

/// Exemplo de uso em uma aplicação Flutter
Future<void> exampleUsage() async {
  // Inicializar database
  final db = ExampleDatabase.development();

  // Criar repositório
  final userRepo = UserRepository(db);

  // ========== OPERAÇÕES BÁSICAS ==========

  // Criar usuário
  final newUser = User(
    id: 0, // Será ignorado pelo autoIncrement
    name: 'João Silva',
    email: 'joao@example.com',
    phoneNumber: '+55 11 99999-9999',
    createdAt: DateTime.now(),
    isActive: true,
  );

  final userId = await userRepo.insert(newUser);
  print('Usuário criado com ID: $userId');

  // Buscar usuário
  final user = await userRepo.findById(userId);
  print('Usuário encontrado: ${user?.name}');

  // Buscar por email
  final userByEmail = await userRepo.findByEmail('joao@example.com');
  print('Usuário por email: ${userByEmail?.name}');

  // Listar todos
  final allUsers = await userRepo.findAll();
  print('Total de usuários: ${allUsers.length}');

  // Atualizar
  await userRepo.updateUserInfo(
    userId: userId,
    name: 'João Pedro Silva',
    phoneNumber: '+55 11 88888-8888',
  );

  // Soft delete (desativar)
  await userRepo.deactivateUser(userId);

  // ========== STREAMS REATIVOS ==========

  // Observar mudanças em tempo real
  userRepo.watchAll().listen((users) {
    print('Usuários atualizados: ${users.length}');
  });

  // Observar usuários ativos
  userRepo.watchActiveUsers().listen((activeUsers) {
    print('Usuários ativos: ${activeUsers.length}');
  });

  // ========== TRANSAÇÕES ==========

  await db.executeTransaction(() async {
    final user1Id = await userRepo.insert(
      User(
        id: 0,
        name: 'Maria',
        email: 'maria@example.com',
        createdAt: DateTime.now(),
        isActive: true,
      ),
    );

    final user2Id = await userRepo.insert(
      User(
        id: 0,
        name: 'José',
        email: 'jose@example.com',
        createdAt: DateTime.now(),
        isActive: true,
      ),
    );

    print('Usuários criados em transação: $user1Id, $user2Id');
  }, operationName: 'Criar múltiplos usuários');

  // ========== OPERAÇÕES EM BATCH ==========

  final users = [
    User(
      id: 0,
      name: 'Ana',
      email: 'ana@example.com',
      createdAt: DateTime.now(),
      isActive: true,
    ),
    User(
      id: 0,
      name: 'Carlos',
      email: 'carlos@example.com',
      createdAt: DateTime.now(),
      isActive: true,
    ),
  ];

  await db.executeBatch((batch) {
    batch.insertAll(db.users, users.map((u) => u.toCompanion()).toList());
  });

  // ========== ESTATÍSTICAS ==========

  final stats = await db.getDatabaseStats();
  print('Estatísticas do banco: $stats');

  final userCount = await userRepo.count();
  print('Total de usuários: $userCount');

  // ========== MANUTENÇÃO ==========

  // Verificar integridade
  final isIntegral = await db.checkIntegrity();
  print('Banco íntegro: $isIntegral');

  // Otimizar (VACUUM)
  await db.vacuum();

  // Backup
  final backupPath = await DriftDatabaseConfig.backupDatabase(
    'example_app_dev.db',
  );
  print('Backup criado em: $backupPath');

  // Tamanho do banco
  final dbSize = await DriftDatabaseConfig.getDatabaseSize(
    'example_app_dev.db',
  );
  print('Tamanho do banco: ${dbSize / 1024} KB');

  // ========== CLEANUP ==========

  await db.close();
}

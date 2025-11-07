# Drift Service - Sistema de Persistência SQL

O **Drift Service** é uma camada robusta de abstração sobre o [Drift](https://drift.simonbinder.eu/), fornecendo um sistema completo de persistência SQL com suporte a reactive streams, migrations, e padrões de repositório.

## 📦 Instalação

O Drift já está incluído no pacote `core`. Para usar em seu app:

```yaml
dependencies:
  core:
    path: ../../packages/core
```

## 🚀 Início Rápido

### 1. Defina suas Tabelas

```dart
import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Posts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get publishedAt => dateTime()();
}
```

### 2. Crie seu Banco de Dados

```dart
import 'package:core/services/drift/drift.dart';
import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users, Posts])
class AppDatabase extends _$AppDatabase with BaseDriftDatabase {
  AppDatabase(QueryExecutor e) : super(e);
  
  @override
  int get schemaVersion => 1;
  
  // Factory para criar a instância
  factory AppDatabase.create() {
    return AppDatabase(
      DriftDatabaseConfig.createExecutor(
        databaseName: 'app.db',
        logStatements: true, // Habilite para debug
      ),
    );
  }
}
```

### 3. Gere o Código

```bash
cd seu_app
dart run build_runner build
```

### 4. Crie um Repositório

```dart
import 'package:core/services/drift/drift.dart';

// Sua entidade de domínio
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // Converter de/para Drift
  factory User.fromData(UserData data) {
    return User(
      id: data.id,
      name: data.name,
      email: data.email,
      createdAt: data.createdAt,
    );
  }

  UsersCompanion toCompanion() {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      createdAt: Value(createdAt),
    );
  }
}

// Repositório
class UserRepository extends BaseDriftRepositoryImpl<User, UserData> {
  UserRepository(this._db);
  
  final AppDatabase _db;
  
  @override
  TableInfo<Users, UserData> get table => _db.users;
  
  @override
  GeneratedDatabase get database => _db;
  
  @override
  User fromData(UserData data) => User.fromData(data);
  
  @override
  Insertable<UserData> toCompanion(User entity) => entity.toCompanion();
  
  // Métodos customizados
  Future<User?> findByEmail(String email) async {
    final query = _db.select(_db.users)
      ..where((tbl) => tbl.email.equals(email))
      ..limit(1);
    
    final results = await query.get();
    return results.isEmpty ? null : fromData(results.first);
  }
  
  Stream<List<User>> watchActiveUsers() {
    final query = _db.select(_db.users)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
    
    return query.watch().map(
      (dataList) => dataList.map((data) => fromData(data)).toList(),
    );
  }
}
```

### 5. Use no seu App

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar database
  final db = AppDatabase.create();
  final userRepo = UserRepository(db);
  
  runApp(MyApp(database: db, userRepository: userRepo));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final UserRepository userRepository;
  
  const MyApp({
    required this.database,
    required this.userRepository,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserListPage(userRepository: userRepository),
    );
  }
}

class UserListPage extends StatelessWidget {
  final UserRepository userRepository;
  
  const UserListPage({required this.userRepository, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuários')),
      body: StreamBuilder<List<User>>(
        stream: userRepository.watchAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final users = snapshot.data!;
          
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await userRepository.insert(
            User(
              id: 0,
              name: 'Novo Usuário',
              email: 'novo@example.com',
              createdAt: DateTime.now(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 🎯 Funcionalidades

### Operações CRUD Básicas

```dart
// Criar
final userId = await userRepo.insert(user);

// Ler
final user = await userRepo.findById(userId);
final allUsers = await userRepo.findAll();

// Atualizar
await userRepo.update(user);

// Deletar
await userRepo.delete(userId);

// Contar
final count = await userRepo.count();

// Verificar existência
final exists = await userRepo.exists(userId);
```

### Streams Reativos

```dart
// Observar todos os registros
userRepo.watchAll().listen((users) {
  print('Total de usuários: ${users.length}');
});

// Observar um registro específico
userRepo.watchById(1).listen((user) {
  if (user != null) {
    print('Usuário atualizado: ${user.name}');
  }
});
```

### Transações

```dart
await db.executeTransaction(() async {
  final userId = await userRepo.insert(user);
  await postRepo.insert(Post(userId: userId, title: 'Primeiro post'));
}, operationName: 'Criar usuário e post');
```

### Operações em Batch

```dart
await db.executeBatch((batch) {
  batch.insertAll(db.users, userCompanions);
  batch.insertAll(db.posts, postCompanions);
});
```

### Estatísticas e Manutenção

```dart
// Obter estatísticas
final stats = await db.getDatabaseStats();
print(stats); // {users: 10, posts: 50}

// Verificar integridade
final isIntegral = await db.checkIntegrity();

// Otimizar banco de dados
await db.vacuum();

// Limpar todas as tabelas
await db.clearAllTables();
```

### Backup e Restore

```dart
// Criar backup
final backupPath = await DriftDatabaseConfig.backupDatabase('app.db');
print('Backup criado: $backupPath');

// Restaurar backup
await DriftDatabaseConfig.restoreDatabase(
  databaseName: 'app.db',
  backupPath: backupPath,
);

// Verificar tamanho
final size = await DriftDatabaseConfig.getDatabaseSize('app.db');
print('Tamanho do banco: $size bytes');
```

## 🔄 Migrações

Para adicionar migrações quando você alterar o schema:

```dart
@DriftDatabase(tables: [Users, Posts])
class AppDatabase extends _$AppDatabase with BaseDriftDatabase {
  AppDatabase(QueryExecutor e) : super(e);
  
  @override
  int get schemaVersion => 2; // Incrementar versão
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Adicionar coluna na versão 2
        await m.addColumn(users, users.phoneNumber);
      }
    },
  );
}
```

## 🧪 Testes

Para testes, use um banco em memória:

```dart
void main() {
  late AppDatabase db;
  late UserRepository userRepo;
  
  setUp(() {
    db = AppDatabase(
      DriftDatabaseConfig.createInMemoryExecutor(logStatements: true),
    );
    userRepo = UserRepository(db);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  test('Deve inserir e buscar usuário', () async {
    final user = User(
      id: 0,
      name: 'Teste',
      email: 'teste@example.com',
      createdAt: DateTime.now(),
    );
    
    final userId = await userRepo.insert(user);
    final foundUser = await userRepo.findById(userId);
    
    expect(foundUser, isNotNull);
    expect(foundUser!.name, equals('Teste'));
  });
}
```

## 📚 Recursos Adicionais

- [Documentação Oficial do Drift](https://drift.simonbinder.eu/)
- [Exemplos de Queries](https://drift.simonbinder.eu/docs/getting-started/writing_queries/)
- [Migrações](https://drift.simonbinder.eu/docs/advanced-features/migrations/)
- [Testes](https://drift.simonbinder.eu/docs/testing/)

## 💡 Dicas

1. **Performance**: Use `batch()` para inserções múltiplas
2. **Reactive**: Prefira `watch()` ao invés de `get()` para UI reativa
3. **Índices**: Crie índices para colunas frequentemente consultadas
4. **Transactions**: Use transações para operações relacionadas
5. **Migrations**: Sempre teste migrações com dados reais
6. **Backup**: Implemente backups automáticos periodicamente
7. **Debug**: Habilite `logStatements` durante desenvolvimento

## 🐛 Troubleshooting

### Build Runner não gera arquivos

```bash
# Limpar cache
dart run build_runner clean

# Rebuildar
dart run build_runner build --delete-conflicting-outputs
```

### Erro de conflito de tipos

Certifique-se de que suas entidades de domínio correspondem aos tipos das tabelas Drift.

### Erro em migrations

Sempre teste migrations em um banco de teste antes de aplicar em produção.

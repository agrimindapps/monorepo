# Análise e Plano de Migração: App-PetiVeti para SOLID

> **📁 Projeto Original**: `/plans/app-petiveti/`  
> **🎯 Destino**: `/apps/app-petiveti/` (Nova arquitetura SOLID)

## 📋 Análise do Projeto Atual

> **⚠️ IMPORTANTE**: Este documento serve como base para migração. Todo material original está em:  
> `📂 /Users/lucineiloch/Documents/deveopment/monorepo/plans/app-petiveti/`

### Estrutura Identificada
O **app-petiveti** é um aplicativo veterinário completo com as seguintes características:

#### 📂 Referências do Código Original
```
plans/app-petiveti/
├── app-page.dart                    # Entry point da aplicação
├── constants/                       # Configurações e constantes
├── controllers/                     # Controllers GetX atuais
├── core/                           # Núcleo atual (error_manager, interfaces)
├── models/                         # Modelos Hive (11_animal_model.dart, etc.)
├── pages/                          # Todas as páginas da aplicação
├── repository/                     # Repositórios atuais
├── services/                       # Serviços de negócio
├── utils/                          # Utilitários e helpers
└── widgets/                        # Widgets reutilizáveis
```

#### Funcionalidades Principais
- **Gestão de Animais**: Cadastro, edição e controle de pets (cães/gatos)
- **Consultas Veterinárias**: Agendamento e histórico de consultas
- **Controle de Vacinas**: Sistema de vacinação e lembretes
- **Gestão de Medicamentos**: Controle de medicações e dosagens
- **Controle de Peso**: Monitoramento do peso dos animais
- **Lembretes**: Sistema de notificações para cuidados
- **Despesas**: Controle financeiro veterinário
- **Calculadoras Veterinárias**: 15+ calculadoras especializadas
- **Sistema de Autenticação**: Login e controle de usuários
- **Sistema de Assinaturas**: Integração com RevenueCat

#### Calculadoras Especializadas
- Condição Corporal
- Conversão de Unidades
- Diabetes/Insulina
- Dieta Caseira
- Dosagem de Anestésicos
- Dosagem de Medicamentos
- Fluidoterapia
- Gestação
- Hidratação
- Idade Animal
- Necessidades Calóricas
- E outras...

### Arquitetura Atual
- **Padrão**: MVC com GetX
- **Persistência**: Hive Database + Firebase Firestore
- **Estado**: GetX Controller
- **Estrutura**: Modular mas com acoplamento

### Problemas Identificados
1. **Violação SRP**: Controladores fazem múltiplas responsabilidades
2. **Acoplamento Alto**: Dependências diretas entre camadas
3. **Falta de Abstração**: Repositórios acoplados ao Hive
4. **Testabilidade Limitada**: Difícil criar testes unitários
5. **Escalabilidade**: Difícil adicionar novas funcionalidades

## 🔄 Transformação de Padrões: Atual vs. SOLID

### GetX Controller → Provider/Riverpod + Use Cases

#### ❌ ANTES (GetX Pattern)
```dart
// plans/app-petiveti/controllers/vacinas_controller.dart
// Violação SRP: Mistura UI state, business logic e data access
class VacinasController extends GetxController {
  final _vacinas = <VacinaVet>[].obs;
  final _isLoading = false.obs;
  final _repository = VacinaRepository();
  
  List<VacinaVet> get vacinas => _vacinas;
  bool get isLoading => _isLoading.value;
  
  Future<void> loadVacinas(String animalId) async {
    _isLoading.value = true;
    try {
      final result = await _repository.getVacinas(animalId);
      _vacinas.assignAll(result);
      Get.snackbar('Sucesso', 'Vacinas carregadas');
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar vacinas');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> addVacina(VacinaVet vacina) async {
    // Business logic + UI state + Data access misturados
    if (vacina.nomeVacina.isEmpty) {
      Get.snackbar('Erro', 'Nome é obrigatório');
      return;
    }
    
    await _repository.addVacina(vacina);
    _vacinas.add(vacina);
    Get.back(); // Navigation logic aqui também
  }
}
```

#### ✅ DEPOIS (SOLID Pattern)

**1. Domain Layer: Use Case com Business Logic Isolada**
```dart
// apps/app-petiveti/lib/features/vaccines/domain/usecases/get_vaccines.dart
class GetVaccinesUseCase {
  final VaccineRepository repository;
  
  GetVaccinesUseCase(this.repository);
  
  Future<Either<Failure, List<Vaccine>>> call(String animalId) async {
    if (animalId.isEmpty) {
      return Left(ValidationFailure('Animal ID é obrigatório'));
    }
    
    return await repository.getVaccines(animalId);
  }
}

// apps/app-petiveti/lib/features/vaccines/domain/usecases/add_vaccine.dart
class AddVaccineUseCase {
  final VaccineRepository repository;
  
  AddVaccineUseCase(this.repository);
  
  Future<Either<Failure, void>> call(Vaccine vaccine) async {
    final validation = vaccine.validate();
    if (validation.isLeft()) {
      return Left(ValidationFailure('Dados inválidos'));
    }
    
    return await repository.addVaccine(vaccine);
  }
}
```

**2. Presentation Layer: Provider Apenas Gerencia Estado**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/providers/vaccines_provider.dart
class VaccinesProvider extends ChangeNotifier {
  final GetVaccinesUseCase _getVaccinesUseCase;
  final AddVaccineUseCase _addVaccineUseCase;
  
  VaccinesProvider(this._getVaccinesUseCase, this._addVaccineUseCase);
  
  List<Vaccine> _vaccines = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Vaccine> get vaccines => _vaccines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadVaccines(String animalId) async {
    _setLoading(true);
    
    final result = await _getVaccinesUseCase(animalId);
    
    result.fold(
      (failure) => _setError(failure.message),
      (vaccines) => _setVaccines(vaccines),
    );
    
    _setLoading(false);
  }
  
  Future<void> addVaccine(Vaccine vaccine) async {
    final result = await _addVaccineUseCase(vaccine);
    
    result.fold(
      (failure) => _setError(failure.message),
      (_) => _addVaccineToList(vaccine),
    );
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setVaccines(List<Vaccine> vaccines) {
    _vaccines = vaccines;
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _addVaccineToList(Vaccine vaccine) {
    _vaccines.add(vaccine);
    notifyListeners();
  }
}
```

### Repository Pattern: Direct Coupling → Interface Abstraction

#### ❌ ANTES (Acoplamento Direto)
```dart
// plans/app-petiveti/repository/vacina_repository.dart
class VacinaRepository {
  static const String _boxName = 'box_vet_vacinas';
  static const String collectionName = 'box_vet_vacinas';
  
  // Direct coupling com implementações específicas
  final _firestore = FirestoreService();
  Box<VacinaVet> get _box => Hive.box<VacinaVet>(_boxName);
  
  Future<List<VacinaVet>> getVacinas(String animalId) async {
    try {
      // Lógica misturada: local + remote + sync
      final localVacinas = _box.values.where((v) => v.animalId == animalId).toList();
      
      if (isOnline) {
        final remoteVacinas = await _firestore.getVacinas(animalId);
        // Sync logic aqui...
        return remoteVacinas;
      }
      
      return localVacinas;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
```

#### ✅ DEPOIS (Interface + Dependency Injection)

**1. Domain Interface**
```dart
// apps/app-petiveti/lib/features/vaccines/domain/repositories/vaccine_repository.dart
abstract class VaccineRepository {
  Future<Either<Failure, List<Vaccine>>> getVaccines(String animalId);
  Future<Either<Failure, void>> addVaccine(Vaccine vaccine);
  Future<Either<Failure, void>> updateVaccine(Vaccine vaccine);
  Future<Either<Failure, void>> deleteVaccine(String vaccineId);
}
```

**2. Data Implementation com Dependency Injection**
```dart
// apps/app-petiveti/lib/features/vaccines/data/repositories/vaccine_repository_impl.dart
class VaccineRepositoryImpl implements VaccineRepository {
  final VaccineLocalDataSource localDataSource;
  final VaccineRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  VaccineRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Vaccine>>> getVaccines(String animalId) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteVaccines = await remoteDataSource.getVaccines(animalId);
        await localDataSource.cacheVaccines(remoteVaccines);
        return Right(remoteVaccines.map((model) => model.toEntity()).toList());
      } else {
        final localVaccines = await localDataSource.getVaccines(animalId);
        return Right(localVaccines.map((model) => model.toEntity()).toList());
      }
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

**3. DataSources Separados e Testáveis**
```dart
// Local DataSource
abstract class VaccineLocalDataSource {
  Future<List<VaccineModel>> getVaccines(String animalId);
  Future<void> cacheVaccines(List<VaccineModel> vaccines);
}

class VaccineLocalDataSourceImpl implements VaccineLocalDataSource {
  final HiveService hiveService;
  
  VaccineLocalDataSourceImpl(this.hiveService);
  
  @override
  Future<List<VaccineModel>> getVaccines(String animalId) async {
    final box = await hiveService.getBox<VaccineModel>('vaccines');
    return box.values.where((v) => v.animalId == animalId).toList();
  }
}

// Remote DataSource  
abstract class VaccineRemoteDataSource {
  Future<List<VaccineModel>> getVaccines(String animalId);
  Future<void> addVaccine(VaccineModel vaccine);
}

class VaccineRemoteDataSourceImpl implements VaccineRemoteDataSource {
  final FirebaseService firebaseService;
  
  VaccineRemoteDataSourceImpl(this.firebaseService);
  
  @override
  Future<List<VaccineModel>> getVaccines(String animalId) async {
    return await firebaseService.getCollection<VaccineModel>(
      'vaccines',
      where: [WhereCondition('animalId', isEqualTo: animalId)],
      fromMap: VaccineModel.fromMap,
    );
  }
}
```

### Model/Entity Separation: Hive Annotations → Clean Entities

#### ❌ ANTES (Model Poluído)
```dart
// plans/app-petiveti/models/16_vacina_model.dart
@HiveType(typeId: 16)
class VacinaVet extends BaseModel {
  @HiveField(7)
  String nomeVacina;
  
  @HiveField(8)
  int dataAplicacao;
  
  @HiveField(9)
  int? proximaAplicacao;
  
  // Model misturado com business logic
  String get statusVacina {
    if (proximaAplicacao == null) return 'Dose única';
    final agora = DateTime.now().millisecondsSinceEpoch;
    if (proximaAplicacao! < agora) return 'Atrasada';
    return 'Em dia';
  }
  
  // Serialization misturada com domain
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'nomeVacina': nomeVacina,
      'dataAplicacao': dataAplicacao,
      'proximaAplicacao': proximaAplicacao,
    });
  }
}
```

#### ✅ DEPOIS (Separação Clara)

**1. Domain Entity (Pura)**
```dart
// apps/app-petiveti/lib/features/vaccines/domain/entities/vaccine.dart
class Vaccine extends Equatable {
  final String id;
  final String animalId;
  final String name;
  final DateTime applicationDate;
  final DateTime? nextApplicationDate;
  final String? observations;
  
  const Vaccine({
    required this.id,
    required this.animalId,
    required this.name,
    required this.applicationDate,
    this.nextApplicationDate,
    this.observations,
  });
  
  // Business logic no domain
  VaccineStatus get status {
    if (nextApplicationDate == null) return VaccineStatus.singleDose;
    
    final now = DateTime.now();
    if (nextApplicationDate!.isBefore(now)) return VaccineStatus.overdue;
    
    final daysUntilNext = nextApplicationDate!.difference(now).inDays;
    if (daysUntilNext <= 7) return VaccineStatus.soon;
    
    return VaccineStatus.upToDate;
  }
  
  bool get isOverdue => status == VaccineStatus.overdue;
  
  Either<ValidationFailure, Vaccine> validate() {
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Nome da vacina é obrigatório'));
    }
    
    if (applicationDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Data de aplicação não pode ser futura'));
    }
    
    return Right(this);
  }
  
  @override
  List<Object?> get props => [id, animalId, name, applicationDate, nextApplicationDate];
}

enum VaccineStatus { singleDose, upToDate, soon, overdue }
```

**2. Data Model (Serialização)**
```dart
// apps/app-petiveti/lib/features/vaccines/data/models/vaccine_model.dart
@HiveType(typeId: 16)
class VaccineModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String animalId;
  
  @HiveField(2)
  late String name;
  
  @HiveField(3)
  late int applicationDateTimestamp;
  
  @HiveField(4)
  int? nextApplicationDateTimestamp;
  
  @HiveField(5)
  String? observations;
  
  VaccineModel({
    required this.id,
    required this.animalId,
    required this.name,
    required this.applicationDateTimestamp,
    this.nextApplicationDateTimestamp,
    this.observations,
  });
  
  // Conversion methods
  factory VaccineModel.fromEntity(Vaccine vaccine) {
    return VaccineModel(
      id: vaccine.id,
      animalId: vaccine.animalId,
      name: vaccine.name,
      applicationDateTimestamp: vaccine.applicationDate.millisecondsSinceEpoch,
      nextApplicationDateTimestamp: vaccine.nextApplicationDate?.millisecondsSinceEpoch,
      observations: vaccine.observations,
    );
  }
  
  Vaccine toEntity() {
    return Vaccine(
      id: id,
      animalId: animalId,
      name: name,
      applicationDate: DateTime.fromMillisecondsSinceEpoch(applicationDateTimestamp),
      nextApplicationDate: nextApplicationDateTimestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(nextApplicationDateTimestamp!)
        : null,
      observations: observations,
    );
  }
  
  factory VaccineModel.fromMap(Map<String, dynamic> map) {
    return VaccineModel(
      id: map['id'] ?? '',
      animalId: map['animalId'] ?? '',
      name: map['name'] ?? '',
      applicationDateTimestamp: map['applicationDate'] ?? 0,
      nextApplicationDateTimestamp: map['nextApplicationDate'],
      observations: map['observations'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animalId': animalId,
      'name': name,
      'applicationDate': applicationDateTimestamp,
      'nextApplicationDate': nextApplicationDateTimestamp,
      'observations': observations,
    };
  }
}

## ⚠️ BaseModel Pattern Discovery

### PROBLEMA CRÍTICO IDENTIFICADO
Todos os modelos (`Animal`, `Vacina`, `Consulta`, etc.) herdam de `BaseModel`, mas esta classe **não foi encontrada** no código fonte analisado em `plans/app-petiveti/`.

### 📂 Evidências no Código Original
```dart
// plans/app-petiveti/models/11_animal_model.dart
class Animal extends BaseModel {  // ← BaseModel não encontrada!
  @HiveField(7)
  String nome;
  // ...
}

// plans/app-petiveti/models/16_vacina_model.dart  
class VacinaVet extends BaseModel {  // ← BaseModel não encontrada!
  @HiveField(7)
  String nomeVacina;
  // ...
}
```

### 🔍 INFERÊNCIA BASEADA NO USO NOS REPOSITÓRIOS
Analisando como os repositórios utilizam os modelos, BaseModel deve conter:

```dart
// INFERÊNCIA: Como BaseModel deve ser implementada
abstract class BaseModel {
  String id;
  int createdAt;           // Timestamp de criação
  int updatedAt;           // Timestamp de atualização  
  bool isDeleted;          // Soft delete flag
  bool needsSync;          // Flag de sincronização pendente
  int? lastSyncAt;         // Último timestamp de sincronização
  int version;             // Controle de versão para conflicts
  
  // Métodos abstratos que devem ser implementados
  Map<String, dynamic> toMap();
  
  // Métodos de utilidade para sincronização
  void markForSync() {
    needsSync = true;
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }
  
  void markSynced() {
    needsSync = false;
    lastSyncAt = DateTime.now().millisecondsSinceEpoch;
  }
  
  // Método de construção padrão
  BaseModel({
    String? id,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    bool? needsSync,
    int? lastSyncAt,
    int? version,
  }) : 
    id = id ?? _generateId(),
    createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
    updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    isDeleted = isDeleted ?? false,
    needsSync = needsSync ?? true,
    lastSyncAt = lastSyncAt,
    version = version ?? 1;
    
  static String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
```

### 🏗️ MIGRAÇÃO PARA CLEAN ARCHITECTURE

#### ❌ PROBLEMA: BaseModel Viola Single Responsibility
```dart
// ATUAL: Model com responsabilidades misturadas
class Animal extends BaseModel {
  String nome;
  String especie;
  
  // Serialization + Domain logic + Sync logic misturados
  @override
  Map<String, dynamic> toMap() {
    return super.toMap()..addAll({
      'nome': nome,
      'especie': especie,
    });
  }
}
```

#### ✅ SOLUÇÃO: Separação Entity/Model

**1. Domain Entity (Sem dependências externas)**
```dart
// apps/app-petiveti/lib/features/animals/domain/entities/animal.dart
class Animal extends Equatable {
  final String id;
  final String name;
  final AnimalSpecies species;
  final String breed;
  final DateTime birthDate;
  final AnimalGender gender;
  final String color;
  final double currentWeight;
  final String? photo;
  final String? observations;
  
  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.gender,
    required this.color,
    required this.currentWeight,
    this.photo,
    this.observations,
  });
  
  // Business logic puro no domain
  int get ageInMonths {
    final now = DateTime.now();
    return (now.difference(birthDate).inDays / 30).round();
  }
  
  bool get isAdult => ageInMonths >= (species == AnimalSpecies.dog ? 12 : 10);
  
  Either<ValidationFailure, Animal> validate() {
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Nome é obrigatório'));
    }
    
    if (currentWeight <= 0) {
      return Left(ValidationFailure('Peso deve ser maior que zero'));
    }
    
    if (birthDate.isAfter(DateTime.now())) {
      return Left(ValidationFailure('Data de nascimento não pode ser futura'));
    }
    
    return Right(this);
  }
  
  @override
  List<Object?> get props => [id, name, species, breed, birthDate, gender, color, currentWeight];
}

enum AnimalSpecies { dog, cat }
enum AnimalGender { male, female }
```

**2. Data Model (Com BaseModel Legacy Support)**
```dart
// apps/app-petiveti/lib/features/animals/data/models/animal_model.dart
@HiveType(typeId: 11)
class AnimalModel extends HiveObject {
  // Core fields from BaseModel pattern
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late int createdAt;
  
  @HiveField(2)
  late int updatedAt;
  
  @HiveField(3)
  late bool isDeleted;
  
  @HiveField(4)
  late bool needsSync;
  
  @HiveField(5)
  int? lastSyncAt;
  
  @HiveField(6)
  late int version;
  
  // Animal specific fields
  @HiveField(7)
  late String nome;
  
  @HiveField(8)
  late String especie;
  
  @HiveField(9)
  late String raca;
  
  @HiveField(10)
  late int dataNascimento;
  
  @HiveField(11)
  late String sexo;
  
  @HiveField(12)
  late String cor;
  
  @HiveField(13)
  late double pesoAtual;
  
  @HiveField(14)
  String? foto;
  
  @HiveField(15)
  String? observacoes;
  
  AnimalModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.needsSync,
    this.lastSyncAt,
    required this.version,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.dataNascimento,
    required this.sexo,
    required this.cor,
    required this.pesoAtual,
    this.foto,
    this.observacoes,
  });
  
  // Conversion from legacy BaseModel to Entity
  Animal toEntity() {
    return Animal(
      id: id,
      name: nome,
      species: especie == 'Cachorro' ? AnimalSpecies.dog : AnimalSpecies.cat,
      breed: raca,
      birthDate: DateTime.fromMillisecondsSinceEpoch(dataNascimento),
      gender: sexo == 'Macho' ? AnimalGender.male : AnimalGender.female,
      color: cor,
      currentWeight: pesoAtual,
      photo: foto,
      observations: observacoes,
    );
  }
  
  // Conversion from Entity to Model
  factory AnimalModel.fromEntity(Animal animal) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return AnimalModel(
      id: animal.id,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
      needsSync: true,
      version: 1,
      nome: animal.name,
      especie: animal.species == AnimalSpecies.dog ? 'Cachorro' : 'Gato',
      raca: animal.breed,
      dataNascimento: animal.birthDate.millisecondsSinceEpoch,
      sexo: animal.gender == AnimalGender.male ? 'Macho' : 'Fêmea',
      cor: animal.color,
      pesoAtual: animal.currentWeight,
      foto: animal.photo,
      observacoes: animal.observations,
    );
  }
  
  // Legacy toMap support for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'needsSync': needsSync,
      'lastSyncAt': lastSyncAt,
      'version': version,
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'dataNascimento': dataNascimento,
      'sexo': sexo,
      'cor': cor,
      'pesoAtual': pesoAtual,
      'foto': foto,
      'observacoes': observacoes,
    };
  }
  
  factory AnimalModel.fromMap(Map<String, dynamic> map) {
    return AnimalModel(
      id: map['id'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isDeleted: map['isDeleted'] ?? false,
      needsSync: map['needsSync'] ?? true,
      lastSyncAt: map['lastSyncAt'],
      version: map['version'] ?? 1,
      nome: map['nome'] ?? '',
      especie: map['especie'] ?? '',
      raca: map['raca'] ?? '',
      dataNascimento: map['dataNascimento'] ?? 0,
      sexo: map['sexo'] ?? '',
      cor: map['cor'] ?? '',
      pesoAtual: map['pesoAtual']?.toDouble() ?? 0.0,
      foto: map['foto'],
      observacoes: map['observacoes'],
    );
  }
  
  // Sync management methods
  void markForSync() {
    needsSync = true;
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }
  
  void markSynced() {
    needsSync = false;
    lastSyncAt = DateTime.now().millisecondsSinceEpoch;
  }
}
```

### 🚀 STRATEGY PARA MIGRAÇÃO
1. **Manter compatibilidade** com estrutura BaseModel existente
2. **Separar concerns** entre Entity (domain) e Model (data)
3. **Preservar campos** de sincronização para Firebase
4. **Converter progressivamente** cada feature
5. **Testar thoroughly** conversões Entity ↔ Model

## 🎯 Objetivo da Migração

Criar um novo **app-petiveti** na pasta `apps/` seguindo:
- **Clean Architecture** (Domain, Data, Presentation)
- **Princípios SOLID**
- **Dependency Injection** (GetIt)
- **Testabilidade** completa
- **Modularidade** aprimorada

## 🔥 Firebase Integration Architecture

### SERVIÇOS FIREBASE IDENTIFICADOS NO CÓDIGO
O código atual referencia serviços Firebase que devem estar em packages não incluídos:

```dart
// plans/app-petiveti/repository/animal_repository.dart
final _firestore = FirestoreService(); // ← Serviço não encontrado!

// plans/app-petiveti/services/auth_service.dart  
final _auth = FirebaseAuthService(); // ← Serviço não encontrado!

// plans/app-petiveti/core/navigation/route_manager.dart
final _authNav = AuthNavigationService(); // ← Serviço não encontrado!
```

### 📂 EVIDÊNCIAS DE USO NO CÓDIGO ORIGINAL
```dart
// Padrão atual encontrado nos repositórios
class VacinaRepository {
  final _firestore = FirestoreService();
  
  Future<List<VacinaVet>> getVacinas(String animalId) async {
    if (isOnline) {
      final remoteVacinas = await _firestore.getVacinas(animalId);
      return remoteVacinas;
    }
    // Fallback para local
  }
}
```

### 🏗️ MIGRAÇÃO PARA PACKAGES/CORE INTEGRATION

#### ❌ PROBLEMA: Direct Service Instantiation
```dart
// ATUAL: Instanciação direta viola DIP
class AnimalRepository {
  final _firestore = FirestoreService(); // Hard dependency
  final _auth = FirebaseAuthService();   // Hard dependency
  
  Future<List<Animal>> getAnimals() async {
    final user = await _auth.getCurrentUser();
    return _firestore.getAnimals(user.id);
  }
}
```

#### ✅ SOLUÇÃO: Dependency Injection via Packages/Core

**1. Core Firebase Service Interfaces**
```dart
// packages/core/lib/src/interfaces/firebase_service.dart
abstract class FirebaseService {
  Future<T> getDocument<T>(
    String collection,
    String documentId, {
    required T Function(Map<String, dynamic>) fromMap,
  });
  
  Future<List<T>> getCollection<T>(
    String collection, {
    List<WhereCondition>? where,
    OrderByCondition? orderBy,
    int? limit,
    required T Function(Map<String, dynamic>) fromMap,
  });
  
  Future<void> setDocument<T>(
    String collection,
    String documentId,
    T data, {
    required Map<String, dynamic> Function(T) toMap,
  });
  
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  );
  
  Future<void> deleteDocument(String collection, String documentId);
  
  Stream<List<T>> streamCollection<T>(
    String collection, {
    List<WhereCondition>? where,
    required T Function(Map<String, dynamic>) fromMap,
  });
}

class WhereCondition {
  final String field;
  final dynamic isEqualTo;
  final dynamic isGreaterThan;
  final dynamic isLessThan;
  final List<dynamic>? whereIn;
  
  WhereCondition(
    this.field, {
    this.isEqualTo,
    this.isGreaterThan,
    this.isLessThan,
    this.whereIn,
  });
}

class OrderByCondition {
  final String field;
  final bool descending;
  
  OrderByCondition(this.field, {this.descending = false});
}
```

**2. Core Auth Service Interface**
```dart
// packages/core/lib/src/interfaces/auth_service.dart
abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<AuthResult> signInWithEmailPassword(String email, String password);
  Future<AuthResult> signUpWithEmailPassword(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
}

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final bool isEmailVerified;
  
  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.isEmailVerified,
  });
}

class AuthResult {
  final User? user;
  final String? errorMessage;
  final bool isSuccess;
  
  AuthResult({this.user, this.errorMessage, required this.isSuccess});
}
```

**3. App-Petiveti Data Sources com Dependency Injection**
```dart
// apps/app-petiveti/lib/features/animals/data/datasources/animal_remote_datasource.dart
abstract class AnimalRemoteDataSource {
  Future<List<AnimalModel>> getAnimals(String userId);
  Future<void> addAnimal(AnimalModel animal);
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String animalId);
  Stream<List<AnimalModel>> streamAnimals(String userId);
}

class AnimalRemoteDataSourceImpl implements AnimalRemoteDataSource {
  final FirebaseService _firebaseService;
  final AuthService _authService;
  
  AnimalRemoteDataSourceImpl(this._firebaseService, this._authService);
  
  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    return await _firebaseService.getCollection<AnimalModel>(
      'animals',
      where: [WhereCondition('userId', isEqualTo: userId)],
      orderBy: OrderByCondition('nome'),
      fromMap: AnimalModel.fromMap,
    );
  }
  
  @override
  Future<void> addAnimal(AnimalModel animal) async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw AuthException('User not authenticated');
    
    final animalWithUser = animal.copyWith(userId: user.id);
    
    await _firebaseService.setDocument<AnimalModel>(
      'animals',
      animal.id,
      animalWithUser,
      toMap: (animal) => animal.toMap(),
    );
  }
  
  @override
  Stream<List<AnimalModel>> streamAnimals(String userId) {
    return _firebaseService.streamCollection<AnimalModel>(
      'animals',
      where: [WhereCondition('userId', isEqualTo: userId)],
      fromMap: AnimalModel.fromMap,
    );
  }
}
```

**4. Hive Service Integration**
```dart
// packages/core/lib/src/interfaces/hive_service.dart
abstract class HiveService {
  Future<void> init();
  Future<Box<T>> getBox<T>(String boxName);
  Future<void> closeBox(String boxName);
  Future<void> deleteBox(String boxName);
  void registerAdapter<T>(TypeAdapter<T> adapter);
}

// apps/app-petiveti/lib/features/animals/data/datasources/animal_local_datasource.dart
abstract class AnimalLocalDataSource {
  Future<List<AnimalModel>> getAnimals(String userId);
  Future<void> cacheAnimals(List<AnimalModel> animals);
  Future<void> addAnimal(AnimalModel animal);
  Future<void> updateAnimal(AnimalModel animal);
  Future<void> deleteAnimal(String animalId);
}

class AnimalLocalDataSourceImpl implements AnimalLocalDataSource {
  final HiveService _hiveService;
  static const String _boxName = 'animals';
  
  AnimalLocalDataSourceImpl(this._hiveService);
  
  @override
  Future<List<AnimalModel>> getAnimals(String userId) async {
    final box = await _hiveService.getBox<AnimalModel>(_boxName);
    return box.values.where((animal) => animal.userId == userId).toList();
  }
  
  @override
  Future<void> cacheAnimals(List<AnimalModel> animals) async {
    final box = await _hiveService.getBox<AnimalModel>(_boxName);
    final Map<String, AnimalModel> animalMap = {
      for (var animal in animals) animal.id: animal
    };
    await box.putAll(animalMap);
  }
}
```

**5. Repository Implementation com Network-First Strategy**
```dart
// apps/app-petiveti/lib/features/animals/data/repositories/animal_repository_impl.dart
class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalLocalDataSource _localDataSource;
  final AnimalRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  
  AnimalRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );
  
  @override
  Future<Either<Failure, List<Animal>>> getAnimals(String userId) async {
    try {
      if (await _networkInfo.isConnected) {
        // Network-first strategy
        final remoteAnimals = await _remoteDataSource.getAnimals(userId);
        await _localDataSource.cacheAnimals(remoteAnimals);
        return Right(remoteAnimals.map((model) => model.toEntity()).toList());
      } else {
        // Fallback to cache
        final localAnimals = await _localDataSource.getAnimals(userId);
        return Right(localAnimals.map((model) => model.toEntity()).toList());
      }
    } on ServerException {
      // Try local fallback on server error
      try {
        final localAnimals = await _localDataSource.getAnimals(userId);
        return Right(localAnimals.map((model) => model.toEntity()).toList());
      } on CacheException {
        return Left(CacheFailure());
      }
    } on CacheException {
      return Left(CacheFailure());
    }
  }
  
  @override
  Stream<Either<Failure, List<Animal>>> watchAnimals(String userId) async* {
    try {
      // Start with cached data
      final localAnimals = await _localDataSource.getAnimals(userId);
      yield Right(localAnimals.map((model) => model.toEntity()).toList());
      
      // Then stream from remote if connected
      if (await _networkInfo.isConnected) {
        yield* _remoteDataSource.streamAnimals(userId).map(
          (animals) => Right<Failure, List<Animal>>(
            animals.map((model) => model.toEntity()).toList(),
          ),
        );
      }
    } catch (e) {
      yield Left(CacheFailure());
    }
  }
}
```

### 🔧 DEPENDENCY INJECTION SETUP
```dart
// apps/app-petiveti/lib/core/di/injection_container.dart
@module
abstract class FirebaseModule {
  @singleton
  FirebaseService get firebaseService => FirebaseServiceImpl();
  
  @singleton  
  AuthService get authService => AuthServiceImpl();
  
  @singleton
  HiveService get hiveService => HiveServiceImpl();
  
  @singleton
  NetworkInfo get networkInfo => NetworkInfoImpl();
}

@module
abstract class AnimalModule {
  @singleton
  AnimalLocalDataSource get animalLocalDataSource => 
    AnimalLocalDataSourceImpl(get<HiveService>());
  
  @singleton
  AnimalRemoteDataSource get animalRemoteDataSource => 
    AnimalRemoteDataSourceImpl(
      get<FirebaseService>(),
      get<AuthService>(),
    );
    
  @singleton
  AnimalRepository get animalRepository => AnimalRepositoryImpl(
    get<AnimalLocalDataSource>(),
    get<AnimalRemoteDataSource>(),
    get<NetworkInfo>(),
  );
}
```

### 🚀 BENEFITS DA NOVA ARQUITETURA
1. **Testabilidade**: Fácil mock de serviços externos
2. **Flexibilidade**: Troca de implementação sem mudança de código
3. **Reutilização**: Core services compartilhados entre apps
4. **Maintainability**: Separação clara de responsabilidades
5. **Offline-first**: Strategy automática de fallback

## 🏗️ Nova Arquitetura Proposta

## 🧮 Calculator System Architecture

### PADRÃO ATUAL DESCOBERTO
O sistema de calculadoras segue uma estrutura modular específica em `plans/app-petiveti/pages/calc/`:

```bash
calc/[calculator_name]/
├── controller/              # Business logic + state management (GetX)
├── model/                   # Data structures + calculations
├── widgets/                 # UI components específicos da calculadora
├── utils/                   # Helper functions (alguns calculadores)
├── services/               # Serviços específicos (alguns calculadores)
├── index.dart              # Export barrel file
└── issues.md               # Analysis issues documentadas
```

### 📂 CALCULADORAS IDENTIFICADAS (15+ implementadas)
```bash
# Estrutura real encontrada em plans/app-petiveti/pages/calc/
├── condicao_corporal/      # Condição corporal dos animais
├── conversao/              # Conversão de unidades veterinárias
├── diabetes_insulina/      # Cálculos diabetes e dosagem insulina
├── dieta_caseira/          # Cálculos de dieta caseira para pets
├── dosagem_anestesico/     # Dosagens de anestésicos veterinários
├── dosagem_medicamento/    # Dosagens de medicamentos
├── fluidoterapia/          # Cálculos de fluidoterapia
├── gestacao/               # Cálculos de gestação
├── gestacao_parto/         # Cálculos específicos de parto
├── hidratacao_fluidoterapia/ # Hidratação e fluidoterapia
├── idade_animal/           # Conversão idade animal/humana
├── necessidade_calorias/   # Necessidades calóricas dos pets
├── peso_ideal_condicao_corporal/ # Peso ideal baseado em condição
└── controllers/calculadoras_controller.dart # Controller central
```

### 🔍 ANÁLISE DO PADRÃO ATUAL

#### ❌ PROBLEMAS IDENTIFICADOS
```dart
// plans/app-petiveti/pages/calc/condicao_corporal/controller/condicao_corporal_controller.dart
class CondicaoCorporalController extends GetxController {
  final _especie = ''.obs;
  final _indice = Rxn<int>();
  final _resultado = ''.obs;
  
  // Business logic misturado com state management
  void atualizarIndice(int? indice) {
    if (indice != null && (indice < 1 || indice > 9)) {
      throw ArgumentError('Índice inválido');
    }
    _indice.value = indice;
    _calcularResultado(); // Side effect
  }
  
  // Calculation logic no controller (Violação SRP)
  void _calcularResultado() {
    if (_especie.value.isEmpty || _indice.value == null) {
      _resultado.value = '';
      return;
    }
    
    // Complex business logic embedded here
    final indice = _indice.value!;
    if (_especie.value == 'Cão') {
      if (indice <= 3) {
        _resultado.value = 'Magro - Aumentar alimentação';
      } else if (indice <= 5) {
        _resultado.value = 'Ideal - Manter alimentação';
      } else {
        _resultado.value = 'Obeso - Reduzir alimentação';
      }
    }
    // Similar logic for cats...
  }
}
```

**Problemas:**
1. **Business Logic no Controller**: Cálculos misturados com UI state
2. **Validação Inconsistente**: Cada calculadora valida diferente
3. **Duplicação de Código**: Padrões similares repetidos
4. **Falta de Testabilidade**: Difícil testar isoladamente
5. **Hard to Extend**: Adicionar nova calculadora requer boilerplate

### 🏗️ MIGRAÇÃO PARA STRATEGY PATTERN + CLEAN ARCHITECTURE

#### ✅ NOVA ARQUITETURA PROPOSTA

**1. Domain Layer: Strategy Pattern Base**
```dart
// apps/app-petiveti/lib/features/calculators/domain/entities/calculator_input.dart
abstract class CalculatorInput extends Equatable {
  const CalculatorInput();
  
  Either<ValidationFailure, CalculatorInput> validate();
}

// apps/app-petiveti/lib/features/calculators/domain/entities/calculator_result.dart
abstract class CalculatorResult extends Equatable {
  final String summary;
  final String? recommendation;
  final Map<String, dynamic>? details;
  
  const CalculatorResult({
    required this.summary,
    this.recommendation,
    this.details,
  });
  
  @override
  List<Object?> get props => [summary, recommendation, details];
}

// apps/app-petiveti/lib/features/calculators/domain/interfaces/calculator_strategy.dart
abstract class CalculatorStrategy<T extends CalculatorInput, R extends CalculatorResult> {
  CalculatorType get type;
  String get name;
  String get description;
  
  R calculate(T input);
  Either<ValidationFailure, T> validateInput(T input);
  List<String> get requiredFields;
}

enum CalculatorType {
  bodyCondition,
  unitConversion,
  diabetesInsulin,
  homemadeDiet,
  anesthesiaDosage,
  medicationDosage,
  fluidTherapy,
  pregnancy,
  hydration,
  animalAge,
  calorieNeeds,
}
```

**2. Domain Entities para Condição Corporal**
```dart
// apps/app-petiveti/lib/features/calculators/domain/entities/body_condition_input.dart
class BodyConditionInput extends CalculatorInput {
  final AnimalSpecies species;
  final int conditionScore;
  final double? currentWeight;
  
  const BodyConditionInput({
    required this.species,
    required this.conditionScore,
    this.currentWeight,
  });
  
  @override
  Either<ValidationFailure, CalculatorInput> validate() {
    if (conditionScore < 1 || conditionScore > 9) {
      return Left(ValidationFailure('Condição corporal deve estar entre 1 e 9'));
    }
    
    if (currentWeight != null && currentWeight! <= 0) {
      return Left(ValidationFailure('Peso deve ser maior que zero'));
    }
    
    return Right(this);
  }
  
  @override
  List<Object?> get props => [species, conditionScore, currentWeight];
}

// apps/app-petiveti/lib/features/calculators/domain/entities/body_condition_result.dart
class BodyConditionResult extends CalculatorResult {
  final BodyConditionCategory category;
  final double? idealWeightRange;
  final String nutritionalRecommendation;
  
  const BodyConditionResult({
    required this.category,
    required String summary,
    required this.nutritionalRecommendation,
    this.idealWeightRange,
    String? recommendation,
    Map<String, dynamic>? details,
  }) : super(
    summary: summary,
    recommendation: recommendation,
    details: details,
  );
  
  @override
  List<Object?> get props => [...super.props, category, idealWeightRange, nutritionalRecommendation];
}

enum BodyConditionCategory {
  underweight,
  ideal,
  overweight,
  obese,
}
```

**3. Strategy Implementation**
```dart
// apps/app-petiveti/lib/features/calculators/data/strategies/body_condition_strategy.dart
class BodyConditionStrategy implements CalculatorStrategy<BodyConditionInput, BodyConditionResult> {
  @override
  CalculatorType get type => CalculatorType.bodyCondition;
  
  @override
  String get name => 'Condição Corporal';
  
  @override
  String get description => 'Avalia a condição corporal do animal baseada na escala 1-9';
  
  @override
  List<String> get requiredFields => ['species', 'conditionScore'];
  
  @override
  Either<ValidationFailure, BodyConditionInput> validateInput(BodyConditionInput input) {
    return input.validate().fold(
      (failure) => Left(failure),
      (_) => Right(input),
    );
  }
  
  @override
  BodyConditionResult calculate(BodyConditionInput input) {
    final validation = validateInput(input);
    if (validation.isLeft()) {
      throw CalculationException('Input inválido');
    }
    
    final category = _determineCategory(input.conditionScore);
    final summary = _generateSummary(input.species, input.conditionScore, category);
    final recommendation = _generateRecommendation(category);
    final idealWeight = _calculateIdealWeight(input);
    
    return BodyConditionResult(
      category: category,
      summary: summary,
      nutritionalRecommendation: recommendation,
      idealWeightRange: idealWeight,
      details: {
        'score': input.conditionScore,
        'species': input.species.toString(),
        'interpretation': _getInterpretation(input.conditionScore),
      },
    );
  }
  
  BodyConditionCategory _determineCategory(int score) {
    if (score <= 3) return BodyConditionCategory.underweight;
    if (score <= 5) return BodyConditionCategory.ideal;
    if (score <= 7) return BodyConditionCategory.overweight;
    return BodyConditionCategory.obese;
  }
  
  String _generateSummary(AnimalSpecies species, int score, BodyConditionCategory category) {
    final animalType = species == AnimalSpecies.dog ? 'Cão' : 'Gato';
    
    switch (category) {
      case BodyConditionCategory.underweight:
        return '$animalType com condição corporal $score/9 - Magro';
      case BodyConditionCategory.ideal:
        return '$animalType com condição corporal $score/9 - Peso Ideal';
      case BodyConditionCategory.overweight:
        return '$animalType com condição corporal $score/9 - Acima do Peso';
      case BodyConditionCategory.obese:
        return '$animalType com condição corporal $score/9 - Obeso';
    }
  }
  
  String _generateRecommendation(BodyConditionCategory category) {
    switch (category) {
      case BodyConditionCategory.underweight:
        return 'Aumentar a quantidade de ração e consultar veterinário para descartar doenças';
      case BodyConditionCategory.ideal:
        return 'Manter a alimentação atual e exercícios regulares';
      case BodyConditionCategory.overweight:
        return 'Reduzir 10-15% da ração e aumentar exercícios. Consultar veterinário';
      case BodyConditionCategory.obese:
        return 'Dieta restritiva supervisionada por veterinário. Exercícios graduais';
    }
  }
  
  double? _calculateIdealWeight(BodyConditionInput input) {
    if (input.currentWeight == null) return null;
    
    final currentWeight = input.currentWeight!;
    final score = input.conditionScore;
    
    // Fórmula baseada em estudos veterinários
    if (score <= 3) {
      return currentWeight * 1.15; // Precisa ganhar peso
    } else if (score <= 5) {
      return currentWeight; // Peso ideal
    } else if (score <= 7) {
      return currentWeight * 0.85; // Precisa perder peso
    } else {
      return currentWeight * 0.70; // Precisa perder muito peso
    }
  }
  
  String _getInterpretation(int score) {
    switch (score) {
      case 1: return 'Extremamente magro - costelas, vértebras e ossos pélvicos facilmente visíveis';
      case 2: return 'Muito magro - costelas facilmente palpáveis';
      case 3: return 'Magro - costelas palpáveis com pressão mínima';
      case 4: return 'Abaixo do ideal - costelas palpáveis com facilidade';
      case 5: return 'Ideal - costelas palpáveis sem excesso de gordura';
      case 6: return 'Acima do ideal - costelas palpáveis com ligeira pressão';
      case 7: return 'Sobrepeso - costelas difíceis de palpar';
      case 8: return 'Obeso - costelas não palpáveis ou com muita pressão';
      case 9: return 'Extremamente obeso - depósitos massivos de gordura';
      default: return 'Score inválido';
    }
  }
}
```

**4. Calculator Service (Unified)**
```dart
// apps/app-petiveti/lib/features/calculators/domain/services/calculator_service.dart
abstract class CalculatorService {
  List<CalculatorType> get availableCalculators;
  CalculatorStrategy getStrategy(CalculatorType type);
  R calculate<T extends CalculatorInput, R extends CalculatorResult>(
    CalculatorType type, 
    T input,
  );
}

// apps/app-petiveti/lib/features/calculators/data/services/calculator_service_impl.dart
class CalculatorServiceImpl implements CalculatorService {
  final Map<CalculatorType, CalculatorStrategy> _strategies;
  
  CalculatorServiceImpl(this._strategies);
  
  @override
  List<CalculatorType> get availableCalculators => _strategies.keys.toList();
  
  @override
  CalculatorStrategy getStrategy(CalculatorType type) {
    final strategy = _strategies[type];
    if (strategy == null) {
      throw CalculatorNotFoundException('Calculator $type not found');
    }
    return strategy;
  }
  
  @override
  R calculate<T extends CalculatorInput, R extends CalculatorResult>(
    CalculatorType type,
    T input,
  ) {
    final strategy = getStrategy(type);
    return strategy.calculate(input) as R;
  }
}
```

**5. Presentation Layer (Unified)**
```dart
// apps/app-petiveti/lib/features/calculators/presentation/providers/calculator_provider.dart
class CalculatorProvider extends ChangeNotifier {
  final CalculatorService _calculatorService;
  
  CalculatorProvider(this._calculatorService);
  
  CalculatorResult? _currentResult;
  String? _errorMessage;
  bool _isCalculating = false;
  
  CalculatorResult? get currentResult => _currentResult;
  String? get errorMessage => _errorMessage;
  bool get isCalculating => _isCalculating;
  List<CalculatorType> get availableCalculators => _calculatorService.availableCalculators;
  
  Future<void> calculate<T extends CalculatorInput, R extends CalculatorResult>(
    CalculatorType type,
    T input,
  ) async {
    _setCalculating(true);
    _clearError();
    
    try {
      final result = _calculatorService.calculate<T, R>(type, input);
      _setResult(result);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setCalculating(false);
    }
  }
  
  void clearResult() {
    _currentResult = null;
    _clearError();
    notifyListeners();
  }
  
  CalculatorStrategy getStrategy(CalculatorType type) {
    return _calculatorService.getStrategy(type);
  }
  
  void _setCalculating(bool calculating) {
    _isCalculating = calculating;
    notifyListeners();
  }
  
  void _setResult(CalculatorResult result) {
    _currentResult = result;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
```

**6. Widget System (Reusable)**
```dart
// apps/app-petiveti/lib/features/calculators/presentation/widgets/calculator_input_form.dart
class CalculatorInputForm<T extends CalculatorInput> extends StatefulWidget {
  final CalculatorType type;
  final Function(T) onSubmit;
  final T? initialInput;
  
  const CalculatorInputForm({
    super.key,
    required this.type,
    required this.onSubmit,
    this.initialInput,
  });
  
  @override
  State<CalculatorInputForm<T>> createState() => _CalculatorInputFormState<T>();
}

// Formulário dinâmico baseado no tipo de calculadora
class _CalculatorInputFormState<T extends CalculatorInput> extends State<CalculatorInputForm<T>> {
  final _formKey = GlobalKey<FormState>();
  late final CalculatorStrategy _strategy;
  
  @override
  void initState() {
    super.initState();
    _strategy = context.read<CalculatorProvider>().getStrategy(widget.type);
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(_strategy.name, style: Theme.of(context).textTheme.headlineMedium),
          Text(_strategy.description),
          const SizedBox(height: 16),
          
          // Dynamic form fields based on calculator type
          ..._buildFormFields(),
          
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildFormFields() {
    // Dynamic field generation based on calculator type
    switch (widget.type) {
      case CalculatorType.bodyCondition:
        return _buildBodyConditionFields();
      case CalculatorType.unitConversion:
        return _buildUnitConversionFields();
      // Add other calculator fields...
      default:
        return [];
    }
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final input = _buildInputFromForm();
      widget.onSubmit(input);
    }
  }
  
  T _buildInputFromForm() {
    // Build specific input based on calculator type
    // This would be implemented using a factory pattern
    throw UnimplementedError('Implement input building for ${widget.type}');
  }
}
```

### 🔧 DEPENDENCY INJECTION SETUP
```dart
// apps/app-petiveti/lib/core/di/calculator_module.dart
@module
abstract class CalculatorModule {
  @singleton
  BodyConditionStrategy get bodyConditionStrategy => BodyConditionStrategy();
  
  @singleton
  UnitConversionStrategy get unitConversionStrategy => UnitConversionStrategy();
  
  @singleton
  DiabetesInsulinStrategy get diabetesInsulinStrategy => DiabetesInsulinStrategy();
  
  // Register all calculator strategies
  @singleton
  Map<CalculatorType, CalculatorStrategy> get calculatorStrategies => {
    CalculatorType.bodyCondition: get<BodyConditionStrategy>(),
    CalculatorType.unitConversion: get<UnitConversionStrategy>(),
    CalculatorType.diabetesInsulin: get<DiabetesInsulinStrategy>(),
    // Add all other strategies...
  };
  
  @singleton
  CalculatorService get calculatorService => CalculatorServiceImpl(
    get<Map<CalculatorType, CalculatorStrategy>>(),
  );
  
  @factory
  CalculatorProvider get calculatorProvider => CalculatorProvider(
    get<CalculatorService>(),
  );
}
```

### 🚀 BENEFITS DA NOVA ARQUITETURA
1. **Single Responsibility**: Cada strategy só faz um tipo de cálculo
2. **Open/Closed**: Fácil adicionar novas calculadoras sem mudar código existente
3. **Testabilidade**: Cada strategy é testável isoladamente
4. **Reusabilidade**: UI components reutilizáveis entre calculadoras
5. **Maintainability**: Lógica de negócio centralizada e organizada
6. **Type Safety**: Type safety com generics para inputs/outputs
7. **Validation**: Validação consistente em todas as calculadoras

### Estrutura de Pastas
```
apps/app-petiveti/
├── lib/
│   ├── core/                     # Núcleo compartilhado
│   │   ├── di/                   # Dependency Injection
│   │   ├── error/                # Error Handling
│   │   ├── interfaces/           # Contratos base
│   │   ├── network/              # HTTP Client
│   │   ├── storage/              # Local Storage
│   │   └── utils/                # Utilitários
│   ├── features/                 # Features modulares
│   │   ├── animals/              # Gestão de Animais
│   │   ├── appointments/         # Consultas
│   │   ├── vaccines/             # Vacinas
│   │   ├── medications/          # Medicamentos
│   │   ├── weight/               # Controle de Peso
│   │   ├── reminders/            # Lembretes
│   │   ├── expenses/             # Despesas
│   │   ├── calculators/          # Calculadoras
│   │   ├── auth/                 # Autenticação
│   │   └── subscription/         # Assinaturas
│   └── main.dart
```

## 💉 Dependency Injection Migration

### PADRÃO GETX ATUAL
O código atual utiliza GetX com inicialização manual e acoplamento forte:

```dart
// plans/app-petiveti/controllers/vacinas_controller.dart  
class VacinasController extends GetxController {
  static Future<VacinasController> initialize() async {
    // Manual dependency setup
    await VacinaRepository.initialize();
    final controller = VacinasController();
    Get.put(controller); // Global state registration
    return controller;
  }
  
  final _repository = VacinaRepository(); // Direct instantiation
}

// plans/app-petiveti/app-page.dart
class _PetivetiAppState extends State<PetivetiApp> {
  Future<void> _initializePetivetiModule() async {
    // Manual initialization chain
    Get.put(ErrorManager());
    await PetivetiHiveService.initialize();
    
    // Controllers initialized one by one
    await VacinasController.initialize();
    await AnimalController.initialize();
    // ...
  }
}
```

### 📂 PROBLEMAS DO PADRÃO ATUAL
1. **Manual Dependency Management**: Ordem de inicialização hardcoded
2. **Global State**: GetX.put() cria estado global difícil de testar
3. **Hard Dependencies**: Classes instanciam dependências diretamente
4. **Initialization Coupling**: App initialization acoplado aos controllers
5. **Testing Nightmare**: Impossível mockar dependências facilmente

### 🏗️ MIGRAÇÃO PARA GETIT + INJECTABLE

#### ✅ NOVA ARQUITETURA DE DI

**1. Core Dependency Interfaces**
```dart
// apps/app-petiveti/lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();

// apps/app-petiveti/lib/core/di/modules/core_module.dart
@module
abstract class CoreModule {
  @preResolve
  @singleton
  Future<HiveService> get hiveService async {
    final service = HiveServiceImpl();
    await service.init();
    return service;
  }
  
  @preResolve
  @singleton
  Future<FirebaseService> get firebaseService async {
    final service = FirebaseServiceImpl();
    await service.initialize();
    return service;
  }
  
  @singleton
  AuthService get authService => AuthServiceImpl();
  
  @singleton
  NetworkInfo get networkInfo => NetworkInfoImpl();
  
  @singleton
  @Named('storage')
  SharedPreferences get sharedPreferences => throw UnimplementedError();
}

// Register SharedPreferences separately since it needs async init
@module
abstract class StorageModule {
  @preResolve
  @singleton
  @Named('storage')
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
}
```

**2. Feature-Based Dependency Modules**
```dart
// apps/app-petiveti/lib/features/animals/di/animal_module.dart
@module
abstract class AnimalModule {
  // DataSources
  @singleton
  AnimalLocalDataSource get animalLocalDataSource => AnimalLocalDataSourceImpl(
    getIt<HiveService>(),
  );
  
  @singleton
  AnimalRemoteDataSource get animalRemoteDataSource => AnimalRemoteDataSourceImpl(
    getIt<FirebaseService>(),
    getIt<AuthService>(),
  );
  
  // Repository
  @singleton
  AnimalRepository get animalRepository => AnimalRepositoryImpl(
    getIt<AnimalLocalDataSource>(),
    getIt<AnimalRemoteDataSource>(),
    getIt<NetworkInfo>(),
  );
  
  // Use Cases
  @factory
  GetAnimalsUseCase get getAnimalsUseCase => GetAnimalsUseCase(
    getIt<AnimalRepository>(),
  );
  
  @factory
  CreateAnimalUseCase get createAnimalUseCase => CreateAnimalUseCase(
    getIt<AnimalRepository>(),
  );
  
  @factory
  UpdateAnimalUseCase get updateAnimalUseCase => UpdateAnimalUseCase(
    getIt<AnimalRepository>(),
  );
  
  @factory
  DeleteAnimalUseCase get deleteAnimalUseCase => DeleteAnimalUseCase(
    getIt<AnimalRepository>(),
  );
  
  // Providers (Factory for multiple instances)
  @factory
  AnimalsProvider get animalsProvider => AnimalsProvider(
    getIt<GetAnimalsUseCase>(),
    getIt<CreateAnimalUseCase>(),
    getIt<UpdateAnimalUseCase>(),
    getIt<DeleteAnimalUseCase>(),
  );
}

// apps/app-petiveti/lib/features/vaccines/di/vaccine_module.dart
@module
abstract class VaccineModule {
  @singleton
  VaccineLocalDataSource get vaccineLocalDataSource => VaccineLocalDataSourceImpl(
    getIt<HiveService>(),
  );
  
  @singleton
  VaccineRemoteDataSource get vaccineRemoteDataSource => VaccineRemoteDataSourceImpl(
    getIt<FirebaseService>(),
    getIt<AuthService>(),
  );
  
  @singleton
  VaccineRepository get vaccineRepository => VaccineRepositoryImpl(
    getIt<VaccineLocalDataSource>(),
    getIt<VaccineRemoteDataSource>(),
    getIt<NetworkInfo>(),
  );
  
  @factory
  GetVaccinesUseCase get getVaccinesUseCase => GetVaccinesUseCase(
    getIt<VaccineRepository>(),
  );
  
  @factory
  AddVaccineUseCase get addVaccineUseCase => AddVaccineUseCase(
    getIt<VaccineRepository>(),
  );
  
  @factory
  VaccinesProvider get vaccinesProvider => VaccinesProvider(
    getIt<GetVaccinesUseCase>(),
    getIt<AddVaccineUseCase>(),
  );
}

// apps/app-petiveti/lib/features/calculators/di/calculator_module.dart
@module
abstract class CalculatorModule {
  // Individual Strategies
  @singleton
  BodyConditionStrategy get bodyConditionStrategy => BodyConditionStrategy();
  
  @singleton
  UnitConversionStrategy get unitConversionStrategy => UnitConversionStrategy();
  
  @singleton
  DiabetesInsulinStrategy get diabetesInsulinStrategy => DiabetesInsulinStrategy();
  
  @singleton
  DietStrategy get dietStrategy => DietStrategy();
  
  @singleton
  AnesthesiaStrategy get anesthesiaStrategy => AnesthesiaStrategy();
  
  @singleton
  MedicationDosageStrategy get medicationDosageStrategy => MedicationDosageStrategy();
  
  @singleton
  FluidTherapyStrategy get fluidTherapyStrategy => FluidTherapyStrategy();
  
  @singleton
  PregnancyStrategy get pregnancyStrategy => PregnancyStrategy();
  
  @singleton
  HydrationStrategy get hydrationStrategy => HydrationStrategy();
  
  @singleton
  AnimalAgeStrategy get animalAgeStrategy => AnimalAgeStrategy();
  
  @singleton
  CalorieNeedsStrategy get calorieNeedsStrategy => CalorieNeedsStrategy();
  
  // Strategy Map (All calculators)
  @singleton
  Map<CalculatorType, CalculatorStrategy> get calculatorStrategies => {
    CalculatorType.bodyCondition: getIt<BodyConditionStrategy>(),
    CalculatorType.unitConversion: getIt<UnitConversionStrategy>(),
    CalculatorType.diabetesInsulin: getIt<DiabetesInsulinStrategy>(),
    CalculatorType.homemadeDiet: getIt<DietStrategy>(),
    CalculatorType.anesthesiaDosage: getIt<AnesthesiaStrategy>(),
    CalculatorType.medicationDosage: getIt<MedicationDosageStrategy>(),
    CalculatorType.fluidTherapy: getIt<FluidTherapyStrategy>(),
    CalculatorType.pregnancy: getIt<PregnancyStrategy>(),
    CalculatorType.hydration: getIt<HydrationStrategy>(),
    CalculatorType.animalAge: getIt<AnimalAgeStrategy>(),
    CalculatorType.calorieNeeds: getIt<CalorieNeedsStrategy>(),
  };
  
  // Calculator Service
  @singleton
  CalculatorService get calculatorService => CalculatorServiceImpl(
    getIt<Map<CalculatorType, CalculatorStrategy>>(),
  );
  
  // Provider
  @factory
  CalculatorProvider get calculatorProvider => CalculatorProvider(
    getIt<CalculatorService>(),
  );
}
```

**3. App Initialization com Dependency Resolution**
```dart
// apps/app-petiveti/lib/main.dart
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure all dependencies before app starts
  await configureDependencies();
  
  runApp(const PetivetiApp());
}

// apps/app-petiveti/lib/app.dart
class PetivetiApp extends StatelessWidget {
  const PetivetiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers are created via GetIt when needed
        ChangeNotifierProvider<AnimalsProvider>(
          create: (_) => getIt<AnimalsProvider>(),
        ),
        ChangeNotifierProvider<VaccinesProvider>(
          create: (_) => getIt<VaccinesProvider>(),
        ),
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) => getIt<CalculatorProvider>(),
        ),
        // Add other providers...
      ],
      child: MaterialApp.router(
        routerConfig: getIt<GoRouter>(),
      ),
    );
  }
}
```

**4. Usage in Components (Clean Injection)**
```dart
// apps/app-petiveti/lib/features/animals/presentation/pages/animals_page.dart
class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    // No direct dependency injection in UI
    // Provider handles it via GetIt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalsProvider>().loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pets')),
      body: Consumer<AnimalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.errorMessage != null) {
            return Center(child: Text('Erro: ${provider.errorMessage}'));
          }
          
          return ListView.builder(
            itemCount: provider.animals.length,
            itemBuilder: (context, index) {
              final animal = provider.animals[index];
              return AnimalCard(animal: animal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAnimal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**5. Testing with Dependency Injection**
```dart
// test/features/animals/presentation/providers/animals_provider_test.dart
class MockGetAnimalsUseCase extends Mock implements GetAnimalsUseCase {}
class MockCreateAnimalUseCase extends Mock implements CreateAnimalUseCase {}

void main() {
  late AnimalsProvider provider;
  late MockGetAnimalsUseCase mockGetAnimalsUseCase;
  late MockCreateAnimalUseCase mockCreateAnimalUseCase;
  
  setUp(() {
    mockGetAnimalsUseCase = MockGetAnimalsUseCase();
    mockCreateAnimalUseCase = MockCreateAnimalUseCase();
    
    // Easy dependency injection for testing
    provider = AnimalsProvider(
      mockGetAnimalsUseCase,
      mockCreateAnimalUseCase,
      Mock(), // other use cases
      Mock(),
    );
  });
  
  group('AnimalsProvider', () {
    test('should load animals successfully', () async {
      // Arrange
      final animals = [
        Animal(id: '1', name: 'Rex', species: AnimalSpecies.dog, /* ... */),
      ];
      when(mockGetAnimalsUseCase(any))
          .thenAnswer((_) async => Right(animals));
      
      // Act
      await provider.loadAnimals();
      
      // Assert
      expect(provider.animals, equals(animals));
      expect(provider.isLoading, false);
      expect(provider.errorMessage, null);
      verify(mockGetAnimalsUseCase(any)).called(1);
    });
    
    test('should handle error when loading animals fails', () async {
      // Arrange
      when(mockGetAnimalsUseCase(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      
      // Act
      await provider.loadAnimals();
      
      // Assert
      expect(provider.animals, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.errorMessage, isNotNull);
    });
  });
}
```

**6. Injectable Code Generation Setup**
```yaml
# apps/app-petiveti/pubspec.yaml
dev_dependencies:
  build_runner: ^2.4.6
  injectable_generator: ^2.4.0
  
# apps/app-petiveti/build.yaml
targets:
  $default:
    builders:
      injectable_generator:injectable_builder:
        enabled: true
```

### 🔧 INITIALIZATION ORDER MANAGEMENT
```dart
// apps/app-petiveti/lib/core/di/injection_container.dart
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // GetIt automatically resolves dependency order
  await getIt.init();
  
  // Manual registration for complex async dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);
  
  // Register Router after all dependencies are ready
  getIt.registerSingleton<GoRouter>(AppRouter.createRouter());
}

// Dependency resolution happens automatically:
// 1. Core services (Firebase, Hive, Auth, Network)
// 2. DataSources (depend on core services)
// 3. Repositories (depend on datasources)
// 4. UseCases (depend on repositories)
// 5. Providers (depend on use cases)
```

### 🚀 BENEFITS DA NOVA ARQUITETURA DI
1. **Automatic Resolution**: GetIt resolve dependências automaticamente
2. **Testability**: Fácil mock de qualquer dependência
3. **Type Safety**: Injectable garante type safety em compile time
4. **Performance**: Singleton vs Factory otimizado por uso
5. **Modular**: Cada feature tem seu próprio módulo de DI
6. **Async Support**: @preResolve para dependências async
7. **Code Generation**: Reduz boilerplate manual
8. **Debugging**: GetIt oferece debugging tools integradas

### 📋 MIGRATION CHECKLIST
- [ ] Setup Injectable e GetIt dependencies
- [ ] Create core module (Firebase, Hive, Auth, Network)
- [ ] Create feature modules (Animals, Vaccines, Calculators, etc.)
- [ ] Replace GetX.put() com Provider creation via GetIt
- [ ] Update app initialization to use configureDependencies()
- [ ] Update tests to use dependency injection
- [ ] Run build_runner para gerar injection_container.config.dart
- [ ] Test dependency resolution em diferentes cenários

## 🔄 State Management Migration Strategy

### PADRÃO GETX ATUAL
O código atual utiliza GetX com reactive variables e state mixing:

```dart
// plans/app-petiveti/controllers/vacinas_controller.dart
class VacinasController extends GetxController {
  // Reactive state variables
  final _vacinas = <VacinaVet>[].obs;
  final _isLoading = false.obs;
  final _selectedAnimal = Rxn<String>();
  final _filtroMes = DateTime.now().obs;
  
  // Getters exposing reactive state
  List<VacinaVet> get vacinas => _vacinas;
  bool get isLoading => _isLoading.value;
  String? get selectedAnimal => _selectedAnimal.value;
  DateTime get filtroMes => _filtroMes.value;
  
  // Business logic mixed with state management
  Future<void> carregarVacinas() async {
    _isLoading.value = true;
    try {
      final result = await _repository.getVacinas(_selectedAnimal.value ?? '');
      _vacinas.assignAll(result);
      
      // Side effects and UI updates mixed
      Get.snackbar('Sucesso', 'Vacinas carregadas');
      update(); // Manual update trigger
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  void selecionarAnimal(String animalId) {
    _selectedAnimal.value = animalId;
    carregarVacinas(); // Immediate side effect
  }
  
  void alterarFiltroMes(DateTime mes) {
    _filtroMes.value = mes;
    _filtrarVacinas(); // Another side effect
  }
}

// UI consuming GetX state
class VacinasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VacinasController>(
      builder: (controller) {
        return Obx(() => // Mixed reactive patterns
          controller.isLoading 
            ? CircularProgressIndicator()
            : ListView.builder(...)
        );
      },
    );
  }
}
```

### 📂 PROBLEMAS DO GETX PATTERN
1. **Mixed Reactive Patterns**: .obs + GetBuilder + Obx confusion
2. **State + Side Effects**: Business logic triggers UI side effects
3. **Global Dependencies**: Get.snackbar() couples controller to UI
4. **Manual Updates**: Mixing automatic (.obs) and manual (update()) updates
5. **Testing Complexity**: Hard to test reactive variables and side effects
6. **No Clear State Structure**: State scattered across multiple reactive variables

### 🏗️ MIGRAÇÃO PARA PROVIDER + STATE CLASSES

#### ✅ OPÇÃO 1: PROVIDER COM STATE CLASSES (Recomendado)

**1. State Classes com Immutability**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/providers/vaccines_state.dart
@freezed
class VaccinesState with _$VaccinesState {
  const factory VaccinesState({
    @Default([]) List<Vaccine> vaccines,
    @Default(false) bool isLoading,
    @Default('') String selectedAnimalId,
    @Default(null) String? errorMessage,
    @Default(null) DateTime? filterMonth,
    @Default(VaccinesFilter.all) VaccinesFilter filter,
  }) = _VaccinesState;
  
  // Computed properties (business logic in state)
  List<Vaccine> get filteredVaccines {
    var result = vaccines;
    
    if (selectedAnimalId.isNotEmpty) {
      result = result.where((v) => v.animalId == selectedAnimalId).toList();
    }
    
    if (filterMonth != null) {
      result = result.where((v) => 
        v.applicationDate.month == filterMonth!.month &&
        v.applicationDate.year == filterMonth!.year
      ).toList();
    }
    
    switch (filter) {
      case VaccinesFilter.overdue:
        result = result.where((v) => v.isOverdue).toList();
        break;
      case VaccinesFilter.upcoming:
        result = result.where((v) => v.isDueSoon).toList();
        break;
      case VaccinesFilter.all:
        break;
    }
    
    return result;
  }
  
  bool get hasVaccines => vaccines.isNotEmpty;
  bool get hasError => errorMessage != null;
  
  // State statistics
  int get overdueCount => vaccines.where((v) => v.isOverdue).length;
  int get upcomingCount => vaccines.where((v) => v.isDueSoon).length;
}

enum VaccinesFilter { all, overdue, upcoming }
```

**2. Provider com Clean State Management**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/providers/vaccines_provider.dart
class VaccinesProvider extends ChangeNotifier {
  final GetVaccinesUseCase _getVaccinesUseCase;
  final AddVaccineUseCase _addVaccineUseCase;
  final UpdateVaccineUseCase _updateVaccineUseCase;
  final DeleteVaccineUseCase _deleteVaccineUseCase;
  
  VaccinesProvider(
    this._getVaccinesUseCase,
    this._addVaccineUseCase,
    this._updateVaccineUseCase,
    this._deleteVaccineUseCase,
  );
  
  VaccinesState _state = const VaccinesState();
  VaccinesState get state => _state;
  
  // Convenience getters for UI
  List<Vaccine> get vaccines => _state.filteredVaccines;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.errorMessage;
  bool get hasError => _state.hasError;
  int get overdueCount => _state.overdueCount;
  
  Future<void> loadVaccines([String? animalId]) async {
    final targetAnimalId = animalId ?? _state.selectedAnimalId;
    if (targetAnimalId.isEmpty) return;
    
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _getVaccinesUseCase(targetAnimalId);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (vaccines) => _updateState(_state.copyWith(
        isLoading: false,
        vaccines: vaccines,
        errorMessage: null,
      )),
    );
  }
  
  Future<void> addVaccine(Vaccine vaccine) async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    
    final result = await _addVaccineUseCase(vaccine);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) {
        final updatedVaccines = [..._state.vaccines, vaccine];
        _updateState(_state.copyWith(
          isLoading: false,
          vaccines: updatedVaccines,
          errorMessage: null,
        ));
      },
    );
  }
  
  void selectAnimal(String animalId) {
    _updateState(_state.copyWith(selectedAnimalId: animalId));
    loadVaccines(animalId);
  }
  
  void setFilter(VaccinesFilter filter) {
    _updateState(_state.copyWith(filter: filter));
  }
  
  void setFilterMonth(DateTime? month) {
    _updateState(_state.copyWith(filterMonth: month));
  }
  
  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }
  
  void _updateState(VaccinesState newState) {
    _state = newState;
    notifyListeners();
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Erro de conexão com o servidor';
      case CacheFailure:
        return 'Erro ao acessar dados locais';
      case ValidationFailure:
        return 'Dados inválidos: ${(failure as ValidationFailure).message}';
      default:
        return 'Erro desconhecido';
    }
  }
}
```

**3. UI com Consumer Pattern**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/pages/vaccines_page.dart
class VaccinesPage extends StatefulWidget {
  final String animalId;
  
  const VaccinesPage({super.key, required this.animalId});

  @override
  State<VaccinesPage> createState() => _VaccinesPageState();
}

class _VaccinesPageState extends State<VaccinesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaccinesProvider>().selectAnimal(widget.animalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacinas'),
        actions: [
          Consumer<VaccinesProvider>(
            builder: (context, provider, child) {
              if (provider.overdueCount > 0) {
                return Badge(
                  label: Text('${provider.overdueCount}'),
                  child: IconButton(
                    icon: const Icon(Icons.warning),
                    onPressed: () => provider.setFilter(VaccinesFilter.overdue),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Consumer<VaccinesProvider>(
            builder: (context, provider, child) {
              return VaccineFilterBar(
                currentFilter: provider.state.filter,
                onFilterChanged: provider.setFilter,
                onMonthChanged: provider.setFilterMonth,
              );
            },
          ),
          
          // Content Section
          Expanded(
            child: Consumer<VaccinesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.hasError) {
                  return VaccineErrorWidget(
                    message: provider.errorMessage!,
                    onRetry: () => provider.loadVaccines(),
                  );
                }
                
                if (provider.vaccines.isEmpty) {
                  return const VaccineEmptyWidget();
                }
                
                return VaccineList(vaccines: provider.vaccines);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddVaccine(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### ✅ OPÇÃO 2: RIVERPOD (Para Apps Complexos)

**1. State Notifier Pattern**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/providers/vaccines_notifier.dart
class VaccinesNotifier extends StateNotifier<VaccinesState> {
  final GetVaccinesUseCase _getVaccinesUseCase;
  final AddVaccineUseCase _addVaccineUseCase;
  
  VaccinesNotifier(
    this._getVaccinesUseCase,
    this._addVaccineUseCase,
  ) : super(const VaccinesState());
  
  Future<void> loadVaccines(String animalId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final result = await _getVaccinesUseCase(animalId);
    
    state = result.fold(
      (failure) => state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (vaccines) => state.copyWith(
        isLoading: false,
        vaccines: vaccines,
        selectedAnimalId: animalId,
        errorMessage: null,
      ),
    );
  }
  
  Future<void> addVaccine(Vaccine vaccine) async {
    state = state.copyWith(isLoading: true);
    
    final result = await _addVaccineUseCase(vaccine);
    
    state = result.fold(
      (failure) => state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (_) => state.copyWith(
        isLoading: false,
        vaccines: [...state.vaccines, vaccine],
      ),
    );
  }
  
  void setFilter(VaccinesFilter filter) {
    state = state.copyWith(filter: filter);
  }
}

// Provider registration
final vaccinesProvider = StateNotifierProvider<VaccinesNotifier, VaccinesState>(
  (ref) => VaccinesNotifier(
    ref.read(getVaccinesUseCaseProvider),
    ref.read(addVaccineUseCaseProvider),
  ),
);

// Computed providers
final filteredVaccinesProvider = Provider<List<Vaccine>>((ref) {
  final state = ref.watch(vaccinesProvider);
  return state.filteredVaccines;
});

final vaccineStatsProvider = Provider<VaccineStats>((ref) {
  final vaccines = ref.watch(filteredVaccinesProvider);
  return VaccineStats.fromVaccines(vaccines);
});
```

**2. UI com Riverpod Hooks**
```dart
// apps/app-petiveti/lib/features/vaccines/presentation/pages/vaccines_page_riverpod.dart
class VaccinesPageRiverpod extends HookConsumerWidget {
  final String animalId;
  
  const VaccinesPageRiverpod({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinesState = ref.watch(vaccinesProvider);
    final filteredVaccines = ref.watch(filteredVaccinesProvider);
    final vaccineStats = ref.watch(vaccineStatsProvider);
    
    // Auto-load on mount
    useEffect(() {
      Future.microtask(() {
        ref.read(vaccinesProvider.notifier).loadVaccines(animalId);
      });
      return null;
    }, [animalId]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacinas'),
        actions: [
          if (vaccineStats.overdueCount > 0)
            Badge(
              label: Text('${vaccineStats.overdueCount}'),
              child: IconButton(
                icon: const Icon(Icons.warning),
                onPressed: () => ref.read(vaccinesProvider.notifier)
                    .setFilter(VaccinesFilter.overdue),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          VaccineFilterBar(
            currentFilter: vaccinesState.filter,
            onFilterChanged: (filter) => 
                ref.read(vaccinesProvider.notifier).setFilter(filter),
          ),
          Expanded(
            child: vaccinesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vaccinesState.hasError
                    ? VaccineErrorWidget(
                        message: vaccinesState.errorMessage!,
                        onRetry: () => ref.read(vaccinesProvider.notifier)
                            .loadVaccines(animalId),
                      )
                    : filteredVaccines.isEmpty
                        ? const VaccineEmptyWidget()
                        : VaccineList(vaccines: filteredVaccines),
          ),
        ],
      ),
    );
  }
}
```

### 🧪 TESTING STATE MANAGEMENT

**1. Provider Testing**
```dart
// test/features/vaccines/presentation/providers/vaccines_provider_test.dart
void main() {
  late VaccinesProvider provider;
  late MockGetVaccinesUseCase mockGetVaccinesUseCase;
  
  setUp(() {
    mockGetVaccinesUseCase = MockGetVaccinesUseCase();
    provider = VaccinesProvider(mockGetVaccinesUseCase, Mock(), Mock(), Mock());
  });
  
  group('VaccinesProvider State Management', () {
    test('should have initial state correctly', () {
      expect(provider.state, equals(const VaccinesState()));
      expect(provider.isLoading, false);
      expect(provider.vaccines, isEmpty);
      expect(provider.hasError, false);
    });
    
    test('should update loading state during loadVaccines', () async {
      // Arrange
      when(mockGetVaccinesUseCase(any))
          .thenAnswer((_) async => Right([]));
      
      // Act
      final future = provider.loadVaccines('animal-1');
      
      // Assert loading state
      expect(provider.isLoading, true);
      
      await future;
      expect(provider.isLoading, false);
    });
    
    test('should update vaccines list on successful load', () async {
      // Arrange
      final vaccines = [
        Vaccine(id: '1', animalId: 'animal-1', name: 'Raiva', /*...*/),
      ];
      when(mockGetVaccinesUseCase(any))
          .thenAnswer((_) async => Right(vaccines));
      
      // Act
      await provider.loadVaccines('animal-1');
      
      // Assert
      expect(provider.vaccines, equals(vaccines));
      expect(provider.state.selectedAnimalId, equals('animal-1'));
      expect(provider.hasError, false);
    });
    
    test('should filter vaccines correctly', () async {
      // Arrange
      final vaccines = [
        Vaccine(id: '1', animalId: 'animal-1', name: 'Raiva', isOverdue: true),
        Vaccine(id: '2', animalId: 'animal-1', name: 'V8', isOverdue: false),
      ];
      when(mockGetVaccinesUseCase(any))
          .thenAnswer((_) async => Right(vaccines));
      
      await provider.loadVaccines('animal-1');
      
      // Act
      provider.setFilter(VaccinesFilter.overdue);
      
      // Assert
      expect(provider.vaccines.length, equals(1));
      expect(provider.vaccines.first.name, equals('Raiva'));
    });
  });
}
```

**2. Riverpod Testing**
```dart
// test/features/vaccines/presentation/providers/vaccines_notifier_test.dart
void main() {
  late ProviderContainer container;
  late MockGetVaccinesUseCase mockGetVaccinesUseCase;
  
  setUp(() {
    mockGetVaccinesUseCase = MockGetVaccinesUseCase();
    container = ProviderContainer(
      overrides: [
        getVaccinesUseCaseProvider.overrideWithValue(mockGetVaccinesUseCase),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  test('should load vaccines and update state', () async {
    // Arrange
    final vaccines = [Vaccine(id: '1', /*...*/)];
    when(mockGetVaccinesUseCase(any))
        .thenAnswer((_) async => Right(vaccines));
    
    // Act
    await container.read(vaccinesProvider.notifier).loadVaccines('animal-1');
    
    // Assert
    final state = container.read(vaccinesProvider);
    expect(state.vaccines, equals(vaccines));
    expect(state.isLoading, false);
    expect(state.selectedAnimalId, equals('animal-1'));
  });
}
```

### 🚀 BENEFITS DA NOVA ARQUITETURA STATE
1. **Immutable State**: Estado previsível e debuggable
2. **Single Source of Truth**: Estado centralizado por feature
3. **Computed Properties**: Lógica derivada no estado
4. **Testability**: Fácil testar estados isolados
5. **DevTools Support**: Provider/Riverpod oferecem debugging tools
6. **No Side Effects**: Estado puro separado de side effects
7. **Type Safety**: Estado tipado e verificado em compile time
8. **Performance**: Re-renders otimizados com Consumer/Selector

### 📋 MIGRATION STRATEGY
1. **Identify GetX Controllers**: Map all existing controllers
2. **Extract State Classes**: Create immutable state classes with freezed
3. **Create Providers**: Convert controllers to providers with use cases
4. **Update UI**: Replace GetBuilder/Obx with Consumer
5. **Add Computed Properties**: Move filtering/sorting logic to state
6. **Write Tests**: Test state changes and provider logic
7. **Remove GetX Dependencies**: Clean up GetX imports and dependencies

## ⚠️ Error Handling Standardization

### PADRÃO ATUAL INCONSISTENTE
O código atual possui tratamento de erro inconsistente e espalhado:

```dart
// plans/app-petiveti/repository/animal_repository.dart
class AnimalRepository {
  Future<bool> addAnimal(Animal animal) async {
    try {
      await _firestore.addAnimal(animal);
      return true; // Boolean return pattern
    } catch (e) {
      debugPrint('Error: $e'); // Simple debug print
      return false; // No error details
    }
  }
}

// plans/app-petiveti/controllers/vacinas_controller.dart
class VacinasController extends GetxController {
  Future<void> carregarVacinas() async {
    try {
      final result = await _repository.getVacinas(_selectedAnimal.value ?? '');
      _vacinas.assignAll(result);
      Get.snackbar('Sucesso', 'Vacinas carregadas'); // UI coupling
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar: $e'); // Generic error message
    }
  }
}

// plans/app-petiveti/utils/consulta/consulta_validators.dart
void validateConsulta(Consulta consulta) {
  if (consulta.nomeVeterinario.isEmpty) {
    throw ArgumentError('Nome do veterinário é obrigatório'); // Different exception type
  }
  
  if (consulta.dataConsulta > DateTime.now().millisecondsSinceEpoch) {
    throw StateError('Data não pode ser futura'); // Another exception type
  }
}
```

### 📂 PROBLEMAS IDENTIFICADOS
1. **Multiple Exception Types**: ArgumentError, StateError, generic Exception
2. **Boolean Returns**: Perda de informação sobre o tipo de erro
3. **UI Coupling**: Snackbars nos controllers acoplam lógica à UI
4. **No Error Context**: Falta de contexto sobre onde/quando erro ocorreu
5. **Debug Only**: Logs apenas em debug, não em production
6. **No Error Recovery**: Sem estratégias de retry ou fallback
7. **Inconsistent Messages**: Mensagens de erro não padronizadas

### 🏗️ MIGRAÇÃO PARA EITHER + FAILURE PATTERN

#### ✅ NOVA ARQUITETURA DE ERROR HANDLING

**1. Core Failure Classes**
```dart
// apps/app-petiveti/lib/core/error/failures.dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;
  
  const Failure({
    required this.message,
    this.code,
    this.context,
  });
  
  @override
  List<Object?> get props => [message, code, context];
}

// Network Failures
class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Erro do servidor',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Erro de conexão',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Tempo limite esgotado',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

// Local Storage Failures
class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Erro no armazenamento local',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({
    String message = 'Erro no banco de dados',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

// Business Logic Failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure(String message, {
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Erro de autenticação',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Sem permissão para esta operação',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

// Data Failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Recurso não encontrado',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}

class ConflictFailure extends Failure {
  const ConflictFailure({
    String message = 'Conflito de dados',
    String? code,
    Map<String, dynamic>? context,
  }) : super(message: message, code: code, context: context);
}
```

**2. Exception to Failure Mappers**
```dart
// apps/app-petiveti/lib/core/error/exception_mapper.dart
class ExceptionMapper {
  static Failure mapExceptionToFailure(dynamic exception, {
    String? operation,
    Map<String, dynamic>? context,
  }) {
    final enhancedContext = {
      'operation': operation,
      'exception_type': exception.runtimeType.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      ...?context,
    };
    
    switch (exception.runtimeType) {
      case SocketException:
        return NetworkFailure(
          message: 'Sem conexão com a internet',
          code: 'NETWORK_ERROR',
          context: enhancedContext,
        );
        
      case TimeoutException:
        return TimeoutFailure(
          message: 'Operação demorou muito para responder',
          code: 'TIMEOUT_ERROR',
          context: enhancedContext,
        );
        
      case FormatException:
        return ValidationFailure(
          'Formato de dados inválido',
          code: 'FORMAT_ERROR',
          context: enhancedContext,
        );
        
      case FirebaseException:
        final firebaseEx = exception as FirebaseException;
        return _mapFirebaseException(firebaseEx, enhancedContext);
        
      case HiveError:
        return CacheFailure(
          message: 'Erro no armazenamento local',
          code: 'HIVE_ERROR',
          context: enhancedContext,
        );
        
      case ArgumentError:
        final argError = exception as ArgumentError;
        return ValidationFailure(
          argError.message?.toString() ?? 'Argumento inválido',
          code: 'VALIDATION_ERROR',
          context: enhancedContext,
        );
        
      default:
        return ServerFailure(
          message: 'Erro inesperado: ${exception.toString()}',
          code: 'UNKNOWN_ERROR',
          context: enhancedContext,
        );
    }
  }
  
  static Failure _mapFirebaseException(
    FirebaseException exception,
    Map<String, dynamic> context,
  ) {
    switch (exception.code) {
      case 'permission-denied':
        return PermissionFailure(
          message: 'Sem permissão para acessar este recurso',
          code: exception.code,
          context: context,
        );
        
      case 'not-found':
        return NotFoundFailure(
          message: 'Recurso não encontrado',
          code: exception.code,
          context: context,
        );
        
      case 'already-exists':
        return ConflictFailure(
          message: 'Este recurso já existe',
          code: exception.code,
          context: context,
        );
        
      case 'unauthenticated':
        return AuthFailure(
          message: 'Usuário não autenticado',
          code: exception.code,
          context: context,
        );
        
      default:
        return ServerFailure(
          message: exception.message ?? 'Erro do Firebase',
          code: exception.code,
          context: context,
        );
    }
  }
}
```

**3. Repository com Either Pattern**
```dart
// apps/app-petiveti/lib/features/animals/data/repositories/animal_repository_impl.dart
class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalLocalDataSource _localDataSource;
  final AnimalRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  
  AnimalRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._networkInfo,
  );
  
  @override
  Future<Either<Failure, List<Animal>>> getAnimals(String userId) async {
    try {
      if (await _networkInfo.isConnected) {
        // Try remote first
        try {
          final remoteAnimals = await _remoteDataSource.getAnimals(userId);
          await _localDataSource.cacheAnimals(remoteAnimals);
          return Right(remoteAnimals.map((model) => model.toEntity()).toList());
        } catch (e) {
          // If remote fails, try local cache
          return _getAnimalsFromCache(userId, remoteError: e);
        }
      } else {
        // No network, use cache
        return _getAnimalsFromCache(userId);
      }
    } catch (e) {
      final failure = ExceptionMapper.mapExceptionToFailure(
        e,
        operation: 'getAnimals',
        context: {'userId': userId},
      );
      return Left(failure);
    }
  }
  
  @override
  Future<Either<Failure, void>> addAnimal(Animal animal) async {
    try {
      // Validate business rules first
      final validation = animal.validate();
      if (validation.isLeft()) {
        return validation.fold(
          (failure) => Left(failure),
          (_) => throw StateError('Validation succeeded but returned Left'),
        );
      }
      
      // Add to local first for optimistic updates
      final model = AnimalModel.fromEntity(animal);
      await _localDataSource.addAnimal(model);
      
      // Then sync to remote if possible
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.addAnimal(model);
          model.markSynced();
          await _localDataSource.updateAnimal(model);
        } catch (e) {
          // Remote failed, but local succeeded - mark for later sync
          model.markForSync();
          await _localDataSource.updateAnimal(model);
          
          // Log for monitoring but don't fail the operation
          debugPrint('Failed to sync animal to remote: $e');
        }
      } else {
        // No network - mark for later sync
        model.markForSync();
        await _localDataSource.updateAnimal(model);
      }
      
      return const Right(null);
    } catch (e) {
      final failure = ExceptionMapper.mapExceptionToFailure(
        e,
        operation: 'addAnimal',
        context: {
          'animalId': animal.id,
          'animalName': animal.name,
        },
      );
      return Left(failure);
    }
  }
  
  Future<Either<Failure, List<Animal>>> _getAnimalsFromCache(
    String userId, {
    dynamic remoteError,
  }) async {
    try {
      final localAnimals = await _localDataSource.getAnimals(userId);
      if (localAnimals.isEmpty && remoteError != null) {
        // No cache and remote failed
        final failure = ExceptionMapper.mapExceptionToFailure(
          remoteError,
          operation: 'getAnimalsFromRemote',
          context: {'userId': userId, 'fallback': 'cache_empty'},
        );
        return Left(failure);
      }
      
      return Right(localAnimals.map((model) => model.toEntity()).toList());
    } catch (e) {
      final failure = ExceptionMapper.mapExceptionToFailure(
        e,
        operation: 'getAnimalsFromCache',
        context: {'userId': userId},
      );
      return Left(failure);
    }
  }
}
```

**4. Use Case com Error Handling**
```dart
// apps/app-petiveti/lib/features/animals/domain/usecases/get_animals.dart
class GetAnimalsUseCase {
  final AnimalRepository _repository;
  
  GetAnimalsUseCase(this._repository);
  
  Future<Either<Failure, List<Animal>>> call(String userId) async {
    // Business validation
    if (userId.trim().isEmpty) {
      return const Left(ValidationFailure(
        'ID do usuário é obrigatório',
        code: 'USER_ID_REQUIRED',
      ));
    }
    
    // Delegate to repository
    final result = await _repository.getAnimals(userId);
    
    // Business logic post-processing
    return result.fold(
      (failure) => Left(failure),
      (animals) {
        // Apply business rules
        final validAnimals = animals.where((animal) {
          final validation = animal.validate();
          return validation.isRight();
        }).toList();
        
        if (validAnimals.length != animals.length) {
          // Some animals failed validation - log but continue
          debugPrint('Filtered ${animals.length - validAnimals.length} invalid animals');
        }
        
        return Right(validAnimals);
      },
    );
  }
}
```

**5. Provider com Error Handling**
```dart
// apps/app-petiveti/lib/features/animals/presentation/providers/animals_provider.dart
class AnimalsProvider extends ChangeNotifier {
  final GetAnimalsUseCase _getAnimalsUseCase;
  
  AnimalsState _state = const AnimalsState();
  AnimalsState get state => _state;
  
  List<Animal> get animals => _state.animals;
  bool get isLoading => _state.isLoading;
  Failure? get failure => _state.failure;
  bool get hasError => _state.failure != null;
  
  String get errorMessage {
    final failure = _state.failure;
    if (failure == null) return '';
    
    return _getLocalizedErrorMessage(failure);
  }
  
  Future<void> loadAnimals(String userId) async {
    _updateState(_state.copyWith(
      isLoading: true,
      failure: null,
    ));
    
    final result = await _getAnimalsUseCase(userId);
    
    result.fold(
      (failure) => _updateState(_state.copyWith(
        isLoading: false,
        failure: failure,
      )),
      (animals) => _updateState(_state.copyWith(
        isLoading: false,
        animals: animals,
        failure: null,
      )),
    );
  }
  
  Future<void> retryLastOperation() async {
    final lastUserId = _state.lastUserId;
    if (lastUserId != null) {
      await loadAnimals(lastUserId);
    }
  }
  
  void clearError() {
    _updateState(_state.copyWith(failure: null));
  }
  
  String _getLocalizedErrorMessage(Failure failure) {
    // Centralized error message translation
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Verifique sua conexão com a internet e tente novamente';
      case ServerFailure:
        return 'Erro no servidor. Tente novamente em alguns minutos';
      case CacheFailure:
        return 'Erro no armazenamento local. Reinicie o aplicativo';
      case ValidationFailure:
        return failure.message; // Validation messages are already localized
      case AuthFailure:
        return 'Você precisa fazer login novamente';
      case PermissionFailure:
        return 'Você não tem permissão para esta operação';
      case NotFoundFailure:
        return 'Recurso não encontrado';
      default:
        return 'Erro inesperado. Tente novamente';
    }
  }
  
  void _updateState(AnimalsState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

**6. UI com Error Handling**
```dart
// apps/app-petiveti/lib/features/animals/presentation/widgets/error_handler_widget.dart
class ErrorHandlerWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  
  const ErrorHandlerWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(failure).withOpacity(0.1),
        border: Border.all(color: _getErrorColor(failure)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _getErrorIcon(failure),
                color: _getErrorColor(failure),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getErrorTitle(failure),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getErrorColor(failure),
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDismiss,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_getErrorMessage(failure)),
          if (onRetry != null && _canRetry(failure)) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getErrorColor(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
      case TimeoutFailure:
        return Colors.orange;
      case ValidationFailure:
        return Colors.amber;
      case AuthFailure:
      case PermissionFailure:
        return Colors.red;
      default:
        return Colors.red;
    }
  }
  
  IconData _getErrorIcon(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
      case TimeoutFailure:
        return Icons.wifi_off;
      case ValidationFailure:
        return Icons.warning;
      case AuthFailure:
      case PermissionFailure:
        return Icons.lock;
      case NotFoundFailure:
        return Icons.search_off;
      default:
        return Icons.error;
    }
  }
  
  String _getErrorTitle(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Problema de Conexão';
      case ValidationFailure:
        return 'Dados Inválidos';
      case AuthFailure:
        return 'Problema de Autenticação';
      case PermissionFailure:
        return 'Sem Permissão';
      case NotFoundFailure:
        return 'Não Encontrado';
      default:
        return 'Erro';
    }
  }
  
  String _getErrorMessage(Failure failure) {
    return failure.message;
  }
  
  bool _canRetry(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
      case TimeoutFailure:
      case ServerFailure:
        return true;
      case ValidationFailure:
      case AuthFailure:
      case PermissionFailure:
        return false;
      default:
        return true;
    }
  }
}
```

### 🚀 BENEFITS DA NOVA ARQUITETURA ERROR
1. **Consistent Error Types**: Todos erros mapeados para Failure classes
2. **Rich Error Context**: Informações detalhadas sobre erros
3. **Graceful Degradation**: Fallback strategies automáticas
4. **User-Friendly Messages**: Mensagens localizadas e contextuais
5. **Retry Logic**: Estratégias de retry baseadas no tipo de erro
6. **Logging**: Contexto rico para debugging e monitoring
7. **Type Safety**: Either pattern garante tratamento de erros
8. **UI Decoupling**: Erros não acoplados à UI específica

### 📋 ERROR HANDLING CHECKLIST
- [ ] Define Failure hierarchy com todos tipos de erro
- [ ] Implement ExceptionMapper para conversão automática
- [ ] Update repositories para retornar Either<Failure, T>
- [ ] Update use cases para validar e propagar erros
- [ ] Update providers para gerenciar estado de erro
- [ ] Create ErrorHandlerWidget reutilizável
- [ ] Add retry logic baseado no tipo de falha
- [ ] Implement error logging e monitoring
- [ ] Test error scenarios em todos os níveis

## 🧭 Navigation Architecture Migration

### PADRÃO GETX ATUAL
O código atual utiliza navegação imperativa com GetX:

```dart
// plans/app-petiveti/controllers/vacinas_controller.dart
class VacinasController extends GetxController {
  void navegarParaCadastro() {
    Get.to(() => VacinaCadastroPage()); // Imperative navigation
  }
  
  void voltarComSucesso(VacinaVet vacina) {
    Get.back(result: vacina); // Passing data back
    Get.snackbar('Sucesso', 'Vacina cadastrada'); // Side effect
  }
  
  void irParaDetalhes(String vacinaId) {
    Get.toNamed('/vacina/detalhes/$vacinaId'); // Named routes
  }
  
  void navegarParaAnimais() {
    Get.offAllNamed('/animais'); // Replace entire stack
  }
}

// plans/app-petiveti/pages/mobile_page.dart
class MobilePageMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/animais', page: () => AnimaisPage()),
        GetPage(name: '/vacinas', page: () => VacinasPage()),
        GetPage(name: '/vacina/cadastro', page: () => VacinaCadastroPage()),
        GetPage(name: '/vacina/detalhes/:id', page: () => VacinaDetalhesPage()),
        // ... many more routes
      ],
    );
  }
}

// Navigation calls scattered throughout codebase
class AnimalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/animal/detalhes/${animal.id}'), // Direct navigation
      child: // ... widget content
    );
  }
}
```

### 📂 PROBLEMAS DO GETX NAVIGATION
1. **Imperative Navigation**: Navegação espalhada por todo o código
2. **Global State**: Get.to/Get.back() cria dependência global
3. **No Type Safety**: Parâmetros passados como dynamic
4. **Hard to Test**: Difícil mockar navegação em testes
5. **Side Effects**: Snackbars misturados com navegação
6. **Route Management**: Rotas hardcoded e espalhadas
7. **No Deep Linking**: Suporte limitado para deep links
8. **No Route Guards**: Sem proteção de rotas por autorização

### 🏗️ MIGRAÇÃO PARA GOROUTER + DECLARATIVE NAVIGATION

#### ✅ NOVA ARQUITETURA DE NAVIGATION

**1. Route Configuration com Type Safety**
```dart
// apps/app-petiveti/lib/core/router/app_routes.dart
enum AppRoute {
  home('/'),
  animals('/animals'),
  animalDetails('/animals/:animalId'),
  animalForm('/animals/new'),
  editAnimal('/animals/:animalId/edit'),
  vaccines('/animals/:animalId/vaccines'),
  vaccineDetails('/animals/:animalId/vaccines/:vaccineId'),
  vaccineForm('/animals/:animalId/vaccines/new'),
  editVaccine('/animals/:animalId/vaccines/:vaccineId/edit'),
  calculators('/calculators'),
  calculator('/calculators/:calculatorType'),
  settings('/settings'),
  login('/login'),
  profile('/profile');
  
  const AppRoute(this.path);
  final String path;
  
  String location({Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    var result = path;
    
    // Replace path parameters
    if (pathParameters != null) {
      pathParameters.forEach((key, value) {
        result = result.replaceAll(':$key', value);
      });
    }
    
    // Add query parameters
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final query = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      result += '?$query';
    }
    
    return result;
  }
}

// Type-safe parameter classes
class AnimalDetailsParams {
  final String animalId;
  const AnimalDetailsParams({required this.animalId});
}

class VaccineDetailsParams {
  final String animalId;
  final String vaccineId;
  const VaccineDetailsParams({required this.animalId, required this.vaccineId});
}

class CalculatorParams {
  final CalculatorType calculatorType;
  final Map<String, dynamic>? initialData;
  const CalculatorParams({required this.calculatorType, this.initialData});
}
```

**2. GoRouter Configuration**
```dart
// apps/app-petiveti/lib/core/router/app_router.dart
class AppRouter {
  static final _router = GoRouter(
    initialLocation: AppRoute.home.path,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoute.home.path,
            name: AppRoute.home.name,
            builder: (context, state) => const HomePage(),
          ),
          
          GoRoute(
            path: AppRoute.animals.path,
            name: AppRoute.animals.name,
            builder: (context, state) => const AnimalsPage(),
            routes: [
              GoRoute(
                path: 'new',
                name: AppRoute.animalForm.name,
                builder: (context, state) => const AnimalFormPage(),
              ),
              GoRoute(
                path: ':animalId',
                name: AppRoute.animalDetails.name,
                builder: (context, state) {
                  final animalId = state.pathParameters['animalId']!;
                  return AnimalDetailsPage(animalId: animalId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: AppRoute.editAnimal.name,
                    builder: (context, state) {
                      final animalId = state.pathParameters['animalId']!;
                      return AnimalFormPage(animalId: animalId);
                    },
                  ),
                  GoRoute(
                    path: 'vaccines',
                    name: AppRoute.vaccines.name,
                    builder: (context, state) {
                      final animalId = state.pathParameters['animalId']!;
                      return VaccinesPage(animalId: animalId);
                    },
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: AppRoute.vaccineForm.name,
                        builder: (context, state) {
                          final animalId = state.pathParameters['animalId']!;
                          return VaccineFormPage(animalId: animalId);
                        },
                      ),
                      GoRoute(
                        path: ':vaccineId',
                        name: AppRoute.vaccineDetails.name,
                        builder: (context, state) {
                          final animalId = state.pathParameters['animalId']!;
                          final vaccineId = state.pathParameters['vaccineId']!;
                          return VaccineDetailsPage(
                            animalId: animalId,
                            vaccineId: vaccineId,
                          );
                        },
                        routes: [
                          GoRoute(
                            path: 'edit',
                            name: AppRoute.editVaccine.name,
                            builder: (context, state) {
                              final animalId = state.pathParameters['animalId']!;
                              final vaccineId = state.pathParameters['vaccineId']!;
                              return VaccineFormPage(
                                animalId: animalId,
                                vaccineId: vaccineId,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          GoRoute(
            path: AppRoute.calculators.path,
            name: AppRoute.calculators.name,
            builder: (context, state) => const CalculatorsPage(),
            routes: [
              GoRoute(
                path: ':calculatorType',
                name: AppRoute.calculator.name,
                builder: (context, state) {
                  final calculatorTypeStr = state.pathParameters['calculatorType']!;
                  final calculatorType = CalculatorType.values.firstWhere(
                    (type) => type.name == calculatorTypeStr,
                    orElse: () => CalculatorType.bodyCondition,
                  );
                  
                  // Parse initial data from query parameters
                  final initialData = state.uri.queryParameters.isNotEmpty
                      ? state.uri.queryParameters
                      : null;
                      
                  return CalculatorPage(
                    calculatorType: calculatorType,
                    initialData: initialData,
                  );
                },
              ),
            ],
          ),
          
          GoRoute(
            path: AppRoute.settings.path,
            name: AppRoute.settings.name,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      
      // Routes outside main shell (fullscreen)
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
    ],
    
    // Global error handler
    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
      onRetry: () => context.go(AppRoute.home.path),
    ),
    
    // Navigation guards
    redirect: (context, state) {
      final authState = context.read<AuthProvider>().state;
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoute.login.path;
      
      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoggingIn) {
        return AppRoute.login.path;
      }
      
      // Redirect to home if already logged in and trying to access login
      if (isLoggedIn && isLoggingIn) {
        return AppRoute.home.path;
      }
      
      return null; // No redirect needed
    },
  );
  
  static GoRouter get router => _router;
}

// Global navigator key for dialogs and snackbars
final navigatorKey = GlobalKey<NavigatorState>();
```

**3. Navigation Service (Centralized)**
```dart
// apps/app-petiveti/lib/core/router/navigation_service.dart
abstract class NavigationService {
  // Type-safe navigation methods
  void goToAnimalDetails(String animalId);
  void goToVaccineDetails(String animalId, String vaccineId);
  void goToCalculator(CalculatorType type, {Map<String, dynamic>? initialData});
  void goToAnimalForm({String? animalId});
  void goToVaccineForm(String animalId, {String? vaccineId});
  
  // Generic navigation methods
  void go(String location);
  void push(String location);
  void pop<T extends Object?>([T? result]);
  void replace(String location);
  
  // Dialog and overlay methods
  Future<T?> showDialog<T>(Widget dialog);
  void showSnackBar(String message, {SnackBarType type = SnackBarType.info});
  void showErrorSnackBar(String message);
  void showSuccessSnackBar(String message);
}

class NavigationServiceImpl implements NavigationService {
  final GoRouter _router;
  
  NavigationServiceImpl(this._router);
  
  @override
  void goToAnimalDetails(String animalId) {
    _router.goNamed(
      AppRoute.animalDetails.name,
      pathParameters: {'animalId': animalId},
    );
  }
  
  @override
  void goToVaccineDetails(String animalId, String vaccineId) {
    _router.goNamed(
      AppRoute.vaccineDetails.name,
      pathParameters: {
        'animalId': animalId,
        'vaccineId': vaccineId,
      },
    );
  }
  
  @override
  void goToCalculator(CalculatorType type, {Map<String, dynamic>? initialData}) {
    _router.goNamed(
      AppRoute.calculator.name,
      pathParameters: {'calculatorType': type.name},
      queryParameters: initialData?.map((k, v) => MapEntry(k, v.toString())),
    );
  }
  
  @override
  void goToAnimalForm({String? animalId}) {
    if (animalId != null) {
      _router.goNamed(
        AppRoute.editAnimal.name,
        pathParameters: {'animalId': animalId},
      );
    } else {
      _router.goNamed(AppRoute.animalForm.name);
    }
  }
  
  @override
  void go(String location) => _router.go(location);
  
  @override
  void push(String location) => _router.push(location);
  
  @override
  void pop<T extends Object?>([T? result]) => _router.pop(result);
  
  @override
  void replace(String location) => _router.pushReplacement(location);
  
  @override
  Future<T?> showDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      builder: (context) => dialog,
    );
  }
  
  @override
  void showSnackBar(String message, {SnackBarType type = SnackBarType.info}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getSnackBarColor(type),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
  
  @override
  void showErrorSnackBar(String message) {
    showSnackBar(message, type: SnackBarType.error);
  }
  
  @override
  void showSuccessSnackBar(String message) {
    showSnackBar(message, type: SnackBarType.success);
  }
  
  Color _getSnackBarColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }
}

enum SnackBarType { success, error, warning, info }
```

**4. Updated Providers with Navigation Service**
```dart
// apps/app-petiveti/lib/features/animals/presentation/providers/animals_provider.dart
class AnimalsProvider extends ChangeNotifier {
  final GetAnimalsUseCase _getAnimalsUseCase;
  final CreateAnimalUseCase _createAnimalUseCase;
  final NavigationService _navigationService;
  
  AnimalsProvider(
    this._getAnimalsUseCase,
    this._createAnimalUseCase,
    this._navigationService,
  );
  
  // ... state management code ...
  
  Future<void> createAnimal(Animal animal) async {
    _updateState(_state.copyWith(isLoading: true));
    
    final result = await _createAnimalUseCase(animal);
    
    result.fold(
      (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          failure: failure,
        ));
        _navigationService.showErrorSnackBar(
          'Erro ao criar animal: ${failure.message}',
        );
      },
      (_) {
        _updateState(_state.copyWith(
          isLoading: false,
          animals: [..._state.animals, animal],
        ));
        _navigationService.showSuccessSnackBar('Animal criado com sucesso!');
        _navigationService.pop(); // Return to previous screen
      },
    );
  }
  
  void navigateToAnimalDetails(String animalId) {
    _navigationService.goToAnimalDetails(animalId);
  }
  
  void navigateToCreateAnimal() {
    _navigationService.goToAnimalForm();
  }
  
  void navigateToEditAnimal(String animalId) {
    _navigationService.goToAnimalForm(animalId: animalId);
  }
}
```

**5. Updated UI with Declarative Navigation**
```dart
// apps/app-petiveti/lib/features/animals/presentation/pages/animals_page.dart
class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnimalsProvider>().loadAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<AnimalsProvider>().navigateToCreateAnimal(),
          ),
        ],
      ),
      body: Consumer<AnimalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.hasError) {
            return ErrorHandlerWidget(
              failure: provider.failure!,
              onRetry: () => provider.loadAnimals(),
            );
          }
          
          if (provider.animals.isEmpty) {
            return const AnimalEmptyStateWidget();
          }
          
          return ListView.builder(
            itemCount: provider.animals.length,
            itemBuilder: (context, index) {
              final animal = provider.animals[index];
              return AnimalCard(
                animal: animal,
                onTap: () => provider.navigateToAnimalDetails(animal.id),
                onEdit: () => provider.navigateToEditAnimal(animal.id),
              );
            },
          );
        },
      ),
    );
  }
}

// apps/app-petiveti/lib/features/animals/presentation/widgets/animal_card.dart
class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  
  const AnimalCard({
    super.key,
    required this.animal,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: animal.photo != null 
              ? NetworkImage(animal.photo!)
              : null,
          child: animal.photo == null 
              ? Text(animal.name.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Text(animal.name),
        subtitle: Text('${animal.species.displayName} • ${animal.breed}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'vaccines':
                context.read<NavigationService>().goToVaccineDetails(animal.id, '');
                break;
              case 'calculators':
                context.read<NavigationService>().goToCalculator(
                  CalculatorType.bodyCondition,
                  initialData: {'animalId': animal.id},
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'vaccines', child: Text('Vacinas')),
            const PopupMenuItem(value: 'calculators', child: Text('Calculadoras')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
```

**6. Deep Linking Support**
```dart
// apps/app-petiveti/lib/core/router/deep_link_handler.dart
class DeepLinkHandler {
  static void handleInitialLink() async {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }
    
    // Listen for incoming links when app is running
    getLinksStream().listen((String link) {
      _handleDeepLink(link);
    });
  }
  
  static void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    // Handle custom scheme: petiveti://animal/123
    if (uri.scheme == 'petiveti') {
      final path = '/${uri.host}${uri.path}';
      AppRouter.router.go(path);
      return;
    }
    
    // Handle universal links: https://petiveti.app/animal/123
    if (uri.host == 'petiveti.app') {
      AppRouter.router.go(uri.path);
      return;
    }
    
    // Handle QR code sharing
    if (uri.queryParameters.containsKey('shared')) {
      _handleSharedContent(uri.queryParameters);
    }
  }
  
  static void _handleSharedContent(Map<String, String> params) {
    final type = params['type'];
    final id = params['id'];
    
    switch (type) {
      case 'animal':
        AppRouter.router.go('/animals/$id');
        break;
      case 'vaccine':
        final animalId = params['animalId'];
        AppRouter.router.go('/animals/$animalId/vaccines/$id');
        break;
      case 'calculator':
        final calculatorType = params['calculatorType'];
        AppRouter.router.go('/calculators/$calculatorType');
        break;
    }
  }
}
```

### 🚀 BENEFITS DA NOVA ARQUITETURA NAVIGATION
1. **Type Safety**: Parâmetros tipados e verificados em compile time
2. **Declarative Routing**: Rotas definidas declarativamente em um lugar
3. **Deep Linking**: Suporte completo para deep links e universal links
4. **Route Guards**: Proteção de rotas baseada em autenticação
5. **Centralized Navigation**: NavigationService centraliza toda navegação
6. **Testability**: Fácil mockar NavigationService em testes
7. **URL-based**: URLs compartilháveis e bookmarkable
8. **Error Handling**: Tratamento de erro de navegação centralizado
9. **Shell Routes**: Suporte para layouts aninhados (bottom nav, app bar)
10. **Query Parameters**: Suporte robusto para query parameters

### 📋 NAVIGATION MIGRATION CHECKLIST
- [ ] Define AppRoute enum com todas rotas tipadas
- [ ] Configure GoRouter com route hierarchy
- [ ] Implement NavigationService interface
- [ ] Add route guards para autenticação
- [ ] Update providers para usar NavigationService
- [ ] Replace Get.to/Get.back com context navigation
- [ ] Add deep linking support
- [ ] Configure universal links
- [ ] Test navigation em todos os fluxos
- [ ] Add navigation tests com GoRouter testing

### Estrutura de Pastas
│   │   ├── calculators/          # Calculadoras
│   │   ├── auth/                 # Autenticação
│   │   └── subscription/         # Assinaturas
│   └── main.dart
```

### Estrutura por Feature (Clean Architecture)
```
features/animals/
├── data/
│   ├── datasources/
│   │   ├── animal_local_datasource.dart
│   │   └── animal_remote_datasource.dart
│   ├── models/
│   │   └── animal_model.dart
│   └── repositories/
│       └── animal_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── animal.dart
│   ├── repositories/
│   │   └── animal_repository.dart
│   └── usecases/
│       ├── create_animal.dart
│       ├── get_animals.dart
│       ├── update_animal.dart
│       └── delete_animal.dart
└── presentation/
    ├── pages/
    │   ├── animals_page.dart
    │   └── animal_form_page.dart
    ├── providers/
    │   └── animals_provider.dart
    └── widgets/
        ├── animal_card.dart
        └── animal_form.dart
```

## 📋 Plano de Migração por Fases

### FASE 1: Configuração Base (Semana 1)
- [ ] Criar estrutura do projeto em `apps/app-petiveti/`
- [ ] Configurar pubspec.yaml com dependências
- [ ] Implementar Core (DI, Error Handling, Interfaces)
- [ ] Configurar Hive + Firebase adapters
- [ ] Implementar sistema de roteamento

### FASE 2: Feature Animals (Semana 2)
> **📋 Referência**: `plans/app-petiveti/models/11_animal_model.dart`  
> **📋 Repository**: `plans/app-petiveti/repository/animal_repository.dart`  
> **📋 Pages**: `plans/app-petiveti/pages/meupet/`

- [ ] Migrar entidade Animal do modelo Hive atual
- [ ] Implementar casos de uso (CRUD)
- [ ] Criar repository com interfaces
- [ ] Implementar datasources (local/remote)
- [ ] Criar UI com Provider/Riverpod
- [ ] Testes unitários completos

### FASE 3: Feature Appointments (Semana 3)
> **📋 Referência**: `plans/app-petiveti/models/12_consulta_model.dart`  
> **📋 Repository**: `plans/app-petiveti/repository/consulta_repository.dart`  
> **📋 Utils**: `plans/app-petiveti/utils/consulta/`

- [ ] Migrar sistema de consultas
- [ ] Implementar agendamento
- [ ] Sistema de histórico
- [ ] Integração com lembretes
- [ ] Testes e validações

### FASE 4: Feature Vaccines (Semana 4)
> **📋 Referência**: `plans/app-petiveti/models/16_vacina_model.dart`  
> **📋 Repository**: `plans/app-petiveti/repository/vacina_repository.dart`  
> **📋 Controller**: `plans/app-petiveti/controllers/vacinas_controller.dart`  
> **📋 Pages**: `plans/app-petiveti/pages/vacina_page/`  
> **📋 Utils**: `plans/app-petiveti/utils/vacina_utils.dart`

- [ ] Sistema de vacinação
- [ ] Controle de carteira
- [ ] Lembretes automáticos
- [ ] Histórico de vacinas
- [ ] Exportação de dados

### FASE 5: Feature Medications (Semana 5)
- [ ] Gestão de medicamentos
- [ ] Controle de dosagens
- [ ] Sistema de lembretes
- [ ] Histórico de medicações
- [ ] Integração com calculadoras

### FASE 6: Feature Weight (Semana 6)
- [ ] Controle de peso
- [ ] Gráficos de evolução
- [ ] Metas de peso
- [ ] Histórico detalhado
- [ ] Exportação de relatórios

### FASE 7: Feature Calculators (Semana 7-8)
> **📋 Referência**: `plans/app-petiveti/pages/calc/`  
> **📋 Calculadoras disponíveis**:
> - `condicao_corporal/` - Condição corporal dos animais
> - `conversao/` - Conversão de unidades  
> - `diabetes_insulina/` - Cálculos de diabetes e insulina
> - `dieta_caseira/` - Dietas caseiras
> - `dosagem_anestesico/` - Dosagens de anestésicos
> - `dosagem_medicamento/` - Dosagens de medicamentos
> - `fluidoterapia/` - Cálculos de fluidoterapia
> - `gestacao/` - Cálculos de gestação
> - `hidratacao_fluidoterapia/` - Hidratação
> - `idade_animal/` - Idade dos animais
> - `necessidade_calorias/` - Necessidades calóricas
> - E outras...

- [ ] Migrar 15+ calculadoras
- [ ] Implementar padrão Strategy
- [ ] Sistema modular de cálculos
- [ ] Validações aprimoradas
- [ ] Interface unificada

### FASE 8: Features Auxiliares (Semana 9)
- [ ] Sistema de Lembretes
- [ ] Controle de Despesas
- [ ] Sistema de Backup
- [ ] Exportação de dados
- [ ] Configurações

### FASE 9: Auth & Subscription (Semana 10)
- [ ] Sistema de autenticação
- [ ] Integração Firebase Auth
- [ ] Sistema de assinaturas
- [ ] RevenueCat integration
- [ ] Controle de acesso

### FASE 10: Finalização (Semana 11-12)
- [ ] Migração de dados existentes
- [ ] Testes de integração
- [ ] Otimizações de performance
- [ ] Documentação completa
- [ ] Deploy e validação

## 🔧 Tecnologias e Dependências

### Core Dependencies
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Network
  dio: ^5.3.0
  connectivity_plus: ^5.0.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  
  # Firebase
  firebase_core: ^2.15.0
  firebase_auth: ^4.7.2
  cloud_firestore: ^4.8.4
  
  # UI/UX
  go_router: ^10.1.0
  flutter_svg: ^2.0.7
  cached_network_image: ^3.2.3
  
  # Utils
  intl: ^0.18.1
  equatable: ^2.0.5
  dartz: ^0.10.1
```

### Dev Dependencies
```yaml
dev_dependencies:
  # Testing
  mockito: ^5.4.2
  bloc_test: ^9.1.4
  
  # Code Generation
  build_runner: ^2.4.6
  injectable_generator: ^2.4.0
  hive_generator: ^2.0.0
  
  # Analysis
  flutter_lints: ^2.0.3
  very_good_analysis: ^5.1.0
```

## 📊 Benefícios da Nova Arquitetura

### Princípios SOLID
- **SRP**: Cada classe tem uma responsabilidade única
- **OCP**: Extensível sem modificar código existente
- **LSP**: Substituição de implementações
- **ISP**: Interfaces específicas por contexto
- **DIP**: Dependências por abstração

### Vantagens Técnicas
- **Testabilidade**: 100% de cobertura possível
- **Manutenibilidade**: Código limpo e organizado
- **Escalabilidade**: Fácil adição de features
- **Reutilização**: Componentes reutilizáveis
- **Performance**: Otimizações arquiteturais

### Vantagens de Negócio
- **Time to Market**: Desenvolvimento mais rápido
- **Qualidade**: Menos bugs em produção
- **Flexibilidade**: Adaptação rápida a mudanças
- **Manutenção**: Custos reduzidos
- **Evolução**: Base sólida para crescimento

## 🚀 Próximos Passos

1. **Aprovação do Plano**: Validar arquitetura proposta
2. **Setup Inicial**: Criar estrutura base do projeto
3. **Prototipagem**: Implementar feature Animals como prova de conceito
4. **Validação**: Testar arquitetura com caso real
5. **Execução**: Seguir plano de migração por fases

## 📖 Guia para Agentes de IA

### 🔍 Como Consultar o Material Original
Quando trabalhar na migração, sempre referencie:

1. **Modelos de Dados**: `plans/app-petiveti/models/`
   - `11_animal_model.dart` - Estrutura de Animal
   - `12_consulta_model.dart` - Estrutura de Consulta  
   - `13_despesa_model.dart` - Estrutura de Despesa
   - `14_lembrete_model.dart` - Estrutura de Lembrete
   - `15_medicamento_model.dart` - Estrutura de Medicamento
   - `16_vacina_model.dart` - Estrutura de Vacina
   - `17_peso_model.dart` - Estrutura de Peso

2. **Repositórios Atuais**: `plans/app-petiveti/repository/`
   - Contém toda lógica de persistência atual
   - Padrões de CRUD existentes
   - Integração Hive + Firebase

3. **Páginas e UI**: `plans/app-petiveti/pages/`
   - Estrutura de navegação atual
   - Componentes visuais existentes
   - Fluxos de usuário implementados

4. **Lógica de Negócio**: `plans/app-petiveti/utils/`
   - Validações existentes
   - Cálculos e formatações
   - Helpers por feature

5. **Serviços**: `plans/app-petiveti/services/`
   - Autenticação atual
   - Notificações
   - Integração com APIs

### 📋 Comandos para Consulta
```bash
# Listar arquivos de uma feature específica
find plans/app-petiveti -name "*animal*" -type f

# Examinar estrutura de páginas
ls -la plans/app-petiveti/pages/

# Ver calculadoras disponíveis  
ls -la plans/app-petiveti/pages/calc/

# Consultar utilitários por feature
ls -la plans/app-petiveti/utils/
```

## 📝 Considerações Finais

Esta migração transformará o app-petiveti em uma referência de arquitetura limpa no Flutter, seguindo as melhores práticas da indústria e garantindo um código sustentável e escalável para o futuro.

O investimento inicial em arquitetura retornará em:
- Velocidade de desenvolvimento
- Qualidade do código
- Facilidade de manutenção
- Capacidade de evolução
- Satisfação da equipe de desenvolvimento

---

> **💡 LEMBRE-SE**: Sempre consulte o código original em `plans/app-petiveti/` antes de implementar qualquer migração. Este documento é um guia, mas o código fonte é a verdade absoluta!## 🎯 STATUS ATUAL DA MIGRAÇÃO (ATUALIZADO - 22/08/2025)

### ✅ **IMPLEMENTAÇÕES CONCLUÍDAS**

#### **Issue #1 - Sistema de Appointments [FEATURE]** 
**Status: ✅ CONCLUÍDO** | **Complexidade: Alta**
- ✅ Domain Layer: Entidade Appointment rica implementada
- ✅ Repository: Interface com 15+ métodos especializados
- ✅ Use Cases: CRUD completo + funcionalidades avançadas
- ✅ Data Layer: Datasources local e remote configurados
- ✅ Integration: Sistema funcionando com providers

#### **Issue #2 - Sistema de Vaccines [FEATURE]**
**Status: ✅ CONCLUÍDO** | **Complexidade: Alta**  
- ✅ Domain Layer: Entidade Vaccine com lógica de negócio rica
- ✅ Repository: Interface com 92 métodos especializados
- ✅ Use Cases: 13 casos de uso implementados
- ✅ Remote Datasource: Integração completa com Firestore
- ✅ Features: Status automático, lembretes, calendário, estatísticas

#### **Issue #4 - Auth + Subscriptions [SECURITY]**
**Status: ✅ CONCLUÍDO** | **Complexidade: Muito Alta**
- ✅ Social Logins: Google, Apple, Facebook implementados
- ✅ RevenueCat Integration: Sistema completo de assinaturas
- ✅ Auth Guards: Premium, Auth, Unauthenticated guards
- ✅ Auth Service: Serviço centralizado de autenticação
- ✅ Dependency Injection: Todas as dependências configuradas

### 🚧 **PRÓXIMAS ATIVIDADES PRIORITÁRIAS**

#### **Issue #3 - Calculators System [MIGRATION]**
**Status: 🔄 PENDENTE** | **Complexidade: Muito Alta** | **Prioridade: 🔴 CRÍTICA**

**Descrição**: Migração de 13 calculadoras veterinárias especializadas para arquitetura SOLID com padrão Strategy.

### **📊 INVENTÁRIO COMPLETO (13 Calculadoras)**

#### **🟢 BAIXA COMPLEXIDADE (2-3 dias cada)**
1. **Gestação** - Cálculo simples data + offset por espécie
2. **Condição Corporal** - Lookup em mapas BCS (Body Condition Score)  
3. **Conversão Unidades** - Fórmulas matemáticas básicas (peso, volume, temperatura)

#### **🟡 MÉDIA COMPLEXIDADE (3-5 dias cada)**
4. **Dosagem Medicamentos** - Fórmula + base dados 10 medicamentos
5. **Fluidoterapia** - Cálculos múltiplos de hidratação + validações específicas
6. **Necessidades Calóricas** - RER + fatores multiplicadores por espécie
7. **Idade Animal** - Algoritmos por espécie + condicionais de idade

#### **🔴 ALTA COMPLEXIDADE (5-8 dias cada)**
8. **Dosagem Anestésicos** - Matriz complexa + segurança crítica por espécie
9. **Diabetes/Insulina** - Múltiplos algoritmos + ajustes dinâmicos por glicemia
10. **Hidratação Avançada** - Fórmulas compostas + muitos fatores clínicos
11. **Dieta Caseira** - Macronutrientes + quantidades específicas por alimento
12. **Peso Ideal** - Algoritmo complexo + dados raciais extensos
13. **Gestação Avançada** - Múltiplos métodos + estimativas ultrassom

### **🚀 PLANO DE IMPLEMENTAÇÃO DETALHADO (12 SEMANAS)**

#### **FASE 1: INFRAESTRUTURA (1 semana)**
- [ ] Criar estrutura base Clean Architecture para calculadoras
- [ ] Implementar Strategy Pattern interfaces (CalculatorStrategy, Input/Output)
- [ ] Desenvolver BaseCalculatorController com Provider/Riverpod
- [ ] Criar shared components (validation, form builders, result display)
- [ ] Setup testes unitários base com casos de teste críticos

#### **FASE 2: CALCULADORAS SIMPLES (1 semana)**
- [ ] **Gestação** (0.5 dia): Data início + dias gestação por espécie
- [ ] **Condição Corporal** (1 dia): Lookup BCS + interpretações
- [ ] **Conversão Unidades** (0.5 dia): Peso, volume, temperatura
- [ ] **Testes + refinamentos** (3 dias): Coverage + integração

#### **FASE 3: CALCULADORAS MÉDIAS (1.5 semanas)**
- [ ] **Dosagem Medicamentos** (3 dias): Base dados + fórmulas posologia
- [ ] **Fluidoterapia** (3 dias): Déficit hídrico + manutenção + perdas
- [ ] **Necessidades Calóricas** (2 dias): RER + fatores atividade/fisiologia
- [ ] **Idade Animal** (2.5 dias): Conversão idade animal/humana por espécie

#### **FASE 4: CALCULADORAS COMPLEXAS - LOTE 1 (2 semanas)**
- [ ] **Dosagem Anestésicos** (5 dias): Matriz anestésicos/espécie + segurança
- [ ] **Diabetes Insulina** (5 dias): Fatores insulina + ajustes glicemia + monitoramento
- [ ] **Hidratação Avançada** (4 dias): Múltiplos cálculos + ajustes clínicos

#### **FASE 5: CALCULADORAS COMPLEXAS - LOTE 2 (2 semanas)**
- [ ] **Dieta Caseira** (5 dias): Macronutrientes + composição alimentos + quantidades
- [ ] **Peso Ideal** (4 dias): Algoritmo ECC + fatores raciais + recomendações
- [ ] **Gestação Avançada** (5 dias): Acasalamento + ultrassom + fases gestação

#### **FASE 6: INTEGRAÇÃO E POLIMENTO (1 semana)**
- [ ] Integração completa com navegação GoRouter
- [ ] Testes end-to-end de todos os fluxos
- [ ] Performance optimization para devices baixo-end
- [ ] Documentation completa + guia de uso

### **⚡ ESTIMATIVAS E RECURSOS**

**TEMPO DE DESENVOLVIMENTO:**
- **Infraestrutura**: 7 dias (15%)
- **Calculadoras Simples**: 7 dias (10%)  
- **Calculadoras Médias**: 11 dias (18%)
- **Calculadoras Complexas**: 28 dias (47%)
- **Integração**: 7 dias (10%)
- **TOTAL**: **60 dias úteis (12 semanas)**

**ARQUIVOS ESTIMADOS:**
- Domain Layer: ~40 arquivos (entities, use cases, repositories)
- Data Layer: ~15 arquivos (datasources, models, repositories impl)
- Presentation Layer: ~25 arquivos (providers, pages, widgets)
- **Total: ~80 arquivos novos**

### **🎯 SUBETAPAS DE EXECUÇÃO (Issue #3 - Calculators)**

#### **3.1 - Condição Corporal** (Alto uso + Baixa complexidade) - PILOTO
- [ ] 3.1.1 - Criar entidade BodyConditionInput/Output
- [ ] 3.1.2 - Implementar BodyConditionCalculatorStrategy
- [ ] 3.1.3 - Desenvolver BodyConditionProvider
- [ ] 3.1.4 - Criar UI BodyConditionPage
- [ ] 3.1.5 - Implementar testes unitários
- [ ] 3.1.6 - Integrar com navegação

#### **3.2 - Necessidades Calóricas** (Alto uso + Média complexidade)
- [ ] 3.2.1 - Criar entidade CalorieInput/Output
- [ ] 3.2.2 - Implementar CalorieCalculatorStrategy (RER + fatores)
- [ ] 3.2.3 - Desenvolver CalorieProvider
- [ ] 3.2.4 - Criar UI CaloriePage com formulário espécie/atividade
- [ ] 3.2.5 - Implementar validações peso/estado fisiológico
- [ ] 3.2.6 - Testes unitários + integração

#### **3.3 - Dosagem Medicamentos** (Crítico + Média complexidade)
- [ ] 3.3.1 - Criar entidade MedicationDosageInput/Output
- [ ] 3.3.2 - Implementar MedicationDosageStrategy
- [ ] 3.3.3 - Criar base dados 10 medicamentos
- [ ] 3.3.4 - Desenvolver MedicationDosageProvider
- [ ] 3.3.5 - Criar UI com seletor medicamento + dosagem
- [ ] 3.3.6 - Validações críticas + testes segurança

#### **3.4 - Gestação** (Comum + Baixa complexidade)
- [ ] 3.4.1 - Criar entidade PregnancyInput/Output
- [ ] 3.4.2 - Implementar PregnancyCalculatorStrategy
- [ ] 3.4.3 - Base dados períodos gestação por espécie
- [ ] 3.4.4 - Desenvolver PregnancyProvider
- [ ] 3.4.5 - Criar UI PregnancyPage
- [ ] 3.4.6 - Testes + validação datas

#### **3.5 - Idade Animal** (Popular + Média complexidade)
- [ ] 3.5.1 - Criar entidade AnimalAgeInput/Output
- [ ] 3.5.2 - Implementar AnimalAgeStrategy (algoritmos espécie)
- [ ] 3.5.3 - Desenvolver AnimalAgeProvider
- [ ] 3.5.4 - Criar UI AnimalAgePage
- [ ] 3.5.5 - Validações idade + condicionais
- [ ] 3.5.6 - Testes cobertura cenários

#### **3.6 - Conversão Unidades** (Utilitário + Baixa complexidade)
- [ ] 3.6.1 - Criar entidade UnitConversionInput/Output
- [ ] 3.6.2 - Implementar UnitConversionStrategy
- [ ] 3.6.3 - Desenvolver UnitConversionProvider
- [ ] 3.6.4 - Criar UI UnitConversionPage
- [ ] 3.6.5 - Fórmulas peso/volume/temperatura
- [ ] 3.6.6 - Testes matemáticos + precisão

#### **3.7 - Fluidoterapia** (Profissional + Média complexidade)
- [ ] 3.7.1 - Criar entidade FluidTherapyInput/Output
- [ ] 3.7.2 - Implementar FluidTherapyStrategy
- [ ] 3.7.3 - Cálculos déficit + manutenção + perdas
- [ ] 3.7.4 - Desenvolver FluidTherapyProvider
- [ ] 3.7.5 - Criar UI FluidTherapyPage
- [ ] 3.7.6 - Validações específicas + testes

#### **3.8 - Dosagem Anestésicos** (Crítico + Alta complexidade)
- [ ] 3.8.1 - Criar entidade AnesthesiaDosageInput/Output
- [ ] 3.8.2 - Implementar AnesthesiaDosageStrategy
- [ ] 3.8.3 - Matriz anestésicos/espécie + segurança
- [ ] 3.8.4 - Desenvolver AnesthesiaDosageProvider
- [ ] 3.8.5 - Criar UI com alertas segurança
- [ ] 3.8.6 - Testes críticos + validação profissional

#### **3.9 - Diabetes Insulina** (Especializado + Alta complexidade)
- [ ] 3.9.1 - Criar entidade DiabetesInput/Output
- [ ] 3.9.2 - Implementar DiabetesCalculatorStrategy
- [ ] 3.9.3 - Algoritmos ajuste glicemia + dose anterior
- [ ] 3.9.4 - Desenvolver DiabetesProvider
- [ ] 3.9.5 - Criar UI DiabetesPage + monitoramento
- [ ] 3.9.6 - Testes cenários complexos

#### **3.10 - Peso Ideal** (Complexo + Alta complexidade)
- [ ] 3.10.1 - Criar entidade IdealWeightInput/Output
- [ ] 3.10.2 - Implementar IdealWeightStrategy
- [ ] 3.10.3 - Base dados raciais + fatores ECC
- [ ] 3.10.4 - Desenvolver IdealWeightProvider
- [ ] 3.10.5 - Criar UI IdealWeightPage
- [ ] 3.10.6 - Algoritmo complexo + testes

#### **3.11 - Hidratação Avançada** (Avançado + Alta complexidade)
- [ ] 3.11.1 - Criar entidade AdvancedHydrationInput/Output
- [ ] 3.11.2 - Implementar AdvancedHydrationStrategy
- [ ] 3.11.3 - Múltiplos cálculos + ajustes clínicos
- [ ] 3.11.4 - Desenvolver AdvancedHydrationProvider
- [ ] 3.11.5 - Criar UI AdvancedHydrationPage
- [ ] 3.11.6 - Testes complexos + validações

#### **3.12 - Dieta Caseira** (Complexo + Alta complexidade)
- [ ] 3.12.1 - Criar entidade HomeDietInput/Output
- [ ] 3.12.2 - Implementar HomeDietCalculatorStrategy
- [ ] 3.12.3 - Base dados macronutrientes + alimentos
- [ ] 3.12.4 - Desenvolver HomeDietProvider
- [ ] 3.12.5 - Criar UI HomeDietPage
- [ ] 3.12.6 - Cálculos nutricionais + testes

#### **3.13 - Gestação Avançada** (Especializado + Alta complexidade)
- [ ] 3.13.1 - Criar entidade AdvancedPregnancyInput/Output
- [ ] 3.13.2 - Implementar AdvancedPregnancyStrategy
- [ ] 3.13.3 - Múltiplos métodos + ultrassom
- [ ] 3.13.4 - Desenvolver AdvancedPregnancyProvider
- [ ] 3.13.5 - Criar UI AdvancedPregnancyPage
- [ ] 3.13.6 - Estimativas complexas + testes

### **🔧 DEPENDÊNCIAS E RISCOS IDENTIFICADOS**

**DEPENDÊNCIAS TÉCNICAS:**
- Core Package com services base (analytics, premium checks)
- Navigation system definido (GoRouter vs GetX)
- State management escolhido (Provider vs Riverpod)
- Testing framework configurado

**RISK FACTORS:**
- **Validação Médica**: Fórmulas veterinárias requerem validação profissional
- **Performance**: Cálculos complexos em devices baixo-end
- **Data Migration**: Migração de constantes para estrutura adequada  
- **UX Consistency**: Manter interface familiar durante migração

### **📈 CRITÉRIOS DE SUCESSO**

**QUALITY METRICS:**
- [ ] 100% coverage testes unitários para cálculos críticos
- [ ] 0 regressões em funcionalidade existente
- [ ] Performance equivalente ou superior
- [ ] Redução complexidade código (cyclomatic complexity)

**ARCHITECTURE METRICS:**
- [ ] SOLID principles compliance em todas as calculadoras
- [ ] Clean Architecture layers respeitadas
- [ ] Strategy Pattern implementado corretamente
- [ ] Dependency injection em toda a stack

**USER METRICS:**
- [ ] UX mantida ou melhorada
- [ ] Precisão de cálculos preservada
- [ ] Feature parity completa
- [ ] Melhor tratamento de erros e feedback

#### **Issue #5 - Medications System [FEATURE]**
**Status: 🔄 PENDENTE** | **Complexidade: Alta** | **Prioridade: 🟡 ALTA**

### **🎯 SUBETAPAS DE EXECUÇÃO (Issue #5 - Medications)**

#### **5.1 - Domain Layer Medications**
- [ ] 5.1.1 - Criar entidade Medication (nome, concentração, forma, indicações)
- [ ] 5.1.2 - Criar entidade MedicationSchedule (dosagem, frequência, duração)
- [ ] 5.1.3 - Criar entidade MedicationAdministration (registro aplicação)
- [ ] 5.1.4 - Definir repository interface MedicationRepository
- [ ] 5.1.5 - Criar value objects (Dosage, Frequency, Route)
- [ ] 5.1.6 - Implementar business rules e validações

#### **5.2 - Use Cases Medications**
- [ ] 5.2.1 - CreateMedicationUseCase (CRUD básico)
- [ ] 5.2.2 - GetMedicationsUseCase (listagem e filtros)
- [ ] 5.2.3 - ScheduleMedicationUseCase (agendar medicação)
- [ ] 5.2.4 - RecordAdministrationUseCase (registrar aplicação)
- [ ] 5.2.5 - GetMedicationHistoryUseCase (histórico por animal)
- [ ] 5.2.6 - CalculateDosageUseCase (integração calculadoras)

#### **5.3 - Data Layer Medications**
- [ ] 5.3.1 - Criar MedicationModel (Hive/JSON serialization)
- [ ] 5.3.2 - Implementar MedicationLocalDataSource (Hive)
- [ ] 5.3.3 - Implementar MedicationRemoteDataSource (Firestore)
- [ ] 5.3.4 - Criar MedicationRepositoryImpl
- [ ] 5.3.5 - Setup sincronização local/remote
- [ ] 5.3.6 - Implementar cache e offline support

#### **5.4 - Integration with Calculators**
- [ ] 5.4.1 - Integrar com Issue #3 (CalculatorService)
- [ ] 5.4.2 - Criar MedicationDosageHelper
- [ ] 5.4.3 - Implementar auto-calculation baseado em peso/espécie
- [ ] 5.4.4 - Validações de dosagem segura
- [ ] 5.4.5 - Alertas para overdose/subdose
- [ ] 5.4.6 - Sugestões de ajuste posológico

#### **5.5 - Integration with Reminders**
- [ ] 5.5.1 - Integrar com Issue #6 (RemindersService)
- [ ] 5.5.2 - Auto-criar lembretes ao agendar medicação
- [ ] 5.5.3 - Sincronizar alterações medication ↔ reminder
- [ ] 5.5.4 - Implementar snooze e mark as completed
- [ ] 5.5.5 - Lembretes recorrentes (diário, BID, TID, etc.)
- [ ] 5.5.6 - Notificações push para medicações críticas

#### **5.6 - Presentation Layer**
- [ ] 5.6.1 - Criar MedicationsProvider (state management)
- [ ] 5.6.2 - Implementar MedicationsPage (listagem)
- [ ] 5.6.3 - Criar MedicationFormPage (cadastro/edição)
- [ ] 5.6.4 - Implementar MedicationSchedulePage (agendamento)
- [ ] 5.6.5 - Criar MedicationHistoryPage (histórico)
- [ ] 5.6.6 - Widgets: MedicationCard, DosageCalculator, HistoryTimeline

#### **5.7 - Export and Reports**
- [ ] 5.7.1 - Implementar MedicationReportService
- [ ] 5.7.2 - Export para PDF (prescrição veterinária)
- [ ] 5.7.3 - Export para CSV (controle administrações)
- [ ] 5.7.4 - Gerar gráficos aderência medicamentosa
- [ ] 5.7.5 - Relatório eficácia por medicamento
- [ ] 5.7.6 - Share medication schedule (veterinário ↔ tutor)

**Dependências**: Requer Issue #3 (Calculators) e #6 (Reminders)
**Estimativa**: 2 semanas | **Subetapas**: 42

#### **Issue #6 - Reminders System [FEATURE]**  
**Status: 🔄 PENDENTE** | **Complexidade: Alta** | **Prioridade: 🟡 ALTA**

### **🎯 SUBETAPAS DE EXECUÇÃO (Issue #6 - Reminders)**

#### **6.1 - Domain Layer Reminders**
- [ ] 6.1.1 - Criar entidade Reminder (título, descrição, tipo, recorrência)
- [ ] 6.1.2 - Criar value objects (ReminderType, Frequency, Priority)
- [ ] 6.1.3 - Implementar ReminderSchedule (data/hora, repetições)
- [ ] 6.1.4 - Definir repository interface ReminderRepository
- [ ] 6.1.5 - Business rules para agendamento e recorrência
- [ ] 6.1.6 - Validações de conflito e sobreposição

#### **6.2 - Use Cases Reminders**
- [ ] 6.2.1 - CreateReminderUseCase (CRUD básico)
- [ ] 6.2.2 - GetRemindersUseCase (listagem por data/animal)
- [ ] 6.2.3 - ScheduleReminderUseCase (agendamento inteligente)
- [ ] 6.2.4 - SnoozeReminderUseCase (adiamento)
- [ ] 6.2.5 - MarkReminderCompletedUseCase (marcar concluído)
- [ ] 6.2.6 - GetOverdueRemindersUseCase (lembretes vencidos)

#### **6.3 - Data Layer Reminders**
- [ ] 6.3.1 - Criar ReminderModel (Hive/JSON serialization)
- [ ] 6.3.2 - Implementar ReminderLocalDataSource (Hive)
- [ ] 6.3.3 - Implementar ReminderRemoteDataSource (Firestore)
- [ ] 6.3.4 - Criar ReminderRepositoryImpl
- [ ] 6.3.5 - Sistema de sincronização cross-device
- [ ] 6.3.6 - Cache inteligente e offline first

#### **6.4 - Notification System**
- [ ] 6.4.1 - Integrar Flutter Local Notifications
- [ ] 6.4.2 - Setup Firebase Cloud Messaging (FCM)
- [ ] 6.4.3 - Implementar NotificationService
- [ ] 6.4.4 - Sistema de templates por tipo reminder
- [ ] 6.4.5 - Rich notifications com actions (Done, Snooze)
- [ ] 6.4.6 - Background execution e reliability

#### **6.5 - Integration Layer**
- [ ] 6.5.1 - ReminderFactory para criar lembretes automáticos
- [ ] 6.5.2 - Integração com Vaccines (lembretes vacina)
- [ ] 6.5.3 - Integração com Appointments (lembretes consulta)
- [ ] 6.5.4 - Integração com Medications (lembretes medicação)
- [ ] 6.5.5 - Sistema de categorização automática
- [ ] 6.5.6 - Conflict resolution entre lembretes

#### **6.6 - Presentation Layer**
- [ ] 6.6.1 - Criar RemindersProvider (state management)
- [ ] 6.6.2 - Implementar RemindersPage (dashboard lembretes)
- [ ] 6.6.3 - Criar ReminderFormPage (cadastro/edição)
- [ ] 6.6.4 - CalendarView para visualização mensal
- [ ] 6.6.5 - ReminderCard com actions (snooze, done, edit)
- [ ] 6.6.6 - Notificação in-app + sound/vibration settings

#### **6.7 - Smart Features**
- [ ] 6.7.1 - Implementar ReminderAI (sugestões inteligentes)
- [ ] 6.7.2 - Auto-scheduling baseado em histórico
- [ ] 6.7.3 - Análise padrões usuário (melhor horário)
- [ ] 6.7.4 - Lembretes contextuais (próximo à clínica)
- [ ] 6.7.5 - Integration com calendário sistema
- [ ] 6.7.6 - Bulk operations e templates

**Base para**: Issue #5 (Medications)
**Estimativa**: 2 semanas | **Subetapas**: 42

### 📊 **RESUMO DE PROGRESSO**

| Categoria | Concluído | Pendente | Total | % Complete |
|-----------|-----------|-----------|--------|------------|
| **SECURITY** | 1 | 0 | 1 | ✅ 100% |
| **FEATURE** | 2 | 5 | 7 | 🔄 28.5% |
| **MIGRATION** | 0 | 1 | 1 | 🔄 0% |
| **TOTAL** | 3 | 6 | 9 | 🔄 33.3% |

### 🎯 **ROADMAP RECOMENDADO (PRÓXIMAS 4-6 SEMANAS)**

**Semana 1-2**: Issue #3 - Calculators System (CRÍTICA)
**Semana 3**: Issue #6 - Reminders System  
**Semana 4**: Issue #5 - Medications System
**Semana 5**: Issue #7 - Weight Tracking
**Semana 6**: Issue #8 - Expenses Control

---


#### **Issue #7 - Weight Tracking [FEATURE]**  
**Status: 🔄 PENDENTE** | **Complexidade: Média** | **Prioridade: 🟢 MÉDIA**

### **🎯 SUBETAPAS DE EXECUÇÃO (Issue #7 - Weight Tracking)**

#### **7.1 - Domain Layer Weight**
- [ ] 7.1.1 - Criar entidade WeightRecord (peso, data, observações, IMC)
- [ ] 7.1.2 - Criar entidade WeightGoal (peso alvo, data meta, status)
- [ ] 7.1.3 - Implementar value objects (Weight, BMI, WeightStatus)
- [ ] 7.1.4 - Definir repository interface WeightRepository
- [ ] 7.1.5 - Business rules para metas e progressão
- [ ] 7.1.6 - Algoritmos cálculo peso ideal por espécie/raça

#### **7.2 - Use Cases Weight**
- [ ] 7.2.1 - RecordWeightUseCase (registrar peso)
- [ ] 7.2.2 - GetWeightHistoryUseCase (histórico com filtros)
- [ ] 7.2.3 - SetWeightGoalUseCase (definir meta)
- [ ] 7.2.4 - CalculateBMIUseCase (índice corporal)
- [ ] 7.2.5 - GetWeightStatisticsUseCase (tendências, médias)
- [ ] 7.2.6 - GenerateWeightReportUseCase (relatórios)

#### **7.3 - Data Layer Weight**
- [ ] 7.3.1 - Criar WeightModel (Hive/JSON serialization)
- [ ] 7.3.2 - Implementar WeightLocalDataSource (Hive)
- [ ] 7.3.3 - Implementar WeightRemoteDataSource (Firestore)
- [ ] 7.3.4 - Criar WeightRepositoryImpl
- [ ] 7.3.5 - Sistema sincronização e backup
- [ ] 7.3.6 - Cache otimizado para gráficos

#### **7.4 - Analytics and Charts**
- [ ] 7.4.1 - Integrar fl_chart para gráficos
- [ ] 7.4.2 - Implementar WeightChartService
- [ ] 7.4.3 - Gráficos linha (evolução temporal)
- [ ] 7.4.4 - Gráficos progresso meta
- [ ] 7.4.5 - Estatísticas descritivas (tendências)
- [ ] 7.4.6 - Comparação períodos (mensal, anual)

#### **7.5 - Integration Features**
- [ ] 7.5.1 - Integração com calculadoras (peso ideal)
- [ ] 7.5.2 - Auto-suggestions baseado em peso atual
- [ ] 7.5.3 - Alertas variação significativa peso
- [ ] 7.5.4 - Integration com Reminders (pesagem regular)
- [ ] 7.5.5 - Export dados para veterinário
- [ ] 7.5.6 - Importação dados dispositivos (smart scales)

#### **7.6 - Presentation Layer**
- [ ] 7.6.1 - Criar WeightProvider (state management)
- [ ] 7.6.2 - Implementar WeightDashboardPage
- [ ] 7.6.3 - Criar WeightRecordPage (registrar peso)
- [ ] 7.6.4 - WeightChartPage (visualizações gráficas)
- [ ] 7.6.5 - WeightGoalsPage (metas e progresso)
- [ ] 7.6.6 - Widgets: WeightCard, ProgressIndicator, Chart

**Estimativa**: 1.5 semanas | **Subetapas**: 36

#### **Issue #8 - Expenses Control [FEATURE]**
**Status: 🔄 PENDENTE** | **Complexidade: Média** | **Prioridade: 🟢 MÉDIA**

### **🎯 SUBETAPAS DE EXECUÇÃO (Issue #8 - Expenses)**

#### **8.1 - Domain Layer Expenses**
- [ ] 8.1.1 - Criar entidade Expense (valor, categoria, data, descrição)
- [ ] 8.1.2 - Criar entidade ExpenseCategory (nome, cor, ícone, orçamento)
- [ ] 8.1.3 - Implementar value objects (Money, ExpenseType)
- [ ] 8.1.4 - Definir repository interface ExpenseRepository
- [ ] 8.1.5 - Business rules orçamento e alertas
- [ ] 8.1.6 - Cálculos estatísticos (médias, totais)

#### **8.2 - Use Cases Expenses**
- [ ] 8.2.1 - AddExpenseUseCase (registrar gasto)
- [ ] 8.2.2 - GetExpensesUseCase (listagem com filtros)
- [ ] 8.2.3 - ManageCategoriesUseCase (CRUD categorias)
- [ ] 8.2.4 - SetBudgetUseCase (definir orçamentos)
- [ ] 8.2.5 - GetExpenseStatisticsUseCase (análises)
- [ ] 8.2.6 - GenerateExpenseReportUseCase (relatórios)

#### **8.3 - Data Layer Expenses**
- [ ] 8.3.1 - Criar ExpenseModel (Hive/JSON serialization)
- [ ] 8.3.2 - Implementar ExpenseLocalDataSource (Hive)
- [ ] 8.3.3 - Implementar ExpenseRemoteDataSource (Firestore)
- [ ] 8.3.4 - Criar ExpenseRepositoryImpl
- [ ] 8.3.5 - Sincronização multi-device
- [ ] 8.3.6 - Backup seguro dados financeiros

#### **8.4 - Financial Analytics**
- [ ] 8.4.1 - Implementar ExpenseAnalyticsService
- [ ] 8.4.2 - Gráficos pizza (gastos por categoria)
- [ ] 8.4.3 - Gráficos linha (evolução gastos)
- [ ] 8.4.4 - Análise sazonal (mensal, anual)
- [ ] 8.4.5 - Comparação orçamento vs real
- [ ] 8.4.6 - Projeções e tendências futuras

#### **8.5 - Budget Management**
- [ ] 8.5.1 - Sistema alertas orçamento (80%, 100%, over)
- [ ] 8.5.2 - Notificações gastos elevados
- [ ] 8.5.3 - Sugestões economia baseadas em histórico
- [ ] 8.5.4 - Controle limites por categoria
- [ ] 8.5.5 - Planejamento financeiro (metas anuais)
- [ ] 8.5.6 - Integration com calendário (gastos programados)

#### **8.6 - Reports and Export**
- [ ] 8.6.1 - Export relatórios PDF (mensal, anual)
- [ ] 8.6.2 - Export CSV para planilhas
- [ ] 8.6.3 - Integração compartilhamento (email, drive)
- [ ] 8.6.4 - Relatórios personalizados (período, categoria)
- [ ] 8.6.5 - Templates relatórios veterinário
- [ ] 8.6.6 - Print/save gráficos e estatísticas

#### **8.7 - Presentation Layer**
- [ ] 8.7.1 - Criar ExpensesProvider (state management)
- [ ] 8.7.2 - Implementar ExpensesDashboardPage
- [ ] 8.7.3 - Criar AddExpensePage (registro gastos)
- [ ] 8.7.4 - ExpenseCategoriesPage (gerenciar categorias)
- [ ] 8.7.5 - BudgetPage (orçamentos e metas)
- [ ] 8.7.6 - ReportsPage (relatórios e gráficos)

**Estimativa**: 1.5 semanas | **Subetapas**: 42



### 📊 **RESUMO TOTAL DE SUBETAPAS**

| Issue | Status | Complexidade | Subetapas | Estimativa |
|-------|--------|-------------|-----------|------------|
| **#1 Appointments** | ✅ CONCLUÍDO | Alta | - | - |
| **#2 Vaccines** | ✅ CONCLUÍDO | Alta | - | - |  
| **#3 Calculators** | 🔄 PENDENTE | Muito Alta | **78** | 12 semanas |
| **#4 Auth + Subscriptions** | ✅ CONCLUÍDO | Muito Alta | - | - |
| **#5 Medications** | 🔄 PENDENTE | Alta | **42** | 2 semanas |
| **#6 Reminders** | 🔄 PENDENTE | Alta | **42** | 2 semanas |
| **#7 Weight Tracking** | 🔄 PENDENTE | Média | **36** | 1.5 semanas |
| **#8 Expenses Control** | 🔄 PENDENTE | Média | **42** | 1.5 semanas |
| **TOTAL PENDENTE** | | | **240 subetapas** | **19 semanas** |

### 🎯 **ROADMAP ATUALIZADO**

**Semanas 1-2**: Issue #3 - Calculators System (78 subetapas)
**Semana 3**: Issue #6 - Reminders System (42 subetapas)
**Semana 4**: Issue #5 - Medications System (42 subetapas)
**Semana 5**: Issue #7 - Weight Tracking (36 subetapas)
**Semana 6**: Issue #8 - Expenses Control (42 subetapas)


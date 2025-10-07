# Gerenciamento de Dispositivos - Plantis

**Documento de Implementacao Multi-Device Support**
**Versao:** 1.0
**Data:** 07 de Outubro de 2025
**Status:** Implementado (90%)

---

## Indice

1. [Visao Geral](#visao-geral)
2. [Arquitetura](#arquitetura)
3. [Modelo de Dados](#modelo-de-dados)
4. [Funcionalidades Implementadas](#funcionalidades-implementadas)
5. [Integracao com Firebase](#integracao-com-firebase)
6. [UI/UX](#ui-ux)
7. [Seguranca](#seguranca)
8. [Sincronizacao](#sincronizacao)
9. [Offline-First](#offline-first)
10. [Estado da Implementacao](#estado-da-implementacao)
11. [Casos de Uso](#casos-de-uso)
12. [Gaps e Melhorias](#gaps-e-melhorias)
13. [Recomendacoes](#recomendacoes)
14. [Roadmap](#roadmap)
15. [Atualizacoes e Tarefas](#atualizacoes-e-tarefas)

---

## Visao Geral

O **Gerenciamento de Dispositivos** do Plantis e um sistema robusto que permite aos usuarios gerenciar multiplos dispositivos (smartphones e tablets) associados a sua conta. O sistema oferece controle completo sobre onde o app esta sendo usado, com recursos de seguranca e sincronizacao automatica.

### Objetivos

- Permitir que usuarios usem o Plantis em ate 3 dispositivos simultaneamente
- Fornecer visibilidade completa sobre dispositivos registrados
- Oferecer controle granular de acesso (revogar individual ou em massa)
- Garantir sincronizacao automatica entre dispositivos
- Implementar medidas de seguranca contra uso nao autorizado
- Facilitar recuperacao de conta em caso de perda/roubo de dispositivo

### Stack Tecnologica

- **State Management**: Riverpod (codigo gerado via `@riverpod`)
- **Local Storage**: Hive (via core package)
- **Remote Storage**: Firebase Firestore
- **Device Info**: `device_info_plus` package
- **Architecture**: Clean Architecture + Repository Pattern
- **Error Handling**: `dartz` (Either<Failure, T>)

### Plataformas Suportadas

- **Android**: Totalmente suportado
- **iOS**: Totalmente suportado
- **Web**: Bloqueado intencionalmente (apenas mobile)
- **Desktop**: Bloqueado intencionalmente (apenas mobile)

---

## Arquitetura

### Estrutura de Diretorios

```
apps/app-plantis/
├── lib/
│   ├── features/
│   │   └── device_management/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── device_local_datasource.dart      # Cache Hive
│   │       │   │   └── device_remote_datasource.dart     # Firebase
│   │       │   ├── models/
│   │       │   │   └── device_model.dart                 # Model + conversoes
│   │       │   └── repositories/
│   │       │       └── device_repository_impl.dart       # Implementacao
│   │       ├── domain/
│   │       │   ├── repositories/
│   │       │   │   └── device_repository.dart            # Interface
│   │       │   └── usecases/
│   │       │       ├── get_user_devices_usecase.dart
│   │       │       ├── validate_device_usecase.dart
│   │       │       ├── revoke_device_usecase.dart
│   │       │       ├── update_device_activity_usecase.dart
│   │       │       └── get_device_statistics_usecase.dart
│   │       └── presentation/
│   │           ├── pages/
│   │           │   └── device_management_page.dart       # UI principal
│   │           ├── providers/
│   │           │   ├── device_management_notifier.dart   # State management
│   │           │   ├── device_management_provider.dart   # Provider config
│   │           │   └── device_validation_interceptor.dart # Auto-validation
│   │           └── widgets/
│   │               ├── device_list_widget.dart
│   │               ├── device_tile_widget.dart
│   │               ├── device_actions_widget.dart
│   │               └── device_statistics_widget.dart
│   └── core/
│       └── providers/
│           └── device_management_providers.dart           # Providers globais
│
packages/core/
└── lib/
    └── src/
        ├── domain/
        │   └── entities/
        │       ├── device_entity.dart                     # Entidade base
        │       └── device_statistics.dart                 # Estatisticas
        └── infrastructure/
            └── services/
                └── firebase_device_service.dart           # Service Firebase
```

### Clean Architecture Aplicada

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ DeviceManagementPage (UI)                        │  │
│  │   - TabController (Devices/Statistics)           │  │
│  │   - DeviceListWidget                             │  │
│  │   - DeviceStatisticsWidget                       │  │
│  └──────────────────────────────────────────────────┘  │
│                         ↕                                │
│  ┌──────────────────────────────────────────────────┐  │
│  │ DeviceManagementNotifier (Riverpod)              │  │
│  │   - State: AsyncValue<DeviceManagementState>     │  │
│  │   - Methods: validateDevice, revokeDevice, etc   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Use Cases                                         │  │
│  │   - ValidateDeviceUseCase                        │  │
│  │   - RevokeDeviceUseCase                          │  │
│  │   - GetUserDevicesUseCase                        │  │
│  │   - UpdateDeviceActivityUseCase                  │  │
│  │   - GetDeviceStatisticsUseCase                   │  │
│  └──────────────────────────────────────────────────┘  │
│                         ↕                                │
│  ┌──────────────────────────────────────────────────┐  │
│  │ DeviceRepository (Interface)                     │  │
│  │   - getUserDevices()                             │  │
│  │   - validateDevice()                             │  │
│  │   - revokeDevice()                               │  │
│  │   - updateLastActivity()                         │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                         ↕
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ DeviceRepositoryImpl                             │  │
│  │   - Offline-first strategy                       │  │
│  │   - Cache management                             │  │
│  │   - Error mapping                                │  │
│  └──────────────────────────────────────────────────┘  │
│         ↙                              ↘                 │
│  ┌──────────────────┐       ┌──────────────────────┐   │
│  │ Local DataSource │       │ Remote DataSource    │   │
│  │   - Hive cache   │       │   - Firestore        │   │
│  │   - Memory cache │       │   - Firebase Auth    │   │
│  └──────────────────┘       └──────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Dependency Injection

**GetIt + Injectable** (packages/core):

```dart
@module
abstract class DeviceManagementModule {
  @lazySingleton
  FirebaseDeviceService get firebaseDeviceService;

  @lazySingleton
  DeviceLocalDataSource get deviceLocalDataSource;

  @lazySingleton
  DeviceRemoteDataSource get deviceRemoteDataSource;

  @lazySingleton
  DeviceRepository get deviceRepository;

  // Use Cases
  @lazySingleton
  ValidateDeviceUseCase get validateDeviceUseCase;

  @lazySingleton
  RevokeDeviceUseCase get revokeDeviceUseCase;

  // ... outros use cases
}
```

**Riverpod Providers** (app-plantis):

```dart
@riverpod
ValidateDeviceUseCase validateDeviceUseCase(ValidateDeviceUseCaseRef ref) {
  return getIt<ValidateDeviceUseCase>();
}

@riverpod
class DeviceManagementNotifier extends _$DeviceManagementNotifier {
  // Auto-generated notifier implementation
}
```

---

## Modelo de Dados

### DeviceEntity (Core Package)

**Localizacao:** `packages/core/lib/src/domain/entities/device_entity.dart`

```dart
class DeviceEntity extends Equatable {
  final String id;                      // Firestore document ID
  final String uuid;                    // Device unique identifier
  final String name;                    // Ex: "Samsung Galaxy S23"
  final String model;                   // Ex: "SM-S911B"
  final String platform;                // "Android" ou "iOS"
  final String systemVersion;           // Ex: "Android 14"
  final String appVersion;              // Ex: "1.0.0"
  final String buildNumber;             // Ex: "42"
  final bool isPhysicalDevice;          // true/false (emulator)
  final String manufacturer;            // Ex: "Samsung"
  final DateTime firstLoginAt;          // Primeiro acesso
  final DateTime lastActiveAt;          // Ultima atividade
  final bool isActive;                  // true/false (revogado?)
  final DateTime? createdAt;            // Timestamp criacao
  final DateTime? updatedAt;            // Timestamp atualizacao

  // Propriedades computadas
  bool get isRecentlyActive;            // Ativo nas ultimas 24h
  Duration get inactiveDuration;        // Tempo inativo
  String get displayName;               // Nome formatado para UI
  String get shortPlatform;             // "Android" ou "iOS"
}
```

### DeviceModel (App-Plantis)

**Localizacao:** `apps/app-plantis/lib/features/device_management/data/models/device_model.dart`

Extende `DeviceEntity` com funcionalidades especificas do Plantis:

```dart
class DeviceModel extends DeviceEntity {
  final Map<String, dynamic>? plantisSpecificData;  // Dados extras

  // Conversao
  factory DeviceModel.fromEntity(DeviceEntity entity);
  DeviceEntity toEntity();

  // JSON serialization
  factory DeviceModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();

  // Device info atual
  static Future<DeviceModel?> fromCurrentDevice();

  // UI helpers
  String get platformIcon;              // Emoji da plataforma
  String get statusText;                // "Ativo", "Recente", etc
  String get statusColorHex;            // Cor do status (#4CAF50)
}
```

**Exemplo de Dados:**

```json
{
  "id": "device_abc123",
  "uuid": "android_d8b9e7f6a5c4",
  "name": "Samsung Galaxy S23",
  "model": "SM-S911B",
  "platform": "Android",
  "systemVersion": "Android 14",
  "appVersion": "1.0.0",
  "buildNumber": "42",
  "isPhysicalDevice": true,
  "manufacturer": "Samsung",
  "firstLoginAt": 1704067200000,
  "lastActiveAt": 1733577600000,
  "isActive": true,
  "createdAt": 1704067200000,
  "updatedAt": 1733577600000,
  "plantisSpecificData": {
    "lastSyncVersion": 15,
    "preferredLanguage": "pt_BR"
  }
}
```

### DeviceStatistics (Core Package)

```dart
class DeviceStatistics extends Equatable {
  final int totalDevices;               // Total de dispositivos
  final int activeDevices;              // Dispositivos ativos
  final Map<String, int> devicesByPlatform;  // {"Android": 2, "iOS": 1}
  final DeviceEntity? lastActiveDevice; // Ultimo dispositivo ativo
  final DeviceEntity? oldestDevice;     // Dispositivo mais antigo
  final DeviceEntity? newestDevice;     // Dispositivo mais recente
}
```

### DeviceStatisticsModel (App-Plantis)

```dart
class DeviceStatisticsModel extends DeviceStatistics {
  final Map<String, dynamic>? plantisMetrics;  // Metricas extras

  // UI helpers
  String get summary;                   // "2 de 3 dispositivos ativos"
  String? get mostUsedPlatform;         // "Android"
}
```

---

## Funcionalidades Implementadas

### 1. Deteccao Automatica de Dispositivo Atual

**Status:** Completo
**Localizacao:** `device_model.dart:109-172`

**Como Funciona:**

```dart
final currentDevice = await DeviceModel.fromCurrentDevice();

// Android
if (Platform.isAndroid) {
  final androidInfo = await deviceInfoPlugin.androidInfo;
  return DeviceModel(
    uuid: androidInfo.id,  // Android ID unico
    name: '${androidInfo.brand} ${androidInfo.model}',
    platform: 'Android',
    systemVersion: 'Android ${androidInfo.version.release}',
    // ...
  );
}

// iOS
else if (Platform.isIOS) {
  final iosInfo = await deviceInfoPlugin.iosInfo;
  return DeviceModel(
    uuid: iosInfo.identifierForVendor ?? 'unknown',
    name: iosInfo.name,
    platform: 'iOS',
    systemVersion: '${iosInfo.systemName} ${iosInfo.systemVersion}',
    // ...
  );
}

// Web/Desktop: Bloqueado
else {
  return null;  // Plataforma nao suportada
}
```

**Informacoes Coletadas:**

- Device UUID (Android ID / iOS identifierForVendor)
- Nome do dispositivo
- Modelo e fabricante
- Versao do sistema operacional
- Versao do app Plantis
- Se e dispositivo fisico ou emulador
- Timestamps de criacao e atividade

**Privacidade:**

- Nenhum dado pessoal e coletado
- UUID e especifico do app (reset se app reinstalado)
- Conformidade com LGPD/GDPR

### 2. Registro e Validacao de Dispositivos

**Status:** Completo
**Localizacao:** `validate_device_usecase.dart`

**Fluxo de Validacao:**

```
1. Usuario abre app pela primeira vez
   ↓
2. Sistema detecta dispositivo automaticamente
   ↓
3. Verifica se dispositivo ja esta registrado
   ↓
   [JA REGISTRADO]                [NAO REGISTRADO]
   ↓                              ↓
4a. Atualiza lastActiveAt         4b. Verifica limite (3 dispositivos)
   ↓                              ↓
5a. Retorna success               [DENTRO DO LIMITE]  [LIMITE EXCEDIDO]
                                  ↓                   ↓
                                  5b. Registra        5c. Retorna erro
                                  ↓
                                  6. Sincroniza Firebase
                                  ↓
                                  7. Atualiza cache local
```

**Validacoes Aplicadas:**

```dart
// 1. Plataforma suportada
if (device == null) {
  return DeviceValidationResult(
    isValid: false,
    status: DeviceValidationStatus.unsupportedPlatform,
    message: 'Apenas Android e iOS sao suportados',
  );
}

// 2. Dispositivo ja ativo
if (existingDevice != null && existingDevice.isActive) {
  return DeviceValidationResult(
    isValid: true,
    device: updatedDevice,
    status: DeviceValidationStatus.valid,
    message: 'Dispositivo ja validado',
  );
}

// 3. Limite de dispositivos
if (!canAdd && existingDevice == null) {
  return DeviceValidationResult(
    isValid: false,
    status: DeviceValidationStatus.exceeded,
    message: 'Limite de dispositivos atingido (3/3)',
    remainingSlots: 0,
  );
}

// 4. Validacao no servidor
final validationResult = await repository.validateDevice(
  userId: userId,
  device: device,
);
```

**Estados de Validacao:**

```dart
enum DeviceValidationStatus {
  valid,              // Dispositivo validado com sucesso
  invalid,            // Validacao falhou
  exceeded,           // Limite de dispositivos excedido
  unsupportedPlatform,// Plataforma nao suportada (web/desktop)
}
```

### 3. Listagem de Dispositivos do Usuario

**Status:** Completo
**Localizacao:** `get_user_devices_usecase.dart` + `device_list_widget.dart`

**Estrategia Offline-First:**

```dart
Future<List<DeviceModel>> getUserDevices(String userId) async {
  try {
    // 1. Tentar buscar do servidor
    final remoteResult = await remoteDataSource.getUserDevices(userId);

    return remoteResult.fold(
      // Falhou: usar cache local
      (failure) async {
        return await localDataSource.getUserDevices(userId);
      },

      // Sucesso: atualizar cache e retornar
      (devices) async {
        for (final device in devices) {
          await localDataSource.saveDevice(device);
        }
        return devices;
      },
    );
  } catch (e) {
    return Left(ServerFailure('Erro ao buscar dispositivos'));
  }
}
```

**Dados Retornados:**

- Lista completa de dispositivos (ativos + inativos)
- Ordenacao: Dispositivo atual → Ativos → Inativos
- Separacao em secoes na UI
- Indicacao visual de dispositivo atual

**UI - Device List:**

```dart
// Secao: Dispositivos Ativos
[
  DeviceTile(Samsung Galaxy S23) [ESTE DISPOSITIVO]
  DeviceTile(iPhone 13 Pro)
]

// Secao: Dispositivos Inativos
[
  DeviceTile(OnePlus 9) [REVOGADO]
]
```

### 4. Revogacao Individual de Dispositivo

**Status:** Completo
**Localizacao:** `revoke_device_usecase.dart`

**Fluxo de Revogacao:**

```dart
Future<Either<Failure, void>> revokeDevice(String deviceUuid) async {
  // 1. Validar dispositivo existe
  final device = await repository.getDeviceByUuid(deviceUuid);
  if (device == null) {
    return Left(NotFoundFailure('Dispositivo nao encontrado'));
  }

  // 2. Validar dispositivo esta ativo
  if (!device.isActive) {
    return Left(ValidationFailure('Dispositivo ja revogado'));
  }

  // 3. Prevenir auto-revogacao
  if (params.preventSelfRevoke) {
    final currentDevice = await DeviceModel.fromCurrentDevice();
    if (currentDevice?.uuid == device.uuid) {
      return Left(ValidationFailure('Nao pode revogar dispositivo atual'));
    }
  }

  // 4. Executar revogacao
  return await repository.revokeDevice(
    userId: userId,
    deviceUuid: deviceUuid,
  );
}
```

**Efeitos da Revogacao:**

1. **Firebase**: Marca `isActive = false` no Firestore
2. **Cache Local**: Remove dispositivo do cache
3. **Dispositivo Remoto**: Na proxima sincronizacao:
   - Detecta status revogado
   - Desloga usuario automaticamente
   - Limpa dados locais
   - Exibe mensagem de acesso revogado

**Protecoes:**

- Nao permite revogar dispositivo atual
- Requer confirmacao do usuario
- Apenas usuario autenticado pode revogar seus proprios dispositivos

### 5. Revogacao em Massa (Logout Remoto)

**Status:** Completo
**Localizacao:** `revoke_device_usecase.dart:112-219`

**Funcionalidade:**

Revoga **todos** os outros dispositivos, mantendo apenas o dispositivo atual ativo. Util para:

- Logout remoto em caso de roubo
- Troca de dispositivo principal
- Reset de seguranca

**Implementacao:**

```dart
Future<Either<Failure, RevokeAllResult>> revokeAllOtherDevices() async {
  // 1. Obter UUID do dispositivo atual
  final currentDevice = await DeviceModel.fromCurrentDevice();
  final currentDeviceUuid = currentDevice?.uuid;

  // 2. Listar todos os dispositivos do usuario
  final devicesResult = await repository.getUserDevices(userId);

  // 3. Contar dispositivos que serao revogados
  final deviceCount = devices
    .where((d) => d.isActive && d.uuid != currentDeviceUuid)
    .length;

  // 4. Executar revogacao em massa
  await repository.revokeAllOtherDevices(
    userId: userId,
    currentDeviceUuid: currentDeviceUuid,
  );

  return RevokeAllResult(
    revokedCount: deviceCount,
    message: '$deviceCount dispositivos foram revogados',
  );
}
```

**UI - Dialog de Confirmacao:**

```dart
AlertDialog(
  title: Text('Revogar Outros Dispositivos'),
  content: Text(
    'Isso ira desconectar todos os outros dispositivos (2), '
    'mantendo apenas este dispositivo ativo.\n\n'
    'Esta acao nao pode ser desfeita.',
  ),
  actions: [
    TextButton('Cancelar'),
    ElevatedButton('Revogar Todos', style: red),
  ],
)
```

### 6. Atualizacao de Ultima Atividade

**Status:** Completo
**Localizacao:** `update_device_activity_usecase.dart`

**Quando e Atualizado:**

- App entra em foreground
- Usuario realiza acao significativa (adicionar planta, etc)
- Sincronizacao periodica (a cada 15 minutos)
- Login/autenticacao

**Implementacao:**

```dart
Future<Either<Failure, DeviceModel>> updateLastActivity({
  required String userId,
  required String deviceUuid,
}) async {
  // 1. Buscar dispositivo
  final device = await localDataSource.getDeviceByUuid(deviceUuid);

  // 2. Atualizar timestamp
  final updatedDevice = device.copyWith(
    lastActiveAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 3. Salvar localmente (imediato)
  await localDataSource.saveDevice(updatedDevice);

  // 4. Sincronizar com Firebase (background)
  unawaited(remoteDataSource.updateLastActivity(
    userId: userId,
    deviceUuid: deviceUuid,
  ));

  return Right(updatedDevice);
}
```

**Estrategia:**

- **Local-first**: Atualiza cache local imediatamente
- **Async sync**: Sincroniza com Firebase em background
- **Nao bloqueia UI**: Usuario nao percebe sincronizacao

### 7. Estatisticas de Dispositivos

**Status:** Completo
**Localizacao:** `get_device_statistics_usecase.dart`

**Metricas Calculadas:**

```dart
class DeviceStatisticsModel {
  final int totalDevices;        // Total: 3
  final int activeDevices;       // Ativos: 2
  final int inactiveDevices;     // Inativos: 1

  final Map<String, int> devicesByPlatform;
  // {"Android": 2, "iOS": 1}

  final DeviceModel? lastActiveDevice;
  // Ultimo dispositivo usado: iPhone 13 Pro (ha 2h)

  final DeviceModel? oldestDevice;
  // Dispositivo mais antigo: Galaxy S20 (desde Jan 2024)

  final DeviceModel? newestDevice;
  // Dispositivo mais novo: Galaxy S23 (desde Out 2025)

  // Metricas especificas Plantis
  final Map<String, dynamic>? plantisMetrics;
  // {
  //   'hoursSinceLastActivity': 2,
  //   'isActiveToday': true,
  //   'mostUsedPlatform': 'Android',
  //   'platformDiversity': 2,
  //   'deviceUtilization': 67,  // 2 de 3 ativos = 67%
  //   'hasInactiveDevices': true,
  //   'recommendations': [
  //     'Voce tem 1 dispositivo inativo. Revogue-o para liberar espaco.'
  //   ]
  // }
}
```

**Enhanced Statistics:**

Se `includeExtendedInfo: true`, o use case enriquece os dados com:

- Tempo desde ultima atividade
- Plataforma mais usada
- Diversidade de plataformas
- Taxa de utilizacao de dispositivos
- Recomendacoes inteligentes

**Recomendacoes Geradas:**

```dart
// Limite atingido
if (totalDevices >= 3) {
  'Limite de dispositivos atingido. Considere revogar dispositivos inativos.'
}

// Dispositivos inativos
if (activeDevices < totalDevices) {
  'Voce tem 1 dispositivo inativo. Revogue-o para liberar espaco.'
}

// Multiplas plataformas
if (devicesByPlatform.length > 2) {
  'Voce usa multiplas plataformas. Mantenha apenas os dispositivos que usa regularmente.'
}
```

---

## Integracao com Firebase

### Estrutura no Firestore

**Collection:** `users/{userId}/devices/{deviceId}`

```javascript
{
  // Identificacao
  "id": "device_abc123",
  "uuid": "android_d8b9e7f6a5c4",
  "userId": "user_xyz789",

  // Informacoes do Dispositivo
  "name": "Samsung Galaxy S23",
  "model": "SM-S911B",
  "platform": "Android",
  "systemVersion": "Android 14",
  "manufacturer": "Samsung",
  "isPhysicalDevice": true,

  // Informacoes do App
  "appVersion": "1.0.0",
  "buildNumber": "42",

  // Timestamps
  "firstLoginAt": {".sv": "timestamp"},
  "lastActiveAt": {".sv": "timestamp"},
  "createdAt": {".sv": "timestamp"},
  "updatedAt": {".sv": "timestamp"},

  // Status
  "isActive": true,

  // Metadata (opcional)
  "plantisSpecificData": {
    "lastSyncVersion": 15,
    "preferredLanguage": "pt_BR",
    "notificationSettings": {...}
  }
}
```

### Security Rules

**Recomendacao:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Regra para dispositivos do usuario
    match /users/{userId}/devices/{deviceId} {
      // Usuario so pode ler/escrever seus proprios dispositivos
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;

      // Validacoes em write
      allow create: if request.auth != null
                    && request.auth.uid == userId
                    && request.resource.data.userId == userId
                    && request.resource.data.isActive == true;

      allow update: if request.auth != null
                    && request.auth.uid == userId
                    && resource.data.userId == userId;

      // Delete nao permitido (apenas isActive = false)
      allow delete: if false;
    }

    // Indice composto necessario
    // Collection: users/{userId}/devices
    // Fields: lastActiveAt (Descending), isActive (Ascending)
  }
}
```

### Indices Necessarios

**Firebase Console → Firestore → Indexes → Create Index**

```javascript
// Indice 1: Dispositivos ativos ordenados por atividade
Collection: users/{userId}/devices
Fields:
  - isActive (Ascending)
  - lastActiveAt (Descending)

// Indice 2: Todos os dispositivos ordenados por data de criacao
Collection: users/{userId}/devices
Fields:
  - createdAt (Descending)

// Indice 3: Dispositivos por plataforma
Collection: users/{userId}/devices
Fields:
  - platform (Ascending)
  - lastActiveAt (Descending)
```

### Firebase Device Service (Core Package)

**Localizacao:** `packages/core/lib/src/infrastructure/services/firebase_device_service.dart`

**Metodos Principais:**

```dart
class FirebaseDeviceService {
  // Obter dispositivos do Firestore
  Future<Either<Failure, List<DeviceEntity>>> getDevicesFromFirestore(
    String userId,
  );

  // Validar/registrar dispositivo
  Future<Either<Failure, DeviceEntity>> validateDevice({
    required String userId,
    required DeviceEntity device,
  });

  // Revogar dispositivo
  Future<Either<Failure, void>> revokeDevice({
    required String userId,
    required String deviceUuid,
  });

  // Atualizar ultima atividade
  Future<Either<Failure, DeviceEntity>> updateDeviceLastActivity({
    required String userId,
    required String deviceUuid,
  });

  // Obter contagem de dispositivos ativos
  Future<Either<Failure, int>> getActiveDeviceCount(String userId);
}
```

**Queries Otimizadas:**

```dart
// Query 1: Dispositivos ativos
final devicesQuery = _firestore
  .collection('users/$userId/devices')
  .where('isActive', isEqualTo: true)
  .orderBy('lastActiveAt', descending: true);

// Query 2: Todos os dispositivos
final allDevicesQuery = _firestore
  .collection('users/$userId/devices')
  .orderBy('createdAt', descending: true);

// Query 3: Dispositivo especifico por UUID
final deviceDoc = await _firestore
  .collection('users/$userId/devices')
  .where('uuid', isEqualTo: deviceUuid)
  .limit(1)
  .get();
```

---

## UI/UX

### DeviceManagementPage

**Localizacao:** `presentation/pages/device_management_page.dart`

**Layout:**

```
┌─────────────────────────────────────────┐
│ ← Gerenciar Dispositivos         ⋮ Menu │
│─────────────────────────────────────────│
│ [Dispositivos] [Estatisticas]           │  ← TabBar
│─────────────────────────────────────────│
│                                         │
│ ✓ Status: 2 dispositivos ativos         │  ← Status Card
│ 2/3 dispositivos              [QUASE]   │
│                                         │
│─────────────────────────────────────────│
│                                         │
│ Dispositivos Ativos (2)       Limite: 3 │  ← Section Header
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🤖 Samsung Galaxy S23         [...]  │ │  ← Device Tile
│ │ Android 14 • v1.0.0                  │ │
│ │ Ativo • Este dispositivo             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🍎 iPhone 13 Pro             [...]  │ │
│ │ iOS 17.0 • v1.0.0                    │ │
│ │ Ativo • Usado ha 2 horas             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Dispositivos Inativos (1)               │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ 🤖 OnePlus 9                 [...]  │ │
│ │ Android 13 • v0.9.0                  │ │
│ │ Revogado • Inativo ha 30 dias        │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
                    [+] Validar Dispositivo  ← FAB
```

**Features da UI:**

1. **Tabs:**
   - Dispositivos: Lista completa
   - Estatisticas: Dashboard com metricas

2. **Status Card:**
   - Resumo visual (icone + cor)
   - Contagem de dispositivos ativos
   - Badge de limite (QUASE/LIMITE)

3. **Menu de Opcoes:**
   - Atualizar
   - Revogar outros dispositivos
   - Ajuda

4. **Feedback Messages:**
   - Erro: Banner vermelho dismissible
   - Sucesso: Banner verde dismissible
   - Posicionados no topo da tela

5. **Empty State:**
   - Icone ilustrativo
   - Mensagem explicativa
   - Botao de acao primaria

### Device Tile Widget

**Localizacao:** `presentation/widgets/device_tile_widget.dart`

**Anatomia:**

```
┌─────────────────────────────────────────────┐
│ 🤖  Samsung Galaxy S23               [...]  │  ← Icon + Nome + Menu
│     SM-S911B • Samsung                      │  ← Modelo + Fabricante
│                                             │
│     Android 14 • Plantis 1.0.0              │  ← Sistema + App
│                                             │
│     ✓ Ativo • Este dispositivo              │  ← Status + Badge
│     Ultimo acesso: ha 5 minutos             │  ← Timestamp
└─────────────────────────────────────────────┘
```

**Estados Visuais:**

```dart
// Dispositivo Atual
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.blue, width: 2),
  ),
  child: Badge(
    label: Text('ESTE DISPOSITIVO'),
    backgroundColor: Colors.blue,
  ),
)

// Dispositivo Ativo
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.green.shade200),
  ),
)

// Dispositivo Inativo (Revogado)
Opacity(
  opacity: 0.5,
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
    ),
  ),
)

// Dispositivo sendo revogado
Stack(
  children: [
    DeviceTile(...),
    Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: CircularProgressIndicator(),
      ),
    ),
  ],
)
```

**Acoes Disponiveis:**

```dart
// Menu de contexto
PopupMenuButton(
  items: [
    // Apenas para dispositivos ativos
    if (device.isActive && !isCurrentDevice)
      PopupMenuItem('Revogar'),

    // Sempre disponivel
    PopupMenuItem('Ver detalhes'),
    PopupMenuItem('Copiar UUID'),
  ],
)
```

### Device Details Sheet

**Apresentacao:** Bottom Sheet com scroll

**Secoes:**

```
┌─────────────────────────────────────────┐
│ ━━━━━━                                  │  ← Handle
│                                         │
│ 🤖  Samsung Galaxy S23                  │  ← Header
│     [Ativo]                             │
│                                         │
│ ───────────────────────────────────────┐│
│ Informacoes do Dispositivo             ││
│ ┌─────────────────────────────────────┐││
│ │ Modelo          SM-S911B            │││
│ │ Fabricante      Samsung             │││
│ │ Plataforma      Android 14          │││
│ │ Tipo            Fisico              │││
│ └─────────────────────────────────────┘││
│                                         │
│ Informacoes do App                     ││
│ ┌─────────────────────────────────────┐││
│ │ Versao          1.0.0 (42)          │││
│ │ UUID            android_d8b9e7f...  │││  ← Monospace
│ └─────────────────────────────────────┘││
│                                         │
│ Atividade                              ││
│ ┌─────────────────────────────────────┐││
│ │ Primeiro Login  15/01/2024 14:30    │││
│ │ Ultima Ativid.  07/10/2025 16:45    │││
│ │ Status          Ativo               │││
│ └─────────────────────────────────────┘││
│                                         │
│ [INFO BOX]                             ││  ← Se dispositivo atual
│ 📱 Dispositivo Atual                   ││
│ Este e o dispositivo que voce esta     ││
│ usando agora                           ││
│                                         │
└─────────────────────────────────────────┘
```

### Device Statistics Widget

**Localizacao:** `presentation/widgets/device_statistics_widget.dart`

**Layout:**

```
┌─────────────────────────────────────────┐
│ Estatisticas                            │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Total de Dispositivos               │ │
│ │            3                        │ │  ← Card principal
│ │ 2 ativos • 1 inativo                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Distribuicao por Plataforma            │
│ ┌─────────────────────────────────────┐ │
│ │ 🤖 Android        2 dispositivos    │ │
│ │ ██████████████ 67%                  │ │
│ │                                     │ │
│ │ 🍎 iOS            1 dispositivo     │ │
│ │ ███████ 33%                         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Ultimo Dispositivo Ativo               │
│ ┌─────────────────────────────────────┐ │
│ │ 🤖 Samsung Galaxy S23               │ │
│ │ Usado ha 5 minutos                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Recomendacoes                          │
│ ┌─────────────────────────────────────┐ │
│ │ • Voce tem 1 dispositivo inativo.   │ │
│ │   Revogue-o para liberar espaco.    │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Device Actions Widget

**Localizacao:** `presentation/widgets/device_actions_widget.dart`

**Acoes Rapidas:**

```
┌─────────────────────────────────────────┐
│ Acoes Rapidas                           │
│                                         │
│ ┌─────────────────┐ ┌─────────────────┐ │
│ │  ↻ Atualizar   │ │  🗑 Revogar     │ │
│ │                │ │  Outros         │ │
│ └─────────────────┘ └─────────────────┘ │
└─────────────────────────────────────────┘
```

**Comportamentos:**

- **Atualizar**: Pull-to-refresh ou botao manual
- **Revogar Outros**: Abre dialog de confirmacao
- Desabilitados se houver operacao em andamento

---

## Seguranca

### 1. Validacao de Plataforma

**Restricao:** Apenas Android e iOS

```dart
static Future<DeviceModel?> fromCurrentDevice() async {
  if (Platform.isAndroid) {
    // Permitido
  } else if (Platform.isIOS) {
    // Permitido
  } else {
    // Web, Windows, macOS, Linux: Bloqueado
    debugPrint('Plataforma ${Platform.operatingSystem} nao permitida');
    return null;
  }
}
```

**Motivo:**

- Web: Nao possui UUID persistente confiavel
- Desktop: Fora do escopo do produto
- Gerenciamento simplificado focado em mobile

### 2. Limite de Dispositivos

**Configuracao:** 3 dispositivos ativos simultaneamente

```dart
Future<Either<Failure, bool>> canAddMoreDevices(String userId) async {
  final devicesResult = await getUserDevices(userId);

  return devicesResult.fold(
    (failure) => Left(failure),
    (devices) {
      final activeDevices = devices.where((d) => d.isActive).length;
      final canAdd = activeDevices < 3;  // Limite hardcoded
      return Right(canAdd);
    },
  );
}
```

**Enforcement:**

- Verificado antes de registrar novo dispositivo
- Impedimento no cliente (UI)
- Validacao no servidor (Firebase Rules)

**Configuravel:**

- Para versao premium, o limite pode ser aumentado
- Parametro configuravel via Firebase Remote Config

### 3. Prevencao de Auto-Revogacao

**Protecao:** Usuario nao pode revogar o dispositivo que esta usando

```dart
if (params.preventSelfRevoke) {
  final currentDevice = await DeviceModel.fromCurrentDevice();
  if (currentDevice != null && device.uuid == currentDevice.uuid) {
    return Left(ValidationFailure(
      'Nao e possivel revogar o dispositivo atual',
      code: 'CANNOT_REVOKE_CURRENT_DEVICE',
    ));
  }
}
```

**UI:**

- Dispositivo atual nao exibe opcao "Revogar"
- Se usuario tentar (via API), recebe erro claro
- Snackbar amarela com mensagem explicativa

### 4. Autenticacao Obrigatoria

**Todas as operacoes requerem usuario autenticado:**

```dart
final currentUser = _authStateNotifier.currentUser;
if (currentUser == null) {
  return const Left(AuthFailure('Usuario nao autenticado'));
}
```

**Firebase Rules:**

```javascript
allow read, write: if request.auth != null
                   && request.auth.uid == userId;
```

### 5. Isolamento de Dados

**Princípio:** Usuario X nao pode ver/modificar dispositivos do Usuario Y

**Implementacao:**

```dart
// Query sempre filtra por userId
final devicesQuery = _firestore
  .collection('users/$userId/devices')  // ← userId hardcoded na query
  .where('userId', isEqualTo: userId);   // ← Double-check
```

**Firebase Rules:**

```javascript
// Regra garante que resource.data.userId == request.auth.uid
match /users/{userId}/devices/{deviceId} {
  allow write: if request.auth.uid == userId
               && request.resource.data.userId == userId;
}
```

### 6. Validacao de UUID

**Garantia:** UUID e unico por dispositivo e app

**Android:**

```dart
uuid: androidInfo.id  // Android ID (unico por device + app)
```

**iOS:**

```dart
uuid: iosInfo.identifierForVendor  // Vendor ID (unico por vendor + device)
```

**Caracteristicas:**

- Reseta se app for desinstalado e reinstalado
- Nao e compartilhado entre apps
- Nao identifica usuario pessoalmente

### 7. Rate Limiting (Recomendado)

**Status:** Nao implementado
**Prioridade:** Media

**Recomendacao:**

```javascript
// Firebase Security Rules
match /users/{userId}/devices/{deviceId} {
  allow create: if request.auth.uid == userId
                && request.time > resource.data.lastCreateAt + duration.value(1, 'h');
}
```

**Protecao:**

- Previne registro em massa de dispositivos
- Limite: 1 novo dispositivo por hora

---

## Sincronizacao

### Estrategia: Offline-First + Real-Time Sync

**Principio:** Dados locais sao a fonte primaria da verdade, sincronizacao e transparente

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  Device A   │         │  Firebase   │         │  Device B   │
│   (Local)   │         │ (Firestore) │         │   (Local)   │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │ 1. Operacao Local     │                       │
       │    (instantanea)      │                       │
       │                       │                       │
       │ 2. Sync Background    │                       │
       │──────────────────────>│                       │
       │                       │                       │
       │                       │ 3. Real-time Update   │
       │                       │──────────────────────>│
       │                       │                       │
       │                       │ 4. Update Local Cache │
       │                       │                       │ (Device B)
       │                       │                       │
```

### Cenarios de Sincronizacao

#### Cenario 1: Registro de Novo Dispositivo

```
Device B (novo):
1. Usuario faz login no app
2. Sistema detecta: dispositivo nao registrado
3. Valida no servidor (Firebase)
4. Registra no Firestore: users/{userId}/devices/{deviceB}
5. Salva no cache local

Device A (existente):
1. Recebe notificacao real-time do Firestore
2. Atualiza cache local com novo dispositivo
3. UI atualiza automaticamente (Riverpod stream)
4. Mostra: "Novo dispositivo registrado: iPhone 13 Pro"
```

#### Cenario 2: Revogacao de Dispositivo

```
Device A (revoga Device B):
1. Usuario clica "Revogar" no Device B
2. Atualiza cache local: isActive = false
3. Sincroniza Firebase: deviceB.isActive = false
4. UI atualiza instantaneamente

Device B (revogado):
1. Na proxima sincronizacao (15min ou app foreground)
2. Detecta status revogado no Firebase
3. Atualiza cache local: isActive = false
4. Executa logout automatico
5. Navega para tela de login
6. Exibe mensagem: "Seu acesso foi revogado neste dispositivo"
```

#### Cenario 3: Uso Offline

```
Device A (offline):
1. Usuario tenta listar dispositivos
2. Detecta sem conectividade
3. Usa cache local (ultima sincronizacao)
4. Exibe dispositivos com badge "Dados locais"

Quando voltar online:
1. Sync automatico com Firebase
2. Atualiza cache local
3. UI atualiza com dados frescos
```

### Auto-Sync Timer

**Configuracao:**

```dart
// Sincronizacao automatica a cada 15 minutos
class DeviceManagementNotifier {
  Timer? _syncTimer;

  void startAutoSync() {
    _syncTimer = Timer.periodic(
      Duration(minutes: 15),
      (_) => _syncDevices(),
    );
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
```

**Lifecycle:**

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      // App voltou ao foreground: sincronizar
      notifier.startAutoSync();
      notifier.syncNow();
      break;

    case AppLifecycleState.paused:
      // App foi para background: parar timer
      notifier.stopAutoSync();
      break;
  }
}
```

### Conflict Resolution

**Estrategia:** Last-Write-Wins (baseado em timestamp)

```dart
// Exemplo: Dois devices atualizam o mesmo dispositivo

// Device A: Update as 10:00:00
{
  "lastActiveAt": 1704067200000,
  "updatedAt": 1704067200000
}

// Device B: Update as 10:00:05
{
  "lastActiveAt": 1704067205000,
  "updatedAt": 1704067205000
}

// Resultado: Update do Device B vence (timestamp mais recente)
```

**Implementacao:**

```dart
Future<void> _syncDevices() async {
  final remoteDevices = await remoteDataSource.getUserDevices(userId);
  final localDevices = await localDataSource.getUserDevices(userId);

  for (final remoteDevice in remoteDevices) {
    final localDevice = localDevices.firstWhereOrNull(
      (d) => d.uuid == remoteDevice.uuid,
    );

    // Conflito: versoes diferentes
    if (localDevice != null &&
        remoteDevice.updatedAt.isAfter(localDevice.updatedAt)) {
      // Remote mais recente: sobrescrever local
      await localDataSource.saveDevice(remoteDevice);
    }
  }
}
```

### Listeners Real-Time

**Firebase Firestore Streams:**

```dart
Stream<List<DeviceModel>> watchUserDevices(String userId) {
  return _firestore
    .collection('users/$userId/devices')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => DeviceModel.fromJson(doc.data()))
      .toList()
    );
}
```

**Riverpod Integration:**

```dart
@riverpod
Stream<List<DeviceModel>> userDevices(UserDevicesRef ref) {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(deviceRepositoryProvider).watchUserDevices(userId);
}

// Na UI: atualiza automaticamente
final devices = ref.watch(userDevicesProvider);
```

---

## Offline-First

### Estrategia de Cache

**Dual-Layer Cache:**

1. **Memory Cache:** Dados em RAM para acesso instantaneo
2. **Persistent Cache:** Hive para sobreviver reinicializacao

```dart
class DeviceLocalDataSourceImpl {
  // Memory cache
  final Map<String, List<DeviceModel>> _memoryUserDevicesCache = {};
  final Map<String, DeviceModel> _memoryDevicesCache = {};
  bool _isMemoryCacheInitialized = false;

  // Persistent cache (Hive)
  final ILocalStorageRepository _storageService;
  static const String _devicesBoxKey = 'devices_cache';
  static const String _userDevicesBoxKey = 'user_devices_cache';
}
```

### Cache Initialization

**Lazy Loading:**

```dart
Future<void> _ensureMemoryCacheInitialized() async {
  if (_isMemoryCacheInitialized) return;

  // Carregar do Hive para memoria
  final deviceKeysResult = await _storageService.getKeys(
    box: _devicesBoxKey,
  );

  for (final deviceUuid in deviceKeys) {
    final deviceData = await _storageService.get<Map<String, dynamic>>(
      key: deviceUuid,
      box: _devicesBoxKey,
    );

    if (deviceData != null) {
      final device = DeviceModel.fromJson(deviceData);
      _memoryDevicesCache[deviceUuid] = device;
    }
  }

  _isMemoryCacheInitialized = true;
}
```

### Cache Operations

**Read (3-tier fallback):**

```dart
Future<List<DeviceModel>> getUserDevices(String userId) async {
  try {
    // 1. Tentar Firebase (fonte primaria)
    final remoteResult = await _remoteDataSource.getUserDevices(userId);

    return remoteResult.fold(
      // 2. Falhou: usar cache local
      (failure) async {
        debugPrint('Remote failed, using local cache');
        return await _localDataSource.getUserDevices(userId);
      },

      // 3. Sucesso: atualizar cache e retornar
      (devices) async {
        for (final device in devices) {
          await _localDataSource.saveDevice(device);
        }
        return devices;
      },
    );
  } catch (e) {
    // 4. Erro total: retornar cache ou vazio
    return await _localDataSource.getUserDevices(userId);
  }
}
```

**Write (local-first, sync later):**

```dart
Future<Either<Failure, DeviceModel>> updateLastActivity({
  required String userId,
  required String deviceUuid,
}) async {
  // 1. Atualizar cache local IMEDIATAMENTE
  final device = await _localDataSource.getDeviceByUuid(deviceUuid);
  final updatedDevice = device.copyWith(
    lastActiveAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  await _localDataSource.saveDevice(updatedDevice);

  // 2. Sincronizar com Firebase em background (nao bloqueia)
  unawaited(_remoteDataSource.updateLastActivity(
    userId: userId,
    deviceUuid: deviceUuid,
  ));

  return Right(updatedDevice);
}
```

### Cache Invalidation

**Estrategias:**

1. **Time-Based:** Cache expira apos 1 hora

```dart
Future<DeviceStatistics> getDeviceStatistics(String userId) async {
  final cachedStats = await _storageService.get<Map<String, dynamic>>(
    key: userId,
    box: _statisticsBoxKey,
  );

  if (cachedStats != null) {
    final timestamp = cachedStats['timestamp'] as int?;
    if (timestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      const oneHourInMs = 60 * 60 * 1000;

      if (cacheAge < oneHourInMs) {
        return DeviceStatistics.fromJson(cachedStats);
      }
    }
  }

  // Cache expirado: buscar novo
  return await _fetchFreshStatistics(userId);
}
```

2. **Manual Refresh:** Pull-to-refresh

```dart
// UI
RefreshIndicator(
  onRefresh: () => ref.read(deviceManagementProvider.notifier).refresh(),
  child: DeviceListWidget(),
)

// Notifier
Future<void> refresh() async {
  // Ignorar cache, buscar direto do Firebase
  final devices = await _remoteDataSource.getUserDevices(userId);
  // Atualizar cache
  await _localDataSource.saveUserDevices(userId, devices);
  // Atualizar state
  state = AsyncValue.data(currentState.copyWith(devices: devices));
}
```

3. **Event-Based:** Invalidar ao receber evento Firebase

```dart
// Stream listener
_firestore
  .collection('users/$userId/devices')
  .snapshots()
  .listen((snapshot) {
    // Novos dados do Firebase: invalidar cache
    _localDataSource.clearCache();
    // Recarregar com dados frescos
    loadDevices(refresh: true);
  });
```

### Cache Cleanup

**Clear All:**

```dart
Future<Either<Failure, void>> clearCache() async {
  try {
    // Limpar memoria
    _memoryUserDevicesCache.clear();
    _memoryDevicesCache.clear();

    // Limpar Hive
    await _storageService.clear(box: _devicesBoxKey);
    await _storageService.clear(box: _userDevicesBoxKey);
    await _storageService.clear(box: _statisticsBoxKey);

    // Forcar reinicializacao
    _isMemoryCacheInitialized = false;

    return const Right(null);
  } catch (e) {
    return Left(CacheFailure('Erro ao limpar cache'));
  }
}
```

**Quando Limpar:**

- Logout do usuario
- Troca de conta
- Reset de dados do app
- Erro de corrupcao de cache

---

## Estado da Implementacao

### Funcionalidades 100% Implementadas

#### Completo

1. **Deteccao de Dispositivo Atual** - `device_model.dart:109-172`
   - Android e iOS suportados
   - Bloqueio de web/desktop funcional
   - Coleta de informacoes completa

2. **Validacao de Dispositivos** - `validate_device_usecase.dart`
   - Verificacao de limites
   - Prevencao de duplicatas
   - Integracao Firebase

3. **Listagem de Dispositivos** - `get_user_devices_usecase.dart`
   - Offline-first funcional
   - Cache Hive + Memoria
   - Ordenacao e filtragem

4. **Revogacao Individual** - `revoke_device_usecase.dart:10-109`
   - Validacoes de seguranca
   - Atualizacao Firebase + cache
   - Prevencao auto-revogacao

5. **Revogacao em Massa** - `revoke_device_usecase.dart:112-219`
   - Logout remoto funcional
   - Contagem precisa
   - Dialog de confirmacao

6. **Atualizacao de Atividade** - `update_device_activity_usecase.dart`
   - Local-first implementado
   - Sync background
   - Timestamps precisos

7. **Estatisticas** - `get_device_statistics_usecase.dart`
   - Metricas basicas + avancadas
   - Recomendacoes inteligentes
   - Cache com expiracao

8. **UI Completa** - `device_management_page.dart`
   - Tabs (Devices/Stats)
   - Lista com secoes
   - Details bottom sheet
   - Feedback messages

9. **State Management** - `device_management_notifier.dart`
   - Riverpod com code generation
   - Imutabilidade garantida
   - Lifecycle management

10. **Cache System** - `device_local_datasource.dart`
    - Dual-layer (memoria + Hive)
    - Auto-initialization
    - Cache statistics

### Funcionalidades Parcialmente Implementadas

#### 85% Completo

1. **Device Validation Interceptor** - `device_validation_interceptor.dart`
   - **Status:** Implementado, nao testado em producao
   - **Pendente:**
     - Testes de integracao
     - Validacao em diferentes cenarios
     - Tuning de intervalos

#### 70% Completo

2. **Firebase Security Rules**
   - **Status:** Regras basicas funcionais
   - **Pendente:**
     - Rate limiting
     - Validacao de schema
     - Auditoria de acesso

### Funcionalidades Nao Implementadas

#### 0% Completo

1. **Push Notifications**
   - Notificar usuario sobre novo dispositivo registrado
   - Alerta de revogacao de dispositivo
   - Notificacao de limite atingido

2. **Device Verification (2FA)**
   - Confirmar novo dispositivo via email/SMS
   - Codigo de verificacao temporario
   - Whitelist de dispositivos confiaveis

3. **Geolocation Tracking**
   - Registrar localizacao aproximada de dispositivos
   - Detectar uso em localizacoes incomuns
   - Alerta de atividade suspeita

4. **Session Management**
   - Sessoes ativas por dispositivo
   - Logout remoto de sessao especifica
   - Tempo de sessao configuravel

5. **Device Nicknames**
   - Usuario pode renomear dispositivos
   - Persistencia de nicknames
   - Sincronizacao cross-device

---

## Casos de Uso

### Caso 1: Usuario Compra Novo Celular

**Cenario:**

Usuario tem Plantis instalado no Galaxy S20. Compra Galaxy S23 e quer migrar.

**Fluxo:**

```
1. Usuario instala Plantis no Galaxy S23 (novo)
   ↓
2. Faz login com mesma conta
   ↓
3. Sistema detecta novo dispositivo automaticamente
   ↓
4. Valida: usuario tem 2 dispositivos (S20 + S23), limite nao atingido
   ↓
5. Registra S23 no Firebase
   ↓
6. Usuario agora tem 2 dispositivos ativos
   ↓
7. (Opcional) Usuario pode revogar S20 se nao usar mais
```

**Resultado:**

- S23 funciona normalmente
- S20 continua ativo (se nao revogar)
- Dados sincronizados entre ambos

### Caso 2: Celular e Roubado

**Cenario:**

Usuario tem Plantis no iPhone 13. Celular e roubado.

**Fluxo:**

```
1. Usuario acessa Plantis no iPad (backup)
   ↓
2. Vai em Configuracoes → Gerenciar Dispositivos
   ↓
3. Ve lista de dispositivos:
   - iPad (este dispositivo)
   - iPhone 13 (ativo)
   ↓
4. Clica "..." no iPhone 13 → Revogar
   ↓
5. Confirma revogacao
   ↓
6. iPhone 13 e revogado imediatamente
   ↓
7. Se ladrao tentar usar o Plantis no iPhone 13:
   - Detecta status revogado na proxima sincronizacao
   - App faz logout automatico
   - Exibe: "Acesso revogado neste dispositivo"
```

**Resultado:**

- Ladrao nao tem acesso aos dados
- Usuario continua usando no iPad
- iPhone 13 pode ser re-registrado se recuperado

### Caso 3: Usuario Atinge Limite de Dispositivos

**Cenario:**

Usuario tem Plantis em: Galaxy S23, Galaxy Tab S8, iPhone 13 (3/3). Quer adicionar iPad.

**Fluxo:**

```
1. Usuario instala Plantis no iPad (novo)
   ↓
2. Faz login
   ↓
3. Sistema detecta novo dispositivo
   ↓
4. Valida: usuario tem 3 dispositivos ativos (limite atingido)
   ↓
5. Retorna erro: "Limite de dispositivos atingido (3/3)"
   ↓
6. App exibe mensagem:
   "Voce atingiu o limite de 3 dispositivos.
    Revogue um dispositivo inativo para adicionar este."
   ↓
7. Usuario:
   - Opcao A: Revogar iPhone 13 (se nao usar mais)
   - Opcao B: Revogar Galaxy Tab S8
   ↓
8. Apos revogar, tenta novamente
   ↓
9. iPad e registrado com sucesso
```

**Resultado:**

- Limite e respeitado
- Usuario tem controle sobre quais dispositivos manter
- Processo guiado pela UI

### Caso 4: Logout Remoto de Todos os Dispositivos

**Cenario:**

Usuario suspeita que alguem tem acesso a sua conta. Quer fazer logout de todos os outros dispositivos.

**Fluxo:**

```
1. Usuario abre Plantis no celular principal
   ↓
2. Vai em Configuracoes → Gerenciar Dispositivos
   ↓
3. Clica menu "⋮" → "Revogar Outros Dispositivos"
   ↓
4. Dialog de confirmacao:
   "Isso ira desconectar todos os outros dispositivos (2),
    mantendo apenas este dispositivo ativo.
    Esta acao nao pode ser desfeita."
   ↓
5. Usuario confirma
   ↓
6. Sistema revoga todos os dispositivos exceto o atual
   ↓
7. Nos outros dispositivos:
   - Proxima sincronizacao detecta revogacao
   - Logout automatico
   - Mensagem: "Seu acesso foi revogado"
```

**Resultado:**

- Apenas dispositivo atual permanece ativo
- Todos os outros sao desconectados
- Usuario tem certeza que ninguem mais tem acesso

### Caso 5: Uso Offline

**Cenario:**

Usuario viaja para area sem internet. Quer ver lista de dispositivos.

**Fluxo:**

```
1. Usuario abre Plantis (sem internet)
   ↓
2. Vai em Configuracoes → Gerenciar Dispositivos
   ↓
3. Sistema tenta buscar do Firebase:
   - Detecta sem conectividade
   ↓
4. Usa cache local (ultima sincronizacao)
   ↓
5. Exibe dispositivos com badge: "Dados locais"
   ↓
6. Usuario pode visualizar, mas nao pode:
   - Revogar dispositivos
   - Validar novo dispositivo
   - Ver estatisticas em tempo real
   ↓
7. Quando voltar online:
   - Sync automatico
   - Badge "Dados locais" desaparece
   - Todas as funcionalidades voltam
```

**Resultado:**

- Usuario nao fica bloqueado sem internet
- Dados essenciais disponiveis offline
- Sincronizacao transparente ao voltar online

---

## Gaps e Melhorias

### Criticos (Impedem uso completo)

Nenhum gap critico identificado. Sistema e funcional.

### Importantes (Melhoram experiencia)

#### 1. Push Notifications

**Problema:** Usuario nao e notificado sobre atividades em dispositivos

**Impacto:** Medio - Afeta seguranca

**Solucao Necessaria:**

```dart
// Firebase Cloud Messaging
Future<void> sendDeviceNotification({
  required String userId,
  required String deviceName,
  required String action,
}) async {
  await _fcm.send(
    token: userFcmToken,
    notification: Notification(
      title: 'Plantis - Novo Dispositivo',
      body: '$deviceName foi registrado na sua conta',
    ),
    data: {
      'type': 'device_management',
      'action': action,
      'deviceName': deviceName,
    },
  );
}
```

**Tipos de Notificacao:**

- Novo dispositivo registrado
- Dispositivo revogado
- Limite de dispositivos atingido
- Atividade suspeita detectada

**Estimativa:** 6-8 horas

#### 2. Device Verification (2FA)

**Problema:** Qualquer pessoa com credenciais pode adicionar dispositivos

**Impacto:** Alto - Seguranca

**Solucao Necessaria:**

```dart
// Fluxo de verificacao
Future<void> validateDeviceWithVerification() async {
  // 1. Enviar codigo por email/SMS
  await _sendVerificationCode(userId, email);

  // 2. Usuario insere codigo no app
  final code = await _showCodeInputDialog();

  // 3. Validar codigo
  final isValid = await _verifyCode(userId, code);

  // 4. Se valido, registrar dispositivo
  if (isValid) {
    await _registerDevice();
  }
}
```

**Configuracao:**

- Opcional: usuario escolhe se quer 2FA
- Obrigatorio: para contas premium
- Codigo expira em 10 minutos

**Estimativa:** 12-16 horas

#### 3. Rate Limiting

**Problema:** Sem protecao contra registro em massa

**Impacto:** Medio - Seguranca e performance

**Solucao Necessaria:**

```javascript
// Firebase Security Rules
match /users/{userId}/devices/{deviceId} {
  allow create: if request.auth.uid == userId
                && request.time > resource.data.lastCreateAt + duration.value(1, 'h');
}
```

**Limites Propostos:**

- 1 dispositivo novo por hora
- Maximo 5 tentativas de validacao por dia
- Bloqueio temporario apos 10 falhas

**Estimativa:** 3-4 horas

#### 4. Device Nicknames

**Problema:** Nomes automaticos nao sao personalizaveis

**Impacto:** Baixo - UX

**Solucao Necessaria:**

```dart
class DeviceEntity {
  final String name;          // Auto: "Samsung Galaxy S23"
  final String? nickname;     // User: "Celular Trabalho"

  String get displayName => nickname ?? name;
}

// UI
Future<void> _renameDevice(DeviceModel device) async {
  final nickname = await showDialog<String>(
    context: context,
    builder: (_) => TextInputDialog(
      title: 'Renomear Dispositivo',
      hint: device.name,
    ),
  );

  if (nickname != null) {
    await repository.updateDeviceNickname(
      deviceUuid: device.uuid,
      nickname: nickname,
    );
  }
}
```

**Estimativa:** 4-5 horas

### Desejaveis (Nice-to-Have)

#### 5. Geolocation Tracking

**Descricao:** Registrar localizacao aproximada de dispositivos

**Beneficios:**

- Detectar uso em localizacoes incomuns
- Alerta de atividade suspeita
- Visualizar mapa de dispositivos

**Privacidade:**

- Localizacao aproximada (cidade)
- Opt-in pelo usuario
- Nao rastreamento em tempo real

**Estimativa:** 10-12 horas

#### 6. Session Management

**Descricao:** Gerenciar sessoes ativas por dispositivo

**Funcionalidades:**

- Ver sessoes ativas
- Logout de sessao especifica
- Tempo de sessao configuravel
- Auto-logout por inatividade

**Estimativa:** 8-10 horas

#### 7. Device Usage Analytics

**Descricao:** Dashboard com metricas de uso

**Metricas:**

- Tempo de uso por dispositivo
- Plataforma mais usada
- Historico de atividade
- Padroes de uso

**Estimativa:** 12-16 horas

#### 8. Export Device Data

**Descricao:** Exportar historico de dispositivos

**Formatos:**

- JSON
- CSV
- PDF (relatorio)

**Conteudo:**

- Lista de dispositivos
- Historico de atividade
- Eventos de revogacao
- Estatisticas

**Estimativa:** 4-6 horas

---

## Recomendacoes

### 1. Performance

#### Cache Optimization

**Recomendacao:** Implementar cache warming

```dart
class DeviceCacheWarmer {
  // Pre-carregar cache durante splash screen
  Future<void> warmCache(String userId) async {
    await Future.wait([
      _preloadUserDevices(userId),
      _preloadStatistics(userId),
      _preloadCurrentDevice(),
    ]);
  }
}
```

**Beneficio:** Reduz tempo de carregamento inicial

#### Query Optimization

**Recomendacao:** Limitar dados retornados

```dart
// Antes: Busca todos os campos
final devices = await _firestore
  .collection('users/$userId/devices')
  .get();

// Depois: Apenas campos necessarios
final devices = await _firestore
  .collection('users/$userId/devices')
  .select(['uuid', 'name', 'platform', 'isActive', 'lastActiveAt'])
  .get();
```

**Beneficio:** Reduz bandwidth e melhora performance

### 2. UX/UI

#### Loading States Granulares

**Recomendacao:** Feedback contextual

```dart
enum DeviceLoadingContext {
  initialLoad,     // Carregando dispositivos...
  validating,      // Validando dispositivo...
  revoking,        // Revogando acesso...
  syncing,         // Sincronizando...
}
```

**Beneficio:** Usuario sabe exatamente o que esta acontecendo

#### Skeleton Screens

**Recomendacao:** Placeholders enquanto carrega

```dart
Widget _buildDevicesSkeleton() {
  return Column(
    children: List.generate(3, (index) =>
      Shimmer.fromColors(
        child: DeviceTileSkeletonWidget(),
      ),
    ),
  );
}
```

**Beneficio:** Percepcao de performance melhorada

#### Empty States Melhorados

**Recomendacao:** Ilustracoes e mensagens claras

```dart
Widget _buildEmptyState() {
  return EmptyStateWidget(
    illustration: Assets.images.noDevices,
    title: 'Nenhum dispositivo registrado',
    subtitle: 'Este e seu primeiro dispositivo. Voce pode adicionar ate 3.',
    action: ElevatedButton(
      onPressed: _validateCurrentDevice,
      child: Text('Registrar Este Dispositivo'),
    ),
  );
}
```

**Beneficio:** Guia usuario na acao correta

### 3. Seguranca

#### Audit Logging

**Recomendacao:** Log completo de operacoes

```dart
Future<void> _logDeviceOperation({
  required String userId,
  required String operation,
  required Map<String, dynamic> metadata,
}) async {
  await _firestore.collection('device_audit_logs').add({
    'userId': userId,
    'operation': operation,  // 'register', 'revoke', 'update'
    'metadata': metadata,
    'timestamp': FieldValue.serverTimestamp(),
    'ipAddress': await _getIpAddress(),
  });
}
```

**Beneficio:** Rastreabilidade e deteccao de anomalias

#### Anomaly Detection

**Recomendacao:** Detectar padroes suspeitos

```dart
class AnomalyDetector {
  Future<bool> detectSuspiciousActivity({
    required String userId,
    required DeviceModel device,
  }) async {
    // 1. Muitos dispositivos em curto periodo
    final recentDevices = await _getDevicesRegisteredInLast24Hours(userId);
    if (recentDevices.length > 3) return true;

    // 2. Localizacao incomum (se implementado)
    if (device.location != null && !_isKnownLocation(device.location)) {
      return true;
    }

    // 3. Dispositivo emulador (suspeito)
    if (!device.isPhysicalDevice) return true;

    return false;
  }
}
```

**Beneficio:** Prevencao de fraudes e acessos nao autorizados

### 4. Testes

#### Testes Unitarios

**Recomendacao:** Cobertura minima de 80%

```dart
// test/features/device_management/usecases/validate_device_usecase_test.dart
void main() {
  group('ValidateDeviceUseCase', () {
    test('should validate new device successfully', () async { });
    test('should return error when limit exceeded', () async { });
    test('should update activity for existing device', () async { });
    test('should block unsupported platforms', () async { });
    test('should handle network failures gracefully', () async { });
  });
}
```

**Estimativa:** 16-20 horas para cobertura completa

#### Testes de Integracao

**Recomendacao:** Testar fluxos completos

```dart
testWidgets('Device management flow', (tester) async {
  // 1. Login
  await tester.pumpWidget(MyApp());
  await _performLogin(tester);

  // 2. Navigate to device management
  await tester.tap(find.text('Gerenciar Dispositivos'));
  await tester.pumpAndSettle();

  // 3. Validate current device
  await tester.tap(find.text('Validar Dispositivo'));
  await tester.pumpAndSettle();

  // 4. Verify device appears in list
  expect(find.text('Samsung Galaxy S23'), findsOneWidget);
});
```

**Estimativa:** 12-16 horas

### 5. Monitoramento

#### Firebase Analytics

**Recomendacao:** Eventos customizados

```dart
// Eventos de dispositivos
await _analytics.logEvent('device_validated');
await _analytics.logEvent('device_revoked', parameters: {
  'device_platform': device.platform,
  'days_since_registration': daysSinceRegistration,
});
await _analytics.logEvent('device_limit_reached');
```

**Metricas:**

- Taxa de validacao de dispositivos
- Tempo medio ate primeiro dispositivo adicional
- Taxa de revogacao por plataforma
- Usuarios com multiplos dispositivos

#### Crashlytics

**Recomendacao:** Logs contextuais

```dart
try {
  await _validateDevice();
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Device validation failed');
  FirebaseCrashlytics.instance.setCustomKey('device_uuid', device.uuid);
  FirebaseCrashlytics.instance.setCustomKey('platform', device.platform);
  rethrow;
}
```

**Beneficio:** Debug facilitado em producao

---

## Roadmap

### Fase 1: Fundacao (Completo)

**Status:** 100%
**Duracao:** 3 semanas

- [x] Entidade DeviceEntity (core)
- [x] Repository pattern implementado
- [x] Use cases principais
- [x] Data sources (local + remote)
- [x] State management (Riverpod)
- [x] UI completa
- [x] Cache offline-first

### Fase 2: Melhorias Importantes (Em Planejamento)

**Status:** 0%
**Duracao Estimada:** 3 semanas

**Sprint 1 - Seguranca (1 semana):**

- [ ] Push notifications (6-8h)
- [ ] Rate limiting (3-4h)
- [ ] Audit logging (4-5h)

**Sprint 2 - UX (1 semana):**

- [ ] Device nicknames (4-5h)
- [ ] Loading states melhorados (3-4h)
- [ ] Skeleton screens (2-3h)
- [ ] Empty states ilustrados (2-3h)

**Sprint 3 - Testes (1 semana):**

- [ ] Testes unitarios core (16-20h)
- [ ] Testes de integracao (12-16h)

### Fase 3: Features Avancadas (Futuro)

**Status:** 0%
**Duracao Estimada:** 4 semanas

**Sprint 1 - Device Verification (1.5 semanas):**

- [ ] 2FA para novos dispositivos (12-16h)
- [ ] Email/SMS verification (8-10h)
- [ ] UI de verificacao (4-6h)

**Sprint 2 - Analytics (1 semana):**

- [ ] Device usage analytics (12-16h)
- [ ] Dashboard visual (8-10h)

**Sprint 3 - Session Management (1 semana):**

- [ ] Sessoes ativas (8-10h)
- [ ] Logout de sessao especifica (4-6h)

**Sprint 4 - Geolocation (0.5 semana):**

- [ ] Tracking de localizacao (10-12h)
- [ ] Deteccao de anomalias (6-8h)

### Fase 4: Otimizacao (Continuo)

**Duracao:** Continua

- [ ] Performance optimization
- [ ] A/B testing de UX
- [ ] Analytics avancado
- [ ] Machine learning para deteccao de fraudes

---

## Atualizacoes e Tarefas

### Log de Atualizacoes

#### v1.0 - 07/10/2025

- Documento inicial criado
- Analise completa da implementacao
- Identificacao de gaps
- Roadmap definido
- Recomendacoes documentadas

---

### Tarefas Prioritarias

#### Importante (Proximas 2 Semanas)

1. **[DM-001] Implementar Push Notifications**
   - **Estimativa:** 8 horas
   - **Responsavel:** TBD
   - **Criterio de Aceite:**
     - [ ] Notificacao de novo dispositivo
     - [ ] Notificacao de revogacao
     - [ ] Configuracoes de notificacao
     - [ ] Testado em iOS e Android

2. **[DM-002] Adicionar Rate Limiting**
   - **Estimativa:** 4 horas
   - **Responsavel:** TBD
   - **Criterio de Aceite:**
     - [ ] Firebase Rules com rate limiting
     - [ ] Limite: 1 dispositivo/hora
     - [ ] Mensagem de erro clara
     - [ ] Testado em staging

3. **[DM-003] Implementar Testes Unitarios**
   - **Estimativa:** 20 horas
   - **Responsavel:** TBD
   - **Cobertura Alvo:** ≥80%
   - **Arquivos:**
     - [ ] `validate_device_usecase_test.dart`
     - [ ] `revoke_device_usecase_test.dart`
     - [ ] `device_repository_impl_test.dart`
     - [ ] `device_local_datasource_test.dart`
     - [ ] `device_remote_datasource_test.dart`

#### Desejavel (Proximo Mes)

4. **[DM-004] Device Nicknames**
   - **Estimativa:** 5 horas
   - **Responsavel:** TBD
   - **Criterio de Aceite:**
     - [ ] Usuario pode renomear dispositivo
     - [ ] Nickname sincroniza cross-device
     - [ ] UI de edicao implementada

5. **[DM-005] Device Verification (2FA)**
   - **Estimativa:** 16 horas
   - **Responsavel:** TBD
   - **Criterio de Aceite:**
     - [ ] Codigo via email/SMS
     - [ ] UI de verificacao
     - [ ] Configuracao opcional
     - [ ] Testado em producao

6. **[DM-006] Melhorar UX (Skeletons + Empty States)**
   - **Estimativa:** 8 horas
   - **Responsavel:** TBD
   - **Criterio de Aceite:**
     - [ ] Skeleton screens
     - [ ] Empty states com ilustracoes
     - [ ] Loading states contextuais

---

### Backlog

- [ ] **[DM-007]** Geolocation Tracking
- [ ] **[DM-008]** Session Management
- [ ] **[DM-009]** Device Usage Analytics
- [ ] **[DM-010]** Export Device Data
- [ ] **[DM-011]** Anomaly Detection
- [ ] **[DM-012]** Audit Logging
- [ ] **[DM-013]** Testes de Integracao
- [ ] **[DM-014]** Performance Optimization
- [ ] **[DM-015]** A/B Testing de UX

---

### Questoes em Aberto

1. **Limite de Dispositivos:**
   - Manter limite de 3 para free tier?
   - Aumentar para premium? Quanto?
   - Permitir configuracao via Remote Config?

2. **Device Verification:**
   - Tornar 2FA obrigatorio para todos?
   - Apenas para contas premium?
   - Opcional com incentivo?

3. **Geolocation:**
   - Implementar tracking de localizacao?
   - Concerns de privacidade?
   - Opt-in ou opt-out?

4. **Infraestrutura:**
   - Firebase Emulator para testes locais?
   - Staging environment separado?
   - CI/CD para testes automatizados?

---

### Metricas de Sucesso

#### KPIs Tecnicos

- [ ] Cobertura de testes ≥80%
- [ ] Tempo de carregamento <2s
- [ ] Taxa de erro em operacoes <1%
- [ ] Latencia de sync <3s
- [ ] 0 crashes relacionados

#### KPIs de Produto

- [ ] ≥70% usuarios tem multiplos dispositivos
- [ ] Taxa de revogacao <5%/mes
- [ ] Tempo medio para adicionar dispositivo <30s
- [ ] Satisfacao do usuario ≥4.5/5

#### KPIs de Seguranca

- [ ] 0 acessos nao autorizados
- [ ] Tempo de resposta a incidentes <2h
- [ ] 100% operacoes logadas
- [ ] Taxa de deteccao de anomalias ≥90%

---

## Referencias

### Documentacao Oficial

- [device_info_plus](https://pub.dev/packages/device_info_plus)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Database](https://docs.hivedb.dev/)

### Arquivos do Projeto

**Core Package:**

- `packages/core/lib/src/domain/entities/device_entity.dart`
- `packages/core/lib/src/infrastructure/services/firebase_device_service.dart`

**App Plantis:**

- `apps/app-plantis/lib/features/device_management/data/models/device_model.dart`
- `apps/app-plantis/lib/features/device_management/domain/repositories/device_repository.dart`
- `apps/app-plantis/lib/features/device_management/presentation/pages/device_management_page.dart`
- `apps/app-plantis/lib/features/device_management/presentation/providers/device_management_notifier.dart`

### Benchmarks

- **WhatsApp:** Multi-device support (ate 4 dispositivos)
- **Telegram:** Session management avancado
- **Google Account:** Security checkup de dispositivos
- **Notion:** Logout remoto bem implementado

---

**Documento Vivo:** Este documento sera atualizado conforme o projeto evolui. Ultima atualizacao: 07/10/2025.

# 📱 Análise de Gerenciamento de Dispositivos - Monorepo

## 📊 Resumo Executivo

Analisei as implementações de gerenciamento de dispositivos em **3 apps** (app-plantis, app-gasometer, app-receituagro) e no **packages/core**.

### Estado Atual (Atualizado em 2025-12-23)

| Componente | Situação | Usa Core? | Nível de Integração |
|-----------|----------|-----------|---------------------|
| **packages/core** | ✅ Completo | N/A | Base de código |
| **app-plantis** | ✅ Bom | Sim | 🟢 Alta (90%) |
| **app-gasometer** | ✅ Bom | Sim | 🟢 Alta (85%) |
| **app-receituagro** | ✅ Migrado | Sim | 🟢 Alta (90%) |

---

## ✅ IMPLEMENTAÇÃO CONCLUÍDA

### Fase 1: DeviceIdentityService no Core ✅

O `DeviceIdentityService` foi criado no packages/core em:
`packages/core/lib/src/infrastructure/services/device_identity_service.dart`

**Funcionalidades:**
- `getDeviceUuid()` - Obtém UUID único do dispositivo
- `getCurrentDeviceEntity()` - Retorna DeviceEntity com informações completas
- `refreshDeviceInfo()` - Força atualização
- `hasDeviceChanged()` - Detecta mudanças no dispositivo
- `clearStoredData()` - Limpa dados (logout)

**Provider disponível:**
```dart
// packages/core - device_management_providers.dart
final deviceIdentityServiceProvider = Provider<DeviceIdentityService>((ref) {
  return DeviceIdentityService.instance;
});
```

### Fase 2: app-receituagro Migrado ✅

**Alterações realizadas:**

1. **`device_identity_service.dart`** - Agora re-exporta do core
   ```dart
   export 'package:core/core.dart' show DeviceIdentityService, DeviceEntity;
   typedef DeviceInfo = DeviceEntity;  // Alias para compatibilidade
   ```

2. **`core_providers.dart`** - Usa DeviceIdentityService do core
   ```dart
   final deviceIdentityServiceProvider = Provider<core.DeviceIdentityService>((ref) {
     return core.DeviceIdentityService.instance;
   });
   ```

3. **`auth_notifier.dart`** - Atualizado para usar `getCurrentDeviceEntity()`

4. **`settings_state.dart`** - Simplificado (DeviceInfo agora é alias para DeviceEntity)

5. **`settings_providers.dart`** - Usa DeviceIdentityService do core

6. **`auth_session_manager.dart`** - Usa DeviceIdentityService do core

---

## 🏗️ Arquitetura no packages/core

### Entidades e Configuração

```
packages/core/lib/src/
├── domain/
│   ├── entities/
│   │   ├── device_entity.dart          ✅ Entidade principal
│   │   └── device_limit_config.dart    ✅ Configuração de limites
│   ├── repositories/
│   │   └── i_device_repository.dart    ✅ Interface do repositório
│   └── usecases/
│       └── validate_device_usecase.dart ✅ Use case de validação
├── infrastructure/
│   ├── services/
│   │   ├── device_management_service.dart  ✅ Serviço de alto nível
│   │   └── firebase_device_service.dart    ✅ Integração Firebase
│   └── repositories/
│       └── device_repository_impl.dart     ✅ Implementação do repo
└── riverpod/
    └── domain/
        └── device/
            └── device_management_providers.dart ✅ Providers Riverpod
```

### DeviceLimitConfig (Configuração Flexível)

```dart
DeviceLimitConfig({
  maxMobileDevices: 3,        // Limite mobile free
  maxWebDevices: -1,          // Web ilimitado
  countWebInLimit: false,     // Web NÃO conta
  premiumMaxMobileDevices: 6, // Limite mobile premium
  allowEmulators: true,
  inactivityDaysForCleanup: 90,
});
```

### Providers Disponíveis no Core

| Provider | Descrição | Status |
|----------|-----------|--------|
| `deviceLimitConfigProvider` | Configuração de limites | ✅ Override disponível |
| `deviceRepositoryProvider` | Repository unificado | ✅ Requer override |
| `userDevicesFromRepositoryProvider` | Lista de dispositivos | ✅ Funcional |
| `canAddMoreDevicesProvider` | Verificação de limite | ✅ Funcional |
| `deviceStatisticsProvider` | Estatísticas | ✅ Funcional |
| `currentDeviceProvider` | Dispositivo atual | ⚠️ Placeholder |
| `deviceManagementProvider` | Notifier principal | ✅ Funcional |

---

## 📱 Implementação por App

### 1. app-plantis (🟢 Melhor Implementação)

**Nível de Integração: 90%**

#### Estrutura
```
app-plantis/lib/features/device_management/
├── data/
│   └── models/device_model.dart
├── presentation/
│   ├── managers/
│   │   ├── device_dialog_manager.dart
│   │   ├── device_menu_action_handler.dart
│   │   └── device_status_builder.dart
│   ├── pages/
│   │   └── device_management_page.dart
│   ├── providers/
│   │   ├── device_management_provider.dart
│   │   ├── device_management_providers.dart    ✅ USA CORE
│   │   ├── device_services_providers.dart
│   │   └── device_validation_interceptor.dart
│   └── widgets/
│       ├── device_actions_widget.dart
│       ├── device_list_widget.dart
│       ├── device_statistics_widget.dart
│       └── device_tile_widget.dart
└── device_management.dart  ✅ Re-exporta do core
```

#### Pontos Positivos
- ✅ Re-exporta entidades do core corretamente
- ✅ Usa `DeviceManagementService` do core
- ✅ Configura `DeviceLimitConfig` específico via provider
- ✅ Widgets de UI reutilizáveis
- ✅ Barrel file bem organizado

#### Configuração de Providers
```dart
@riverpod
DeviceLimitConfig plantisDeviceLimitConfig(Ref ref) {
  return const DeviceLimitConfig(
    maxMobileDevices: 3,
    premiumMaxMobileDevices: 6,
    // ... customizado para plantis
  );
}

@riverpod
DeviceManagementService plantisDeviceManagementService(Ref ref) {
  // Usa FirebaseDeviceService do core
  return DeviceManagementService(
    firebaseDeviceService: ...,
    authService: ...,
    analyticsService: ...,
    deviceRepository: ...,
  );
}
```

---

### 2. app-gasometer (🟢 Boa Implementação)

**Nível de Integração: 85%**

#### Estrutura
```
app-gasometer/lib/features/device_management/
├── core/
├── di/
├── domain/
│   ├── entities/
│   └── extensions/
│       └── vehicle_device_extension.dart  ✅ Extensão customizada
└── presentation/
    └── providers/
        └── vehicle_device_notifier.dart    ✅ USA CORE
```

#### Pontos Positivos
- ✅ Usa `core.DeviceManagementService` diretamente
- ✅ Extensões específicas para veículos (`VehicleDeviceExtension`)
- ✅ State customizado (`VehicleDeviceState`) com lógica de negócio
- ✅ Integração com connectivity para offline

#### Características Únicas
```dart
// Extensões específicas para veículos
extension VehicleDeviceExtension on DeviceEntity {
  bool get canAccessVehicle => isActive;
  bool get canAccessFinancialData => isPhysicalDevice && isActive;
  int get syncPriority => ...;
  bool get canSyncOfflineData => ...;
}

// State customizado com funcionalidades veiculares
class VehicleDeviceState {
  List<DeviceEntity> get activeDevices => ...;
  List<DeviceEntity> get trustedDevices => ...;
  DeviceEntity? get currentDevice => ...;
}
```

#### Diferenças do Padrão
- ⚠️ Limite hardcoded `_deviceLimit = 3` ao invés de usar provider
- ⚠️ `VehicleDeviceStatistics` customizado ao invés de `DeviceStatistics` do core

---

### 3. app-receituagro (🟡 Implementação Parcial)

**Nível de Integração: 50%**

#### Estrutura
```
app-receituagro/lib/
├── core/services/
│   └── device_identity_service.dart    ⚠️ DUPLICADO do core
├── features/settings/
│   ├── data/datasources/
│   │   ├── device_local_datasource.dart
│   │   └── device_remote_datasource.dart  ✅ USA CORE parcialmente
│   ├── pages/
│   │   └── profile_page.dart
│   └── widgets/dialogs/
│       └── device_management_dialog.dart  ⚠️ USA DeviceInfo local
```

#### Problemas Identificados

1. **DeviceIdentityService Duplicado**
   - `app-receituagro` tem seu próprio `DeviceIdentityService`
   - Gera `DeviceInfo` (classe local) ao invés de `DeviceEntity` (core)
   - Duplicação de código de ~400 linhas

2. **DeviceInfo vs DeviceEntity**
   ```dart
   // app-receituagro usa classe local:
   class DeviceInfo {
     final String uuid;
     final String name;
     // ... campos similares ao DeviceEntity
   }
   
   // Core usa:
   class DeviceEntity {
     final String id;
     final String uuid;
     // ... campos mais completos
   }
   ```

3. **Dialog com Dynamic**
   ```dart
   class DeviceManagementDialog extends ConsumerWidget {
     final dynamic settingsData;  // ⚠️ Tipo dinâmico
     
     List<DeviceInfo> _extractDevices(dynamic data) {
       // Extração frágil com dynamic
     }
   }
   ```

4. **Funcionalidade Desabilitada**
   ```dart
   Future<void> _revokeDevice(...) async {
     await showDialog<void>(
       // "Recurso em Desenvolvimento" - não funciona!
     );
   }
   ```

---

## 🎯 Plano de Padronização

### Fase 1: Consolidar DeviceIdentityService no Core

**Ação:** Mover `DeviceIdentityService` do app-receituagro para o core

```dart
// packages/core/lib/src/infrastructure/services/device_identity_service.dart
class DeviceIdentityService {
  static DeviceIdentityService? _instance;
  static DeviceIdentityService get instance => _instance ??= DeviceIdentityService._();
  
  Future<String> getDeviceUuid() async { ... }
  Future<DeviceEntity> getDeviceInfo() async { ... }  // Retorna DeviceEntity!
  Future<bool> hasDeviceChanged() async { ... }
}
```

### Fase 2: Remover DeviceInfo Local

**Ação:** Substituir `DeviceInfo` por `DeviceEntity` no app-receituagro

```dart
// ANTES (app-receituagro)
class DeviceInfo { ... }

// DEPOIS
export 'package:core/core.dart' show DeviceEntity;
// Usar DeviceEntity diretamente
```

### Fase 3: Criar Provider Padrão para currentDevice

**Ação:** Implementar `currentDeviceProvider` funcional no core

```dart
@riverpod
Future<DeviceEntity> currentDevice(Ref ref) async {
  final deviceIdentityService = ref.watch(deviceIdentityServiceProvider);
  return await deviceIdentityService.getDeviceInfo();
}
```

### Fase 4: Padronizar Configuração de Limites

**Ação:** Todos os apps devem overridar `deviceLimitConfigProvider`

```dart
// Em cada app (main.dart ou providers.dart)
@riverpod
DeviceLimitConfig appDeviceLimitConfig(Ref ref) {
  return const DeviceLimitConfig(
    maxMobileDevices: 3,
    premiumMaxMobileDevices: 6,
    // ... configuração específica do app
  );
}

// Override no ProviderScope
ProviderScope(
  overrides: [
    deviceLimitConfigProvider.overrideWithProvider(appDeviceLimitConfigProvider),
  ],
  child: App(),
)
```

### Fase 5: Ativar Device Management no app-receituagro

**Ação:** Implementar funcionalidade completa

```dart
class DeviceManagementDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(userDevicesFromRepositoryProvider);
    final canAdd = ref.watch(canAddMoreDevicesProvider);
    
    return devicesAsync.when(
      data: (devices) => _buildDeviceList(devices),
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Erro: $e'),
    );
  }
  
  Future<void> _revokeDevice(WidgetRef ref, DeviceEntity device) async {
    final service = ref.read(deviceManagementServiceProvider);
    await service.revokeDevice(device.uuid);
    ref.invalidate(userDevicesFromRepositoryProvider);
  }
}
```

---

## 📋 Checklist de Padronização

### packages/core
- [ ] Mover `DeviceIdentityService` para core
- [ ] Criar provider `deviceIdentityServiceProvider`
- [ ] Implementar `currentDeviceProvider` funcional
- [ ] Exportar tudo no `core.dart`

### app-plantis
- [ ] ✅ Já está padronizado (modelo a seguir)
- [ ] Verificar se usa `deviceIdentityServiceProvider` do core

### app-gasometer
- [ ] Remover `_deviceLimit` hardcoded
- [ ] Usar `deviceLimitConfigProvider` para limites
- [ ] Considerar usar `DeviceStatistics` do core

### app-receituagro
- [ ] Remover `DeviceIdentityService` local
- [ ] Remover classe `DeviceInfo` local
- [ ] Usar `DeviceEntity` do core
- [ ] Refatorar `DeviceManagementDialog` para usar providers do core
- [ ] Implementar funcionalidade de revoke real
- [ ] Criar providers específicos como plantis

---

## 🏆 Padrão Recomendado (Baseado em app-plantis)

### Estrutura de Pasta
```
features/device_management/
├── data/
│   └── models/           # Modelos/extensões específicos do app
├── presentation/
│   ├── managers/         # Lógica de UI complexa
│   ├── pages/            # Páginas
│   ├── providers/        # Providers específicos do app
│   └── widgets/          # Widgets reutilizáveis
└── device_management.dart # Barrel file com re-exports do core
```

### Barrel File Padrão
```dart
/// Device Management Feature Export
library;

// Re-export core device management
export 'package:core/core.dart'
    show
        DeviceEntity,
        DeviceStatistics,
        DeviceLimitConfig,
        DeviceManagementService,
        IDeviceRepository,
        deviceLimitConfigProvider,
        userDevicesFromRepositoryProvider,
        canAddMoreDevicesProvider,
        deviceStatisticsProvider,
        DeviceValidationResult;

// Exports específicos do app
export 'data/models/app_specific_device_model.dart';
export 'presentation/pages/device_management_page.dart';
export 'presentation/providers/app_device_providers.dart';
export 'presentation/widgets/device_list_widget.dart';
```

### Provider Pattern
```dart
// 1. Configuração de limites (override do core)
@riverpod
DeviceLimitConfig appDeviceLimitConfig(Ref ref) {
  return const DeviceLimitConfig(
    maxMobileDevices: 3,
    premiumMaxMobileDevices: 10,
  );
}

// 2. Service configurado para o app
@riverpod
DeviceManagementService appDeviceManagementService(Ref ref) {
  final config = ref.watch(appDeviceLimitConfigProvider);
  return DeviceManagementService(
    firebaseDeviceService: FirebaseDeviceService(limitConfig: config),
    authService: ref.watch(firebaseAuthServiceProvider),
    analyticsService: ref.watch(firebaseAnalyticsServiceProvider),
    deviceRepository: FirebaseDeviceService(limitConfig: config),
  );
}

// 3. Providers derivados
@riverpod
Future<List<DeviceEntity>> appUserDevices(Ref ref) async {
  final service = ref.watch(appDeviceManagementServiceProvider);
  final result = await service.getUserDevices();
  return result.fold((f) => [], (devices) => devices);
}
```

---

## 📊 Métricas de Sucesso

| Métrica | Antes | Depois |
|---------|-------|--------|
| Linhas de código duplicadas | ~800 | ~100 |
| Arquivos duplicados | 4+ | 0 |
| Apps usando core completo | 1/3 | 3/3 |
| Cobertura de funcionalidades | 60% | 100% |

---

## 🚀 Próximos Passos

1. **Imediato:** Mover `DeviceIdentityService` para core
2. **Curto prazo:** Refatorar app-receituagro
3. **Médio prazo:** Padronizar app-gasometer
4. **Longo prazo:** Criar widgets compartilhados no core

---

**Autor:** Claude AI  
**Data:** 2025-12-23  
**Versão:** 1.0

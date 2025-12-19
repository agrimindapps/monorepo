# 🚀 Plano de Equalização - Nebulalist Settings & Profile
## Baseado na arquitetura do App-plantis

---

## 📋 RESUMO EXECUTIVO

**Objetivo:** Refatorar as páginas de Settings e Profile do app-nebulalist para o mesmo nível de qualidade do app-plantis.

**Tempo estimado:** 12-18 dias úteis  
**Complexidade:** Média-Alta  
**Impacto:** Alto (melhoria de 300% em manutenibilidade)

---

## 🎯 OBJETIVOS ESPECÍFICOS

### Arquitetura
- [ ] Implementar Clean Architecture (Domain/Data/Presentation)
- [ ] Aplicar SOLID principles
- [ ] Reduzir acoplamento em 80%
- [ ] Aumentar testabilidade para 90%+

### Código
- [ ] Reduzir SettingsPage de 575 → ~250 linhas
- [ ] Reduzir ProfilePage de 922 → ~100 linhas
- [ ] Extrair 15+ widgets reutilizáveis
- [ ] Criar 8+ managers/dialogs dedicados

### Features
- [ ] Adicionar Backup Settings Page
- [ ] Adicionar Device Management Section
- [ ] Adicionar Data Sync Section
- [ ] Implementar Photo Picker para avatar

---

## 📅 CRONOGRAMA DETALHADO

### **FASE 1: Quick Wins (2-3 dias)**
> Melhorias visíveis com baixo risco

#### Dia 1: Extração de Dialogs
**Tempo:** 6-8 horas

**Tarefas:**
1. Criar pasta `features/settings/presentation/dialogs/`
2. Extrair dialogs do settings_page.dart:
   - [ ] `theme_selection_dialog.dart` (dialog de tema)
   - [ ] `rate_app_dialog.dart` (avaliação)
   - [ ] `feedback_dialog.dart` (feedback)
   - [ ] `about_dialog.dart` (sobre o app)

3. Criar pasta `features/settings/presentation/profile_dialogs/`
4. Extrair dialogs do profile_page.dart:
   - [ ] `edit_name_dialog.dart`
   - [ ] `change_password_dialog.dart`
   - [ ] `clear_data_confirmation_dialog.dart`
   - [ ] `delete_account_dialog.dart`
   - [ ] `logout_confirmation_dialog.dart`

**Entregável:**
```
features/settings/presentation/
├── dialogs/
│   ├── theme_selection_dialog.dart
│   ├── rate_app_dialog.dart
│   ├── feedback_dialog.dart
│   └── about_dialog.dart
└── profile_dialogs/
    ├── edit_name_dialog.dart
    ├── change_password_dialog.dart
    ├── clear_data_confirmation_dialog.dart
    ├── delete_account_dialog.dart
    └── logout_confirmation_dialog.dart
```

**Testes:**
- [ ] Widget tests para cada dialog
- [ ] Verificar navegação e callbacks

---

#### Dia 2: Componentização - Profile Widgets
**Tempo:** 6-8 horas

**Tarefas:**
1. Criar pasta `features/settings/presentation/widgets/profile/`
2. Extrair seções do ProfilePage:
   - [ ] `profile_header_widget.dart` (SliverAppBar + gradient)
   - [ ] `profile_info_section.dart` (informações da conta)
   - [ ] `profile_actions_section.dart` (editar perfil, senha)
   - [ ] `danger_zone_section.dart` (limpar dados, excluir conta)
   - [ ] `profile_premium_card.dart` (card premium)

**Entregável:**
```
features/settings/presentation/widgets/profile/
├── profile_header_widget.dart
├── profile_info_section.dart
├── profile_actions_section.dart
├── danger_zone_section.dart
└── profile_premium_card.dart
```

**Resultado esperado:**
- ProfilePage reduzido de 922 → ~300 linhas
- Cada widget com responsabilidade única

---

#### Dia 3: Componentização - Settings Widgets
**Tempo:** 6-8 horas

**Tarefas:**
1. Criar pasta `features/settings/presentation/widgets/settings/`
2. Extrair componentes do SettingsPage:
   - [ ] `settings_user_card.dart` (card de usuário)
   - [ ] `settings_premium_card.dart` (card premium)
   - [ ] `app_settings_section.dart` (notificações, tema)
   - [ ] `support_section.dart` (avaliar, feedback)
   - [ ] `legal_section.dart` (políticas, termos)

**Entregável:**
```
features/settings/presentation/widgets/settings/
├── settings_user_card.dart
├── settings_premium_card.dart
├── app_settings_section.dart
├── support_section.dart
└── legal_section.dart
```

**Resultado esperado:**
- SettingsPage reduzido de 575 → ~250 linhas

---

### **FASE 2: Clean Architecture - Domain Layer (3-4 dias)**
> Criar fundação arquitetural

#### Dia 4-5: Entities & Interfaces
**Tempo:** 12-16 horas

**Tarefas:**

**1. Criar estrutura de pastas:**
```
features/settings/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── data/
    ├── models/
    ├── datasources/
    └── repositories/
```

**2. Criar Entities (Domain):**
```dart
// features/settings/domain/entities/settings_entity.dart
class SettingsEntity {
  final AppSettings app;
  final NotificationSettings notifications;
  final ThemeSettings theme;
  final AccountSettings account;
  
  const SettingsEntity({
    required this.app,
    required this.notifications,
    required this.theme,
    required this.account,
  });
  
  factory SettingsEntity.defaults() { ... }
  SettingsEntity copyWith({ ... });
}

class AppSettings {
  final String version;
  final String locale;
  const AppSettings({required this.version, required this.locale});
}

class NotificationSettings {
  final bool enabled;
  final bool taskReminders;
  final bool dueDateAlerts;
  const NotificationSettings({
    required this.enabled,
    required this.taskReminders,
    required this.dueDateAlerts,
  });
}

class ThemeSettings {
  final ThemeMode mode;
  const ThemeSettings({required this.mode});
}

class AccountSettings {
  final bool syncEnabled;
  final DateTime? lastSync;
  const AccountSettings({required this.syncEnabled, this.lastSync});
}
```

**3. Criar Account Entity:**
```dart
// features/settings/domain/entities/account_entity.dart
class AccountEntity {
  final String userId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;
  
  const AccountEntity({ ... });
  
  String get initials { ... }
  bool get hasProfilePhoto { ... }
}
```

**4. Criar Repository Interfaces:**
```dart
// features/settings/domain/repositories/i_settings_repository.dart
abstract class ISettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings);
  Future<Either<Failure, void>> resetSettings();
  Stream<SettingsEntity> watchSettings();
}

// features/settings/domain/repositories/i_account_repository.dart
abstract class IAccountRepository {
  Future<Either<Failure, AccountEntity>> getAccountInfo();
  Future<Either<Failure, void>> updateProfile({
    String? displayName,
    String? photoUrl,
  });
  Future<Either<Failure, void>> changePassword(String newPassword);
  Future<Either<Failure, int>> clearUserData();
  Future<Either<Failure, void>> deleteAccount();
}
```

**Checklist:**
- [ ] Entities criadas (imutáveis)
- [ ] Repository interfaces definidas
- [ ] Documentação inline
- [ ] Testes unitários de entities

---

#### Dia 6-7: UseCases
**Tempo:** 12-16 horas

**Tarefas:**

**1. Criar UseCases de Settings:**
```dart
// features/settings/domain/usecases/get_settings_usecase.dart
class GetSettingsUseCase implements UseCase<SettingsEntity, NoParams> {
  final ISettingsRepository repository;
  
  const GetSettingsUseCase(this.repository);
  
  @override
  Future<Either<Failure, SettingsEntity>> call(NoParams params) async {
    return await repository.getSettings();
  }
}

// features/settings/domain/usecases/update_theme_usecase.dart
class UpdateThemeUseCase implements UseCase<void, ThemeMode> {
  final ISettingsRepository repository;
  
  const UpdateThemeUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(ThemeMode mode) async {
    final currentSettings = await repository.getSettings();
    return currentSettings.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(
          theme: ThemeSettings(mode: mode),
        );
        return await repository.updateSettings(updated);
      },
    );
  }
}

// features/settings/domain/usecases/toggle_notifications_usecase.dart
class ToggleNotificationsUseCase implements UseCase<void, bool> {
  final ISettingsRepository repository;
  
  const ToggleNotificationsUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(bool enabled) async {
    final currentSettings = await repository.getSettings();
    return currentSettings.fold(
      (failure) => Left(failure),
      (settings) async {
        final updated = settings.copyWith(
          notifications: NotificationSettings(
            enabled: enabled,
            taskReminders: enabled,
            dueDateAlerts: enabled,
          ),
        );
        return await repository.updateSettings(updated);
      },
    );
  }
}
```

**2. Criar UseCases de Account:**
```dart
// features/settings/domain/usecases/clear_data_usecase.dart
class ClearDataUseCase implements UseCase<int, NoParams> {
  final IAccountRepository repository;
  
  const ClearDataUseCase(this.repository);
  
  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.clearUserData();
  }
}

// features/settings/domain/usecases/delete_account_usecase.dart
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final IAccountRepository repository;
  
  const DeleteAccountUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}

// features/settings/domain/usecases/update_profile_usecase.dart
class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final IAccountRepository repository;
  
  const UpdateProfileUseCase(this.repository);
  
  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams {
  final String? displayName;
  final String? photoUrl;
  
  const UpdateProfileParams({this.displayName, this.photoUrl});
}
```

**Checklist:**
- [ ] 8+ UseCases implementados
- [ ] Testes unitários com mocks
- [ ] Coverage > 90%

---

### **FASE 3: Clean Architecture - Data Layer (3-4 dias)**
> Implementação de repositories e datasources

#### Dia 8-9: Models & DataSources
**Tempo:** 12-16 horas

**Tarefas:**

**1. Criar Models com Freezed:**
```dart
// features/settings/data/models/settings_data.dart
@freezed
class SettingsData with _$SettingsData {
  const factory SettingsData({
    required AppSettingsData app,
    required NotificationSettingsData notifications,
    required ThemeSettingsData theme,
    required AccountSettingsData account,
  }) = _SettingsData;
  
  factory SettingsData.fromEntity(SettingsEntity entity) { ... }
  SettingsEntity toEntity() { ... }
  
  factory SettingsData.fromJson(Map<String, dynamic> json) =>
      _$SettingsDataFromJson(json);
}
```

**2. Criar Local DataSource:**
```dart
// features/settings/data/datasources/settings_local_datasource.dart
abstract class SettingsLocalDataSource {
  Future<SettingsData> getSettings();
  Future<void> saveSettings(SettingsData settings);
  Future<void> clearSettings();
  Stream<SettingsData> watchSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences prefs;
  final StreamController<SettingsData> _controller = StreamController.broadcast();
  
  static const _settingsKey = 'nebulalist_settings';
  
  SettingsLocalDataSourceImpl(this.prefs);
  
  @override
  Future<SettingsData> getSettings() async {
    final json = prefs.getString(_settingsKey);
    if (json == null) {
      return SettingsData.defaults();
    }
    return SettingsData.fromJson(jsonDecode(json));
  }
  
  @override
  Future<void> saveSettings(SettingsData settings) async {
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
    _controller.add(settings);
  }
  
  @override
  Stream<SettingsData> watchSettings() => _controller.stream;
}
```

**3. Criar Account DataSource:**
```dart
// features/settings/data/datasources/account_local_datasource.dart
abstract class AccountLocalDataSource {
  Future<int> clearAllData();
  Future<void> deleteLocalAccount();
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final ListLocalDataSource listDataSource;
  final ListItemLocalDataSource itemDataSource;
  final ItemMasterLocalDataSource masterDataSource;
  
  const AccountLocalDataSourceImpl({
    required this.listDataSource,
    required this.itemDataSource,
    required this.masterDataSource,
  });
  
  @override
  Future<int> clearAllData() async {
    await listDataSource.clearAll();
    await itemDataSource.clearAll();
    await masterDataSource.clearAllData();
    return 3; // Number of tables cleared
  }
  
  @override
  Future<void> deleteLocalAccount() async {
    await clearAllData();
    // Clear settings, cache, etc
  }
}
```

**Checklist:**
- [ ] Models com Freezed
- [ ] DataSources implementados
- [ ] Testes de persistência

---

#### Dia 10-11: Repository Implementations
**Tempo:** 12-16 horas

**Tarefas:**

**1. Implementar SettingsRepository:**
```dart
// features/settings/data/repositories/settings_repository_impl.dart
class SettingsRepositoryImpl implements ISettingsRepository {
  final SettingsLocalDataSource localDataSource;
  
  const SettingsRepositoryImpl(this.localDataSource);
  
  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      final data = await localDataSource.getSettings();
      return Right(data.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings) async {
    try {
      final data = SettingsData.fromEntity(settings);
      await localDataSource.saveSettings(data);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Stream<SettingsEntity> watchSettings() {
    return localDataSource.watchSettings().map((data) => data.toEntity());
  }
}
```

**2. Implementar AccountRepository:**
```dart
// features/settings/data/repositories/account_repository_impl.dart
class AccountRepositoryImpl implements IAccountRepository {
  final AccountLocalDataSource localDataSource;
  final AuthNotifier authNotifier;
  
  const AccountRepositoryImpl({
    required this.localDataSource,
    required this.authNotifier,
  });
  
  @override
  Future<Either<Failure, AccountEntity>> getAccountInfo() async {
    try {
      final user = authNotifier.currentUser;
      if (user == null) {
        return Left(AuthenticationFailure('User not logged in'));
      }
      
      final entity = AccountEntity(
        userId: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        lastLogin: user.lastLogin,
      );
      
      return Right(entity);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, int>> clearUserData() async {
    try {
      final count = await localDataSource.clearAllData();
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await localDataSource.deleteLocalAccount();
      await authNotifier.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
```

**Checklist:**
- [ ] Repositories implementados
- [ ] Error handling completo
- [ ] Testes com mocks
- [ ] Integration tests

---

### **FASE 4: Managers & Riverpod Providers (2-3 dias)**
> Camada de apresentação avançada

#### Dia 12-13: Dialog Managers
**Tempo:** 12-16 horas

**Tarefas:**

**1. Criar Settings Dialog Manager:**
```dart
// features/settings/presentation/managers/settings_dialog_manager.dart
class SettingsDialogManager {
  final BuildContext context;
  final WidgetRef? ref;
  
  const SettingsDialogManager({required this.context, this.ref});
  
  Future<void> showThemeDialog() async {
    if (ref == null) return;
    
    final currentTheme = ref.read(themeProvider);
    
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (_) => ThemeSelectionDialog(currentTheme: currentTheme),
    );
    
    if (selected != null && ref != null) {
      await ref.read(themeProvider.notifier).setThemeMode(selected);
      _showSuccessSnackBar('Tema "$_getThemeName(selected)" selecionado');
    }
  }
  
  Future<void> showRateAppDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const RateAppDialog(),
    );
    
    if (confirmed == true) {
      // Implementar rating via InAppReview
      _showSuccessSnackBar('Obrigado pela avaliação!');
    }
  }
  
  Future<void> showFeedbackDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const FeedbackDialog(),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

**2. Criar Account Dialog Manager:**
```dart
// features/settings/presentation/managers/account_dialog_manager.dart
class AccountDialogManager {
  final BuildContext context;
  final WidgetRef ref;
  
  const AccountDialogManager({required this.context, required this.ref});
  
  Future<void> showEditNameDialog(String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(currentName: currentName),
    );
    
    if (newName != null && newName.isNotEmpty) {
      await _updateProfile(displayName: newName);
    }
  }
  
  Future<void> showChangePasswordDialog(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ChangePasswordDialog(email: email),
    );
    
    if (confirmed == true) {
      await _sendPasswordResetEmail(email);
    }
  }
  
  Future<void> showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ClearDataConfirmationDialog(),
    );
    
    if (confirmed == true) {
      await _executeClearData();
    }
  }
  
  Future<void> showDeleteAccountDialog(String email) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteAccountDialog(email: email),
    );
    
    if (confirmed == true) {
      await _executeDeleteAccount();
    }
  }
  
  Future<void> _executeClearData() async {
    _showLoadingSnackBar('Limpando dados...');
    
    final useCase = ref.read(clearDataUseCaseProvider);
    final result = await useCase(NoParams());
    
    result.fold(
      (failure) => _showErrorSnackBar('Erro ao limpar dados: ${failure.message}'),
      (count) => _showSuccessSnackBar('✅ $count tabelas limpas com sucesso!'),
    );
  }
  
  Future<void> _executeDeleteAccount() async {
    _showLoadingSnackBar('Excluindo conta...');
    
    final useCase = ref.read(deleteAccountUseCaseProvider);
    final result = await useCase(NoParams());
    
    result.fold(
      (failure) => _showErrorSnackBar('Erro ao excluir conta: ${failure.message}'),
      (_) {
        _showSuccessSnackBar('✅ Conta excluída com sucesso');
        context.go(AppConstants.loginRoute);
      },
    );
  }
}
```

**3. Criar Riverpod Providers:**
```dart
// features/settings/presentation/providers/settings_providers.dart
@riverpod
ISettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final localDataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(localDataSource);
}

@riverpod
GetSettingsUseCase getSettingsUseCase(GetSettingsUseCaseRef ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettingsUseCase(repository);
}

@riverpod
UpdateThemeUseCase updateThemeUseCase(UpdateThemeUseCaseRef ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateThemeUseCase(repository);
}

@riverpod
SettingsDialogManager settingsDialogManager(
  SettingsDialogManagerRef ref,
  BuildContext context,
) {
  return SettingsDialogManager(context: context, ref: ref);
}

// features/settings/presentation/providers/account_providers.dart
@riverpod
IAccountRepository accountRepository(AccountRepositoryRef ref) {
  final localDataSource = ref.watch(accountLocalDataSourceProvider);
  final authNotifier = ref.watch(authProvider.notifier);
  return AccountRepositoryImpl(
    localDataSource: localDataSource,
    authNotifier: authNotifier,
  );
}

@riverpod
ClearDataUseCase clearDataUseCase(ClearDataUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return ClearDataUseCase(repository);
}

@riverpod
DeleteAccountUseCase deleteAccountUseCase(DeleteAccountUseCaseRef ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return DeleteAccountUseCase(repository);
}

@riverpod
AccountDialogManager accountDialogManager(
  AccountDialogManagerRef ref,
  BuildContext context,
) {
  return AccountDialogManager(context: context, ref: ref);
}
```

**Checklist:**
- [ ] Dialog managers criados
- [ ] Providers configurados
- [ ] Code generation executado
- [ ] Testes de managers

---

### **FASE 5: Novas Features (2-3 dias)**
> Adicionar funcionalidades do app-plantis

#### Dia 14: Backup Settings Page
**Tempo:** 6-8 horas

**Tarefas:**

**1. Criar BackupSettingsPage:**
```dart
// features/settings/presentation/pages/backup_settings_page.dart
class BackupSettingsPage extends ConsumerWidget {
  const BackupSettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupSettingsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Backup e Sincronização')),
      body: ListView(
        children: [
          // Auto backup toggle
          SwitchListTile(
            title: const Text('Backup Automático'),
            subtitle: const Text('Fazer backup automático dos dados'),
            value: backupState.autoBackupEnabled,
            onChanged: (value) {
              ref.read(backupSettingsProvider.notifier).toggleAutoBackup(value);
            },
          ),
          
          // Manual backup trigger
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Fazer Backup Agora'),
            subtitle: Text(
              backupState.lastBackup != null
                  ? 'Último backup: ${_formatDate(backupState.lastBackup!)}'
                  : 'Nenhum backup realizado',
            ),
            trailing: backupState.isBackingUp
                ? const CircularProgressIndicator()
                : const Icon(Icons.chevron_right),
            onTap: backupState.isBackingUp
                ? null
                : () => ref.read(backupSettingsProvider.notifier).triggerManualBackup(),
          ),
          
          // Restore from backup
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Restaurar Backup'),
            subtitle: const Text('Restaurar dados de um backup anterior'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestoreDialog(context, ref),
          ),
        ],
      ),
    );
  }
}
```

**Checklist:**
- [ ] Página criada
- [ ] Auto backup toggle
- [ ] Manual backup trigger
- [ ] Restore functionality

---

#### Dia 15: Device Management & Data Sync
**Tempo:** 6-8 horas

**Tarefas:**

**1. Criar DeviceManagementSection:**
```dart
// features/settings/presentation/widgets/profile/device_management_section.dart
class DeviceManagementSection extends ConsumerWidget {
  const DeviceManagementSection({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesState = ref.watch(userDevicesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Dispositivos Conectados'),
        const SizedBox(height: 8),
        Card(
          child: devicesState.when(
            data: (devices) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: Icon(_getDeviceIcon(device.platform)),
                  title: Text(device.name),
                  subtitle: Text('Último acesso: ${_formatDate(device.lastActive)}'),
                  trailing: device.isCurrent
                      ? const Chip(label: Text('Este dispositivo'))
                      : IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => _showLogoutDeviceDialog(context, ref, device),
                        ),
                );
              },
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Erro ao carregar dispositivos: $e'),
            ),
          ),
        ),
      ],
    );
  }
}
```

**2. Criar DataSyncSection:**
```dart
// features/settings/presentation/widgets/profile/data_sync_section.dart
class DataSyncSection extends ConsumerWidget {
  const DataSyncSection({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(dataSyncProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sincronização de Dados'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  syncState.isSynced ? Icons.cloud_done : Icons.cloud_off,
                  color: syncState.isSynced ? Colors.green : Colors.grey,
                ),
                title: Text(
                  syncState.isSynced ? 'Sincronizado' : 'Não sincronizado',
                ),
                subtitle: syncState.lastSync != null
                    ? Text('Última sincronização: ${_formatDate(syncState.lastSync!)}')
                    : const Text('Nunca sincronizado'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sincronizar Agora'),
                subtitle: const Text('Enviar dados locais para a nuvem'),
                trailing: syncState.isSyncing
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.chevron_right),
                onTap: syncState.isSyncing
                    ? null
                    : () => ref.read(dataSyncProvider.notifier).triggerSync(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

**Checklist:**
- [ ] Device management implementado
- [ ] Data sync implementado
- [ ] Testes de UI

---

### **FASE 6: Polish & Testing (2-3 dias)**
> Finalização e garantia de qualidade

#### Dia 16-17: Testes
**Tempo:** 12-16 horas

**Tarefas:**

**1. Unit Tests (UseCases):**
```dart
// test/unit/usecases/clear_data_usecase_test.dart
void main() {
  late ClearDataUseCase useCase;
  late MockAccountRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAccountRepository();
    useCase = ClearDataUseCase(mockRepository);
  });
  
  test('should return count when clear is successful', () async {
    when(() => mockRepository.clearUserData())
        .thenAnswer((_) async => const Right(3));
    
    final result = await useCase(NoParams());
    
    expect(result.isRight(), true);
    expect(result.getOrElse(() => 0), 3);
    verify(() => mockRepository.clearUserData()).called(1);
  });
  
  test('should return failure when clear fails', () async {
    when(() => mockRepository.clearUserData())
        .thenAnswer((_) async => Left(DatabaseFailure('Error')));
    
    final result = await useCase(NoParams());
    
    expect(result.isLeft(), true);
  });
}
```

**2. Widget Tests (Sections):**
```dart
// test/widget/profile_info_section_test.dart
void main() {
  testWidgets('should display user info correctly', (tester) async {
    final mockUser = UserEntity(
      email: 'test@example.com',
      displayName: 'Test User',
      isEmailVerified: true,
    );
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => AsyncValue.data(mockUser)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ProfileInfoSection(),
          ),
        ),
      ),
    );
    
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.byIcon(Icons.verified_user), findsOneWidget);
  });
}
```

**3. Integration Tests:**
```dart
// test/integration/profile_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('full profile edit flow', (tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Navigate to profile
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Ver Perfil'));
    await tester.pumpAndSettle();
    
    // Edit name
    await tester.tap(find.text('Editar Perfil'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'New Name');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    
    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('✅ Nome atualizado'), findsOneWidget);
  });
}
```

**Checklist:**
- [ ] 20+ unit tests
- [ ] 15+ widget tests
- [ ] 5+ integration tests
- [ ] Coverage > 80%

---

#### Dia 18: Documentação & Review
**Tempo:** 6-8 horas

**Tarefas:**

**1. Documentação:**
- [ ] README.md da feature
- [ ] Architecture decision records (ADR)
- [ ] Inline documentation
- [ ] Code examples

**2. Code Review:**
- [ ] Lint checks
- [ ] Format code
- [ ] Remove dead code
- [ ] Optimize imports

**3. Performance:**
- [ ] Profile app performance
- [ ] Check memory leaks
- [ ] Optimize heavy widgets
- [ ] Lazy loading where applicable

**Checklist:**
- [ ] Documentação completa
- [ ] 0 warnings no analyzer
- [ ] Performance satisfatório
- [ ] Code review aprovado

---

## 📊 MÉTRICAS DE SUCESSO

### Código
- [ ] SettingsPage: 575 → ~250 linhas (-56%)
- [ ] ProfilePage: 922 → ~100 linhas (-89%)
- [ ] 15+ widgets reutilizáveis criados
- [ ] 8+ managers/dialogs dedicados
- [ ] Complexidade ciclomática < 10 por método

### Arquitetura
- [ ] 3 camadas bem definidas (Domain/Data/Presentation)
- [ ] SOLID principles aplicados
- [ ] Dependency Inversion implementado
- [ ] 0 acoplamentos diretos entre camadas

### Testes
- [ ] 20+ unit tests
- [ ] 15+ widget tests
- [ ] 5+ integration tests
- [ ] Coverage total > 80%
- [ ] Coverage de UseCases > 95%

### Features
- [ ] Backup Settings Page funcional
- [ ] Device Management implementado
- [ ] Data Sync funcional
- [ ] Photo Picker para avatar

---

## 🎯 CHECKLIST FINAL

### Arquitetura
- [ ] Domain layer completo
- [ ] Data layer completo
- [ ] Presentation layer refatorado
- [ ] Dependency Injection configurado

### Código
- [ ] Todos os widgets extraídos
- [ ] Todos os dialogs separados
- [ ] Managers criados
- [ ] Providers configurados

### Features
- [ ] Settings page atualizado
- [ ] Profile page atualizado
- [ ] Backup settings implementado
- [ ] Device management implementado
- [ ] Data sync implementado

### Qualidade
- [ ] Testes implementados
- [ ] Coverage > 80%
- [ ] 0 analyzer warnings
- [ ] Documentação completa
- [ ] Code review aprovado

---

## 🚨 RISCOS E MITIGAÇÕES

### Risco 1: Breaking Changes
**Mitigação:**
- Criar feature flags
- Rollout gradual
- Manter versão antiga em paralelo
- Testes extensivos antes do merge

### Risco 2: Regressões
**Mitigação:**
- Testes automatizados
- Integration tests
- Manual QA
- Beta testing

### Risco 3: Prazo Excedido
**Mitigação:**
- Priorizar features críticas
- Deixar polish para depois
- Pair programming em partes complexas
- Daily reviews

---

## 📚 RECURSOS NECESSÁRIOS

### Desenvolvedores
- 1 desenvolvedor senior (full-time)
- 1 desenvolvedor mid-level (part-time para reviews)

### Ferramentas
- Freezed (code generation)
- Mocktail (testing)
- Flutter DevTools (profiling)
- Coverage tools

### Conhecimento
- Clean Architecture
- SOLID principles
- Riverpod advanced
- Testing strategies

---

## 🎉 ENTREGA FINAL

Ao final das 6 fases, você terá:

✅ **Arquitetura de nível empresarial**
- Clean Architecture completa
- SOLID principles aplicados
- Testabilidade máxima

✅ **Código limpo e manutenível**
- 89% redução em linhas da ProfilePage
- 56% redução em linhas da SettingsPage
- Componentes reutilizáveis

✅ **Features robustas**
- Backup & restore
- Device management
- Data synchronization
- Photo picker

✅ **Qualidade garantida**
- 80%+ test coverage
- 0 analyzer warnings
- Performance otimizado
- Documentação completa

---

**Tempo total:** 12-18 dias úteis  
**ROI esperado:** 300% de melhoria em manutenibilidade  
**Dívida técnica reduzida:** 85%

---

**Última atualização:** 19/12/2024  
**Status:** Plano aprovado ✅  
**Próximo passo:** Iniciar Fase 1

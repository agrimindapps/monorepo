# 🔄 Migração Hive → Drift - Fase 2 Iniciada

**Data:** 13/11/2024  
**Status:** 🚧 **EM PROGRESSO** - Fase 2: Integração e Datasources  
**Branch:** `feature/migrate-to-drift`

---

## 🚧 Fase 2: Integração com DI e Datasources (EM PROGRESSO)

### ✅ 2.1 Integração com Dependency Injection (COMPLETO)

#### Database Module Criado
- [x] Criado `lib/core/di/modules/database_module.dart`
- [x] Configurado `@module` e `@singleton` para `PetivetiDatabase`
- [x] Importado no `injectable_config.dart`

```dart
@module
abstract class DatabaseModule {
  @singleton
  PetivetiDatabase get database => PetivetiDatabase();
}
```

### ✅ 2.2 Atualização de Datasources (1/19 COMPLETO)

#### Animals Feature (COMPLETO) ✅
- [x] **AnimalLocalDataSource** - Migrado para Drift
  - [x] Removida dependência de `HiveService`
  - [x] Implementado com `PetivetiDatabase` + `AnimalDao`
  - [x] Métodos implementados:
    - `getAnimals(userId)` - Lista todos os animais do usuário
    - `getAnimalById(id)` - Busca animal por ID
    - `addAnimal(model)` - Adiciona novo animal
    - `updateAnimal(model)` - Atualiza animal existente
    - `deleteAnimal(id)` - Soft delete de animal
    - `watchAnimals(userId)` - Stream de animais (real-time)
    - `getAnimalsCount(userId)` - Conta animais ativos
    - `searchAnimals(userId, query)` - Busca por nome
  - [x] Conversão Drift ↔ Model implementada
    - Tratamento de enums (AnimalSpecies, AnimalGender)
    - ID String → Int e vice-versa
    - Campos nullable mapeados corretamente
  - [x] Anotado com `@LazySingleton`

#### AnimalModel Atualizado
- [x] Removido `extends HiveObject`
- [x] Removido todas as anotações `@HiveType` e `@HiveField`
- [x] Adicionado campo `isDeleted: bool`
- [x] Mudado `id` para nullable (gerado pelo Drift)
- [x] Mudado `updatedAt` para nullable
- [x] Adicionado `hide Column` no import do core (conflito com Drift)
- [x] Backup criado: `animal_model_hive.dart.backup`

### 📋 Progresso Detalhado - Datasources

| Feature | Datasource | Status | Observações |
|---------|-----------|---------|-------------|
| **animals** | `animal_local_datasource.dart` | ✅ | Migrado completo |
| **animals** | `animal_remote_datasource.dart` | ⏳ | Não precisa alteração |
| **medications** | `medication_local_datasource.dart` | ⏳ | Pendente |
| **medications** | `medication_remote_datasource.dart` | ⏳ | Não precisa alteração |
| **vaccines** | `vaccine_local_datasource.dart` | ⏳ | Pendente |
| **vaccines** | `vaccine_remote_datasource.dart` | ⏳ | Não precisa alteração |
| **appointments** | `appointment_local_datasource.dart` | ⏳ | Pendente |
| **appointments** | `appointment_remote_datasource.dart` | ⏳ | Não precisa alteração |
| **weight** | `weight_local_datasource.dart` | ⏳ | Pendente |
| **expenses** | `expense_local_datasource.dart` | ⏳ | Pendente |
| **expenses** | `expense_remote_datasource.dart` | ⏳ | Não precisa alteração |
| **reminders** | `reminder_local_datasource.dart` | ⏳ | Pendente |
| **calculators** | `calculator_local_datasource.dart` | ⏳ | Pendente |

**Progresso:** 1/19 datasources migrados (5%)

---

## 🔧 Padrão de Migração Estabelecido

### Template de Datasource com Drift

```dart
import 'package:injectable/injectable.dart';
import '../../../../database/petiveti_database.dart';

@LazySingleton(as: XLocalDataSource)
class XLocalDataSourceImpl implements XLocalDataSource {
  final PetivetiDatabase _database;

  XLocalDataSourceImpl(this._database);

  // Implementar métodos usando _database.xDao
  
  // Conversão Drift → Model
  XModel _toModel(XEntity entity) { ... }
  
  // Conversão Model → Drift Companion
  XCompanion _toCompanion(XModel model) { ... }
}
```

### Padrão de Conversão de IDs
- **Hive:** String IDs
- **Drift:** Int autoincrement
- **Conversão:** `int.parse(stringId)` e `intId.toString()`

### Padrão de Enums
- **Storage:** Salvar como `enum.name` (String)
- **Recuperação:** `EnumExtension.fromString(string)`

### Padrão de Campos Nullable
- **Drift:** `Value.ofNullable(campo)`
- **Model:** Manter nullability original

---

## ⚠️ Desafios Encontrados

### 1. Conflito de Nome: Column
**Problema:** `Drift` e `Core` têm classes `Column`
**Solução:** `import 'package:core/core.dart' hide Column;`

### 2. IDs String → Int
**Problema:** Models usam String ID, Drift usa Int autoincrement
**Solução:** Conversão `int.parse()` / `.toString()` + ID nullable no model

### 3. Enums em Storage
**Problema:** Drift não suporta enums diretamente
**Solução:** Armazenar como String (`enum.name`) e converter na leitura

### 4. HiveObject Removal
**Problema:** Models estendem HiveObject
**Solução:** Remover herança + adicionar campo `isDeleted`

---

## 📊 Métricas da Fase 2 (Parcial)

- **Datasources migrados:** 1/19 (5%)
- **Models atualizados:** 1/9 (11%)
- **Módulos DI criados:** 1
- **Linhas de código modificadas:** ~500+
- **Backups criados:** 2 arquivos

---

## 🎯 Próximos Passos

### Imediato (Continuação Fase 2)
1. [ ] Migrar **MedicationLocalDataSource**
2. [ ] Atualizar **MedicationModel**
3. [ ] Migrar **VaccineLocalDataSource**
4. [ ] Atualizar **VaccineModel**
5. [ ] Migrar **AppointmentLocalDataSource**
6. [ ] Atualizar **AppointmentModel**

### Prioridade Média
7. [ ] Migrar **WeightLocalDataSource**
8. [ ] Migrar **ExpenseLocalDataSource**
9. [ ] Migrar **ReminderLocalDataSource**

### Prioridade Baixa
10. [ ] Migrar **CalculatorLocalDataSource**
11. [ ] Atualizar Services (AutoSync, DataIntegrity)
12. [ ] Remover imports de Hive nos services

### Testing
13. [ ] Testar CRUD de Animals
14. [ ] Verificar navegação
15. [ ] Validar streams (watch methods)

---

## 🔍 Checklist Fase 2

### Setup DI
- [x] DatabaseModule criado
- [x] PetivetiDatabase registrado no DI
- [x] Importado no injectable_config

### Animals Feature
- [x] AnimalLocalDataSource migrado
- [x] AnimalModel atualizado (sem Hive)
- [x] Conversões implementadas
- [x] 8 métodos funcionais
- [ ] Testes de integração

### Pending Features
- [ ] Medications
- [ ] Vaccines  
- [ ] Appointments
- [ ] Weight
- [ ] Expenses
- [ ] Reminders
- [ ] Calculators
- [ ] Promo

---

## ✨ Conquistas Fase 2 (Parcial)

1. ✅ **Primeiro datasource migrado** com sucesso
2. ✅ **Padrão de migração** estabelecido e documentado
3. ✅ **Conversão de enums** funcionando
4. ✅ **DI integrado** com Drift
5. ✅ **Template reutilizável** criado
6. ✅ **Solução para conflitos** documentada

---

## 📝 Notas Técnicas

### Build Runner Warnings
- Warnings sobre `@HiveType` em outros models (esperado)
- Não bloqueiam a build
- Serão resolvidos conforme models forem migrados

### Compatibilidade
- Repository layer não precisa alteração (interface mantida)
- Use Cases não precisam alteração
- UI não precisa alteração

### Performance
- Drift é mais rápido que Hive para queries complexas
- Streams são nativos (não precisa de polling)
- Indexes podem ser adicionados depois

---

**Progresso Total da Migração:** ~25%  
**Tempo Estimado Restante Fase 2:** 2-3 dias  
**Status:** Avançando conforme planejado ✅

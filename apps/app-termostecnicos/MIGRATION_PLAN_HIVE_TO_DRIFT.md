# 📋 Plano de Migração: app-termostecnicos (Hive → Drift)

**Data:** 13/11/2024  
**Estimativa:** 1-2 dias (RÁPIDA)  
**Complexidade:** ⭐⭐☆☆☆ BAIXA  
**Template Base:** app-petiveti (validado 100%)

---

## 🎯 ANÁLISE DO APP

### Características
- **Tipo:** Dicionário de Termos Técnicos
- **DB Local:** Apenas Comentários (Hive)
- **Dados Principais:** JSON Assets (não precisa migração)
- **Settings:** SharedPreferences (não precisa migração)
- **Premium:** LocalStorage (não precisa migração)

### Escopo REDUZIDO ✨
**Somente 1 feature usa Hive:** Comentários

---

## 📊 INVENTÁRIO ATUAL

### Datasources (5 total)
| Datasource | Usa Hive? | Ação |
|------------|-----------|------|
| TermosLocalDataSource | ❌ (JSON Assets) | ✅ Sem ação |
| DatabaseDataSource | ❌ (JSON Assets) | ✅ Sem ação |
| SettingsLocalDataSource | ❌ (SharedPrefs) | ✅ Sem ação |
| PremiumLocalDataSource | ❌ (LocalStorage) | ✅ Sem ação |
| **ComentariosLocalDataSource** | ✅ **Hive** | 🔧 **MIGRAR** |

**Total a migrar:** 1 datasource apenas! 🎉

### Models (4 total)
| Model | Usa Hive? | Ação |
|-------|-----------|------|
| TermoModel | ❌ | ✅ Sem ação |
| CategoriaModel | ❌ | ✅ Sem ação |
| AppSettingsModel | ❌ | ✅ Sem ação |
| **ComentarioModel** | ✅ | 🔧 Atualizar |

**Total a atualizar:** 1 model apenas! 🎉

### Hive Models (1 total)
- `lib/hive_models/comentarios_models.dart` - ❌ Remover após migração

---

## 🗄️ ESTRUTURA DRIFT A CRIAR

### Tabela: Comentarios

```dart
class Comentarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();  // Para multi-user se necessário
  
  // Campos do comentário
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get status => boolean().withDefault(const Constant(true))();
  TextColumn get idReg => text()();  // ID do termo comentado
  TextColumn get titulo => text()();
  TextColumn get conteudo => text()();
  TextColumn get ferramenta => text()();  // Categoria/feature
  TextColumn get pkIdentificador => text()();
  
  // Soft delete
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
```

**Total:** 1 tabela

### DAO: ComentarioDao

```dart
@DriftAccessor(tables: [Comentarios])
class ComentarioDao extends DatabaseAccessor<TermosTecnicosDatabase> 
    with _$ComentarioDaoMixin {
  
  // CRUD Methods (7)
  Future<List<ComentariosEntity>> getAllComentarios(String userId);
  Future<List<ComentariosEntity>> getComentariosByFerramenta(String userId, String ferramenta);
  Future<ComentariosEntity?> getComentarioById(int id);
  Future<int> createComentario(ComentariosCompanion comentario);
  Future<void> updateComentario(int id, ComentariosCompanion comentario);
  Future<void> deleteComentario(int id);
  Future<void> deleteAllComentarios(String userId);
  Future<int> getComentariosCount(String userId);
  
  // Watch methods (2)
  Stream<List<ComentariosEntity>> watchComentarios(String userId);
  Stream<List<ComentariosEntity>> watchComentariosByFerramenta(String userId, String ferramenta);
}
```

**Total:** ~10 métodos

---

## 📋 FASES DA MIGRAÇÃO

### ✅ FASE 1: Setup Database (1-2 horas)

#### 1.1 Adicionar Dependências
```yaml
dependencies:
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: any
  path: any

dev_dependencies:
  drift_dev: ^2.28.0
  build_runner: any
```

#### 1.2 Criar Estrutura
```bash
mkdir -p lib/database/{tables,daos}
touch lib/database/tables/comentarios_table.dart
touch lib/database/daos/comentario_dao.dart
touch lib/database/termostecnicos_database.dart
```

#### 1.3 Implementar Tabela
- Criar `comentarios_table.dart`
- Definir campos conforme schema acima

#### 1.4 Implementar DAO
- Criar `comentario_dao.dart`
- Implementar 10 métodos

#### 1.5 Criar Database
- Criar `termostecnicos_database.dart`
- Registrar tabela e DAO
- Configurar web + mobile

#### 1.6 Build Runner
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ✅ FASE 2: DI Integration (30 min)

#### 2.1 Database Module
```dart
@module
abstract class DatabaseModule {
  @singleton
  TermosTecnicosDatabase get database => TermosTecnicosDatabase();
}
```

#### 2.2 Atualizar Injectable
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### ✅ FASE 3: Migrar Datasource (1 hora)

#### 3.1 Backup
```bash
cp lib/features/comentarios/data/datasources/local/comentarios_local_datasource.dart \
   lib/features/comentarios/data/datasources/local/comentarios_local_datasource_hive.dart.backup
```

#### 3.2 Reimplementar com Drift
```dart
@LazySingleton(as: ComentariosLocalDataSource)
class ComentariosLocalDataSourceImpl implements ComentariosLocalDataSource {
  final TermosTecnicosDatabase _database;
  
  ComentariosLocalDataSourceImpl(this._database);
  
  // Implementar 8 métodos usando _database.comentarioDao
  // Conversões: _toModel() e _toCompanion()
}
```

#### 3.3 Atualizar Model
```bash
cp lib/features/comentarios/data/models/comentario_model.dart \
   lib/features/comentarios/data/models/comentario_model_hive.dart.backup
```

Mudanças no model:
- Remover referência a Hive
- Manter apenas conversão de/para Entity
- Adicionar `hide Column` no import do core

---

### ✅ FASE 4: Cleanup (30 min)

#### 4.1 Remover Hive Models
```bash
rm -rf lib/hive_models/
```

#### 4.2 Remover Hive do pubspec.yaml
```yaml
# Remover:
hive: any
hive_generator: ^2.0.1
```

#### 4.3 Limpar Imports
- Buscar e remover imports de Hive não usados
- Verificar arquivos que importam `comentarios_models.dart`

#### 4.4 Build Final
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze --no-pub
```

---

## 🎯 ESTIMATIVAS DETALHADAS

| Fase | Tarefa | Tempo | Complexidade |
|------|--------|-------|--------------|
| 1.1 | Dependências | 5 min | ⭐ |
| 1.2 | Estrutura | 5 min | ⭐ |
| 1.3 | Tabela | 20 min | ⭐⭐ |
| 1.4 | DAO | 30 min | ⭐⭐ |
| 1.5 | Database | 15 min | ⭐⭐ |
| 1.6 | Build | 10 min | ⭐ |
| 2.1 | DI Module | 10 min | ⭐ |
| 2.2 | Build | 5 min | ⭐ |
| 3.1 | Backup | 2 min | ⭐ |
| 3.2 | Datasource | 40 min | ⭐⭐ |
| 3.3 | Model | 15 min | ⭐ |
| 4.1-4.4 | Cleanup | 30 min | ⭐⭐ |
| **TOTAL** | | **~3h** | ⭐⭐ |

**Margem de segurança:** 1-2 dias (considerando testes)

---

## 🔧 PADRÕES A SEGUIR

### Conversões (Template petiveti)

**IDs:**
```dart
// Hive usa String, Drift usa Int autoincrement
// No model: final String? id (nullable)
// Na conversão: int.parse(id!) / id.toString()
```

**Timestamps:**
```dart
// Drift gerencia automaticamente
createdAt: Value(DateTime.now())
updatedAt: Value(DateTime.now())
```

**Boolean:**
```dart
// Direto, sem conversão
status: model.status
```

---

## ⚠️ PONTOS DE ATENÇÃO

### Baixo Risco ✅
1. Apenas 1 feature usa Hive
2. Dados isolados (comentários)
3. Sem relacionamentos complexos
4. Sem enums para converter
5. Campos simples (String, DateTime, bool)

### Médio Risco ⚠️
1. Verificar se há sincronização remota
2. Validar migração de dados existentes (se houver)

### Sem Risco 🎉
- Termos (JSON Assets) - não mexer
- Settings (SharedPreferences) - não mexer
- Premium (LocalStorage) - não mexer

---

## 📊 COMPARATIVO: ANTES vs DEPOIS

| Aspecto | Antes (Hive) | Depois (Drift) |
|---------|--------------|----------------|
| Database | 1 Hive Box | 1 SQLite Table |
| Type Safety | Runtime | Compile-time ✅ |
| Queries | Manual | SQL tipado ✅ |
| Streams | Manual polling | Nativos ✅ |
| Web Support | Limitado | Completo ✅ |
| Code | ~176 linhas | ~150 linhas ✅ |
| Manutenção | Hive (declínio) | Drift (ativo) ✅ |

---

## 🎯 CHECKLIST DE EXECUÇÃO

### Preparação
- [ ] Criar branch `feature/migrate-to-drift`
- [ ] Backup do código atual
- [ ] Documentar estado atual

### Fase 1: Database
- [ ] Adicionar dependências
- [ ] Criar estrutura de diretórios
- [ ] Implementar `comentarios_table.dart`
- [ ] Implementar `comentario_dao.dart`
- [ ] Criar `termostecnicos_database.dart`
- [ ] Executar build_runner
- [ ] Verificar arquivos `.g.dart` gerados

### Fase 2: DI
- [ ] Criar `database_module.dart`
- [ ] Registrar no injectable
- [ ] Executar build_runner
- [ ] Verificar injeção funcionando

### Fase 3: Migração
- [ ] Backup datasource Hive
- [ ] Backup model Hive
- [ ] Reimplementar datasource com Drift
- [ ] Atualizar model
- [ ] Testar CRUD básico
- [ ] Executar build_runner

### Fase 4: Cleanup
- [ ] Remover `lib/hive_models/`
- [ ] Remover Hive do `pubspec.yaml`
- [ ] Limpar imports não usados
- [ ] Executar `flutter pub get`
- [ ] Executar build_runner final
- [ ] Executar `flutter analyze`
- [ ] Validar compilação

### Finalização
- [ ] Commit organizado
- [ ] Atualizar documentação
- [ ] Marcar como completo
- [ ] Celebrar! 🎉

---

## 📚 RECURSOS DISPONÍVEIS

### Templates Validados
- ✅ app-petiveti (100% completo)
- ✅ Datasource pattern
- ✅ Model pattern
- ✅ DAO pattern
- ✅ Conversions pattern

### Documentação
- `apps/app-petiveti/MIGRATION_COMPLETE.md`
- `apps/app-petiveti/MIGRATION_FINAL_REPORT.md`
- `MONOREPO_MIGRATION_STATUS.md`

---

## 💡 VANTAGENS DESTA MIGRAÇÃO

### Simplicidade 🎯
- **Apenas 1 feature** para migrar
- **Sem enums** para converter
- **Campos simples** (String, DateTime, bool)
- **Sem relacionamentos** complexos

### Rapidez ⚡
- Estimativa: **3 horas** de desenvolvimento
- Template validado pronto
- Processo bem documentado

### Segurança 🛡️
- Backups automáticos
- Rollback fácil
- Sem breaking changes

### Impacto 🚀
- Type-safety completo
- Performance melhorada
- Web support completo
- Código mais limpo

---

## 🎉 PÓS-MIGRAÇÃO

### Validações
1. ✅ Build limpo
2. ✅ Analyzer sem erros
3. ✅ CRUD de comentários funcional
4. ✅ Termos carregando normalmente
5. ✅ Settings funcionando

### Next Steps
1. Testes funcionais
2. Deploy em staging
3. Validação com usuários
4. Deploy em produção

---

**🚀 Esta será a migração mais RÁPIDA do monorepo!**

**Motivo:** Apenas 1 feature usa Hive, resto é JSON/SharedPreferences

**Tempo real esperado:** 3-4 horas + testes

---

**📅 Criado:** 13/11/2024  
**📝 Baseado:** Template app-petiveti  
**🎯 Status:** PRONTO PARA EXECUTAR

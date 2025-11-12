# 🚀 Próximos Passos - App ReceitaAgro

## ✅ Status Atual
- ✅ Migração Hive → Drift: **COMPLETA**
- ✅ Limpeza de código legacy: **COMPLETA**
- ✅ Build e análise: **OK** (0 erros)

---

## 🧪 Fase de Testes

### 1. Build e Deploy
```bash
# Debug build
flutter run --debug

# Release build (teste de performance)
flutter build apk --release
```

### 2. Testes Funcionais Prioritários

#### ✅ Core Features (Críticos):
- [ ] **Listar diagnósticos** - `/home-diagnosticos`
- [ ] **Ver detalhes** - Tap em diagnóstico
- [ ] **Buscar pragas** - `/home-pragas`
- [ ] **Buscar culturas** - Feature culturas
- [ ] **Buscar defensivos** - `/home-defensivos`

#### ✅ Favoritos (Importante):
- [ ] **Adicionar favorito** - Ícone estrela
- [ ] **Remover favorito** - Remover da lista
- [ ] **Persistência** - Reiniciar app e verificar

#### ✅ CRUD Diagnósticos (Importante):
- [ ] **Criar diagnóstico** - Botão "+"
- [ ] **Editar diagnóstico** - Editar existente
- [ ] **Deletar diagnóstico** - Remover item

#### ✅ Sync (Importante):
- [ ] **Sync manual** - Pull to refresh
- [ ] **Sync automático** - Login/logout
- [ ] **Offline-first** - Desconectar internet, usar app

---

## 🐛 Potenciais Problemas a Observar

### 1. **Dados Não Carregando**
```
Sintoma: Telas vazias
Causa possível: Database não inicializado
Verificar: lib/main.dart - PrioritizedDataLoader
```

### 2. **Favoritos Não Salvando**
```
Sintoma: Favoritos perdidos após restart
Causa possível: FavoritoRepository não conectado
Verificar: lib/database/repositories/favorito_repository.dart
```

### 3. **Sync Queue Erro**
```
Sintoma: Erro ao sincronizar
Causa possível: Métodos save() comentados
Verificar: lib/core/sync/sync_queue.dart (linhas 110-180)
Solução: Manter Hive para sync ou migrar para Drift
```

---

## 🔧 TODOs Futuros (Não Bloqueantes)

### Prioridade MÉDIA:
1. **Implementar Extensions Drift Completas**
   - `diagnostico_enrichment_drift_extension.dart`
   - Buscar dados relacionados (praga, cultura, defensivo)

2. **Decidir sobre SyncQueue**
   - Opção A: Manter Hive (recomendado, já funciona)
   - Opção B: Migrar para Drift (criar tabela SyncQueue)

### Prioridade BAIXA:
3. **Revisar Serviços Deprecated**
   - `data_integrity_service.dart` - Reimplementar ou remover?
   - `user_data_repository.dart` - Migrar para Firebase?
   - `app_settings_model.dart` - Migrar para Drift?

---

## 📊 Métricas de Sucesso

### Build:
- ✅ Build time: < 60s
- ✅ Warnings: apenas deprecations do Flutter (não nosso código)
- ✅ Errors: 0

### Runtime:
- [ ] App inicia em < 3s
- [ ] Carregamento de dados < 2s
- [ ] Sem crashes nos primeiros 5 minutos
- [ ] Favoritos persistem após restart
- [ ] Sync funciona online/offline

---

## 🎯 Critérios de Aceitação

### Mínimo para Produção:
1. ✅ App compila sem erros
2. [ ] App inicia sem crashes
3. [ ] Dados carregam corretamente
4. [ ] CRUD básico funciona
5. [ ] Favoritos persistem
6. [ ] Modo offline funcional

### Desejável:
7. [ ] Sync bidirecional funciona
8. [ ] Performance aceitável (< 3s startup)
9. [ ] Sem memory leaks (testar com DevTools)

---

## 📝 Como Reportar Problemas

Se encontrar bugs durante testes:

```markdown
## Bug Report Template

**Feature**: [ex: Favoritos]
**Sintoma**: [ex: Favoritos não persistem]
**Passos para reproduzir**:
1. Abrir app
2. Adicionar favorito
3. Fechar app
4. Reabrir app
5. Favorito sumiu

**Logs relevantes**: 
[Copiar do console/logcat]

**Stack trace**: 
[Se houver crash]

**Prioridade**: [Alta/Média/Baixa]
```

---

## ✅ Comando Rápido de Validação

```bash
# Executar antes de testar
flutter clean && \
flutter pub get && \
flutter pub run build_runner build --delete-conflicting-outputs && \
flutter analyze && \
echo "✅ Pronto para testes!"
```

---

**Status**: 🚀 **PRONTO PARA INICIAR TESTES**  
**Última atualização**: 2025-11-12 16:52 UTC

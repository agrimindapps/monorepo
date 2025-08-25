# Issues e Melhorias - Feature Settings (App AgrHurbi)

## 📋 Índice Geral

### 🔴 Complexidade ALTA (8 issues)
### 🟡 Complexidade MÉDIA (12 issues)  
### 🟢 Complexidade BAIXA (6 issues)

---

## 🔴 Complexidade ALTA

### 1. [BUG] - Métodos não implementados em SettingsProvider causarão runtime errors

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O SettingsProvider chama métodos `exportSettings()` e `importSettings()` que não existem na classe ManageSettings, causando NoSuchMethodError em runtime.

**Prompt de Implementação:**
Implementar os métodos exportSettings() e importSettings() na classe ManageSettings e no SettingsRepository. Criar casos de uso específicos ExportSettings e ImportSettings seguindo o padrão Clean Architecture. Os métodos devem retornar ResultFuture<Map<String, dynamic>> para export e ResultFuture<SettingsEntity> para import.

**Dependências:** 
- /lib/features/settings/domain/usecases/manage_settings.dart
- /lib/features/settings/domain/repositories/settings_repository.dart
- /lib/features/settings/data/repositories/settings_repository_impl.dart

**Validação:** Compilar o projeto e testar as funcionalidades de export/import sem erros de runtime.

---

### 2. [SECURITY] - Hardcoded userId em repository implementation

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O SettingsRepositoryImpl usa 'current_user' hardcoded em múltiplos métodos, violando segurança e funcionalidade multi-usuário.

**Prompt de Implementação:**
Refatorar SettingsRepositoryImpl para injetar AuthService ou CurrentUserService que fornece o userId atual dinamicamente. Remover todos os hardcoded 'current_user' e implementar getUserId() method que obtém o ID do usuário autenticado. Garantir que cada operação de settings seja específica do usuário logado.

**Dependências:**
- /lib/core/services/auth_service.dart ou similar
- /lib/features/settings/data/repositories/settings_repository_impl.dart
- /lib/features/settings/data/datasources/settings_local_datasource.dart

**Validação:** Cada usuário deve ter settings independentes e não deve acessar settings de outros usuários.

---

### 3. [REFACTOR] - Repository implementation com métodos não implementados

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Múltiplos métodos do SettingsRepository retornam implementações vazias (const Right(null)) ou hardcoded, não fornecendo funcionalidade real.

**Prompt de Implementação:**
Implementar completamente todos os métodos do SettingsRepositoryImpl, especialmente: updatePrivacySettings, updateSecuritySettings, updateBackupSettings, createBackup, exportAllData, exportData, getBiometricInfo, setupBiometricAuth, verifyBiometricAuth, getCacheInfo, clearCache, getAppVersion, getDeviceInfo. Cada método deve ter lógica real usando services apropriados.

**Dependências:**
- Device info service
- Biometric authentication service  
- File system service para backup/export
- Cache management service
- App version service

**Validação:** Todos os métodos devem executar operações reais e retornar dados válidos.

---

### 4. [FIXME] - Hive adapters comentados causarão serialization errors

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Todas as anotações @HiveType e @HiveField estão comentadas no SettingsModel, impedindo serialização/deserialização com Hive.

**Prompt de Implementação:**
Descomentar todas as anotações Hive no SettingsModel e suas classes relacionadas (NotificationSettingsModel, DataSettingsModel, etc.). Gerar os adapters Hive executando 'flutter packages pub run build_runner build'. Registrar todos os adapters no HiveInitializer. Implementar TypeIds únicos para cada classe evitando conflitos.

**Dependências:**
- /lib/core/utils/hive_initializer.dart
- build_runner package
- hive_generator package

**Validação:** Settings devem ser persistidos e recuperados corretamente do Hive sem erros de serialização.

---

### 5. [OPTIMIZE] - SettingsProvider com operações síncronas em UI thread

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Múltiplas operações async no SettingsProvider podem bloquear a UI e não implementam debouncing para operações frequentes.

**Prompt de Implementação:**
Implementar debouncing nas operações de settings que podem ser chamadas frequentemente (como updateFontSize, toggles). Adicionar loading states específicos para diferentes operações. Implementar queue system para operações de save evitando race conditions. Adicionar timeout para operações lentas.

**Dependências:**
- dart:async para Timer e Debouncer
- Possível Queue implementation

**Validação:** UI deve permanecer responsiva durante operações de settings e não deve haver conflitos entre saves simultâneos.

---

### 6. [REFACTOR] - Violação de Clean Architecture em data layer

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** SettingsLocalDataSource usa tipos de domain layer (SettingsEntity, AppTheme) diretamente, violando dependency inversion.

**Prompt de Implementação:**
Refatorar SettingsLocalDataSource para trabalhar apenas com SettingsModel e tipos primitivos. Mover toda conversão Entity↔Model para o repository layer. Criar métodos de conversão específicos no repository. Garantir que datasource não conhece domain layer.

**Dependências:**
- /lib/features/settings/data/repositories/settings_repository_impl.dart
- /lib/features/settings/data/datasources/settings_local_datasource.dart

**Validação:** Datasource deve importar apenas data layer e core types, nunca domain types.

---

### 7. [TODO] - Settings validation não implementada

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Métodos de validação de settings retornam hardcoded success sem validação real, permitindo states inválidos.

**Prompt de Implementação:**
Implementar validação completa de settings incluindo: ranges válidos para fontSize, formatos válidos para dateFormat/timeFormat, validação de quiet hours (start < end), validação de cache retention days, validação de currency codes, etc. Retornar erros específicos para cada tipo de validação falha.

**Dependências:**
- Validation service ou validators
- Constants para ranges válidos
- Localization para error messages

**Validação:** Settings inválidos devem ser rejeitados com mensagens de erro apropriadas.

---

### 8. [BUG] - Memory leaks potenciais em SettingsProvider

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** SettingsProvider não implementa dispose() e pode ter listeners não removidos, causando memory leaks.

**Prompt de Implementação:**
Implementar dispose() method em SettingsProvider cancelando timers, streams e outros resources. Adicionar lifecycle management para operações async em curso. Implementar proper cleanup quando provider é destroyed. Adicionar weak references onde necessário.

**Dependências:**
- Lifecycle management
- Stream subscriptions management

**Validação:** Provider deve limpar todos os recursos quando disposed, sem memory leaks.

---

## 🟡 Complexidade MÉDIA

### 9. [STYLE] - Inconsistência em factory constructors

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Algumas classes Model usam factory constructor completos enquanto outras usam arrow functions, criando inconsistência no codebase.

**Prompt de Implementação:**
Padronizar todos os factory constructors em SettingsModel e suas subclasses usando o mesmo estilo. Preferir arrow functions para constructors simples e body completo para constructors com lógica complexa. Manter consistência em fromEntity, fromJson, e toJson methods.

**Dependências:** Apenas refatoração de código existente

**Validação:** Código deve compilar sem mudanças funcionais, apenas melhor consistência.

---

### 10. [OPTIMIZE] - Settings page com rebuilds excessivos

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** SettingsPage usa Consumer sem selector específico, causando rebuilds desnecessários quando apenas partes específicas do state mudam.

**Prompt de Implementação:**
Refatorar SettingsPage usando Consumer com seletores específicos ou Selector widgets para rebuilds granulares. Implementar const constructors onde possível. Separar widgets complexos em componentes independentes. Usar Consumer apenas nas partes que precisam reagir a mudanças específicas.

**Dependências:**
- Provider package com Selector widgets
- Possível refatoração em componentes menores

**Validação:** Page deve ter performance melhorada com menos rebuilds desnecessários.

---

### 11. [FIXME] - Parsing de enum strings sem error handling

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** SettingsModel._parseThemeFromString() e outras conversões enum podem falhar com valores inválidos do storage.

**Prompt de Implementação:**
Adicionar error handling robusto para parsing de enums em SettingsModel. Implementar fallback values para casos de parsing failure. Adicionar logging para valores inválidos encontrados. Considerar usar enum extensions com tryParse methods seguros.

**Dependências:**
- Logging service
- Enum extensions ou helper methods

**Validação:** Parsing de enums deve nunca crashar e sempre retornar valores válidos.

---

### 12. [TODO] - Quiet hours validation inexistente

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** SettingsPage permite configurar quiet hours sem validação se start time é anterior a end time.

**Prompt de Implementação:**
Implementar validação de quiet hours no dialog, mostrando erro se start >= end. Adicionar suporte a quiet hours que cruzam meia-noite (ex: 22:00-07:00). Implementar helper methods para comparação de TimeOfDay. Mostrar feedback visual para configurações inválidas.

**Dependências:**
- TimeOfDay extension methods
- UI validation components

**Validação:** Usuário deve ser impedido de salvar quiet hours inválidos.

---

### 13. [OPTIMIZE] - SharedPreferences operations sem caching

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** SettingsLocalDataSource acessa SharedPreferences diretamente para cada operação sem caching, impactando performance.

**Prompt de Implementação:**
Implementar caching layer para preferences frequentemente acessadas como theme e language. Adicionar write-through cache pattern. Implementar batch operations para múltiplas preference updates. Considerar usar in-memory cache com periodic sync para preferences críticas.

**Dependências:**
- In-memory cache implementation
- Cache invalidation strategy

**Validação:** Preferences access deve ser mais rápido com caching apropriado.

---

### 14. [REFACTOR] - Settings tiles com duplicação de código

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** SettingsPage tem código repetitivo para criar diferentes tipos de tiles, especialmente switches e dropdowns.

**Prompt de Implementação:**
Extrair builder methods ou helper functions para reduzir duplicação de código. Criar extension methods em SettingsProvider para operações comuns. Implementar generic tile builders que recebem configurações. Considerar usar builder pattern para tiles complexos.

**Dependências:** Refatoração de UI components

**Validação:** Código deve ser mais conciso mantendo mesma funcionalidade.

---

### 15. [DOC] - Settings entities sem documentação de constraints

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Campos como fontSize, autoLockMinutes, cacheRetentionDays não documentam ranges válidos ou constraints.

**Prompt de Implementação:**
Adicionar documentação Dart completa para todas as properties de settings entities, incluindo ranges válidos, formatos esperados, valores default, e constraints. Usar dartdoc comments com examples onde apropriado. Documentar comportamento de copyWith methods.

**Dependências:** Apenas adição de documentação

**Validação:** Documentação deve estar disponível no IDE e ser clara sobre constraints.

---

### 16. [OPTIMIZE] - Operações de file export sem streaming

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Futuras implementações de export podem carregar todos os dados em memória, causando issues com datasets grandes.

**Prompt de Implementação:**
Projetar export operations usando streaming approach para datasets grandes. Implementar chunked export para diferentes data types. Adicionar progress reporting para exports longos. Considerar background export usando isolates para datasets muito grandes.

**Dependências:**
- File streaming APIs
- Progress reporting mechanism
- Isolate support para background processing

**Validação:** Export deve funcionar eficientemente independente do tamanho dos dados.

---

### 17. [FIXME] - Error handling inconsistente entre methods

**Status:** 🟡 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Alguns methods em SettingsRepositoryImpl capturam exceptions específicas enquanto outros usam catch genérico.

**Prompt de Implementação:**
Padronizar error handling em todos os methods do SettingsRepositoryImpl. Definir quais exceptions específicas devem ser capturadas para cada tipo de operação. Implementar error mapping consistente de exceptions para failures. Adicionar logging apropriado para diferentes tipos de errors.

**Dependências:**
- Error logging service
- Consistent error mapping strategy

**Validação:** Error handling deve ser consistente e errors devem ser apropriadamente logged.

---

### 18. [TODO] - Settings sync com remote backend

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** forceSyncToCloud() retorna hardcoded success sem implementação real, impedindo sync cross-device.

**Prompt de Implementação:**
Implementar sync real de settings com Firebase ou backend. Adicionar conflict resolution para settings modificadas em múltiplos devices. Implementar timestamp-based merging strategy. Adicionar offline queue para sync quando conectividade retornar.

**Dependências:**
- Firebase Remote Config ou similar
- Conflict resolution strategy
- Network connectivity monitoring

**Validação:** Settings devem sincronizar corretamente entre devices do mesmo usuário.

---

### 19. [STYLE] - Magic numbers em UI components

**Status:** 🟡 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** SettingsPage e widgets têm magic numbers para paddings, sizes, e outros valores UI.

**Prompt de Implementação:**
Extrair magic numbers para constants ou theme values. Criar AppDimensions class com spacing, padding, e size constants. Usar theme-based values onde apropriado. Implementar consistent design tokens.

**Dependências:**
- Design system constants
- Theme configuration

**Validação:** UI deve usar valores consistentes e theme-aware.

---

### 20. [TEST] - Zero coverage de testes para settings

**Status:** 🟡 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Nenhum arquivo de teste encontrado para a feature settings, deixando funcionalidade crítica sem cobertura.

**Prompt de Implementação:**
Criar suite completa de testes para settings: unit tests para entities/models, repository tests com mocks, provider tests para state management, widget tests para UI components. Implementar golden tests para UI consistency. Adicionar integration tests para fluxos completos.

**Dependências:**
- Test framework setup
- Mock libraries
- Golden test configuration

**Validação:** Cobertura de testes deve ser >90% para toda a feature settings.

---

## 🟢 Complexidade BAIXA

### 21. [STYLE] - Import organization inconsistente

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns arquivos organizam imports por tipo (dart, package, relative) enquanto outros não seguem padrão.

**Prompt de Implementação:**
Organizar imports em todos os arquivos settings seguindo padrão: dart imports, package imports, relative imports, separados por linha em branco. Usar dart format ou similar para automatizar. Remover imports não utilizados.

**Dependências:** Apenas reorganização de imports

**Validação:** Imports devem estar organizados consistentemente em todos os arquivos.

---

### 22. [STYLE] - Inconsistência em trailing commas

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns arquivos usam trailing commas consistentemente enquanto outros não, afetando formatação e diffs.

**Prompt de Implementação:**
Adicionar trailing commas em todos os parameter lists, argument lists, e collection literals onde apropriado. Executar dart format para aplicar formatação consistente. Configurar linter rules para enforce trailing commas.

**Dependências:** Dart formatter e linter configuration

**Validação:** Código deve ter formatação consistente com trailing commas apropriadas.

---

### 23. [DOC] - Comments TODO obsoletos

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Comentários como "part 'settings_model.g.dart';" comentados e "Similar pattern for other settings models..." indicam code incomplete.

**Prompt de Implementação:**
Remover ou atualizar comments obsoletos e TODOs que não são mais relevantes. Limpar commented code que não será usado. Adicionar proper documentation onde comments genéricos existem.

**Dependências:** Apenas cleanup de código

**Validação:** Código deve estar limpo sem comments obsoletos ou misleading.

---

### 24. [OPTIMIZE] - Hardcoded strings sem localization

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Settings page contém múltiplos hardcoded strings em português sem suporte a internationalization.

**Prompt de Implementação:**
Extrair todos os strings hardcoded para arquivos de localização. Implementar proper i18n support usando flutter_localizations. Criar keys apropriadas para todos os settings labels, descriptions, e messages.

**Dependências:**
- flutter_localizations package
- Localization files (arb)

**Validação:** UI deve suportar múltiplos idiomas sem hardcoded strings.

---

### 25. [STYLE] - Const constructors faltantes

**Status:** 🟢 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns widgets e classes poderiam usar const constructors para melhor performance mas não implementam.

**Prompt de Implementação:**
Adicionar const constructors onde possível em widgets e value classes. Usar const keywords em widget instantiation onde apropriado. Verificar que todas as immutable classes sejam properly const.

**Dependências:** Apenas refatoração para const usage

**Validação:** Widgets devem usar const constructors onde possível para melhor performance.

---

### 26. [NOTE] - Settings feature bem estruturada arquiteturalmente

**Status:** 🟢 Observação | **Execução:** N/A | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** A feature settings segue Clean Architecture corretamente com separação clara de layers, dependency injection apropriada, e provider pattern bem implementado.

**Prompt de Implementação:**
Manter a estrutura arquitetural existente como referência para outras features. A separação domain/data/presentation está bem implementada e deve ser preservada nas correções.

**Dependências:** N/A

**Validação:** Estrutura arquitetural deve ser mantida durante todas as correções.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Implementar issue específica
- `Detalhar #[número]` - Prompt mais detalhado  
- `Focar [complexidade]` - Trabalhar apenas uma complexidade
- `Agrupar [tipo]` - Executar todas issues de um tipo
- `Validar #[número]` - Revisar implementação concluída

## 📊 Priorização Sugerida

1. **Críticos**: #1, #2, #3, #4 (Métodos não implementados, segurança, Hive adapters)
2. **Arquiteturais**: #5, #6, #7 (Clean Architecture, validação, performance)  
3. **Funcionalidades**: #8, #18, #20 (Memory leaks, sync, testes)
4. **Melhorias**: #9-#19 (Otimizações e refinamentos)
5. **Cleanup**: #21-#25 (Style e documentação)

## 🎯 Resumo Executivo

A feature **Settings** do app_agrihurbi apresenta uma arquitetura sólida seguindo Clean Architecture, mas possui **8 issues críticas** que podem causar runtime errors e problemas de segurança. Os principais problemas identificados são:

- **Métodos não implementados** no provider causando NoSuchMethodError
- **Hardcoded userId** violando segurança multi-usuário  
- **Hive adapters comentados** impedindo persistência correta
- **Múltiplos métodos de repository** com implementações vazias
- **Zero cobertura de testes** para funcionalidade crítica

Apesar dos issues, a estrutura base está bem organizada e será facilmente corrigível mantendo a qualidade arquitetural existente.
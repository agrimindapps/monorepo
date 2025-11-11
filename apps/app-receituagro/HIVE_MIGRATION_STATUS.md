# Estado Atual do Sistema Hive após Migração Drift

## Resumo da Migração
A migração para Drift foi concluída com sucesso para os serviços core de diagnóstico, mas ainda existem dependências do Hive que não podem ser completamente removidas neste momento.

## Componentes Hive Mantidos (Não Removíveis)

### 1. Sistema de Storage (BoxRegistryService, ReceituagroStorageInitializer, ReceitaAgroBoxes)
**Status:** Mantido - Ainda necessário
**Razão:** Usado para configurações do app, dados de assinatura, comentários, favoritos e outras funcionalidades não migradas para Drift
**Arquivos:**
- `lib/core/storage/receituagro_storage_initializer.dart`
- `lib/core/storage/receituagro_boxes.dart`
- `lib/core/services/box_registry_service.dart` (no core package)

### 2. HiveBoxManager
**Status:** Mantido - Ainda necessário
**Razão:** Usado por vários serviços para acesso seguro às boxes Hive
**Usado em:**
- `user_data_repository.dart`
- `data_integrity_service.dart`
- `diagnostico_enrichment_extension.dart`
- `hive_to_drift_migration_tool.dart`

### 2. Extensões Hive (Mantidas - Ainda Necessárias)
**Status:** Mantidas - Ainda necessárias
**Razão:** Ainda usadas em vários widgets e providers do módulo de defensivos e pragas
**Arquivos:**
- `lib/core/extensions/diagnostico_hive_extension.dart` - Usado no detalhe_diagnostico_notifier.dart
- `lib/core/extensions/fitossanitario_hive_extension.dart` - Usado em defensivos_history_notifier.dart, defensivos_statistics_notifier.dart, home_defensivos_notifier.dart, lista_defensivos_notifier.dart, defensivos widgets
- `lib/core/extensions/pragas_hive_extension.dart` - Usado em praga_item_widget.dart
**Status:** Mantido - Ainda necessário
**Razão:** Hive ainda usado para funcionalidades não migradas
**Dependências:**
- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `hive_generator: ^2.0.1` (comentado)

## Componentes Hive Removidos

### 1. HiveLeakDetector
**Status:** Removido
**Razão:** Não estava sendo usado em nenhum lugar
**Arquivo removido:** `lib/core/utils/hive_leak_detector.dart`

## Próximos Passos para Eliminação Completa do Hive

### Fase 1: Migrar Configurações e Dados do Usuário
- Migrar configurações do app (`receituagro_app_settings`) para Drift
- Migrar dados de assinatura (`receituagro_subscription_data`) para Drift
- Migrar comentários e favoritos para Drift

### Fase 2: Refatorar DiagnosticoHiveExtension
- Migrar resolução de dados dinâmicos para `DiagnosticoEntityResolverDrift`
- Atualizar `detalhe_diagnostico_notifier.dart` para usar o novo resolver

### Fase 3: Limpeza Final
- Remover sistema de storage Hive
- Remover HiveBoxManager
- Remover dependências do pubspec.yaml
- Limpar registros do container de injeção de dependências

## Impacto Atual
- **Bundle Size:** Ainda inclui Hive (~500KB adicionais)
- **Manutenção:** Código legado do Hive ainda precisa ser mantido
- **Performance:** Duas bases de dados ativas (Drift + Hive)
- **Complexidade:** Sistema híbrido mais complexo que sistema puro Drift

## Recomendação
Manter o sistema híbrido temporariamente até que todas as funcionalidades sejam migradas para Drift, então fazer limpeza completa.</content>
<parameter name="filePath">/Users/agrimindsolucoes/Documents/GitHub/monorepo/apps/app-receituagro/HIVE_MIGRATION_STATUS.md
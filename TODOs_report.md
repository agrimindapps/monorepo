# TODOs report

Data gerada em: 2025-10-06

Resumo rápido
- Total de ocorrências `// TODO` encontradas em arquivos .dart: 478
- Arquivos mais afetados (top 40, formato: count — path):

```
  19 ./apps/app-gasometer/lib/core/widgets/enhanced_app_scaffold.dart
  11 ./apps/app-agrihurbi/lib/features/livestock/data/datasources/livestock_remote_datasource.dart
  11 ./apps/app-agrihurbi/lib/features/calculators/data/datasources/calculator_remote_datasource.dart
  10 ./packages/core/lib/src/riverpod/domain/device/device_management_providers.dart
  10 ./packages/core/lib/src/infrastructure/services/enhanced_notification_service.dart
  10 ./apps/app-petiveti/lib/core/sync/petiveti_sync_service.dart
   9 ./packages/core/lib/src/riverpod/domain/sync/sync_providers.dart
   9 ./apps/app-plantis/lib/features/data_export/presentation/pages/data_export_page.dart
   9 ./apps/app-petiveti/lib/core/services/core_services_integration.dart
   8 ./apps/app-gasometer/lib/features/device_management/presentation/providers/vehicle_device_notifier.dart
   7 ./packages/core/lib/src/riverpod/domain/premium/subscription_providers.dart
   7 ./apps/app-petiveti/lib/core/di/modules/sync_module.dart
   7 ./apps/app-gasometer/lib/features/profile/presentation/widgets/devices_section_widget.dart
   7 ./apps/app-agrihurbi/lib/core/di/modules/sync_module.dart
   6 ./apps/app-receituagro/lib/features/settings/presentation/providers/settings_notifier.dart
   6 ./apps/app-receituagro/lib/core/services/diagnostico_integration_service.dart
   6 ./apps/app-gasometer/lib/features/data_migration/presentation/widgets/migration_integration_handler.dart
   6 ./apps/app-agrihurbi/lib/core/providers/support_providers.dart
   5 ./apps/app-receituagro/lib/core/services/receituagro_notification_service.dart
   5 ./apps/app-plantis/lib/core/services/task_notification_service.dart
   5 ./apps/app-plantis/lib/core/plugins/plant_care_notification_plugin.dart
   5 ./apps/app-petiveti/lib/core/router/app_router.dart
   5 ./apps/app-gasometer/lib/features/profile/presentation/pages/profile_page.dart
   5 ./apps/app-agrihurbi/lib/features/livestock/data/repositories/livestock_repository_impl.dart
   4 ./packages/core/lib/src/infrastructure/services/profile_image_service.dart
   4 ./apps/app-receituagro/lib/features/busca_avancada/data/mappers/busca_mapper.dart
   4 ./apps/app-plantis/lib/features/plants/presentation/pages/plants_list_page.dart
   4 ./apps/app-plantis/lib/features/license/widgets/premium_feature_gate.dart
   4 ./apps/app-plantis/lib/features/auth/presentation/pages/register_personal_info_page.dart
   4 ./apps/app-plantis/lib/features/auth/presentation/pages/register_password_page.dart
   4 ./apps/app-petiveti/lib/core/notifications/notification_service.dart
   4 ./apps/app-gasometer/lib/features/data_migration/data/datasources/gasometer_migration_data_source_impl.dart
   4 ./apps/app-agrihurbi/lib/features/markets/data/repositories/market_repository_impl.dart
   4 ./apps/app-agrihurbi/lib/features/livestock/presentation/providers/equines_management_provider.dart
   3 ./packages/core/lib/src/infrastructure/services/sync_firebase_service.dart
   3 ./packages/core/lib/src/infrastructure/services/firebase_storage_service.dart
   3 ./apps/app-taskolist/lib/infrastructure/services/sync_service.dart
   3 ./apps/app-receituagro/lib/features/pragas/data/repositories/pragas_repository_impl.dart
   3 ./apps/app-receituagro/lib/core/services/user_action_service.dart
   3 ./apps/app-receituagro/lib/core/providers/auth_notifier.dart
```

Observações
- Total considerável: 478 TODOs sugere que há tech-debt distribuído por múltiplos pacotes/apps.
- Muitos TODOs são placeholders de integração (ex.: "Get from auth service", "Integrar com Riverpod"). Outros são lembretes para implementar features futuras. Alguns servem como sinalizadores temporários (comentários que desativam blocos de código para fases futuras).

Proposta de política para remoção/triagem
1. Não remover TODOs que representam trabalho não-trivial (integração com serviços, features não implementadas). Em vez disso: convertê-los em issues no tracker do projeto (manual) com contexto. Isso preserva o histórico e permite priorização.
2. Remover ou simplificar TODOs triviais e redundantes, por exemplo:
   - TODOs que sugerem usar um valor temporário (e.g., "// TODO: Get from auth service") → substituir por um comentário explicativo mais curto ou usar uma constante `TODO_PLACEHOLDER` com uma nota.
   - TODOs que comentam blocos inativos (comentados com // TODO: temporarily disabled) → remover o comentário se o código já está inativo ou adicionar `// REVIEW:` com instrução clara.
3. Automatizar a extração: primeiro gerar um relatório detalhado (arquivo CSV/MD) com caminho, linha, e texto do TODO. Já criado este arquivo. Em seguida, aplicar mudanças por lote pequeno (ex.: top 20 arquivos), criar commits separados.

Passos sugeridos (práticos)
1. Revisar este relatório e confirmar política (A: remover tudo automaticamente, B: remover apenas TODOs triviais, C: converter TODOs em issues e deixar os comentários). Recomendo B + criação de issues para os casos não-triviais.
2. Se você aprovar B, eu posso:
   - Gerar um arquivo `todos_details.csv` com (file,path,line,text) para inspeção.
   - Aplicar mudanças automáticas em top N arquivos (por exemplo N=20) onde substituo TODO por um comentário formatado `// REVIEW: ...` ou removo quando redundante.
   - Rodar `dart analyze` e executar testes rápidos (se houver) para garantir nada quebre.
3. Criar commits pequenos e claros (uma para export do relatório, outro para as mudanças em lote).

Próximo passo imediato
- Se confirmar, eu gero `todos_details.csv` com todas as ocorrências detalhadas para revisão. Isso me permite aplicar mudanças seguras em lote.

---

Arquivo gerado automaticamente pelo script de análise local.

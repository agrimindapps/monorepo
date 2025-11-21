# ✅ Definition of Done (DoD)

Antes de considerar uma tarefa como "concluída", a IA deve verificar este checklist. Isso garante que o código entregue esteja pronto para produção e siga os padrões do monorepo.

## 1. Qualidade de Código
- [ ] **Análise Estática**: O comando `flutter analyze` roda sem erros ou novos warnings?
- [ ] **Formatação**: O código segue o padrão `dart format`?
- [ ] **Code Generation**: O `build_runner` foi executado (`dart run build_runner build --delete-conflicting-outputs`) e os arquivos `.g.dart` / `.freezed.dart` estão atualizados?
- [ ] **Limpeza**: Todos os `print()` de debug foram removidos ou substituídos por `Logger`?
- [ ] **Imports**: Imports não utilizados foram removidos?

## 2. Arquitetura & Padrões
- [ ] **Camadas**: O código respeita as fronteiras da Clean Architecture (Domain não importa Data/Presentation)?
- [ ] **State Management**: Novos estados usam Riverpod (`@riverpod`) e não `ChangeNotifier` ou `GetX`?
- [ ] **Error Handling**: Exceções são tratadas e convertidas para `Either<Failure, T>` no repositório?
- [ ] **Imutabilidade**: Classes de estado e entidades usam `final` e `copyWith` (ou `freezed`)?

## 3. Testes
- [ ] **Unitários**: Novos UseCases possuem testes cobrindo caminho feliz e falhas?
- [ ] **Execução**: Os testes criados passam com `flutter test`?
- [ ] **Mocks**: Mocks foram criados corretamente usando `mocktail`?

## 4. Documentação
- [ ] **README**: Se uma nova feature grande foi adicionada, o README do app foi atualizado?
- [ ] **Comentários**: Métodos complexos possuem documentação `///` explicando o "porquê" (não o "como")?

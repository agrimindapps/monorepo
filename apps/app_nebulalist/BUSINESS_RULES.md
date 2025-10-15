# NebulaList - Regras de Negócio e Desenvolvimento

> **Versão:** 1.0.0
> **Data:** Outubro 2025
> **Status:** Documento Técnico

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Regras de Negócio - Listas](#regras-de-negócio---listas)
3. [Regras de Negócio - Itens](#regras-de-negócio---itens)
4. [Regras de Negócio - Compartilhamento](#regras-de-negócio---compartilhamento)
5. [Regras de Negócio - Premium](#regras-de-negócio---premium)
6. [Validações e Constraints](#validações-e-constraints)
7. [Lógica de Sincronização](#lógica-de-sincronização)
8. [Estratégias de Implementação](#estratégias-de-implementação)
9. [Casos de Uso Técnicos](#casos-de-uso-técnicos)
10. [Tratamento de Erros](#tratamento-de-erros)
11. [Performance e Otimizações](#performance-e-otimizações)
12. [Segurança e Permissões](#segurança-e-permissões)
13. [Testes Requeridos](#testes-requeridos)

---

## 🎯 Visão Geral

Este documento complementa o `PRODUCT_SPEC.md` com detalhes técnicos sobre implementação, regras de negócio, validações e constraints do sistema.

**Princípios de Design:**
- **Simplicidade**: Funcionalidades core bem feitas > muitas features mal implementadas
- **Offline-first**: App deve funcionar perfeitamente sem internet
- **Performance**: Operações devem ser instantâneas na UI
- **Consistência**: Dados sincronizados devem ser consistentes eventualmente
- **Segurança**: Dados do usuário são privados por padrão

**Mudança Importante:**
- ❌ **Removido**: Colaboração em tempo real (complexidade alta)
- ✅ **Mantido**: Compartilhamento simples via link (read-only ou cópia)

---

## 📝 Regras de Negócio - Listas

### RN-L001: Criação de Listas

**Regra:**
- Usuários podem criar listas com nome obrigatório
- Ícone e cor são opcionais (valores padrão se não informados)
- Descrição é opcional (max 500 caracteres)
- Cada lista recebe um UUID único

**Implementação:**
```dart
class CreateListUseCase {
  Future<Either<Failure, ListEntity>> call({
    required String name,
    String? description,
    String? iconName,
    String? colorHex,
    ListType? type,
  }) async {
    // Validações
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Nome da lista é obrigatório'));
    }

    if (name.length > 100) {
      return Left(ValidationFailure('Nome deve ter no máximo 100 caracteres'));
    }

    if (description != null && description.length > 500) {
      return Left(ValidationFailure('Descrição deve ter no máximo 500 caracteres'));
    }

    // Criar lista
    final list = ListEntity(
      id: const Uuid().v4(),
      name: name.trim(),
      description: description?.trim(),
      iconName: iconName ?? 'list_alt', // padrão
      colorHex: colorHex ?? '#673AB7', // Deep Purple
      type: type ?? ListType.general,
      isFavorite: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerId: currentUser.id,
      itemCount: 0,
      completedCount: 0,
    );

    return await repository.createList(list);
  }
}
```

**Validações:**
- Nome: 1-100 caracteres, não pode ser apenas espaços
- Descrição: 0-500 caracteres
- Ícone: Deve estar na lista de ícones permitidos
- Cor: Deve ser um hex válido (#RRGGBB)

### RN-L002: Limites de Listas

**Free Tier:**
- Máximo 10 listas ativas (não arquivadas)
- Listas arquivadas não contam no limite
- Ao atingir o limite, mostrar paywall para upgrade

**Premium:**
- Listas ilimitadas

**Implementação:**
```dart
class CheckListLimitUseCase {
  Future<Either<Failure, bool>> call() async {
    final user = await getUserUseCase.call();

    if (user.isPremium) {
      return Right(true); // Sem limite
    }

    final activeListsCount = await repository.getActiveListsCount(user.id);

    if (activeListsCount >= 10) {
      return Left(LimitReachedFailure(
        'Você atingiu o limite de 10 listas no plano gratuito. '
        'Faça upgrade para Premium para criar listas ilimitadas.'
      ));
    }

    return Right(true);
  }
}
```

### RN-L003: Arquivamento de Listas

**Regra:**
- Listas podem ser arquivadas (soft delete)
- Listas arquivadas não aparecem na visualização padrão
- Listas arquivadas podem ser restauradas
- Listas arquivadas não contam no limite do free tier
- Listas arquivadas por mais de 90 dias podem ser excluídas automaticamente (com aviso)

**Implementação:**
```dart
class ArchiveListUseCase {
  Future<Either<Failure, void>> call(String listId) async {
    final list = await repository.getList(listId);

    if (list == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    // Verificar permissão
    if (list.ownerId != currentUser.id) {
      return Left(PermissionFailure('Apenas o dono pode arquivar a lista'));
    }

    // Arquivar
    final updatedList = list.copyWith(
      isArchived: true,
      archivedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.updateList(updatedList);
  }
}
```

### RN-L004: Exclusão de Listas

**Regra:**
- Listas podem ser excluídas permanentemente
- Apenas o dono pode excluir
- Requer confirmação (dialog com checkbox "Tenho certeza")
- Ao excluir, todos os ListItems são removidos
- ItemMasters NÃO são excluídos (permanecem no banco global)
- Ação irreversível

**Implementação:**
```dart
class DeleteListUseCase {
  Future<Either<Failure, void>> call(String listId, {required bool confirmed}) async {
    if (!confirmed) {
      return Left(ValidationFailure('Confirmação necessária para excluir'));
    }

    final list = await repository.getList(listId);

    if (list == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    if (list.ownerId != currentUser.id) {
      return Left(PermissionFailure('Apenas o dono pode excluir a lista'));
    }

    // Excluir lista e todos os ListItems associados
    return await repository.deleteList(listId);
  }
}
```

### RN-L005: Duplicação de Listas

**Regra:**
- Usuários podem duplicar uma lista existente
- A nova lista recebe sufixo " (cópia)" no nome
- Todos os itens são copiados (mas não marcados como concluídos)
- Quantidade e prioridade são mantidas
- Nova lista é criada pelo usuário atual (ownership transfer)
- Conta no limite do free tier

**Implementação:**
```dart
class DuplicateListUseCase {
  Future<Either<Failure, ListEntity>> call(String sourceListId) async {
    // Verificar limite
    final limitCheck = await checkListLimitUseCase.call();
    if (limitCheck.isLeft()) return limitCheck;

    // Buscar lista original
    final sourceList = await repository.getList(sourceListId);
    if (sourceList == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    // Criar nova lista
    final newList = sourceList.copyWith(
      id: const Uuid().v4(),
      name: '${sourceList.name} (cópia)',
      isFavorite: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerId: currentUser.id,
      completedCount: 0,
    );

    // Criar lista
    final result = await repository.createList(newList);

    if (result.isRight()) {
      // Copiar itens
      final items = await repository.getListItems(sourceListId);
      for (final item in items) {
        final newItem = item.copyWith(
          id: const Uuid().v4(),
          listId: newList.id,
          isCompleted: false,
          completedAt: null,
          addedAt: DateTime.now(),
          addedBy: currentUser.id,
        );
        await repository.addItemToList(newItem);
      }
    }

    return result;
  }
}
```

### RN-L006: Favoritos

**Regra:**
- Usuários podem marcar listas como favoritas
- Favoritas aparecem no topo da lista
- Toggle simples (favoritar/desfavoritar)
- Não há limite de favoritas

**Implementação:**
```dart
class ToggleFavoriteUseCase {
  Future<Either<Failure, void>> call(String listId) async {
    final list = await repository.getList(listId);

    if (list == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    final updated = list.copyWith(
      isFavorite: !list.isFavorite,
      updatedAt: DateTime.now(),
    );

    return await repository.updateList(updated);
  }
}
```

---

## 🎯 Regras de Negócio - Itens

### RN-I001: Banco de ItemMaster (Itens Reutilizáveis)

**Conceito:**
- ItemMaster é um "template" de item que pode ser reutilizado
- Cada usuário tem seu próprio banco de ItemMasters
- ItemMasters são criados automaticamente ao adicionar um item novo
- ItemMasters podem ser editados (afeta apenas futuras adições)

**Regra:**
- Quando usuário adiciona um item:
  1. Sistema busca ItemMaster com nome similar (fuzzy match)
  2. Se existe: Usa o ItemMaster existente
  3. Se não existe: Cria novo ItemMaster automaticamente

**Implementação:**
```dart
class GetOrCreateItemMasterUseCase {
  Future<Either<Failure, ItemMaster>> call({
    required String name,
    ItemCategory? suggestedCategory,
  }) async {
    // Buscar ItemMaster similar
    final existing = await repository.findItemMasterByName(
      userId: currentUser.id,
      name: name,
      threshold: 0.85, // 85% de similaridade
    );

    if (existing != null) {
      // Incrementar contador de uso
      await repository.incrementUsageCount(existing.id);
      return Right(existing);
    }

    // Criar novo ItemMaster
    final category = suggestedCategory ??
                     await aiCategorizeItem(name); // IA sugere categoria

    final itemMaster = ItemMaster(
      id: const Uuid().v4(),
      name: name.trim(),
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: currentUser.id,
      usageCount: 1,
    );

    return await repository.createItemMaster(itemMaster);
  }
}
```

### RN-I002: Categorização Automática

**Regra:**
- Sistema sugere categoria baseada em:
  1. Nome do item (IA/ML simples)
  2. Histórico de categorizações do usuário
  3. Tipo da lista (se lista é "Supermercado", prioriza categorias de alimentos)

**Implementação:**
```dart
class AutoCategorizationService {
  ItemCategory suggestCategory(String itemName, {ListType? listType}) {
    final lowercaseName = itemName.toLowerCase();

    // Regras baseadas em palavras-chave
    if (_foodKeywords.any((kw) => lowercaseName.contains(kw))) {
      return ItemCategory.food;
    }

    if (_beverageKeywords.any((kw) => lowercaseName.contains(kw))) {
      return ItemCategory.beverages;
    }

    if (_cleaningKeywords.any((kw) => lowercaseName.contains(kw))) {
      return ItemCategory.cleaning;
    }

    if (_hygieneKeywords.any((kw) => lowercaseName.contains(kw))) {
      return ItemCategory.hygiene;
    }

    // Se tipo da lista for específico, usar categoria relacionada
    if (listType == ListType.shopping) {
      return ItemCategory.food; // assume alimentos por padrão
    }

    return ItemCategory.other;
  }

  // Palavras-chave por categoria
  static const _foodKeywords = ['leite', 'pão', 'arroz', 'feijão', 'macarrão', 'carne', 'frango', 'queijo', 'ovos'];
  static const _beverageKeywords = ['água', 'suco', 'refrigerante', 'café', 'chá', 'cerveja', 'vinho'];
  static const _cleaningKeywords = ['sabão', 'detergente', 'desinfetante', 'limpa', 'esponja', 'pano'];
  static const _hygieneKeywords = ['shampoo', 'sabonete', 'pasta', 'escova', 'papel higiênico', 'absorvente'];
}
```

### RN-I003: Adição de Itens às Listas

**Regra:**
- Itens podem ser adicionados de 3 formas:
  1. **Busca e Seleção**: Buscar no banco de ItemMasters
  2. **Criação Nova**: Digitar nome novo e criar
  3. **Quick Add**: Múltiplos itens de uma vez (separados por vírgula/linha)

**Validações:**
- Nome do item: 1-200 caracteres
- Quantidade: texto livre, 0-50 caracteres
- Nota: 0-500 caracteres
- Não pode adicionar item duplicado na mesma lista (mesmo ItemMaster)

**Implementação:**
```dart
class AddItemToListUseCase {
  Future<Either<Failure, ListItem>> call({
    required String listId,
    required String itemName,
    String? quantity,
    Priority priority = Priority.medium,
    String? note,
  }) async {
    // Validações
    if (itemName.trim().isEmpty || itemName.length > 200) {
      return Left(ValidationFailure('Nome inválido'));
    }

    if (quantity != null && quantity.length > 50) {
      return Left(ValidationFailure('Quantidade muito longa'));
    }

    // Verificar limite de itens (free tier)
    final limitCheck = await checkItemLimitUseCase.call(listId);
    if (limitCheck.isLeft()) return limitCheck;

    // Verificar duplicata
    final isDuplicate = await repository.isItemInList(listId, itemName);
    if (isDuplicate) {
      return Left(ValidationFailure('Item já está na lista'));
    }

    // Buscar ou criar ItemMaster
    final itemMasterResult = await getOrCreateItemMasterUseCase.call(
      name: itemName,
    );

    if (itemMasterResult.isLeft()) return itemMasterResult;

    final itemMaster = itemMasterResult.getOrElse(() => throw Exception());

    // Criar ListItem
    final listItem = ListItem(
      id: const Uuid().v4(),
      listId: listId,
      itemMasterId: itemMaster.id,
      quantity: quantity?.trim(),
      priority: priority,
      isCompleted: false,
      note: note?.trim(),
      order: await repository.getNextOrderInList(listId),
      addedAt: DateTime.now(),
      addedBy: currentUser.id,
    );

    return await repository.addItemToList(listItem);
  }
}
```

### RN-I004: Quick Add (Múltiplos Itens)

**Regra:**
- Usuário digita múltiplos itens separados por:
  - Vírgula: `Leite, Ovos, Pão`
  - Nova linha: `Leite\nOvos\nPão`
- Sistema processa cada item individualmente
- Ignora linhas vazias
- Trim() automático
- Se algum item falhar, continua com os outros e reporta erros no final

**Implementação:**
```dart
class QuickAddItemsUseCase {
  Future<Either<Failure, QuickAddResult>> call({
    required String listId,
    required String rawInput,
  }) async {
    // Separar por vírgula ou nova linha
    final items = rawInput
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return Left(ValidationFailure('Nenhum item válido encontrado'));
    }

    final results = <String, Either<Failure, ListItem>>{};

    for (final itemName in items) {
      final result = await addItemToListUseCase.call(
        listId: listId,
        itemName: itemName,
      );

      results[itemName] = result;
    }

    final succeeded = results.values.where((r) => r.isRight()).length;
    final failed = results.values.where((r) => r.isLeft()).length;

    return Right(QuickAddResult(
      total: items.length,
      succeeded: succeeded,
      failed: failed,
      results: results,
    ));
  }
}
```

### RN-I005: Limites de Itens

**Free Tier:**
- Máximo 200 ItemMasters no banco pessoal
- Cada lista pode ter até 100 itens
- Total combinado não pode exceder 200 itens em todas as listas

**Premium:**
- Itens ilimitados

**Implementação:**
```dart
class CheckItemLimitUseCase {
  Future<Either<Failure, bool>> call(String listId) async {
    final user = await getUserUseCase.call();

    if (user.isPremium) {
      return Right(true);
    }

    // Verificar limite de ItemMasters
    final itemMastersCount = await repository.getItemMastersCount(user.id);
    if (itemMastersCount >= 200) {
      return Left(LimitReachedFailure(
        'Você atingiu o limite de 200 itens únicos. '
        'Faça upgrade para Premium para itens ilimitados.'
      ));
    }

    // Verificar limite por lista
    final listItemsCount = await repository.getListItemsCount(listId);
    if (listItemsCount >= 100) {
      return Left(LimitReachedFailure(
        'Esta lista atingiu o limite de 100 itens. '
        'Faça upgrade para Premium.'
      ));
    }

    // Verificar limite total
    final totalItemsCount = await repository.getTotalItemsCount(user.id);
    if (totalItemsCount >= 200) {
      return Left(LimitReachedFailure(
        'Você atingiu o limite total de 200 itens. '
        'Faça upgrade para Premium.'
      ));
    }

    return Right(true);
  }
}
```

### RN-I006: Marcar Item como Concluído

**Regra:**
- Checkbox marca/desmarca item
- Item concluído:
  - Fica com texto riscado (strikethrough)
  - Move para o final da lista (opcional, configurável)
  - Registra timestamp de conclusão
  - Incrementa contador de completedCount da lista
- Item desmarcado:
  - Volta para posição original (ou mantém no final)
  - Remove timestamp
  - Decrementa contador

**Implementação:**
```dart
class ToggleItemCompletionUseCase {
  Future<Either<Failure, void>> call(String listItemId) async {
    final item = await repository.getListItem(listItemId);

    if (item == null) {
      return Left(NotFoundFailure('Item não encontrado'));
    }

    final isCompleting = !item.isCompleted;

    final updated = item.copyWith(
      isCompleted: isCompleting,
      completedAt: isCompleting ? DateTime.now() : null,
    );

    // Atualizar item
    await repository.updateListItem(updated);

    // Atualizar contador da lista
    final list = await repository.getList(item.listId);
    if (list != null) {
      final newCount = isCompleting
          ? list.completedCount + 1
          : list.completedCount - 1;

      await repository.updateList(list.copyWith(
        completedCount: newCount,
        updatedAt: DateTime.now(),
      ));
    }

    return Right(null);
  }
}
```

### RN-I007: Reordenação de Itens

**Regra:**
- Usuários podem arrastar e soltar itens para reordenar
- Ordem é persistida (campo `order` no ListItem)
- Ordem é específica por lista
- Ao adicionar novo item, recebe maior ordem + 1

**Implementação:**
```dart
class ReorderListItemsUseCase {
  Future<Either<Failure, void>> call({
    required String listId,
    required List<String> itemIdsInOrder,
  }) async {
    // Buscar todos os itens
    final items = await repository.getListItems(listId);

    // Criar mapa de ID -> Item
    final itemMap = {for (var item in items) item.id: item};

    // Atualizar ordem
    for (var i = 0; i < itemIdsInOrder.length; i++) {
      final itemId = itemIdsInOrder[i];
      final item = itemMap[itemId];

      if (item != null) {
        final updated = item.copyWith(order: i);
        await repository.updateListItem(updated);
      }
    }

    return Right(null);
  }
}
```

### RN-I008: Edição de ItemMaster

**Regra:**
- Usuários podem editar ItemMasters no banco global
- Alterações NÃO afetam ListItems já adicionados (apenas futuros)
- Pode alterar: nome, categoria, descrição, preço, marca, foto
- Não pode: alterar ID ou timestamps

**Implementação:**
```dart
class UpdateItemMasterUseCase {
  Future<Either<Failure, ItemMaster>> call({
    required String itemMasterId,
    String? name,
    ItemCategory? category,
    String? description,
    double? estimatedPrice,
    String? preferredBrand,
  }) async {
    final existing = await repository.getItemMaster(itemMasterId);

    if (existing == null) {
      return Left(NotFoundFailure('Item não encontrado'));
    }

    // Validações
    if (name != null && (name.trim().isEmpty || name.length > 200)) {
      return Left(ValidationFailure('Nome inválido'));
    }

    final updated = existing.copyWith(
      name: name ?? existing.name,
      category: category ?? existing.category,
      description: description ?? existing.description,
      estimatedPrice: estimatedPrice ?? existing.estimatedPrice,
      preferredBrand: preferredBrand ?? existing.preferredBrand,
      updatedAt: DateTime.now(),
    );

    return await repository.updateItemMaster(updated);
  }
}
```

---

## 🔗 Regras de Negócio - Compartilhamento

### RN-S001: Compartilhamento Simples (Read-Only)

**Conceito Simplificado:**
- Usuário gera link de compartilhamento da lista
- Link pode ser aberto por qualquer pessoa (com ou sem conta)
- Visualização é **read-only** (apenas visualizar)
- Quem abrir o link pode:
  - Ver todos os itens da lista
  - Ver itens marcados/desmarcados
  - NÃO pode editar, adicionar ou remover itens
  - PODE copiar a lista para sua própria conta (se tiver conta)

**Implementação:**
```dart
class GenerateShareLinkUseCase {
  Future<Either<Failure, String>> call(String listId) async {
    final list = await repository.getList(listId);

    if (list == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    if (list.ownerId != currentUser.id) {
      return Left(PermissionFailure('Apenas o dono pode compartilhar'));
    }

    // Gerar token único
    final shareToken = const Uuid().v4();

    // Salvar token
    await repository.saveShareToken(
      listId: listId,
      token: shareToken,
      createdAt: DateTime.now(),
      expiresAt: null, // Nunca expira (ou pode ter expiration)
    );

    // Gerar deep link
    final shareUrl = 'https://nebulalist.app/shared/$shareToken';

    return Right(shareUrl);
  }
}
```

### RN-S002: Copiar Lista Compartilhada

**Regra:**
- Usuário autenticado pode copiar lista compartilhada para sua conta
- Cria uma nova lista (ownership transfer)
- Copia todos os itens (mas não o estado de concluído)
- Lista copiada é independente da original

**Implementação:**
```dart
class CopySharedListUseCase {
  Future<Either<Failure, ListEntity>> call(String shareToken) async {
    // Verificar limite
    final limitCheck = await checkListLimitUseCase.call();
    if (limitCheck.isLeft()) return limitCheck;

    // Buscar lista pelo token
    final sharedList = await repository.getListByShareToken(shareToken);

    if (sharedList == null) {
      return Left(NotFoundFailure('Lista compartilhada não encontrada'));
    }

    // Copiar lista (similar a duplicação)
    final newList = sharedList.copyWith(
      id: const Uuid().v4(),
      name: '${sharedList.name} (compartilhada)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerId: currentUser.id,
      isFavorite: false,
      isArchived: false,
      completedCount: 0,
    );

    final result = await repository.createList(newList);

    if (result.isRight()) {
      // Copiar itens
      final items = await repository.getListItems(sharedList.id);
      for (final item in items) {
        // Buscar ou criar ItemMaster no banco do usuário atual
        final itemMaster = await repository.getItemMaster(item.itemMasterId);
        final newItemMaster = await getOrCreateItemMasterUseCase.call(
          name: itemMaster.name,
        );

        if (newItemMaster.isRight()) {
          final master = newItemMaster.getOrElse(() => throw Exception());

          final newItem = item.copyWith(
            id: const Uuid().v4(),
            listId: newList.id,
            itemMasterId: master.id,
            isCompleted: false,
            completedAt: null,
            addedAt: DateTime.now(),
            addedBy: currentUser.id,
          );

          await repository.addItemToList(newItem);
        }
      }
    }

    return result;
  }
}
```

### RN-S003: Revogar Compartilhamento

**Regra:**
- Dono pode revogar link de compartilhamento
- Ao revogar, link antigo para de funcionar
- Pode gerar novo link se quiser

**Implementação:**
```dart
class RevokeShareLinkUseCase {
  Future<Either<Failure, void>> call(String listId) async {
    final list = await repository.getList(listId);

    if (list == null) {
      return Left(NotFoundFailure('Lista não encontrada'));
    }

    if (list.ownerId != currentUser.id) {
      return Left(PermissionFailure('Apenas o dono pode revogar'));
    }

    // Remover todos os tokens de compartilhamento
    return await repository.revokeShareTokens(listId);
  }
}
```

---

## 💎 Regras de Negócio - Premium

### RN-P001: Verificação de Status Premium

**Regra:**
- Status premium é verificado via RevenueCat
- Cache local do status (refresh a cada app start)
- Se offline, usa cache (assume status anterior)
- Premium expira automaticamente se subscription cancelada

**Implementação:**
```dart
class CheckPremiumStatusUseCase {
  Future<Either<Failure, bool>> call({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        // Tentar usar cache
        final cached = await localDataSource.getPremiumStatus();
        if (cached != null && cached.isValid) {
          return Right(cached.isPremium);
        }
      }

      // Buscar do RevenueCat
      final purchaserInfo = await Purchases.getCustomerInfo();
      final isPremium = purchaserInfo.entitlements.active.containsKey('premium');

      // Salvar cache
      await localDataSource.savePremiumStatus(PremiumStatus(
        isPremium: isPremium,
        expiresAt: isPremium ? purchaserInfo.latestExpirationDate : null,
        cachedAt: DateTime.now(),
      ));

      return Right(isPremium);
    } catch (e) {
      // Se falhar, usar cache
      final cached = await localDataSource.getPremiumStatus();
      if (cached != null) {
        return Right(cached.isPremium);
      }

      return Left(NetworkFailure('Erro ao verificar status premium'));
    }
  }
}
```

### RN-P002: Enforcement de Limites

**Regra:**
- Limites são checados ANTES da ação
- Se limite atingido, mostrar paywall
- Premium remove todos os limites
- Se downgrade (premium -> free), listas/itens existentes não são deletados (apenas previne criação de novos)

**Implementação:**
```dart
class EnforceLimitsMiddleware {
  Future<Either<Failure, void>> checkBeforeCreate({
    required LimitType type,
  }) async {
    final premiumStatus = await checkPremiumStatusUseCase.call();

    if (premiumStatus.isRight() && premiumStatus.getOrElse(() => false)) {
      return Right(null); // Premium, sem limites
    }

    // Free tier, verificar limites
    switch (type) {
      case LimitType.lists:
        return await checkListLimitUseCase.call();
      case LimitType.items:
        return await checkItemLimitUseCase.call(listId);
    }
  }
}
```

### RN-P003: Paywall

**Regra:**
- Paywall é mostrado quando:
  1. Usuário atinge limite
  2. Usuário tenta acessar feature premium
  3. Periodicamente (a cada 10 listas criadas ou 50 itens)
- Paywall mostra benefícios e planos
- Pode fechar sem comprar (soft paywall)

**Implementação:**
```dart
class ShowPaywallUseCase {
  Future<void> call({
    required BuildContext context,
    PaywallTrigger trigger = PaywallTrigger.limitReached,
  }) async {
    // Analytics
    await analytics.logEvent(
      name: 'paywall_shown',
      parameters: {'trigger': trigger.name},
    );

    // Navegar para página premium
    await context.push(AppConstants.premiumRoute);
  }
}
```

---

## ✅ Validações e Constraints

### Validações de Input

**Lista:**
- Nome: Obrigatório, 1-100 caracteres, não apenas espaços
- Descrição: Opcional, max 500 caracteres
- Ícone: Deve estar em lista permitida (50+ opções)
- Cor: Hex válido #RRGGBB

**Item:**
- Nome: Obrigatório, 1-200 caracteres
- Quantidade: Opcional, 0-50 caracteres, texto livre
- Nota: Opcional, 0-500 caracteres
- Categoria: Enum válido

**Compartilhamento:**
- Token: UUID válido
- URL: Formato correto

### Constraints de Banco de Dados

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuários podem ler/escrever apenas seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Listas
    match /lists/{listId} {
      // Ler: Apenas dono
      allow read: if request.auth != null &&
                     resource.data.ownerId == request.auth.uid;

      // Criar: Apenas autenticado
      allow create: if request.auth != null &&
                       request.resource.data.ownerId == request.auth.uid;

      // Atualizar/Deletar: Apenas dono
      allow update, delete: if request.auth != null &&
                               resource.data.ownerId == request.auth.uid;
    }

    // ItemMasters
    match /itemMasters/{itemId} {
      // Apenas dono pode ver/editar seus itens
      allow read, write: if request.auth != null &&
                            resource.data.createdBy == request.auth.uid;
    }

    // ListItems
    match /listItems/{itemId} {
      // Apenas dono da lista pode ver/editar
      allow read, write: if request.auth != null &&
                            get(/databases/$(database)/documents/lists/$(resource.data.listId)).data.ownerId == request.auth.uid;
    }

    // Compartilhamentos (read-only)
    match /sharedLists/{token} {
      // Qualquer um pode ler (link público)
      allow read: if true;

      // Apenas dono pode criar/deletar
      allow write: if request.auth != null;
    }
  }
}
```

### Constraints de Hive (Local)

```dart
class HiveConstraints {
  static const int maxListsInCache = 1000;
  static const int maxItemsInCache = 10000;
  static const int cacheExpirationDays = 30;

  // Limpeza automática de cache antigo
  static Future<void> cleanOldCache() async {
    final box = Hive.box('cache');
    final now = DateTime.now();

    final keysToDelete = <String>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data is Map && data['cachedAt'] != null) {
        final cachedAt = DateTime.parse(data['cachedAt']);
        if (now.difference(cachedAt).inDays > cacheExpirationDays) {
          keysToDelete.add(key);
        }
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }
}
```

---

## 🔄 Lógica de Sincronização

### Estratégia: Offline-First com Eventual Consistency

**Conceito:**
1. Todas as operações são feitas primeiro localmente (Hive)
2. UI atualiza instantaneamente
3. Operação é enfileirada para sync
4. Quando online, sync automático
5. Em caso de conflito: Last Write Wins (LWW)

### Implementação

```dart
class SyncService {
  final Queue<SyncOperation> _queue = Queue();
  bool _isSyncing = false;

  // Adicionar operação à fila
  Future<void> enqueue(SyncOperation operation) async {
    _queue.add(operation);
    await _saveQueue();

    if (!_isSyncing) {
      unawaited(_processSyncQueue());
    }
  }

  // Processar fila de sync
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _queue.isEmpty) return;

    _isSyncing = true;

    try {
      // Verificar conectividade
      final isConnected = await connectivity.checkConnectivity();
      if (!isConnected) {
        _isSyncing = false;
        return;
      }

      while (_queue.isNotEmpty) {
        final operation = _queue.first;

        try {
          await _syncOperation(operation);
          _queue.removeFirst();
          await _saveQueue();
        } catch (e) {
          // Se falhar, manter na fila e tentar depois
          logError('Sync failed', error: e);
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  // Sincronizar operação individual
  Future<void> _syncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.createList:
        await _syncCreateList(operation.data);
        break;
      case SyncOperationType.updateList:
        await _syncUpdateList(operation.data);
        break;
      case SyncOperationType.deleteList:
        await _syncDeleteList(operation.data);
        break;
      case SyncOperationType.addItem:
        await _syncAddItem(operation.data);
        break;
      case SyncOperationType.updateItem:
        await _syncUpdateItem(operation.data);
        break;
      case SyncOperationType.deleteItem:
        await _syncDeleteItem(operation.data);
        break;
    }
  }

  // Sync completo (pull do servidor)
  Future<void> fullSync() async {
    final lastSyncTimestamp = await localDataSource.getLastSyncTimestamp();

    // Buscar dados modificados desde último sync
    final updatedLists = await firestore
        .collection('lists')
        .where('ownerId', isEqualTo: currentUser.id)
        .where('updatedAt', isGreaterThan: lastSyncTimestamp)
        .get();

    for (final doc in updatedLists.docs) {
      final list = ListModel.fromFirestore(doc);
      await localDataSource.saveList(list);
    }

    // Atualizar timestamp
    await localDataSource.saveLastSyncTimestamp(DateTime.now());
  }
}
```

### Resolução de Conflitos

**Estratégia: Last Write Wins (LWW)**

```dart
class ConflictResolver {
  Either<Failure, T> resolve<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    // Comparar timestamps
    if (remoteTimestamp.isAfter(localTimestamp)) {
      // Remoto é mais recente, usar remoto
      return Right(remote);
    } else {
      // Local é mais recente, usar local (e fazer push)
      return Right(local);
    }
  }
}
```

---

## 🛠️ Estratégias de Implementação

### Feature Flags

**Uso:**
- Habilitar/desabilitar features remotamente
- A/B testing
- Rollout gradual de features

```dart
class FeatureFlags {
  static const String quickAddEnabled = 'quick_add_enabled';
  static const String aiCategorizationEnabled = 'ai_categorization';
  static const String locationRemindersEnabled = 'location_reminders';

  Future<bool> isEnabled(String flagName) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetchAndActivate();
      return remoteConfig.getBool(flagName);
    } catch (e) {
      // Se falhar, usar valores padrão
      return _defaultValues[flagName] ?? false;
    }
  }

  static const _defaultValues = {
    quickAddEnabled: true,
    aiCategorizationEnabled: true,
    locationRemindersEnabled: false, // Premium feature
  };
}
```

### Analytics e Métricas

```dart
class AnalyticsEvents {
  // User Journey
  static const String listCreated = 'list_created';
  static const String itemAdded = 'item_added';
  static const String itemCompleted = 'item_completed';
  static const String listShared = 'list_shared';

  // Conversão
  static const String paywallShown = 'paywall_shown';
  static const String premiumPurchased = 'premium_purchased';
  static const String premiumRestored = 'premium_restored';

  // Engagement
  static const String sessionStart = 'session_start';
  static const String quickAddUsed = 'quick_add_used';
  static const String searchPerformed = 'search_performed';

  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
```

---

## 🧪 Testes Requeridos

### Testes Unitários (Use Cases)

**Cobertura Mínima: 80%**

```dart
// Exemplo: Test CreateListUseCase
void main() {
  late CreateListUseCase useCase;
  late MockListRepository mockRepository;

  setUp(() {
    mockRepository = MockListRepository();
    useCase = CreateListUseCase(mockRepository);
  });

  group('CreateListUseCase', () {
    test('should create list successfully', () async {
      // Arrange
      when(mockRepository.createList(any))
          .thenAnswer((_) async => Right(mockList));

      // Act
      final result = await useCase.call(name: 'Test List');

      // Assert
      expect(result.isRight(), true);
      verify(mockRepository.createList(any)).called(1);
    });

    test('should fail if name is empty', () async {
      // Act
      final result = await useCase.call(name: '');

      // Assert
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
    });

    test('should fail if name exceeds 100 characters', () async {
      // Act
      final result = await useCase.call(name: 'a' * 101);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### Testes de Integração

```dart
// Teste de fluxo completo: Criar lista e adicionar itens
void main() {
  testWidgets('Create list and add items flow', (tester) async {
    // Setup
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Login
    await loginAsTestUser(tester);

    // Criar lista
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Compras');
    await tester.tap(find.text('Criar'));
    await tester.pumpAndSettle();

    // Verificar lista criada
    expect(find.text('Compras'), findsOneWidget);

    // Abrir lista
    await tester.tap(find.text('Compras'));
    await tester.pumpAndSettle();

    // Adicionar item
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Leite');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    // Verificar item adicionado
    expect(find.text('Leite'), findsOneWidget);

    // Marcar como concluído
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Verificar item riscado
    // ... assertions
  });
}
```

---

## 📝 Conclusão

Este documento estabelece as regras de negócio e diretrizes técnicas para desenvolvimento do NebulaList. Todas as implementações devem seguir:

1. **Padrão Clean Architecture**
2. **Either<Failure, T>** para error handling
3. **Riverpod** para state management
4. **Offline-first** com Hive + Firebase
5. **Validações rigorosas** em todos os inputs
6. **Testes** com cobertura mínima de 80%
7. **Simplicidade** sobre complexidade

**Próximo passo:** Implementar Sprint 1 (Fundação) conforme PRODUCT_SPEC.md

---

**Última Atualização:** 15 de Outubro de 2025
**Versão do Documento:** 1.0.0
**Status:** Aprovado ✅

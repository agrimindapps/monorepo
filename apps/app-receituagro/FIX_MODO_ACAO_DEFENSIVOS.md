# Relatório de Correção: Modo de Ação em Defensivos

## Problema Identificado
1.  **Dashboard**: O card "Modo de Ação" exibia "0" registros.
2.  **Lista Agrupada**: Ao clicar no card, a lista exibia todos os itens como "Não especificado".

## Causa Raiz
- A extensão `FitossanitarioDriftExtension` tinha o getter `displayModoAcao` hardcoded para retornar `'Não especificado'`.
- O `HomeDefensivosNotifier` calculava as estatísticas baseando-se apenas na entidade `Fitossanitario` (Drift), que não possui o campo `modoAcao` (este campo reside na tabela `FitossanitariosInfo`).
- O `DefensivosRepositoryImpl` e o `DefensivoMapper` também não estavam cruzando os dados com a tabela `FitossanitariosInfo` ao criar as entidades de domínio, resultando em `modoAcao` nulo ou padrão.

## Solução Aplicada

### 1. Atualização do `HomeDefensivosNotifier`
- Injetado `FitossanitariosInfoRepository`.
- Atualizado o método `_loadStatisticsData` para buscar os dados de `FitossanitariosInfo`.
- Atualizado o método `_calculateStatistics` para aceitar um mapa de informações (`infoMap`) e usar o `modoAcao` correto para a contagem.

### 2. Atualização do `DefensivoMapper`
- Atualizados os métodos `fromHiveToEntity`, `fromHiveToEntityList`, `fromDriftToEntity` e `fromDriftToEntityList` para aceitar um parâmetro opcional `modoAcao` ou `infoMap`.
- Agora o mapper popula corretamente o campo `modoAcao` na `DefensivoEntity`.

### 3. Atualização do `DefensivosRepositoryImpl`
- Injetado `FitossanitariosInfoRepository`.
- Criado método auxiliar `_fetchInfoMap` para buscar informações complementares.
- Atualizados todos os métodos de busca (`getAllDefensivos`, `getDefensivosAgrupados`, `getDefensivosCompletos`, etc.) para buscar as informações complementares e passá-las ao mapper.

## Resultado Esperado
- **Dashboard**: O card "Modo de Ação" deve exibir a contagem correta de modos de ação distintos (excluindo "Não especificado").
- **Lista Agrupada**: A lista de defensivos agrupados por modo de ação deve exibir os nomes corretos dos modos de ação em vez de "Não especificado".

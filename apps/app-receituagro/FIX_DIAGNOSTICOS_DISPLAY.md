# Relatório de Correção: Exibição de Diagnósticos

## Problema Identificado
Os diagnósticos nas páginas de detalhes (especialmente de defensivos) não estavam exibindo corretamente:
- Dosagens
- Nome científico da praga
- Nome comum da praga

## Causa Raiz
Os widgets `DiagnosticoDefensivoListItemWidget` e `DiagnosticoDefensivoDialogWidget` estavam tentando acessar propriedades diretamente do objeto `Diagnostico` (Drift) que não existiam ou não estavam mapeadas corretamente.
- A entidade `Diagnostico` gerada pelo Drift não possui getters diretos como `dosagem` (possui `dsMin`, `dsMax`, `um`).
- O campo `pragaId` não estava sendo mapeado no helper `_getProperty`, impedindo o carregamento dos dados da praga (necessário para exibir nome científico e comum).

## Solução Aplicada

### 1. Atualização de `list_item_widget.dart`
- Importada a extensão `DiagnosticoDriftExtension`.
- Atualizado o método `_getProperty` para detectar objetos do tipo `Diagnostico`.
- Mapeado o campo `dosagem` para usar `displayDosagem` da extensão (que formata corretamente `dsMin`, `dsMax` e `um`).
- Mapeado `fkIdPraga`/`idPraga` para `pragaId` da entidade.
- Adicionada lógica para sobrescrever o nome comum da praga com o nome carregado do repositório (`_pragaData.nome`), garantindo que "Praga não identificada" seja substituído pelo nome correto.

### 2. Atualização de `dialog_widget.dart`
- Importada a extensão `DiagnosticoDriftExtension`.
- Atualizado o método `_getProperty` para suportar `Diagnostico`.
- Mapeados campos de formatação: `dosagem`, `aplicacaoTerrestre`, `aplicacaoAerea`, `intervaloDias` usando os getters da extensão.
- Mapeado `pragaId` para permitir o carregamento da praga.
- Corrigido `_buildModernHeader` para usar `widget.defensivoName` como fallback se o nome não estiver no objeto de diagnóstico.
- Corrigido `_buildPragaImageSection` para usar o nome da praga carregada (`_pragaData.nome`) ao invés de depender apenas da propriedade do diagnóstico.

## Resultado Esperado
- **Dosagem**: Agora deve aparecer formatada (ex: "100 - 200 ml/ha").
- **Nome Científico**: Deve aparecer corretamente abaixo do nome comum, pois a praga agora é carregada corretamente via `pragaId`.
- **Nome Comum**: Deve aparecer o nome correto da praga, vindo do banco de dados de pragas.

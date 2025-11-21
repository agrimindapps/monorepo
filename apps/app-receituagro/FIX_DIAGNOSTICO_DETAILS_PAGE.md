# Relatório de Correção: Página de Detalhes do Diagnóstico

## Problema Identificado
A página de detalhes do diagnóstico (`DetalheDiagnosticoPage`) exibia informações incorretas ou genéricas (ex: "Praga não identificada") quando os dados passados pela tela anterior estavam incompletos, mesmo que o sistema já tivesse carregado os dados corretos internamente.
Além disso, a imagem da praga muitas vezes não carregava porque o widget tentava usar o nome comum para buscar o arquivo de imagem, em vez do nome científico.

## Solução Aplicada

### 1. Atualização de `DetalheDiagnosticoPage`
- Modificada a lógica de construção da interface para priorizar os dados resolvidos pelo `DetalheDiagnosticoNotifier` (via `DiagnosticoDriftExtension`) em vez dos parâmetros recebidos no construtor.
- Agora, se o `Notifier` conseguir resolver o nome da praga, defensivo ou cultura no banco de dados, esses valores serão usados na exibição.

### 2. Atualização de `DiagnosticoInfoWidget`
- Adicionada lógica para usar o `nomeCientifico` (vindo de `diagnosticoData`) para buscar a imagem da praga. Isso corrige o problema de imagens não carregando.
- Adicionado campo de texto para exibir o nome científico em itálico abaixo do nome comum da praga, melhorando a informação para o usuário.

## Resultado Esperado
- **Nome da Praga**: Deve exibir o nome correto (ex: "Lagarta-do-cartucho") mesmo se a tela anterior passar "Praga não identificada".
- **Imagem da Praga**: Deve carregar corretamente a imagem correspondente à praga.
- **Nome Científico**: Deve aparecer logo abaixo do nome comum.
- **Dados Técnicos**: Continuam sendo exibidos corretamente (dosagem, vazão, etc.) pois já utilizavam o mapa de dados formatado.

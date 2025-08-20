# Issues e Melhorias - index.dart (Déficit/Superávit Calórico)

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [SECURITY] - Validação de entrada inadequada pode causar crashes
2. [BUG] - Erro de parsing sem tratamento pode quebrar aplicação
3. [REFACTOR] - Lógica de negócio misturada com apresentação
4. [TODO] - Funcionalidade de histórico e acompanhamento ausente

### 🟡 Complexidade MÉDIA (6 issues)  
5. [OPTIMIZE] - Rebuilds desnecessários da interface por uso incorreto do Consumer
6. [STYLE] - Código duplicado entre diálogos de informação
7. [TODO] - Sistema de persistência local para preservar dados inseridos
8. [FIXME] - Constante hardcoded de calorias mínimas não considera diferença de gênero
9. [DOC] - Documentação técnica das fórmulas utilizadas ausente
10. [TEST] - Ausência completa de testes unitários para validar cálculos

### 🟢 Complexidade BAIXA (8 issues)
11. [STYLE] - Strings hardcoded impedem internacionalização
12. [TODO] - Melhorias de UX com feedback visual para ações do usuário
13. [OPTIMIZE] - Máscaras de input podem ser reutilizadas
14. [STYLE] - Magic numbers espalhados pelo código sem constantes
15. [TODO] - Função de exportar resultados em PDF ausente
16. [FIXME] - Tratamento inconsistente de vírgula decimal
17. [STYLE] - Widgets poderiam ser extraídos para melhor organização
18. [TODO] - Validação de ranges realistas para entradas do usuário

---

## 🔴 Complexidade ALTA

### 1. [SECURITY] - Validação de entrada inadequada pode causar crashes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O método calcular() do controller faz parsing direto dos valores dos 
campos de texto sem verificação adequada de formato. Valores inválidos ou 
extremamente altos podem causar crashes da aplicação ou resultados incorretos 
que podem prejudicar a saúde do usuário.

**Prompt de Implementação:**
```
Implemente validação robusta de entrada no DeficitSuperavitController. Adicione 
verificações para: valores não numéricos, números negativos, zeros, valores 
extremamente altos (mais de 10000 kcal diárias, mais de 100kg de meta, mais de 
200 semanas). Retorne mensagens de erro específicas para cada tipo de problema. 
Adicione try-catch nos parsing de double e int. Use ranges realistas baseados em 
padrões nutricionais seguros.
```

**Dependências:** controller/deficit_superavit_controller.dart, model/deficit_superavit_model.dart

**Validação:** Testar com valores extremos, strings vazias, caracteres especiais e 
confirmar que não há crashes

---

### 2. [BUG] - Erro de parsing sem tratamento pode quebrar aplicação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** As linhas de parsing (double.parse, int.parse) não possuem 
tratamento de exceção. Se o usuário inserir texto inválido ou caracteres 
especiais, a aplicação irá crashar com FormatException.

**Prompt de Implementação:**
```
Envolva todos os parsing de números no DeficitSuperavitController com blocos 
try-catch. Para cada exceção capturada, exiba mensagem de erro específica 
indicando qual campo está com formato inválido. Implemente função auxiliar 
validateNumericInput que retorna null se válido ou string de erro se inválido. 
Use esta função antes de qualquer parsing.
```

**Dependências:** controller/deficit_superavit_controller.dart

**Validação:** Inserir texto, símbolos e caracteres especiais nos campos e 
confirmar que não há crashes

---

### 3. [REFACTOR] - Lógica de negócio misturada com apresentação

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O arquivo index.dart contém tanto lógica de apresentação quanto 
regras de negócio (como o diálogo de informações com texto educativo). Isso 
dificulta manutenção e testes. A responsabilidade de exibir informações 
educativas deveria estar em um service separado.

**Prompt de Implementação:**
```
Crie um DeficitSuperavitEducationService que contenha todo o texto educativo e 
recomendações. Extraia o método _showInfoDialog para um widget separado 
InfoDialogWidget que receba o conteúdo como parâmetro. Mova constantes como 
strings de texto para um arquivo de constantes. Implemente um 
DeficitSuperavitHelper para funções utilitárias. Mantenha o index.dart focado 
apenas na composição de widgets.
```

**Dependências:** Criar services/deficit_superavit_education_service.dart, 
widgets/info_dialog_widget.dart, constants/deficit_superavit_constants.dart

**Validação:** Verificar que funcionalidade permanece idêntica mas código está 
mais organizado e testável

---

### 4. [TODO] - Funcionalidade de histórico e acompanhamento ausente

**Status:** 🔴 Pendente | **Execução:** Muito Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Uma calculadora de déficit calórico seria muito mais útil se 
permitisse acompanhar o progresso ao longo do tempo, salvando cálculos 
anteriores e mostrando gráficos de evolução. Atualmente cada cálculo é isolado.

**Prompt de Implementação:**
```
Projete e implemente sistema de histórico que salve cada cálculo realizado com 
timestamp. Crie model HistoricoCalculo com todos os dados de entrada e 
resultados. Implemente repository usando SharedPreferences para persistir dados. 
Adicione tela de histórico com lista de cálculos anteriores e gráfico simples 
mostrando evolução das metas calóricas ao longo do tempo. Adicione botão na 
AppBar para acessar histórico.
```

**Dependências:** Criar models/historico_calculo_model.dart, 
repositories/historico_repository.dart, pages/historico_page.dart, instalar 
fl_chart para gráficos

**Validação:** Realizar vários cálculos, verificar se são salvos e se aparecem 
corretamente no histórico

---

## 🟡 Complexidade MÉDIA

### 5. [OPTIMIZE] - Rebuilds desnecessários da interface por uso incorreto do Consumer

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O Consumer está envolvendo todo o Scaffold, causando rebuild 
completo da interface a cada notifyListeners(). Partes estáticas como AppBar 
não precisam ser reconstruídas.

**Prompt de Implementação:**
```
Reestruture o uso do Consumer para abranger apenas as partes que realmente 
mudam: o formulário e o card de resultado. Extraia AppBar e elementos estáticos 
para fora do Consumer. Use Selector onde apenas propriedades específicas do 
model são necessárias. Implemente const constructors em widgets que não mudam.
```

**Dependências:** index.dart, widgets relacionados

**Validação:** Usar Flutter Inspector para confirmar redução nos rebuilds

---

### 6. [STYLE] - Código duplicado entre diálogos de informação

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _showInfoDialog tem estrutura duplicada para diferentes 
tipos de informação. A estrutura do diálogo é sempre a mesma, mudando apenas o 
conteúdo.

**Prompt de Implementação:**
```
Crie widget GenericInfoDialog que receba título, ícone, conteúdo e cor como 
parâmetros. Extraia o conteúdo específico para classes de dados 
InfoDialogContent. Substitua o método _showInfoDialog por chamadas ao widget 
genérico passando o conteúdo apropriado para déficit ou superávit.
```

**Dependências:** widgets/generic_info_dialog.dart, models/info_dialog_content.dart

**Validação:** Confirmar que ambos os diálogos funcionam identicamente ao original

---

### 7. [TODO] - Sistema de persistência local para preservar dados inseridos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Quando o usuário navega para outra tela ou fecha o app, todos os 
dados inseridos são perdidos. Isso é frustrante para o usuário que precisa 
reinserir tudo.

**Prompt de Implementação:**
```
Implemente persistência automática usando SharedPreferences. Salve os valores 
dos campos sempre que houver alteração. Carregue valores salvos na inicialização 
do controller. Adicione opção para limpar dados salvos. Implemente também 
funcionalidade de salvar cálculos favoritos ou mais utilizados.
```

**Dependências:** controller/deficit_superavit_controller.dart, adicionar 
shared_preferences no pubspec.yaml

**Validação:** Inserir dados, fechar app, reabrir e verificar se dados foram 
restaurados

---

### 8. [FIXME] - Constante hardcoded de calorias mínimas não considera diferença de gênero

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Médio | **Benefício:** Médio

**Descrição:** A constante MINIMO_CALORIAS_DIARIAS é fixa em 1200, mas padrões 
nutricionais recomendam 1200 para mulheres e 1500 para homens. Isso pode levar 
a recomendações inadequadas.

**Prompt de Implementação:**
```
Adicione campo gênero ao DeficitSuperavitModel. Crie enum Genero com MASCULINO e 
FEMININO. Substitua constante única por função getMinimoCalorias(Genero genero) 
que retorna 1200 para mulher e 1500 para homem. Adicione seletor de gênero no 
formulário. Atualize validações e mensagens para usar o mínimo adequado.
```

**Dependências:** model/deficit_superavit_model.dart, 
widgets/deficit_superavit_form.dart, controller/deficit_superavit_controller.dart

**Validação:** Testar cálculos com ambos os gêneros e confirmar que mínimos 
diferentes são aplicados

---

### 9. [DOC] - Documentação técnica das fórmulas utilizadas ausente

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O código usa fórmulas nutricionais importantes (7700 kcal por kg) 
mas não há documentação explicando a origem dessas fórmulas ou suas limitações 
científicas.

**Prompt de Implementação:**
```
Adicione documentação detalhada no DeficitSuperavitModel explicando cada 
fórmula usada, suas bases científicas e limitações. Documente a origem da 
constante 7700 kcal/kg. Adicione comentários sobre quando os cálculos podem não 
ser precisos. Crie arquivo README específico para a funcionalidade explicando 
metodologia e referências científicas.
```

**Dependências:** model/deficit_superavit_model.dart, criar 
docs/deficit_superavit_README.md

**Validação:** Revisar se documentação está clara e tecnicamente correta

---

### 10. [TEST] - Ausência completa de testes unitários para validar cálculos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Cálculos nutricionais são críticos para a saúde do usuário mas 
não possuem testes automatizados. Mudanças futuras podem introduzir bugs nos 
cálculos sem detecção.

**Prompt de Implementação:**
```
Crie suite completa de testes unitários para DeficitSuperavitModel cobrindo 
todos os cenários: déficit normal, superávit normal, ajuste para mínimo de 
calorias, valores extremos, casos limite. Teste controller para validações de 
entrada. Crie testes de widget para formulário. Implemente golden tests para 
telas principais garantindo consistência visual.
```

**Dependências:** Criar test/deficit_superavit_test.dart, 
test/widget_test/deficit_superavit_form_test.dart

**Validação:** Executar tests e garantir 100% de cobertura nas funções críticas

---

## 🟢 Complexidade BAIXA

### 11. [STYLE] - Strings hardcoded impedem internacionalização

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Todas as strings estão hardcoded no código, dificultando 
tradução futura da aplicação para outros idiomas.

**Prompt de Implementação:**
```
Extraia todas as strings para arquivo de constantes DeficitSuperavitStrings. 
Organize por categoria: labels de campos, mensagens de erro, textos educativos, 
títulos. Substitua strings hardcoded por referências às constantes. Prepare 
estrutura para futura implementação de i18n.
```

**Dependências:** Criar constants/deficit_superavit_strings.dart

**Validação:** Confirmar que toda funcionalidade textual permanece idêntica

---

### 12. [TODO] - Melhorias de UX com feedback visual para ações do usuário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A interface não fornece feedback visual adequado durante ações 
como cálculo, limpeza ou compartilhamento. Usuário não tem certeza se ação foi 
processada.

**Prompt de Implementação:**
```
Adicione loading indicator durante cálculo. Implemente animação de sucesso 
quando cálculo completa. Adicione confirmação visual para ação de limpar 
campos. Implemente feedback tátil (haptic feedback) em ações importantes. 
Adicione subtle animations para melhorar percepção de responsividade.
```

**Dependências:** widgets/deficit_superavit_form.dart, 
controller/deficit_superavit_controller.dart

**Validação:** Testar todas as ações e confirmar feedback visual apropriado

---

### 13. [OPTIMIZE] - Máscaras de input podem ser reutilizadas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** As máscaras MaskTextInputFormatter são criadas individualmente 
em cada widget, mas poderiam ser centralizadas e reutilizadas.

**Prompt de Implementação:**
```
Crie classe InputMasks com factory methods para diferentes tipos de máscara 
(peso, calorias, tempo). Substitua criação individual de máscaras por 
referências à classe centralizada. Implemente masks mais sofisticadas se 
necessário (ex: permitir decimais em peso).
```

**Dependências:** Criar utils/input_masks.dart, 
widgets/deficit_superavit_form.dart

**Validação:** Confirmar que comportamento das máscaras permanece idêntico

---

### 14. [STYLE] - Magic numbers espalhados pelo código sem constantes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Números como 7700 (calorias por kg), 1200 (calorias mínimas), 12 
(semanas padrão) estão espalhados sem explicação do seu significado.

**Prompt de Implementação:**
```
Crie arquivo constants/nutrition_constants.dart com todas as constantes 
nutricionais bem documentadas. Substitua magic numbers por constantes nomeadas. 
Adicione comentários explicando origem científica de cada valor. Organize 
constantes por categoria: calorias, tempo, limites de segurança.
```

**Dependências:** Criar constants/nutrition_constants.dart

**Validação:** Confirmar que todos os cálculos permanecem idênticos

---

### 15. [TODO] - Função de exportar resultados em PDF ausente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários podem querer salvar ou imprimir resultados do cálculo 
para acompanhamento com profissionais de saúde, mas só existe compartilhamento 
como texto.

**Prompt de Implementação:**
```
Implemente funcionalidade de export para PDF usando package pdf. Crie layout 
profissional incluindo logo, dados de entrada, resultados calculados, 
recomendações nutricionais e disclaimers. Adicione botão de export no card de 
resultado. Permita salvar arquivo ou compartilhar diretamente.
```

**Dependências:** Adicionar pdf e printing packages, criar 
services/pdf_export_service.dart

**Validação:** Gerar PDF e confirmar que contém todas as informações relevantes

---

### 16. [FIXME] - Tratamento inconsistente de vírgula decimal

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns campos fazem replaceAll(',', '.') mas outros não. Isso 
pode causar inconsistência na entrada de dados dependendo da localização do 
usuário.

**Prompt de Implementação:**
```
Crie função utilitária parseLocalizedNumber que trata consistentemente vírgulas 
e pontos decimais. Use esta função em todos os parsing de números. Considere 
implementar formatação de saída que respeite localização do usuário (vírgula 
para português, ponto para inglês).
```

**Dependências:** Criar utils/number_utils.dart, atualizar controller

**Validação:** Testar entrada com vírgulas e pontos em diferentes localizações

---

### 17. [STYLE] - Widgets poderiam ser extraídos para melhor organização

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Widgets complexos como o seletor de tipo de meta estão misturados 
no código do formulário principal, dificultando leitura e reutilização.

**Prompt de Implementação:**
```
Extraia widgets específicos para arquivos separados: MetaTypeSelector, 
EducationalInfoCard, ResultSummaryCard. Mantenha cada widget focado em uma 
responsabilidade específica. Implemente proper props e callbacks para 
comunicação. Organize em subpasta widgets/components/.
```

**Dependências:** Criar widgets/components/meta_type_selector.dart e outros

**Validação:** Confirmar que interface e funcionalidade permanecem idênticas

---

### 18. [TODO] - Validação de ranges realistas para entradas do usuário

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há validação se valores inseridos estão em ranges realistas. 
Usuário pode inserir 50000 calorias diárias ou meta de perder 200kg sem aviso.

**Prompt de Implementação:**
```
Implemente validação de ranges baseada em padrões nutricionais: calorias entre 
800-6000, meta de peso entre 0.1-50kg, tempo entre 1-104 semanas. Exiba warnings 
para valores extremos mas permita continuação. Adicione tooltips explicando 
ranges recomendados. Implemente validação em tempo real nos campos.
```

**Dependências:** controller/deficit_superavit_controller.dart, 
widgets/deficit_superavit_form.dart

**Validação:** Testar com valores extremos e confirmar que warnings aparecem 
apropriadamente

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Relacionados:** Issues #1, #2 e #8 são críticas para segurança nutricional. 
Issues #3 e #10 melhoram arquitetura. Issues #4 e #7 adicionam valor significativo.

---
*Relatório gerado em 13 de junho de 2025 para arquivo deficit_superavit/index.dart*

# Issues e Melhorias - Álcool no Sangue (TAS)

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [REFACTOR] - Separar lógica de validação do controller
2. [SECURITY] - Implementar validação robusta de entrada
3. [BUG] - Corrigir falta de feedback visual para validações
4. [OPTIMIZE] - Implementar debounce na validação de campos
5. [TODO] - Adicionar persistência de dados entre sessões

### 🟡 Complexidade MÉDIA (7 issues)  
6. [REFACTOR] - Extrair AppBar personalizada como componente reutilizável
7. [TODO] - Implementar conversões automáticas de unidades
8. [STYLE] - Padronizar responsividade em diferentes tamanhos de tela
9. [TODO] - Adicionar funcionalidade de histórico de cálculos
10. [OPTIMIZE] - Melhorar performance de renderização dos widgets
11. [TODO] - Implementar modo de comparação entre diferentes cenários
12. [STYLE] - Melhorar tema dark/light nos componentes visuais

### 🟢 Complexidade BAIXA (8 issues)
13. [STYLE] - Padronizar formatação de números decimais
14. [TODO] - Adicionar mais tipos de bebidas predefinidas
15. [DOC] - Melhorar documentação da fórmula no dialog de informações
16. [STYLE] - Ajustar espaçamentos e alinhamentos inconsistentes
17. [TODO] - Adicionar tooltips explicativos nos campos
18. [OPTIMIZE] - Implementar validação em tempo real nos campos
19. [TODO] - Adicionar suporte para diferentes fórmulas de cálculo
20. [TEST] - Implementar testes unitários para cálculos e validações

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separar lógica de validação do controller

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller possui validações hardcoded misturadas com lógica 
de negócio. A função validarCampo é muito específica e deveria estar em um 
service separado para melhor organização e reutilização.

**Prompt de Implementação:**
```
Crie um arquivo validation_service.dart na pasta services dentro do módulo 
alcool_sangue. Mova toda a lógica de validação do controller para este service, 
incluindo validação de campos vazios, ranges de valores e mensagens específicas. 
O service deve retornar objetos ValidationResult com sucesso/erro e mensagens. 
Atualize o controller para usar este service e mantenha apenas a orquestração 
do fluxo de dados.
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- services/validation_service.dart (novo arquivo)

**Validação:** Verificar se todas as validações funcionam corretamente e se 
as mensagens de erro são exibidas adequadamente

---

### 2. [SECURITY] - Implementar validação robusta de entrada

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A validação atual apenas verifica ranges básicos, mas não trata 
adequadamente caracteres especiais, strings maliciosas ou valores que podem 
causar overflow na fórmula matemática.

**Prompt de Implementação:**
```
Implemente validação robusta para todos os campos numéricos. Adicione 
verificações para caracteres especiais maliciosos, inputs excessivamente 
longos, formatação inválida e valores que podem causar overflow matemático. 
Crie sanitização de entrada que limpe dados antes do processamento. Implemente 
também validação de combinações perigosas (ex: álcool muito alto + volume 
muito grande).
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- widgets/alcool_sangue_form.dart
- utils/security_utils.dart (novo arquivo)

**Validação:** Testar com entradas maliciosas, valores extremos e caracteres 
especiais para garantir que não há crashes ou comportamentos inesperados

---

### 3. [BUG] - Corrigir falta de feedback visual para validações

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** As validações do controller retornam mensagens de erro mas não 
há feedback visual adequado para o usuário. Os campos não mostram estado de 
erro e o foco é movido sem indicação clara do problema.

**Prompt de Implementação:**
```
Implemente feedback visual completo para validações. Adicione estados de erro 
nos TextFields com bordas vermelhas e mensagens inline. Implemente SnackBars 
ou Toasts para erros de validação. Adicione indicadores visuais de carregamento 
durante cálculos e estados de sucesso quando cálculo é completado. Garanta que 
o foco seja movido para campos com erro com indicação visual clara.
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- widgets/alcool_sangue_form.dart
- index.dart

**Validação:** Testar todos os cenários de validação e verificar se o feedback 
visual é claro e útil para o usuário

---

### 4. [OPTIMIZE] - Implementar debounce na validação de campos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há validação em tempo real nos campos. A validação só ocorre 
ao clicar em calcular, tornando a experiência menos fluida. Seria benéfico ter 
feedback durante a digitação.

**Prompt de Implementação:**
```
Implemente debounce nos campos de entrada para validação em tempo real. 
Adicione listeners nos TextEditingController que acionem validação após 
500ms de inatividade. Mostre feedback visual imediato (bordas vermelhas/verdes) 
sem usar SnackBars intrusivos. Implemente também validação automática ao 
perder foco dos campos e recálculo automático quando todos os campos estão 
válidos.
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- widgets/alcool_sangue_form.dart

**Validação:** Testar digitação rápida e verificar se a validação não 
interfere na experiência do usuário

---

### 5. [TODO] - Adicionar persistência de dados entre sessões

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há persistência dos dados inseridos. Se o usuário sair da 
tela acidentalmente, perde todos os dados. Para uma calculadora médica, isso 
é crítico.

**Prompt de Implementação:**
```
Implemente persistência usando SharedPreferences para salvar automaticamente 
os valores dos campos conforme o usuário digita. Restaure os dados ao retornar 
à tela. Salve também o último resultado calculado. Adicione opção de limpar 
dados persistidos. Implemente também autosave que salva periodicamente 
durante a digitação para evitar perda de dados.
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- services/storage_service.dart (novo arquivo)
- pubspec.yaml (shared_preferences)

**Validação:** Verificar se os dados são restaurados corretamente após restart 
do app e se a funcionalidade não impacta performance

---

## 🟡 Complexidade MÉDIA

### 6. [REFACTOR] - Extrair AppBar personalizada como componente reutilizável

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A AppBar com ícone, título e ação de informações está hardcoded 
no index.dart. Este padrão se repete em outras calculadoras e deveria ser 
um componente reutilizável.

**Prompt de Implementação:**
```
Crie um widget CustomCalculatorAppBar na pasta core/widgets que receba título, 
ícone e ações como parâmetros. Extraia a lógica atual da AppBar do index.dart 
para este novo widget. Atualize o index.dart para usar o novo componente. 
O widget deve ser flexível para ser usado em outras calculadoras mantendo 
consistência visual.
```

**Dependências:** 
- index.dart
- core/widgets/custom_calculator_appbar.dart (novo arquivo)

**Validação:** Verificar se a AppBar funciona corretamente e mantém o mesmo 
visual e funcionalidade

---

### 7. [TODO] - Implementar conversões automáticas de unidades

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O app só aceita medidas em ml, horas e kg. Usuários podem querer 
inserir em diferentes unidades (copos, minutos, libras) especialmente em 
contextos internacionais.

**Prompt de Implementação:**
```
Adicione seletor de unidades para cada campo: volume (ml, L, oz, copos), 
tempo (minutos, horas), peso (kg, lb). Implemente conversão automática para 
as unidades padrão da fórmula. Atualize labels e placeholders conforme a 
unidade selecionada. Mantenha a fórmula funcionando corretamente com todas 
as combinações de unidades.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- controller/alcool_sangue_controller.dart
- utils/conversion_utils.dart (novo arquivo)

**Validação:** Testar cálculos com diferentes combinações de unidades e 
verificar se as conversões estão corretas

---

### 8. [STYLE] - Padronizar responsividade em diferentes tamanhos de tela

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Os componentes têm tratamentos inconsistentes para diferentes 
tamanhos de tela. Alguns widgets adaptam (como result), outros não (como form). 
Falta padronização.

**Prompt de Implementação:**
```
Padronize responsividade em todos os widgets usando MediaQuery consistentemente. 
Defina breakpoints padrão (small: <400px, medium: 400-800px, large: >800px). 
Ajuste padding, margins, tamanhos de fonte e layout conforme o tamanho da tela. 
Crie mixins ou utilities para responsividade que possam ser reutilizados em 
outros módulos.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- widgets/alcool_sangue_result.dart
- widgets/alcool_sangue_info.dart
- core/utils/responsive_utils.dart (novo arquivo)

**Validação:** Testar em diferentes tamanhos de tela e orientações

---

### 9. [TODO] - Adicionar funcionalidade de histórico de cálculos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há histórico dos cálculos realizados. Para uma calculadora 
médica, seria útil acompanhar evolução de TAS ao longo do tempo ou comparar 
diferentes cenários.

**Prompt de Implementação:**
```
Implemente sistema de histórico que salva localmente os cálculos realizados 
com timestamp. Adicione botão para visualizar histórico com lista dos últimos 
cálculos. Permita visualizar detalhes de cada cálculo anterior e restaurar 
valores nos campos. Implemente funcionalidade de deletar entradas e exportar 
histórico. Limite a 50 entradas mais recentes.
```

**Dependências:** 
- controller/alcool_sangue_controller.dart
- widgets/history_dialog.dart (novo arquivo)
- services/history_service.dart (novo arquivo)

**Validação:** Verificar se histórico persiste entre sessões e se interface 
é usável

---

### 10. [OPTIMIZE] - Melhorar performance de renderização dos widgets

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O AlcoolSangueResult reconstrói completamente a cada mudança, 
mesmo quando só pequenas partes mudam. Falta granularidade na atualização 
da interface.

**Prompt de Implementação:**
```
Otimize renderização dividindo AlcoolSangueResult em widgets menores e mais 
específicos. Use Consumer com builders específicos para cada seção. Implemente 
memoização onde apropriado para evitar recálculos desnecessários. Adicione 
Keys estáticas em widgets que não mudam. Use const constructors onde possível.
```

**Dependências:** 
- widgets/alcool_sangue_result.dart
- controller/alcool_sangue_controller.dart

**Validação:** Usar Flutter Inspector para verificar redução de rebuilds e 
medir performance

---

### 11. [TODO] - Implementar modo de comparação entre diferentes cenários

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Seria útil comparar diferentes cenários (diferentes bebidas, 
tempos, pesos) lado a lado para entender como cada fator afeta o TAS.

**Prompt de Implementação:**
```
Adicione modo de comparação que permite calcular múltiplos cenários 
simultaneamente. Implemente interface com abas ou cards para diferentes 
cenários. Permita copiar dados de um cenário para outro. Adicione visualização 
comparativa dos resultados em formato de tabela ou gráfico simples. Limite 
a 3-4 cenários simultâneos para não sobrecarregar a interface.
```

**Dependências:** 
- index.dart
- widgets/comparison_widget.dart (novo arquivo)
- controller/comparison_controller.dart (novo arquivo)

**Validação:** Verificar se comparação funciona corretamente e se interface 
permanece usável

---

### 12. [STYLE] - Melhorar tema dark/light nos componentes visuais

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Alguns componentes não adaptam adequadamente ao tema escuro, 
especialmente cores dos gráficos, bordas e indicadores visuais do TAS gauge.

**Prompt de Implementação:**
```
Atualize todos os componentes para usar corretamente o ThemeData do Flutter. 
Substitua cores hardcoded por referências ao tema atual. Implemente variantes 
dark/light para o TAS gauge, cards de informação e todos os elementos visuais. 
Teste comportamento em ambos os temas garantindo boa legibilidade e contraste.
```

**Dependências:** 
- widgets/alcool_sangue_result.dart
- widgets/alcool_sangue_form.dart
- widgets/alcool_sangue_info.dart

**Validação:** Alternar entre temas e verificar se todos os elementos ficam 
visíveis com bom contraste

---

## 🟢 Complexidade BAIXA

### 13. [STYLE] - Padronizar formatação de números decimais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** A formatação de números decimais não está totalmente consistente. 
O DecimalInputFormatter permite vírgula e ponto, mas a conversão pode gerar 
inconsistências.

**Prompt de Implementação:**
```
Padronize formatação de números decimais em todo o módulo. Use sempre ponto 
como separador decimal internamente e vírgula na apresentação para usuário 
brasileiro. Atualize DecimalInputFormatter para ser mais rigoroso. Implemente 
funções helper para conversão consistente entre formatos de entrada e 
processamento.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- controller/alcool_sangue_controller.dart
- utils/number_utils.dart (novo arquivo)

**Validação:** Verificar se conversão entre vírgula e ponto funciona 
corretamente em todos os cenários

---

### 14. [TODO] - Adicionar mais tipos de bebidas predefinidas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** A lista de bebidas predefinidas é limitada. Faltam bebidas 
populares como diferentes tipos de vinho, cervejas artesanais e drinks mistos.

**Prompt de Implementação:**
```
Expanda a lista de bebidas predefinidas no _buildBebidaSelector. Adicione 
mais tipos de cerveja (artesanal, pilsen nacional, import), vinhos (rosé, 
fortificado, frisante), destilados (gin, rum, tequila) e drinks populares 
(caipirinha, mojito). Organize por categorias se necessário. Mantenha 
percentuais de álcool precisos.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart

**Validação:** Verificar se todas as bebidas têm percentuais corretos e se 
a interface permanece usável

---

### 15. [DOC] - Melhorar documentação da fórmula no dialog de informações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O dialog de informações explica a fórmula mas poderia ser mais 
detalhado sobre limitações, precisão e fatores que afetam o resultado.

**Prompt de Implementação:**
```
Melhore a documentação no AlcoolSangueInfoDialog. Adicione explicação mais 
detalhada sobre limitações da fórmula, fatores não considerados (metabolismo 
individual, alimentação, medicamentos), diferenças entre gêneros e idades. 
Inclua informações sobre precisão do cálculo e recomendações de uso responsável.
```

**Dependências:** 
- widgets/alcool_sangue_info.dart

**Validação:** Verificar se informações são precisas, claras e educativas

---

### 16. [STYLE] - Ajustar espaçamentos e alinhamentos inconsistentes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existem espaçamentos inconsistentes entre widgets e dentro de 
cards. Alguns usam 8px, outros 12px, 16px sem padrão claro.

**Prompt de Implementação:**
```
Padronize todos os espaçamentos usando valores consistentes do design system 
(8, 12, 16, 24, 32px). Ajuste padding e margins em todos os widgets para 
seguir padrão uniforme. Crie constantes para espaçamentos que possam ser 
reutilizadas. Garanta alinhamento correto de elementos em todas as telas.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- widgets/alcool_sangue_result.dart
- widgets/alcool_sangue_info.dart
- core/style/spacing_constants.dart (novo arquivo)

**Validação:** Verificar se visual fica mais limpo e consistente

---

### 17. [TODO] - Adicionar tooltips explicativos nos campos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Os campos não têm tooltips explicando como inserir dados 
corretamente ou dando exemplos de valores típicos.

**Prompt de Implementação:**
```
Adicione tooltips informativos nos campos de entrada. Para álcool: explique 
onde encontrar o percentual na embalagem. Para volume: dê exemplos de medidas 
comuns (lata 350ml, dose 50ml). Para tempo: explique se é desde o último 
drink ou total. Para peso: mencione que deve ser peso atual. Implemente 
tooltips não intrusivos.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart

**Validação:** Verificar se tooltips aparecem adequadamente e são informativos

---

### 18. [OPTIMIZE] - Implementar validação em tempo real nos campos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Relacionado com #4 mas específico para validações simples que 
podem ser implementadas rapidamente sem debounce complexo.

**Prompt de Implementação:**
```
Implemente validação básica em tempo real nos campos usando onChanged dos 
TextEditingController. Adicione verificação simples de formato numérico e 
ranges básicos. Mostre feedback visual imediato com bordas coloridas sem 
mensagens complexas. Mantenha validação leve para não impactar performance 
durante digitação.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- controller/alcool_sangue_controller.dart

**Validação:** Verificar se validação não interfere na digitação e é útil

---

### 19. [TODO] - Adicionar suporte para diferentes fórmulas de cálculo

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Existe apenas uma fórmula de cálculo. Há outras fórmulas na 
literatura (Widmark, Watson) que poderiam ser oferecidas como opção.

**Prompt de Implementação:**
```
Adicione seletor de fórmula no formulário oferecendo diferentes métodos de 
cálculo (atual, Widmark modificado, Watson). Implemente as diferentes fórmulas 
no utils mantendo a atual como padrão. Adicione explicação sobre diferenças 
entre fórmulas no dialog de informações. Permita comparar resultados das 
diferentes fórmulas.
```

**Dependências:** 
- widgets/alcool_sangue_form.dart
- utils/alcool_sangue_utils.dart
- widgets/alcool_sangue_info.dart

**Validação:** Verificar se todas as fórmulas estão implementadas corretamente

---

### 20. [TEST] - Implementar testes unitários para cálculos e validações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há testes unitários para verificar se os cálculos de TAS 
estão corretos, o que é crítico para uma calculadora médica.

**Prompt de Implementação:**
```
Crie arquivo de testes unitários para AlcoolSangueUtils. Implemente testes 
para diferentes valores de entrada, casos extremos e verificação das condições 
retornadas. Adicione testes para o controller verificando validações e estado. 
Use valores conhecidos de literatura médica para verificar precisão dos cálculos.
```

**Dependências:** 
- test/alcool_sangue_test.dart (novo arquivo)
- utils/alcool_sangue_utils.dart
- controller/alcool_sangue_controller.dart

**Validação:** Executar os testes e verificar se todos passam com valores 
conhecidos

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Estatísticas do Módulo

**Total de Issues:** 20
- **Críticas (ALTA):** 5 issues
- **Importantes (MÉDIA):** 7 issues
- **Melhorias (BAIXA):** 8 issues

**Issues Concluídas:** 0 de 20 (0%)

**Distribuição por Tipo:**
- REFACTOR: 3 issues
- TODO: 9 issues
- STYLE: 4 issues
- OPTIMIZE: 3 issues
- SECURITY: 1 issue
- BUG: 1 issue
- DOC: 1 issue
- TEST: 1 issue

**Principais Problemas Identificados:**
- Falta de separação de responsabilidades (validação no controller)
- Ausência de feedback visual para validações
- Validação de segurança insuficiente
- Sem persistência de dados entre sessões
- Performance pode ser otimizada

**Prioridade Sugerida para Implementação:**
1. Issues #1, #2, #3 (fundamentos: validação, segurança, feedback)
2. Issues #4, #5 (UX: debounce e persistência)
3. Issues #6-12 (melhorias de funcionalidade e visual)
4. Issues #13-20 (refinamentos e polimento)

**Principais Benefícios Esperados:**
- Código mais organizado e manutenível
- Melhor experiência do usuário com feedback visual
- Maior segurança contra entradas maliciosas
- Funcionalidades avançadas (histórico, comparação)
- Melhor suporte a diferentes dispositivos e temas

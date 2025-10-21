# Issues e Melhorias - Adiposidade (Módulo Calculadora IAC)

## 📋 Índice Geral

### 🔴 Complexidade ALTA (4 issues)
1. [REFACTOR] - Separar lógica de validação do controlador
2. [SECURITY] - Implementar validação robusta de entrada numérica
3. [OPTIMIZE] - Implementar gerenciamento de estado mais eficiente
4. [TODO] - Implementar funcionalidade de compartilhamento completa

### 🟡 Complexidade MÉDIA (6 issues)  
5. [REFACTOR] - Extrair componente de AppBar personalizada
6. [TODO] - Adicionar suporte a temas dark/light no visual
7. [OPTIMIZE] - Implementar debounce na validação de campos ✅
8. [STYLE] - Padronizar espaçamentos e responsividade
9. [TODO] - Adicionar animações de transição entre estados
10. [DOC] - Implementar documentação das fórmulas e classificações

### 🟢 Complexidade BAIXA (8 issues)
11. [FIXME] - Implementar método _mostrarInfoDialog na view ✅
12. [STYLE] - Ajustar nome da classe AdipososidadePage (inconsistência) ✅
13. [TODO] - Adicionar validação de idades extremas ✅
14. [OPTIMIZE] - Implementar cache dos resultados calculados
15. [STYLE] - Padronizar formatação de números decimais ✅
16. [TODO] - Adicionar suporte a unidades imperiais
17. [TEST] - Implementar testes unitários para cálculos
18. [DOC] - Adicionar comentários explicativos sobre IAC

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separar lógica de validação do controlador

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controlador está acumulando responsabilidades de validação, 
cálculo e apresentação. A validação deveria estar em um service separado para 
melhor organização e reutilização.

**Prompt de Implementação:**
```
Crie um arquivo validation_service.dart na pasta services dentro do módulo 
adiposidade. Mova toda a lógica de validação do controlador para este service, 
incluindo validação de campos vazios, formatação de números e validação de 
ranges. O service deve retornar objetos de resultado com sucesso/erro e 
mensagens específicas. Atualize o controlador para usar este service.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- services/validation_service.dart (novo arquivo)

**Validação:** Verificar se a validação funciona corretamente e se as mensagens 
de erro são exibidas adequadamente

---

### 2. [SECURITY] - Implementar validação robusta de entrada numérica

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A conversão de strings para números não trata adequadamente 
casos extremos, valores negativos, ou entradas maliciosas que podem causar 
crashes ou comportamentos inesperados.

**Prompt de Implementação:**
```
Implemente validação robusta para todos os campos numéricos no controlador. 
Adicione verificações para valores negativos, zero, números muito grandes, 
caracteres especiais e formatos inválidos. Crie funções de sanitização que 
retornem valores seguros ou mensagens de erro específicas. Implemente também 
validação de ranges razoáveis para cada campo (altura: 50-300cm, quadril: 
30-200cm, idade: 1-120 anos).
```

**Dependências:** 
- controller/adiposidade_controller.dart
- utils/adiposidade_utils.dart

**Validação:** Testar com entradas extremas, valores negativos e caracteres 
especiais para garantir que não há crashes

---

### 3. [OPTIMIZE] - Implementar gerenciamento de estado mais eficiente

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controlador chama notifyListeners() em várias situações, 
potencialmente causando rebuilds desnecessários. Falta granularidade no 
controle de estado.

**Prompt de Implementação:**
```
Refatore o controlador para usar um sistema de estado mais granular. Separe 
o estado em diferentes aspectos (campos de entrada, resultado do cálculo, 
estado de loading). Implemente listeners específicos para cada parte do estado 
para evitar rebuilds desnecessários. Considere usar ValueNotifier para estados 
simples ou implementar um sistema de estado mais sofisticado com Riverpod ou 
similar.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- views/adiposidade_view.dart
- widgets/adiposidade_input_form.dart
- widgets/adiposidade_result_card.dart

**Validação:** Verificar se a performance melhorou e se não há rebuilds 
desnecessários usando Flutter Inspector

---

### 4. [TODO] - Implementar funcionalidade de compartilhamento completa

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O método compartilhar() está comentado e não funcional. A 
funcionalidade de compartilhamento é importante para o usuário salvar seus 
resultados.

**Prompt de Implementação:**
```
Implemente completamente a funcionalidade de compartilhamento no controlador. 
Descomente e complete o método compartilhar(), garantindo que o texto gerado 
seja formatado adequadamente. Adicione opções de compartilhamento como texto 
simples, salvar como PDF, ou compartilhar como imagem. Implemente também a 
funcionalidade de salvar o histórico de cálculos localmente.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- utils/adiposidade_utils.dart
- widgets/adiposidade_result_card.dart

**Validação:** Testar compartilhamento em diferentes plataformas e verificar 
se o texto está bem formatado

---

## 🟡 Complexidade MÉDIA

### 5. [REFACTOR] - Extrair componente de AppBar personalizada

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A AppBar com ícone e título está hardcoded no index.dart. Este 
padrão pode ser reutilizado em outras calculadoras e deveria ser um componente.

**Prompt de Implementação:**
```
Crie um widget CustomCalculatorAppBar na pasta core/widgets que receba título 
e ícone como parâmetros. Extraia a lógica atual da AppBar do index.dart para 
este novo widget. Atualize o index.dart para usar o novo componente. O widget 
deve ser flexível o suficiente para ser usado em outras calculadoras.
```

**Dependências:** 
- index.dart
- core/widgets/custom_calculator_appbar.dart (novo arquivo)

**Validação:** Verificar se a AppBar funciona corretamente e se mantém o 
mesmo visual

---

### 6. [TODO] - Adicionar suporte a temas dark/light no visual

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O app não adapta adequadamente o visual para tema escuro, 
especialmente nas cores dos ícones e mensagens de erro/sucesso.

**Prompt de Implementação:**
```
Atualize todos os componentes visuais para usar corretamente o ThemeData 
do Flutter. Substitua cores hardcoded por referências ao tema atual. 
Implemente variantes dark/light para SnackBars, ícones e outros elementos 
visuais. Teste o comportamento em ambos os temas e garanta boa legibilidade 
e contraste.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- widgets/adiposidade_input_form.dart
- widgets/adiposidade_result_card.dart

**Validação:** Alternar entre temas e verificar se todos os elementos ficam 
visíveis e com bom contraste

---

### 7. [OPTIMIZE] - Implementar debounce na validação de campos

**Status:** 🟢 Concluído | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A validação poderia ser mais fluida com feedback em tempo real 
usando debounce para evitar validações excessivas durante a digitação.

**Prompt de Implementação:**
```
Implemente debounce nos campos de entrada para validação em tempo real. 
Adicione listeners nos TextEditingController que acionem validação após 
500ms de inatividade. Mostre feedback visual imediato (bordas vermelhas/verdes) 
sem usar SnackBars. Implemente também validação automática ao perder foco 
dos campos.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- widgets/adiposidade_input_form.dart

**Validação:** Testar digitação rápida e verificar se a validação não 
interfere na experiência do usuário

---

### 8. [STYLE] - Padronizar espaçamentos e responsividade

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Os espaçamentos estão inconsistentes entre os widgets e não há 
adaptação adequada para diferentes tamanhos de tela.

**Prompt de Implementação:**
```
Padronize todos os espaçamentos usando valores consistentes (8, 16, 24, 32px). 
Implemente responsividade baseada no tamanho da tela usando MediaQuery. 
Ajuste padding, margins e tamanhos de fonte para tablets e telas grandes. 
Crie constantes para espaçamentos no arquivo de estilo.
```

**Dependências:** 
- index.dart
- views/adiposidade_view.dart
- widgets/adiposidade_input_form.dart
- widgets/adiposidade_result_card.dart
- core/style/spacing_constants.dart (novo arquivo)

**Validação:** Testar em diferentes tamanhos de tela e orientações

---

### 9. [TODO] - Adicionar animações de transição entre estados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** A transição entre o estado vazio e o resultado calculado é 
abrupta. Animações melhorariam a experiência do usuário.

**Prompt de Implementação:**
```
Implemente animações suaves para a transição entre estados. Adicione 
AnimatedOpacity ou AnimatedSwitcher para a exibição do resultado. Implemente 
também micro-animações nos botões (scale ao pressionar) e loading indicators 
durante o cálculo. Use durations apropriadas (200-300ms) para manter fluidez.
```

**Dependências:** 
- views/adiposidade_view.dart
- widgets/adiposidade_result_card.dart
- widgets/adiposidade_input_form.dart

**Validação:** Verificar se as animações são suaves e não impactam a 
performance

---

### 10. [DOC] - Implementar documentação das fórmulas e classificações

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Falta documentação técnica sobre as fórmulas utilizadas, 
referências científicas e explicação das classificações.

**Prompt de Implementação:**
```
Crie um arquivo documentation.md na pasta do módulo explicando a fórmula IAC, 
suas origens científicas, limitações e diferenças com o IMC. Adicione também 
comentários detalhados no código sobre as classificações usadas. Implemente 
um dialog informativo mais completo com essas informações para o usuário.
```

**Dependências:** 
- utils/adiposidade_utils.dart
- views/adiposidade_view.dart
- widgets/adiposidade_info_dialog.dart
- documentation.md (novo arquivo)

**Validação:** Verificar se as informações são precisas e compreensíveis

---

## 🟢 Complexidade BAIXA

### 11. [FIXME] - Implementar método _mostrarInfoDialog na view

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O método _mostrarInfoDialog está vazio e não funcional, mas 
é chamado pelo botão de informações.

**Prompt de Implementação:**
```
Implemente o método _mostrarInfoDialog na AdipososidadeView. O dialog deve 
explicar o que é o IAC, como é calculado e suas limitações. Use um 
AlertDialog com título, conteúdo scrollable e botão de fechar. Mantenha 
linguagem acessível e informativa.
```

**Dependências:** 
- views/adiposidade_view.dart

**Validação:** Verificar se o dialog abre corretamente e se o conteúdo é 
informativo

---

### 12. [STYLE] - Ajustar nome da classe AdipososidadePage (inconsistência)

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O nome da classe tem grafia inconsistente (AdipososidadePage vs 
AdipiosidadePage), o que pode causar confusão.

**Prompt de Implementação:**
```
Padronize o nome da classe principal para AdipiosidadePage (sem o 's' extra) 
em todos os arquivos. Atualize imports e referências. Mantenha consistência 
com o padrão de nomenclatura do resto do projeto.
```

**Dependências:** 
- index.dart
- Arquivos que importam esta classe

**Validação:** Verificar se não há erros de compilação após a mudança

---

### 13. [TODO] - Adicionar validação de idades extremas

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Não há validação para idades muito baixas ou muito altas, 
que podem gerar resultados incorretos ou não fazer sentido.

**Prompt de Implementação:**
```
Adicione validação de idade no controlador para aceitar apenas valores entre 
5 e 120 anos. Implemente mensagens de erro específicas para idades fora deste 
range. Considere também adicionar avisos para idades extremas mas válidas 
(ex: menores de 18 anos ou maiores de 80).
```

**Dependências:** 
- controller/adiposidade_controller.dart

**Validação:** Testar com idades extremas e verificar se as mensagens são 
apropriadas

---

### 14. [OPTIMIZE] - Implementar cache dos resultados calculados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Não há cache dos resultados, fazendo com que o usuário perca 
o cálculo se sair da tela acidentalmente.

**Prompt de Implementação:**
```
Implemente cache simples usando SharedPreferences para salvar o último 
resultado calculado. Restaure automaticamente os valores dos campos e 
resultado quando o usuário retornar à tela. Adicione opção de limpar o 
cache quando necessário.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- pubspec.yaml (shared_preferences)

**Validação:** Verificar se os dados são restaurados corretamente após 
restart do app

---

### 15. [STYLE] - Padronizar formatação de números decimais

**Status:** 🟢 Concluído | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** A formatação de números decimais não está consistente entre 
entrada e saída de dados.

**Prompt de Implementação:**
```
Padronize a formatação de números decimais em todo o módulo. Use sempre ponto 
como separador decimal internamente e vírgula na apresentação para o usuário 
brasileiro. Implemente funções helper para conversão consistente entre 
formatos.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- utils/adiposidade_utils.dart
- widgets/adiposidade_input_form.dart

**Validação:** Verificar se a conversão entre vírgula e ponto funciona 
corretamente

---

### 16. [TODO] - Adicionar suporte a unidades imperiais

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O app só aceita medidas métricas, limitando uso internacional.

**Prompt de Implementação:**
```
Adicione toggle para alternar entre unidades métricas e imperiais. Implemente 
conversão automática entre centímetros/polegadas. Atualize labels e 
placeholders dos campos conforme a unidade selecionada. Mantenha a fórmula 
funcionando corretamente com ambas as unidades.
```

**Dependências:** 
- controller/adiposidade_controller.dart
- widgets/adiposidade_input_form.dart
- utils/adiposidade_utils.dart

**Validação:** Testar cálculos com ambas as unidades e verificar se as 
conversões estão corretas

---

### 17. [TEST] - Implementar testes unitários para cálculos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Não há testes unitários para verificar se os cálculos do IAC 
estão corretos, o que é crítico para uma calculadora médica.

**Prompt de Implementação:**
```
Crie arquivo de testes unitários para AdipososidadeUtils. Implemente testes 
para diferentes valores de entrada, casos extremos e verificação das 
classificações. Adicione também testes para o controlador verificando 
validações e estado. Use valores conhecidos para verificar precisão dos 
cálculos.
```

**Dependências:** 
- test/adiposidade_test.dart (novo arquivo)
- utils/adiposidade_utils.dart
- controller/adiposidade_controller.dart

**Validação:** Executar os testes e verificar se todos passam

---

### 18. [DOC] - Adicionar comentários explicativos sobre IAC

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** O código carece de comentários explicando o que é o IAC e 
como funciona a fórmula.

**Prompt de Implementação:**
```
Adicione comentários explicativos no código sobre o que é o Índice de 
Adiposidade Corporal, suas aplicações e limitações. Documente a fórmula 
matemática e explique os ranges de classificação. Adicione também 
documentação JSDoc/DartDoc nas funções principais.
```

**Dependências:** 
- utils/adiposidade_utils.dart
- model/adiposidade_model.dart

**Validação:** Verificar se os comentários são claros e informativos

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Estatísticas do Módulo

**Total de Issues:** 18
- **Críticas (ALTA):** 4 issues
- **Importantes (MÉDIA):** 5 issues (1 concluída)
- **Melhorias (BAIXA):** 4 issues (4 concluídas)

**Issues Concluídas:** 5 de 18 (27.8%)

**Distribuição por Tipo:**
- REFACTOR: 3 issues
- TODO: 6 issues (2 concluídas)
- STYLE: 3 issues (2 concluídas)
- OPTIMIZE: 3 issues (1 concluída)
- SECURITY: 1 issue
- FIXME: 1 issue (1 concluída)
- TEST: 1 issue
- DOC: 2 issues

**Prioridade Sugerida:**
1. Issues #1, #2, #3 (fundamentais para robustez)
2. Issues #4, #11 (funcionalidades essenciais)
3. Issues #5, #6, #7 (melhorias de UX)
4. Demais issues (refinamentos)

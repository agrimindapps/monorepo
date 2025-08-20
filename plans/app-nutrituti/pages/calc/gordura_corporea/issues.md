# Issues e Melhorias - Gordura Corporal Calculator

## 📋 Índice Geral

### 🔴 Complexidade ALTA (8 issues)
1. [FIXME] - Widget principal completamente não implementado
2. [BUG] - Controller construtor requer parâmetros não fornecidos
3. [FIXME] - Implementação de UI completa ausente
4. [REFACTOR] - Arquitetura MVC não conectada adequadamente
5. [TODO] - Sistema de validação de entradas não implementado
6. [TODO] - Funcionalidade de compartilhamento não implementada
7. [SECURITY] - Falta de sanitização e validação de dados
8. [FIXME] - Gestão de estado e ciclo de vida inadequada

### 🟡 Complexidade MÉDIA (7 issues)
9. [REFACTOR] - Imports desnecessários gerando warnings
10. [OPTIMIZE] - Falta de responsividade e adaptação de tela
11. [TODO] - Ausência de máscaras de input e formatação
12. [STYLE] - Inconsistência visual com outros módulos
13. [TODO] - Falta de persistência de dados e preferências
14. [TODO] - Animações e feedback visual ausentes
15. [OPTIMIZE] - Performance não otimizada para rebuilds

### 🟢 Complexidade BAIXA (5 issues)
16. [DOC] - Documentação e comentários insuficientes
17. [STYLE] - Nomenclatura inconsistente entre arquivos
18. [TEST] - Ausência de testes unitários
19. [TODO] - Acessibilidade não implementada
20. [NOTE] - Fórmulas matemáticas não documentadas

---

## 🔴 Complexidade ALTA

### 1. [FIXME] - Widget principal completamente não implementado

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O GorduraCorporeaWidget está apenas com estrutura básica e comentários, 
sem implementação real dos campos de entrada, botões ou lógica de interface.

**Prompt de Implementação:**
```
Implemente completamente o GorduraCorporeaWidget seguindo os padrões dos outros módulos 
nutrituti. Crie um formulário que colete dados pessoais como gênero, idade, altura, peso 
e medidas corporais específicas (cintura, pescoço, quadril para mulheres). Use Provider 
para gerenciar estado, implemente validação de campos, máscaras de input apropriadas e 
inclua botões para calcular, limpar e mostrar informações. O resultado deve ser exibido 
em um card separado quando calculado.
```

**Dependências:** controller/gordura_corporea_controller.dart, 
widgets/gordura_corporea_info_dialog.dart, core/style/shadcn_style.dart

**Validação:** Widget renderiza corretamente, campos aceitam entrada válida, botões 
funcionam e resultados são exibidos

---

### 2. [BUG] - Controller construtor requer parâmetros não fornecidos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O GorduraCorporeaController tem construtor que requer todos os parâmetros 
do cálculo, mas não há como criar uma instância vazia para começar a entrada de dados.

**Prompt de Implementação:**
```
Refatore o GorduraCorporeaController para ter um construtor padrão vazio e métodos 
setter para atualizar os valores conforme o usuário preenche o formulário. Adicione 
TextEditingController e FocusNode para cada campo necessário. Implemente métodos 
calcular(), limpar() e validar() que trabalhem com os dados atuais do formulário.
```

**Dependências:** model/gordura_corporea_model.dart, widget principal

**Validação:** Controller pode ser instanciado sem parâmetros e permite entrada 
progressiva de dados

---

### 3. [FIXME] - Implementação de UI completa ausente

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** A interface do usuário precisa implementar campos específicos para 
medições corporais, seleção de gênero e exibição de resultados classificados.

**Prompt de Implementação:**
```
Crie uma interface completa para o cálculo de gordura corporal incluindo: seletor de 
gênero via dropdown, campos numéricos para idade, altura, peso, cintura e pescoço, 
campo adicional de quadril que aparece apenas para mulheres, validação em tempo real 
dos valores inseridos, card de resultado que mostra porcentagem de gordura e 
classificação colorida, botão de compartilhamento funcional e integração com o dialog 
de informações.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Interface funcional permite entrada de dados, calcula resultados e 
exibe classificação correta

---

### 4. [REFACTOR] - Arquitetura MVC não conectada adequadamente

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O padrão MVC existe mas não há integração funcional entre View, 
Controller e Model para fluxo de dados completo.

**Prompt de Implementação:**
```
Estabeleça conexão funcional completa entre os componentes MVC: Widget deve usar 
Provider ou Consumer para acessar controller, controller deve atualizar model e 
notificar listeners das mudanças, model deve conter apenas lógica de negócio e 
cálculos. Implemente fluxo de dados unidirecional e gerenciamento de estado 
adequado.
```

**Dependências:** Todos os arquivos MVC do módulo

**Validação:** Mudanças na View atualizam Controller que modifica Model e reflete 
na interface

---

### 5. [TODO] - Sistema de validação de entradas não implementado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não existe validação para garantir que valores inseridos estão dentro 
de ranges fisiológicos aceitáveis para medições corporais.

**Prompt de Implementação:**
```
Implemente sistema de validação robusto que verifique: idade entre 1-120 anos, altura 
entre 50-250 cm, peso entre 20-300 kg, medidas corporais dentro de ranges realistas, 
campos obrigatórios preenchidos antes do cálculo. Exiba mensagens de erro claras e 
impeça cálculos com dados inválidos.
```

**Dependências:** Controller e widget principal

**Validação:** Entradas inválidas são rejeitadas com feedback apropriado ao usuário

---

### 6. [TODO] - Funcionalidade de compartilhamento não implementada

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O share_plus está importado mas não há implementação de funcionalidade 
de compartilhamento dos resultados calculados.

**Prompt de Implementação:**
```
Implemente funcionalidade de compartilhamento que gere texto formatado contendo os 
dados inseridos pelo usuário, resultado da porcentagem de gordura corporal, 
classificação obtida e disclaimer sobre precisão. Use o package share_plus para 
permitir compartilhamento via diferentes apps do dispositivo.
```

**Dependências:** package share_plus, controller

**Validação:** Usuário consegue compartilhar resultados via apps instalados

---

### 7. [SECURITY] - Falta de sanitização e validação de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Dados de entrada não são sanitizados e podem causar erros de runtime 
ou comportamentos inesperados durante cálculos.

**Prompt de Implementação:**
```
Implemente sanitização de dados que converta vírgulas para pontos, remova caracteres 
não numéricos, valide que números são positivos e finitos, trate casos de divisão 
por zero ou valores extremos nas fórmulas matemáticas. Use try-catch para capturar 
exceções durante cálculos.
```

**Dependências:** Controller e model

**Validação:** Aplicação não falha com entradas mal formadas ou extremas

---

### 8. [FIXME] - Gestão de estado e ciclo de vida inadequada

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Não há implementação adequada de dispose para TextControllers e 
FocusNodes, podendo causar memory leaks.

**Prompt de Implementação:**
```
Implemente gestão adequada de ciclo de vida criando métodos dispose no controller 
para limpar TextEditingController e FocusNode, use StatefulWidget no widget principal 
se necessário, garanta que listeners sejam removidos adequadamente quando widget é 
destruído. Configure Provider para dispose automático do controller.
```

**Dependências:** Widget principal e controller

**Validação:** Não há memory leaks detectados durante navegação entre telas

---

## 🟡 Complexidade MÉDIA

### 9. [REFACTOR] - Imports desnecessários gerando warnings

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** GorduraCorporeaWidget tem 8 imports não utilizados que geram warnings 
de compilação e indicam código não implementado.

**Prompt de Implementação:**
```
Remova todos os imports não utilizados do arquivo gordura_corporea_widget.dart. 
Posteriormente, reimporte apenas os packages necessários conforme a implementação 
for sendo desenvolvida. Mantenha apenas imports que são efetivamente utilizados 
no código.
```

**Dependências:** widgets/gordura_corporea_widget.dart

**Validação:** Arquivo compila sem warnings sobre imports desnecessários

---

### 10. [OPTIMIZE] - Falta de responsividade e adaptação de tela

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Interface não se adapta a diferentes tamanhos de tela e orientações, 
limitando usabilidade em tablets e dispositivos móveis.

**Prompt de Implementação:**
```
Implemente layout responsivo usando LayoutBuilder para detectar tamanho da tela, 
adapte disposição dos campos entre layout de coluna para mobile e linha para desktop, 
ajuste tamanhos de fontes e espaçamentos conforme densidade da tela, teste em 
diferentes orientações e dispositivos.
```

**Dependências:** Widget principal

**Validação:** Interface funciona bem em dispositivos móveis e tablets

---

### 11. [TODO] - Ausência de máscaras de input e formatação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Campos numéricos não têm formatação apropriada para melhorar experiência 
do usuário durante entrada de dados.

**Prompt de Implementação:**
```
Implemente máscaras de input usando MaskTextInputFormatter para campos numéricos: 
peso com formato ###,## kg, altura com formato ### cm, medidas corporais com 
formato ###,# cm, idade apenas números inteiros. Configure teclado numérico 
apropriado para cada campo.
```

**Dependências:** package mask_text_input_formatter, widget principal

**Validação:** Campos formatam entrada automaticamente conforme usuário digita

---

### 12. [STYLE] - Inconsistência visual com outros módulos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Design visual deve seguir padrões estabelecidos nos outros módulos 
nutrituti para manter consistência da aplicação.

**Prompt de Implementação:**
```
Padronize visual seguindo outros módulos nutrituti: use ShadcnStyle para decoração 
de campos, implemente cards com elevação e bordas arredondadas similares aos outros 
calculadores, use ícones consistentes com a temática corporal, aplique cores do 
tema para modo claro e escuro.
```

**Dependências:** core/style/shadcn_style.dart, outros módulos como referência

**Validação:** Interface visual é consistente com resto da aplicação

---

### 13. [TODO] - Falta de persistência de dados e preferências

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Dados inseridos pelo usuário não são salvos e se perdem ao sair da tela, 
prejudicando experiência de uso.

**Prompt de Implementação:**
```
Implemente persistência local usando SharedPreferences para salvar últimos valores 
inseridos pelo usuário, dados pessoais básicos que podem ser reutilizados em outros 
calculadores, preferências de unidades de medida. Carregue dados salvos ao inicializar 
a tela.
```

**Dependências:** package shared_preferences, controller

**Validação:** Dados persistem entre sessões da aplicação

---

### 14. [TODO] - Animações e feedback visual ausentes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface estática não fornece feedback visual adequado durante ações 
do usuário, diminuindo percepção de qualidade.

**Prompt de Implementação:**
```
Adicione animações sutis: transição de opacity quando resultado aparece, animação 
de shake para campos com erro de validação, feedback visual nos botões quando 
pressionados, indicador de loading durante cálculos complexos, transições suaves 
entre estados.
```

**Dependências:** Widget principal e components

**Validação:** Interface responde visualmente às ações do usuário

---

### 15. [OPTIMIZE] - Performance não otimizada para rebuilds

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Widget pode fazer rebuilds desnecessários durante entrada de dados 
afetando performance em dispositivos menos potentes.

**Prompt de Implementação:**
```
Otimize performance usando const constructors onde possível, implemente 
ValueListenableBuilder para campos específicos que mudam frequentemente, use 
Consumer seletivo do Provider apenas para partes que precisam atualizar, evite 
rebuilds desnecessários do widget inteiro.
```

**Dependências:** Widget principal e Provider setup

**Validação:** Performance fluida durante entrada de dados e cálculos

---

## 🟢 Complexidade BAIXA

### 16. [DOC] - Documentação e comentários insuficientes

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Código não possui documentação adequada sobre funcionamento dos 
cálculos e propósito das funções.

**Prompt de Implementação:**
```
Adicione documentação dartdoc para todas as classes e métodos públicos, comente 
fórmulas matemáticas utilizadas nos cálculos explicando sua origem científica, 
documente parâmetros esperados e valores de retorno, inclua exemplos de uso onde 
apropriado.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Código está bem documentado e autoexplicativo

---

### 17. [STYLE] - Nomenclatura inconsistente entre arquivos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Mistura de convenções de nomenclatura português/inglês pode confundir 
outros desenvolvedores.

**Prompt de Implementação:**
```
Padronize nomenclatura escolhendo entre português ou inglês para nomes de variáveis, 
métodos e classes. Mantenha consistência com outros módulos da aplicação. Atualize 
todos os arquivos do módulo para seguir a convenção escolhida.
```

**Dependências:** Todos os arquivos do módulo

**Validação:** Nomenclatura é consistente em todo o módulo

---

### 18. [TEST] - Ausência de testes unitários

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Não existem testes para validar cálculos matemáticos e comportamento 
dos componentes.

**Prompt de Implementação:**
```
Crie testes unitários para validar precisão dos cálculos de gordura corporal, 
teste casos extremos e valores limites, valide comportamento do controller com 
diferentes entradas, teste integração entre componentes MVC.
```

**Dependências:** Framework de testes Flutter

**Validação:** Testes passam e cobrem funcionalidades principais

---

### 19. [TODO] - Acessibilidade não implementada

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface não possui recursos de acessibilidade para usuários com 
necessidades especiais.

**Prompt de Implementação:**
```
Adicione widgets Semantics com labels apropriados, implemente navegação por teclado, 
garanta contrast ratio adequado entre cores, adicione hints de voz para screen 
readers, teste com TalkBack/VoiceOver ativados.
```

**Dependências:** Widget principal

**Validação:** Interface é acessível com tecnologias assistivas

---

### 20. [NOTE] - Fórmulas matemáticas não documentadas

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Fórmulas de cálculo de gordura corporal precisam de referências 
científicas e explicação de contexto de aplicação.

**Prompt de Implementação:**
```
Documente origem das fórmulas matemáticas utilizadas citando estudos científicos, 
explique diferenças entre métodos para homens e mulheres, inclua limitações e 
precisão esperada dos cálculos, adicione disclaimers sobre uso médico.
```

**Dependências:** model/gordura_corporea_model.dart

**Validação:** Fórmulas têm documentação científica adequada

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar ALTA` - Para trabalhar apenas com issues de complexidade alta
- `Agrupar FIXME` - Para executar todas as issues do tipo FIXME
- `Validar #[número]` - Para que a IA revise implementação concluída

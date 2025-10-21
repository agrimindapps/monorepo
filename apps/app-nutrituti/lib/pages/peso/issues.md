# Issues e Melhorias - peso_page.dart

## 📋 Índice Geral

### 🔴 Complexidade ALTA (5 issues)
1. [REFACTOR] - Separar responsabilidades da view principal
2. [BUG] - Calendário não integrado com dados de peso
3. [SECURITY] - Validação inadequada de entrada de dados
4. [REFACTOR] - Widget de gráfico genérico sem dados reais
5. [OPTIMIZE] - Inicialização ineficiente do controller GetX

### 🟡 Complexidade MÉDIA (6 issues)  
6. [TODO] - Implementar funcionalidade de filtros por período
7. [STYLE] - Layout responsivo inadequado para diferentes telas
8. [TODO] - Adicionar exportação de dados em múltiplos formatos
9. [OPTIMIZE] - Performance com muitos registros de peso
10. [TODO] - Implementar notificações e lembretes
11. [REFACTOR] - Extrair dialogs para widgets especializados

### 🟢 Complexidade BAIXA (7 issues)
12. [STYLE] - Melhorar acessibilidade e navegação por teclado
13. [DOC] - Adicionar documentação e comentários explicativos
14. [TODO] - Implementar modo offline com sincronização
15. [STYLE] - Padronizar espaçamentos e design system
16. [TODO] - Adicionar suporte a temas personalizados
17. [TEST] - Implementar testes automatizados
18. [TODO] - Adicionar animações e micro-interações

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Separar responsabilidades da view principal

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** A PesoPage acumula muitas responsabilidades incluindo construção 
de UI complexa, gerenciamento de dialogs, formatação de dados e lógica de 
apresentação. Viola princípios SOLID e dificulta manutenção e testes.

**Prompt de Implementação:**
```
Refatore a PesoPage seguindo padrão de arquitetura limpa. Crie: 
PesoPageController para lógica específica da página, DialogService para 
gerenciar dialogs, FormatterService para formatação de dados, e separe widgets 
complexos em arquivos próprios. Mantenha apenas construção básica da UI na 
view principal. Use injeção de dependência adequada.
```

**Dependências:** peso_page.dart, controllers/peso_page_controller.dart (novo), 
services/dialog_service.dart (novo), services/formatter_service.dart (novo), 
widgets específicos

**Validação:** View fica focada apenas em apresentação, lógica separada em 
services testáveis, funcionalidade permanece idêntica

---

### 2. [BUG] - Calendário não integrado com dados de peso

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O TableCalendar está implementado mas não mostra registros de 
peso nas datas correspondentes. Variable events está vazia e nunca populada, 
desperdiçando funcionalidade importante para visualização temporal dos dados.

**Prompt de Implementação:**
```
Integre o TableCalendar com dados reais de peso. Popule o mapa events com 
registros de peso agrupados por data. Adicione indicadores visuais nos dias 
com registros, tooltip mostrando peso do dia, e navegação para registros 
específicos ao clicar nas datas. Implemente cache para performance.
```

**Dependências:** peso_page.dart, controllers/peso_controller.dart, 
models/peso_model.dart, services/calendar_service.dart (novo)

**Validação:** Calendário mostra indicadores nos dias com registros, tooltips 
funcionam corretamente, navegação por data funciona sem afetar performance

---

### 3. [SECURITY] - Validação inadequada de entrada de dados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** Dialog de meta de peso apenas verifica se texto não está vazio 
e se valor é maior que zero. Não valida ranges biologicamente plausíveis, 
caracteres especiais ou possíveis ataques de input, podendo causar crashes 
ou dados incorretos.

**Prompt de Implementação:**
```
Implemente validação robusta para entrada de peso incluindo: range válido para 
peso humano (1kg a 300kg), sanitização de entrada removendo caracteres inválidos, 
validação de formato numérico com decimais, limites de precisão, e tratamento 
de edge cases. Adicione mensagens de erro específicas e user-friendly.
```

**Dependências:** peso_page.dart, services/validation_service.dart (novo), 
utils/input_validators.dart (novo), controllers/peso_controller.dart

**Validação:** Testar com valores extremos, caracteres especiais e entradas 
maliciosas verificando que aplicação não quebra e mostra mensagens adequadas

---

### 4. [REFACTOR] - Widget de gráfico genérico sem dados reais

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** BarChartSample3 é um widget genérico que não utiliza dados reais 
de peso. Não há integração entre registros do usuário e visualização gráfica, 
perdendo oportunidade de fornecer insights valiosos sobre progresso.

**Prompt de Implementação:**
```
Substitua BarChartSample3 por WeightChartWidget customizado que use dados reais 
do usuário. Implemente gráfico de linha para evolução temporal, barras para 
comparação mensal, indicadores de meta, e diferentes visualizações (semana, mês, 
ano). Adicione interatividade com zoom, tooltip e seleção de períodos.
```

**Dependências:** peso_page.dart, widgets/weight_chart_widget.dart (novo), 
controllers/peso_controller.dart, services/chart_service.dart (novo)

**Validação:** Gráfico mostra dados reais do usuário, diferentes visualizações 
funcionam, interatividade responde adequadamente, performance mantida

---

### 5. [OPTIMIZE] - Inicialização ineficiente do controller GetX

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Get.put(PesoController()) é chamado diretamente na declaração da 
variável, causando inicialização imediata mesmo se página nunca for exibida. 
Pode causar vazamentos de memória e inicializações desnecessárias.

**Prompt de Implementação:**
```
Refatore inicialização do controller para usar lazy loading com Get.lazyPut ou 
Bindings apropriadas. Implemente dispose adequado e gerencie ciclo de vida do 
controller corretamente. Use padrão de injeção de dependência que permita 
testes e evite instanciações desnecessárias.
```

**Dependências:** peso_page.dart, bindings/peso_bindings.dart (novo), 
controllers/peso_controller.dart

**Validação:** Controller só é criado quando necessário, dispose é chamado 
adequadamente, sem vazamentos de memória, testes podem mockar dependências

---

## 🟡 Complexidade MÉDIA

### 6. [TODO] - Implementar funcionalidade de filtros por período

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Aplicação não oferece filtros para visualizar registros por 
períodos específicos (última semana, mês, trimestre). Usuários com muitos 
registros têm dificuldade para analisar tendências específicas.

**Prompt de Implementação:**
```
Adicione widget de filtros com opções pré-definidas (7 dias, 30 dias, 90 dias, 
ano) e seletor de período customizado. Implemente filtragem reativa que atualiza 
gráficos, lista de registros e estatísticas automaticamente. Persista preferência 
do usuário e otimize queries para performance.
```

**Dependências:** widgets/filter_widget.dart (novo), controllers/peso_controller.dart, 
services/filter_service.dart (novo), repository/peso_repository.dart

**Validação:** Filtros funcionam corretamente, dados são atualizados em tempo 
real, performance mantida com grandes volumes de dados

---

### 7. [STYLE] - Layout responsivo inadequado para diferentes telas

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** SizedBox com largura fixa de 1020 não se adapta adequadamente 
a diferentes tamanhos de tela. Em dispositivos menores pode causar overflow, 
em maiores desperdiça espaço disponível.

**Prompt de Implementação:**
```
Implemente layout responsivo usando MediaQuery e breakpoints. Crie sistema de 
grid adaptativo que funcione bem em smartphones, tablets e desktop. Use 
LayoutBuilder para ajustar número de colunas e tamanhos dinamicamente. 
Teste em diferentes resoluções e orientações.
```

**Dependências:** peso_page.dart, utils/responsive_helper.dart (novo), 
widgets adaptados para responsividade

**Validação:** Layout funciona bem em todas as resoluções testadas, sem 
overflow ou espaços desperdiçados, transições suaves entre breakpoints

---

### 8. [TODO] - Adicionar exportação de dados em múltiplos formatos

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários não podem exportar seus dados de peso para backup ou 
análise externa. Funcionalidade importante para portabilidade e integração 
com outras ferramentas de saúde.

**Prompt de Implementação:**
```
Implemente sistema de exportação suportando CSV, PDF e JSON. Para CSV inclua 
todos os registros com colunas organizadas. PDF deve ter gráficos e estatísticas 
formatadas. JSON para backup completo. Adicione opções de período e compartilhamento 
via system share. Use plugins adequados para cada formato.
```

**Dependências:** services/export_service.dart (novo), utils/pdf_generator.dart (novo), 
controllers/peso_controller.dart, pubspec.yaml (novos packages)

**Validação:** Arquivos são gerados corretamente em todos os formatos, 
compartilhamento funciona, dados mantêm integridade

---

### 9. [OPTIMIZE] - Performance com muitos registros de peso

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Aplicação carrega todos os registros na memória simultaneamente 
sem paginação ou lazy loading. Com centenas de registros pode causar lentidão 
e uso excessivo de memória.

**Prompt de Implementação:**
```
Implemente paginação para lista de registros com lazy loading. Use virtualização 
para listas grandes. Adicione cache inteligente que mantém dados recentes em 
memória. Otimize queries do banco para buscar apenas dados necessários para 
período visível. Implemente debounce em operações de busca.
```

**Dependências:** controllers/peso_controller.dart, repository/peso_repository.dart, 
services/cache_service.dart (novo), widgets/paginated_list_widget.dart (novo)

**Validação:** Performance mantida com 1000+ registros, uso de memória otimizado, 
scroll suave em listas grandes

---

### 10. [TODO] - Implementar notificações e lembretes

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Aplicação não oferece lembretes para pesagem regular ou 
notificações sobre progresso. Funcionalidade importante para engajamento e 
criação de hábitos saudáveis.

**Prompt de Implementação:**
```
Implemente sistema de notificações locais para lembretes de pesagem diária/semanal. 
Adicione notificações de milestone (meta atingida, sequência de dias). Crie 
configurações para horário e frequência personalizáveis. Use flutter_local_notifications 
e permissões adequadas. Adicione opção de desabilitar notificações.
```

**Dependências:** services/notification_service.dart (novo), 
controllers/peso_controller.dart, pubspec.yaml (flutter_local_notifications), 
pages/settings_page.dart (configurações)

**Validação:** Notificações são enviadas nos horários corretos, configurações 
funcionam, permissões são solicitadas adequadamente

---

### 11. [REFACTOR] - Extrair dialogs para widgets especializados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Métodos _showMetaDialog, _showDeleteConfirmation e _dialogNovoPeso 
estão implementados inline na view principal, dificultando reutilização, testes 
e manutenção. Relacionado com issue #1.

**Prompt de Implementação:**
```
Extraia cada dialog para widgets especializados: MetaDialog, DeleteConfirmationDialog 
e WeightFormDialog. Cada um deve ter interface consistente, validações próprias 
e ser testável independentemente. Use padrão de factory methods para criação 
simplificada. Mantenha API simples para uso na view principal.
```

**Dependências:** widgets/meta_dialog.dart (novo), widgets/delete_confirmation_dialog.dart (novo), 
widgets/weight_form_dialog.dart (novo), peso_page.dart

**Validação:** Dialogs funcionam identicamente, código mais limpo e testável, 
reutilização possível em outras telas

---

## 🟢 Complexidade BAIXA

### 12. [STYLE] - Melhorar acessibilidade e navegação por teclado

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Aplicação não possui labels semânticos adequados, navegação por 
teclado limitada e suporte insuficiente para leitores de tela. Importante para 
inclusão e conformidade com diretrizes de acessibilidade.

**Prompt de Implementação:**
```
Adicione Semantics widgets apropriados para todos os elementos interativos. 
Implemente navegação por Tab entre campos e botões. Configure labels descritivos 
para leitores de tela. Adicione hints explicativos e atalhos de teclado úteis. 
Teste com TalkBack/VoiceOver para garantir funcionalidade.
```

**Dependências:** peso_page.dart, todos os widgets filho, 
utils/accessibility_helper.dart (novo)

**Validação:** Navegação por teclado funciona completamente, leitores de tela 
conseguem interpretar todos os elementos, atalhos respondem adequadamente

---

### 13. [DOC] - Adicionar documentação e comentários explicativos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Código carece de documentação adequada explicando propósito dos 
métodos, parâmetros esperados e comportamentos especiais. Dificulta manutenção 
por outros desenvolvedores.

**Prompt de Implementação:**
```
Adicione comentários dartdoc para todos os métodos públicos explicando propósito, 
parâmetros e retorno. Documente comportamentos especiais e edge cases. Adicione 
comentários inline para lógica complexa. Use exemplos quando apropriado. 
Mantenha documentação concisa mas informativa.
```

**Dependências:** peso_page.dart, todos os arquivos relacionados

**Validação:** Documentação gerada corretamente pelo dartdoc, comentários são 
úteis e precisos, não há warnings de documentação

---

### 14. [TODO] - Implementar modo offline com sincronização

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Aplicação não funciona offline e não oferece sincronização de 
dados entre dispositivos. Limitação importante para usuários com conectividade 
intermitente.

**Prompt de Implementação:**
```
Implemente armazenamento local com Hive ou SQLite para funcionamento offline. 
Adicione sistema de sincronização que detecta conexão e sincroniza dados 
automaticamente. Implemente resolução de conflitos para registros modificados 
em múltiplos dispositivos. Adicione indicador de status de sincronização.
```

**Dependências:** services/sync_service.dart (novo), services/offline_service.dart (novo), 
repository/peso_repository.dart, widgets/sync_indicator.dart (novo)

**Validação:** Aplicação funciona completamente offline, sincronização ocorre 
automaticamente quando online, conflitos são resolvidos adequadamente

---

### 15. [STYLE] - Padronizar espaçamentos e design system

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Espaçamentos estão hardcoded com valores inconsistentes (8, 16, etc). 
Não há design system padronizado, dificultando manutenção visual e inconsistências 
no design.

**Prompt de Implementação:**
```
Crie design system com espaçamentos padronizados, cores e tipografia consistentes. 
Defina tokens de design reutilizáveis. Substitua valores hardcoded por constantes 
semânticas. Use extensões de ThemeData para customizações. Documente padrões 
visuais para consistência futura.
```

**Dependências:** core/design_system.dart (novo), core/theme_extensions.dart (novo), 
peso_page.dart, todos os widgets

**Validação:** Visual permanece idêntico, código usa design tokens consistentes, 
mudanças de tema são aplicadas globalmente

---

### 16. [TODO] - Adicionar suporte a temas personalizados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Aplicação usa apenas tema padrão sem opções de personalização. 
Usuários podem preferir temas escuros ou personalizações que melhorem sua 
experiência visual.

**Prompt de Implementação:**
```
Implemente sistema de temas com modo claro/escuro e opções de cores personalizadas. 
Adicione persistência de preferências do usuário. Use ThemeData adequadamente 
e teste contrastes para acessibilidade. Adicione tela de configurações de tema 
com preview em tempo real.
```

**Dependências:** services/theme_service.dart (novo), pages/theme_settings_page.dart (novo), 
core/custom_themes.dart (novo)

**Validação:** Temas aplicam corretamente, preferências são persistidas, 
contrastes atendem diretrizes de acessibilidade

---

### 17. [TEST] - Implementar testes automatizados

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Ausência completa de testes automatizados. Dificulta detecção 
de regressões e refatorações seguras. Importante para manutenção de qualidade 
do código.

**Prompt de Implementação:**
```
Crie suite de testes incluindo testes unitários para controller, testes de 
widget para componentes UI e testes de integração para fluxos principais. 
Use mockito para dependências externas. Implemente testes para cenários de 
erro e edge cases. Configure CI para execução automática.
```

**Dependências:** test/peso_page_test.dart (novo), test/peso_controller_test.dart (novo), 
pubspec.yaml (flutter_test, mockito)

**Validação:** Testes executam com sucesso, cobertura adequada dos cenários 
principais, detecção efetiva de regressões

---

### 18. [TODO] - Adicionar animações e micro-interações

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Interface estática sem animações ou feedback visual para interações. 
Micro-interações melhoram percepção de qualidade e tornam experiência mais 
fluida e responsiva.

**Prompt de Implementação:**
```
Adicione animações sutis para transições entre estados, loading states, 
adição/remoção de itens da lista. Implemente micro-interações como hover effects, 
pressed states e feedback tátil. Use AnimationController e Tween apropriados. 
Mantenha animações consistentes e performáticas.
```

**Dependências:** peso_page.dart, utils/animation_utils.dart (novo), 
widgets com animações customizadas

**Validação:** Animações executam suavemente, feedback visual é claro, 
performance não é impactada negativamente

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

**Priorização sugerida:** Issues críticas (#2, #3, #5) primeiro, seguidas por 
refatorações estruturais (#1, #4), melhorias de UX (#6, #7, #8) e polimentos finais.

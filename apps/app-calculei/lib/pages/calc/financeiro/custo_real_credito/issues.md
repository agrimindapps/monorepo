# Issues e Melhorias - Custo Real do Crédito

## 📋 Índice Geral

### 🔴 Complexidade ALTA (7 issues)
1. [REFACTOR] - Reestruturar controller para melhor separação de responsabilidades
2. [BUG] - Corrigir cálculo de juros compostos no modelo
3. [SECURITY] - Implementar validação robusta de entrada de dados
4. [OPTIMIZE] - Otimizar performance de validação em tempo real
5. [REFACTOR] - Separar lógica de formatação duplicada entre services
6. [BUG] - Corrigir gerenciamento de estado durante navegação
7. [OPTIMIZE] - Implementar cache para cálculos repetitivos

### 🟡 Complexidade MÉDIA (10 issues)
8. [TODO] - Implementar compartilhamento de resultados
9. [TODO] - Adicionar persistência de dados do formulário
10. [REFACTOR] - Consolidar múltiplos services de formatação
11. [TODO] - Implementar modo comparação com múltiplos cenários
12. [OPTIMIZE] - Melhorar responsividade em dispositivos móveis
13. [TODO] - Adicionar histórico de cálculos anteriores
14. [REFACTOR] - Extrair lógica de tema para service dedicado
15. [TODO] - Implementar exportação de resultados para PDF
16. [OPTIMIZE] - Reduzir rebuilds desnecessários na UI
17. [TODO] - Adicionar suporte a diferentes tipos de investimento

### 🟢 Complexidade BAIXA (8 issues)
18. [STYLE] - Padronizar constantes de layout e espaçamento
19. [TODO] - Melhorar feedback visual para estados de loading
20. [FIXME] - Corrigir warning de key deprecation
21. [TODO] - Adicionar tooltips explicativos nos campos
22. [STYLE] - Melhorar consistência visual entre widgets
23. [TODO] - Implementar modo escuro aprimorado
24. [DOC] - Adicionar documentação para fórmulas financeiras
25. [TEST] - Implementar testes unitários para services

---

## 🔴 Complexidade ALTA

### 1. [REFACTOR] - Reestruturar controller para melhor separação de responsabilidades

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O controller está gerenciando múltiplas responsabilidades como validação, formatação, estado da UI e lógica de negócio. Isso dificulta testes e manutenção.

**Prompt de Implementação:**
Refatore o CustoRealCreditoController separando as responsabilidades em componentes especializados. Crie um StateManager para gerenciar estado da UI, mantenha apenas coordenação no controller principal, e extraia lógica de validação para um ValidationController dedicado. Implemente dependency injection para os services e garanta que a interface pública permaneça compatível.

**Dependências:** controllers/custo_real_credito_controller.dart, services/validation_service.dart, services/formatting_service.dart

**Validação:** Verificar se funcionalidades continuam funcionando após refatoração e se código está mais testável com responsabilidades bem definidas.

---

### 2. [BUG] - Corrigir cálculo de juros compostos no modelo

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O modelo CustoRealCreditoModel possui lógica de cálculo que deveria estar no CalculationService, e há inconsistências entre os dois métodos de cálculo de juros compostos.

**Prompt de Implementação:**
Remova completamente o método calcular do CustoRealCreditoModel e garanta que toda lógica de cálculo seja centralizada no CalculationService. Revise a fórmula de juros compostos para garantir precisão matemática e consistência. Implemente validação para evitar valores que possam causar overflow ou resultados incorretos.

**Dependências:** models/custo_real_credito_model.dart, services/calculation_service.dart

**Validação:** Executar testes com diferentes cenários de cálculo e comparar resultados com calculadoras financeiras confiáveis.

---

### 3. [SECURITY] - Implementar validação robusta de entrada de dados

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O sistema não possui validação adequada contra valores maliciosos ou extremos que podem causar overflow, crash ou resultados incorretos.

**Prompt de Implementação:**
Implemente validação robusta nos services de validação para prevenir entrada de valores que possam causar problemas matemáticos. Adicione sanitização de dados de entrada, validação de ranges seguros para cálculos financeiros e tratamento de edge cases como valores muito grandes ou muito pequenos. Implemente rate limiting para evitar spam de cálculos.

**Dependências:** services/enhanced_validation_service.dart, services/validation_service.dart, constants/calculation_constants.dart

**Validação:** Testar com valores extremos, negativos, zero e verificar se sistema mantém estabilidade e retorna erros apropriados.

---

### 4. [OPTIMIZE] - Otimizar performance de validação em tempo real

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** O sistema executa validação completa a cada keystroke mesmo quando não necessário, impactando performance especialmente em dispositivos mais lentos.

**Prompt de Implementação:**
Otimize o sistema de validação implementando validação incremental que executa apenas quando necessário. Melhore o debouncing para diferentes tipos de campo, implemente cancelamento de validações pendentes e cache resultados de validações custosas. Adicione lazy loading para validações complexas e otimize streams de validação.

**Dependências:** controllers/custo_real_credito_controller.dart, services/validation_service.dart, utils/debouncer.dart

**Validação:** Medir performance de validação antes e depois da otimização usando ferramentas de profiling.

---

### 5. [REFACTOR] - Separar lógica de formatação duplicada entre services

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Médio | **Benefício:** Alto

**Descrição:** Existe duplicação de lógica de formatação entre múltiplos services como FormattingService, OptimizedMoneyFormatter e Enhanced services.

**Prompt de Implementação:**
Consolide toda lógica de formatação em um único service autoritativo. Identifique e remova duplicações entre os diferentes formatters, crie interfaces claras para diferentes tipos de formatação e implemente factory pattern para criar formatters específicos. Mantenha apenas um formatter por tipo de dado.

**Dependências:** services/formatting_service.dart, services/enhanced_formatting_service.dart, services/optimized_money_formatter.dart, services/money_input_formatter.dart

**Validação:** Verificar se formatação funciona consistentemente em todos os pontos do sistema após consolidação.

---

### 6. [BUG] - Corrigir gerenciamento de estado durante navegação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Alto | **Benefício:** Alto

**Descrição:** O estado do formulário pode ser perdido durante navegação ou quando usuário minimiza app, e há potential memory leaks no dispose de resources.

**Prompt de Implementação:**
Implemente preservação de estado durante navegação usando storage local ou session storage. Corrija potential memory leaks no dispose do controller garantindo que todos os listeners sejam removidos. Adicione recovery mechanism para restaurar estado após crash ou minimização do app.

**Dependências:** controllers/custo_real_credito_controller.dart, index.dart

**Validação:** Testar navegação entre telas múltiplas vezes e verificar se não há vazamentos de memória usando memory profiler.

---

### 7. [OPTIMIZE] - Implementar cache para cálculos repetitivos

**Status:** 🔴 Pendente | **Execução:** Complexa | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** O sistema recalcula valores idênticos múltiplas vezes sem cache, desperdiçando recursos computacionais.

**Prompt de Implementação:**
Implemente sistema de cache inteligente para cálculos financeiros usando hash dos parâmetros de entrada como chave. Adicione cache com TTL para resultados temporários, implemente invalidação de cache quando necessário e otimize memory usage do cache. Considere cache persistente para cálculos frequentes.

**Dependências:** services/calculation_service.dart, controllers/custo_real_credito_controller.dart

**Validação:** Verificar se performance melhora significativamente para cálculos repetitivos e se cache é invalidado corretamente.

---

## 🟡 Complexidade MÉDIA

### 8. [TODO] - Implementar compartilhamento de resultados

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** O botão de compartilhar está presente na UI mas não funciona, impedindo usuários de compartilhar resultados importantes.

**Prompt de Implementação:**
Implemente funcionalidade de compartilhamento que permita usuários compartilhar resultados via diferentes canais como WhatsApp, email, clipboard. Crie formatação adequada para diferentes tipos de compartilhamento e adicione opção de compartilhar como imagem ou texto. Implemente preview antes do compartilhamento.

**Dependências:** widgets/custo_real_credito_result_widget.dart, novos services de compartilhamento

**Validação:** Verificar se compartilhamento funciona corretamente em diferentes plataformas e aplicativos.

---

### 9. [TODO] - Adicionar persistência de dados do formulário

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Dados do formulário são perdidos quando usuário fecha o aplicativo, forçando nova entrada de dados frequentemente.

**Prompt de Implementação:**
Implemente persistência automática dos dados do formulário usando SharedPreferences ou database local. Adicione auto-restore na inicialização do formulário, permita usuário escolher se quer manter dados salvos e implemente cleanup de dados antigos. Considere criptografia para dados sensíveis.

**Dependências:** controllers/custo_real_credito_controller.dart, novo storage service

**Validação:** Verificar se dados são restaurados corretamente após restart do aplicativo.

---

### 10. [REFACTOR] - Consolidar múltiplos services de formatação

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Médio | **Benefício:** Médio

**Descrição:** Existem múltiplos services fazendo formatação similar, causando inconsistência e dificultando manutenção.

**Prompt de Implementação:**
Analise todos os services de formatação e identifique funcionalidades duplicadas. Crie um FormattingService unificado que contenha toda lógica de formatação necessária. Remova services redundantes e migre toda utilização para o service consolidado. Implemente factory methods para diferentes tipos de formatação.

**Dependências:** services/formatting_service.dart, services/enhanced_formatting_service.dart, services/optimized_money_formatter.dart

**Validação:** Verificar se formatação permanece consistente em todo o sistema após consolidação.

---

### 11. [TODO] - Implementar modo comparação com múltiplos cenários

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários poderiam se beneficiar de comparar diferentes cenários de investimento ou condições de pagamento lado a lado.

**Prompt de Implementação:**
Crie interface para comparação de múltiplos cenários permitindo usuário definir diferentes taxas de investimento, prazos ou valores. Implemente visualização lado a lado dos resultados, adicione gráficos comparativos e permita salvar diferentes cenários para comparação posterior. Adicione análise de sensibilidade.

**Dependências:** nova UI para comparação, controllers/custo_real_credito_controller.dart, services/calculation_service.dart

**Validação:** Verificar se comparações são precisas e interface é intuitiva para usuário.

---

### 12. [OPTIMIZE] - Melhorar responsividade em dispositivos móveis

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Layout pode não se adaptar adequadamente a diferentes tamanhos de tela, especialmente em dispositivos móveis pequenos.

**Prompt de Implementação:**
Otimize layout para diferentes tamanhos de tela implementando breakpoints responsivos. Melhore espaçamento e padding para telas menores, implemente scroll otimizado e garanta que todos os elementos sejam acessíveis em telas pequenas. Teste em diferentes dispositivos e orientações.

**Dependências:** index.dart, widgets/custo_real_credito_form_widget.dart, widgets/custo_real_credito_result_widget.dart

**Validação:** Testar em diferentes tamanhos de tela e orientações para garantir usabilidade adequada.

---

### 13. [TODO] - Adicionar histórico de cálculos anteriores

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários não conseguem consultar cálculos anteriores, forçando nova entrada de dados para comparações.

**Prompt de Implementação:**
Implemente sistema de histórico que armazene cálculos anteriores com timestamp e permita consulta posterior. Adicione interface para visualizar histórico, possibilidade de restaurar cálculos anteriores e comparar com cálculo atual. Implemente limitação de itens no histórico e cleanup automático.

**Dependências:** novo storage service, controllers/custo_real_credito_controller.dart, nova UI para histórico

**Validação:** Verificar se histórico é mantido corretamente e interface de consulta é funcional.

---

### 14. [REFACTOR] - Extrair lógica de tema para service dedicado

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Lógica de tema está espalhada por múltiplos widgets, dificultando manutenção e consistência visual.

**Prompt de Implementação:**
Crie ThemeService dedicado para gerenciar toda lógica relacionada a tema escuro/claro. Extraia verificações de tema dos widgets individuais e centralize em service. Implemente sistema de notificação para mudanças de tema e garanta consistência visual em todos os componentes.

**Dependências:** novo ThemeService, todos os widgets que usam ThemeManager

**Validação:** Verificar se mudanças de tema são aplicadas consistentemente em todos os componentes.

---

### 15. [TODO] - Implementar exportação de resultados para PDF

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Usuários poderiam precisar de relatórios formais dos cálculos para apresentações ou documentação.

**Prompt de Implementação:**
Implemente funcionalidade de exportação para PDF que gere relatório profissional com os dados de entrada, resultados calculados e recomendações. Adicione logo, formatação adequada, gráficos se necessário e metadados do documento. Permita customização do layout do relatório.

**Dependências:** novo PDF service, widgets/custo_real_credito_result_widget.dart

**Validação:** Verificar se PDFs são gerados corretamente com formatação adequada e todos os dados necessários.

---

### 16. [OPTIMIZE] - Reduzir rebuilds desnecessários na UI

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Alguns widgets podem estar fazendo rebuild desnecessário devido a uso inadequado de ListenableBuilder.

**Prompt de Implementação:**
Analise uso de ListenableBuilder e identifique rebuilds desnecessários. Implemente granularidade adequada usando ValueListenableBuilder onde apropriado, optimize listeners para escutar apenas mudanças relevantes e use const constructors onde possível. Adicione RepaintBoundary para widgets custosos.

**Dependências:** todos os widgets que usam ListenableBuilder

**Validação:** Usar Flutter Inspector para verificar redução de rebuilds após otimização.

---

### 17. [TODO] - Adicionar suporte a diferentes tipos de investimento

**Status:** 🔴 Pendente | **Execução:** Moderada | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Sistema atualmente suporta apenas uma taxa fixa de investimento, limitando análises mais realistas.

**Prompt de Implementação:**
Implemente dropdown ou seleção para diferentes tipos de investimento como poupança, CDB, Tesouro Direto, etc. Adicione taxas pré-configuradas para cada tipo e permita customização. Implemente cálculo específico para cada tipo de investimento considerando suas características particulares.

**Dependências:** widgets/custo_real_credito_form_widget.dart, services/calculation_service.dart

**Validação:** Verificar se cálculos são precisos para diferentes tipos de investimento.

---

## 🟢 Complexidade BAIXA

### 18. [STYLE] - Padronizar constantes de layout e espaçamento

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns widgets ainda usam valores hardcoded para espaçamento em vez das constantes definidas em CalculationConstants.

**Prompt de Implementação:**
Revise todos os widgets e substitua valores hardcoded de padding, margin e spacing pelas constantes apropriadas definidas em CalculationConstants. Identifique padrões comuns e crie novas constantes se necessário. Garanta consistência visual em todo o módulo.

**Dependências:** todos os widgets, constants/calculation_constants.dart

**Validação:** Verificar se layout permanece consistente após padronização e se não há valores hardcoded.

---

### 19. [TODO] - Melhorar feedback visual para estados de loading

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Estado de loading poderia ter melhor feedback visual como skeleton screens ou indicadores mais informativos.

**Prompt de Implementação:**
Melhore feedback visual durante cálculos implementando skeleton screens para resultado, progress indicator mais informativo e animações suaves de transição. Adicione feedback haptic em dispositivos móveis e garanta que usuário saiba que sistema está processando.

**Dependências:** widgets/custo_real_credito_result_widget.dart, controllers/custo_real_credito_controller.dart

**Validação:** Verificar se feedback visual é mais claro e informativo para usuário.

---

### 20. [FIXME] - Corrigir warning de key deprecation

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Uso de Key? key está deprecated e deveria ser substituído por super.key.

**Prompt de Implementação:**
Substitua todas as ocorrências de Key? key por super.key nos construtores dos widgets. Verifique se não há outros warnings de deprecation e atualize código para usar APIs mais recentes do Flutter. Execute flutter analyze para identificar outros warnings.

**Dependências:** todos os widgets com construtores

**Validação:** Verificar se não há warnings de deprecation após correção.

---

### 21. [TODO] - Adicionar tooltips explicativos nos campos

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Médio

**Descrição:** Campos do formulário poderiam ter tooltips explicativos para ajudar usuários a entender melhor o que inserir.

**Prompt de Implementação:**
Adicione tooltips informativos para cada campo do formulário explicando o que deve ser inserido e dando exemplos. Implemente tooltips também para elementos de resultado explicando o significado de cada valor calculado. Use linguagem simples e clara.

**Dependências:** widgets/custo_real_credito_form_widget.dart, widgets/custo_real_credito_result_widget.dart

**Validação:** Verificar se tooltips são informativos e melhoram experiência do usuário.

---

### 22. [STYLE] - Melhorar consistência visual entre widgets

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Alguns elementos visuais como cores, bordas e elevações podem não estar completamente consistentes entre widgets.

**Prompt de Implementação:**
Revise todos os widgets e padronize uso de cores, bordas, elevações e outros elementos visuais. Garanta que estilo seja consistente com ShadcnStyle e que tema escuro/claro seja aplicado uniformemente. Crie style guide interno se necessário.

**Dependências:** todos os widgets, core/style/shadcn_style.dart

**Validação:** Verificar se visual é consistente em todos os widgets e modos de tema.

---

### 23. [TODO] - Implementar modo escuro aprimorado

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Modo escuro atual pode ser melhorado com cores mais adequadas e melhor contraste.

**Prompt de Implementação:**
Revise cores usadas no modo escuro para garantir melhor contraste e legibilidade. Teste com diferentes níveis de brilho de tela e garanta que cores sejam adequadas para uso prolongado. Implemente transições suaves entre modos claro e escuro.

**Dependências:** todos os widgets que implementam tema escuro

**Validação:** Verificar se modo escuro oferece boa experiência visual e legibilidade adequada.

---

### 24. [DOC] - Adicionar documentação para fórmulas financeiras

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Baixo

**Descrição:** Fórmulas financeiras usadas nos cálculos não possuem documentação adequada explicando sua origem e funcionamento.

**Prompt de Implementação:**
Adicione documentação detalhada das fórmulas financeiras utilizadas no CalculationService. Explique origem matemática, pressupostos e limitações de cada cálculo. Adicione referências a fontes confiáveis e exemplos de uso. Crie documentação interna para desenvolvedores.

**Dependências:** services/calculation_service.dart

**Validação:** Verificar se documentação é clara e tecnicamente precisa.

---

### 25. [TEST] - Implementar testes unitários para services

**Status:** 🔴 Pendente | **Execução:** Simples | **Risco:** Baixo | **Benefício:** Alto

**Descrição:** Services críticos como CalculationService não possuem testes unitários, aumentando risco de regressões.

**Prompt de Implementação:**
Crie testes unitários abrangentes para CalculationService, ValidationService e FormattingService. Teste diferentes cenários incluindo edge cases, valores extremos e situações de erro. Implemente testes de performance para validar otimizações. Adicione testes de integração para fluxos completos.

**Dependências:** todos os services, nova estrutura de testes

**Validação:** Verificar se testes cobrem cenários críticos e passam consistentemente.

---

## 🔧 Comandos Rápidos

Para solicitar implementação específica, use:
- `Executar #[número]` - Para que a IA implemente uma issue específica
- `Detalhar #[número]` - Para obter prompt mais detalhado sobre implementação
- `Focar [complexidade]` - Para trabalhar apenas com issues de uma complexidade
- `Agrupar [tipo]` - Para executar todas as issues de um tipo
- `Validar #[número]` - Para que a IA revise implementação concluída

## 📊 Estatísticas do Módulo

- **Total de Issues:** 25
- **Complexidade Alta:** 7 issues (28%)
- **Complexidade Média:** 10 issues (40%)
- **Complexidade Baixa:** 8 issues (32%)
- **Criticidade Alta:** 5 issues (BUG, SECURITY críticos)
- **Potencial de Melhoria:** Alto (múltiplas oportunidades de otimização)

## 🎯 Priorização Sugerida

1. **Primeiro:** Issues #1-7 (ALTA) - Críticas para estabilidade e arquitetura
2. **Segundo:** Issues #8-17 (MÉDIA) - Melhorias funcionais significativas
3. **Terceiro:** Issues #18-25 (BAIXA) - Polimento e refinamentos
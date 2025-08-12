# Issues - Calculadora de Idade Animal

## Índice de Issues

### Issues de Complexidade ALTA
1. [ALTA-001] **Implementar Persistência de Dados e Cache** ⚡ Critical
2. [ALTA-002] **Arquitetura de Validação de Dados Avançada** 🔍 Architecture
3. [ALTA-003] **Sistema de Internacionalização Completo** 🌍 Feature

### Issues de Complexidade MÉDIA  
4. [MÉDIA-001] **Melhorar UX com Estados de Loading** 🎨 UX
5. [MÉDIA-002] **Implementar Testes Unitários Abrangentes** 🧪 Testing
6. [MÉDIA-003] **Otimizar Performance de Renderização** ⚡ Performance
7. [MÉDIA-004] **Implementar Acessibilidade Completa** ♿ Accessibility

### Issues de Complexidade BAIXA
8. [BAIXA-001] **Corrigir Memory Leak no Controller** 🐛 Bug
9. [BAIXA-002] **Padronizar Constantes Mágicas** 📊 Code Quality
10. [BAIXA-003] **Melhorar Responsividade Mobile** 📱 UI

---

## Issues de Complexidade ALTA

### [ALTA-001] Implementar Persistência de Dados e Cache

**Status:** 🔴 Crítico - Sem implementação  
**Execução:** ⏱️ 8-12 horas  
**Risco:** 🔥 Alto - Dados perdidos a cada reinicialização  
**Benefício:** 🎯 Alto - Experiência de usuário superior

**Descrição Técnica:**
A calculadora não possui persistência de dados, perdendo todas as configurações do usuário (espécie preferida, histórico de cálculos) a cada reinicialização da aplicação. Isso resulta numa experiência fragmentada onde o usuário precisa reconfigurar tudo sempre.

**Problemas Identificados:**
- Estados volateis no `IdadeAnimalModel`
- Falta de armazenamento local para preferências
- Ausência de histórico de cálculos realizados
- Performance comprometida por recalcular dados estáticos

**Prompt de Implementação:**
```
Implementar sistema de persistência para a calculadora de idade animal:

1. SharedPreferences para configurações:
   - Espécie preferida do usuário
   - Porte padrão (se cão)
   - Preferências de interface

2. SQLite para histórico:
   - Tabela: calculations (id, species, age, size, result, date)
   - Modelo: CalculationHistory
   - Repository: CalculationRepository

3. Cache inteligente:
   - Cache de resultados frequentes
   - Invalidação automática
   - Gestão de memória

4. Integração no controller:
   - Carregar preferências na inicialização
   - Salvar automaticamente após cálculos
   - Limpar cache quando necessário

Mantenha compatibilidade com a arquitetura MVC atual.
```

**Dependências:**
- shared_preferences: ^2.2.2
- sqflite: ^2.3.0
- path: ^1.8.3

**Critérios de Validação:**
- [ ] Preferências persistem entre sessões
- [ ] Histórico armazena últimos 50 cálculos
- [ ] Cache melhora performance em 40%
- [ ] Compatibilidade com temas claro/escuro
- [ ] Testes de integração passando

---

### [ALTA-002] Arquitetura de Validação de Dados Avançada

**Status:** 🟡 Parcial - Validação básica presente  
**Execução:** ⏱️ 6-10 horas  
**Risco:** 🔥 Alto - Falhas de segurança e UX  
**Benefício:** 🎯 Alto - Robustez e confiabilidade

**Descrição Técnica:**
O sistema atual possui apenas validação básica no campo de idade (`validateNumber`), mas carece de validação robusta para edge cases, sanitização de inputs e feedback avançado ao usuário. Isso pode resultar em cálculos incorretos ou experiência confusa.

**Problemas Identificados:**
- Validação limitada apenas para números básicos
- Sem limite superior de idade (aceita 999+ anos)
- Falta validação cross-field (espécie vs porte)
- Ausência de sanitização de entrada
- Feedback de erro genérico

**Prompt de Implementação:**
```
Criar sistema de validação avançada para calculadora:

1. Classe ValidationService:
   - Validação por espécie (cão: 0-30 anos, gato: 0-25 anos)
   - Sanitização automática de inputs
   - Validação cross-field espécie/porte
   - Regras de negócio veterinárias

2. Custom validators:
   - AgeValidator com limites por espécie
   - SpeciesValidator com regras específicas
   - InputSanitizer para limpeza
   - CrossFieldValidator para dependências

3. Feedback melhorado:
   - Mensagens contextuais específicas
   - Sugestões de correção
   - Validação em tempo real
   - Indicadores visuais de status

4. Integração no controller:
   - Refatorar validateNumber para usar novo sistema
   - Adicionar validação assíncrona
   - Implementar debounce para performance

Seguir padrões de validação do Flutter/Dart.
```

**Dependências:**
- form_field_validator: ^1.1.0
- rxdart: ^0.27.7 (para debounce)

**Critérios de Validação:**
- [ ] Valida limites realistas por espécie
- [ ] Sanitiza inputs automaticamente
- [ ] Feedback contextual em tempo real
- [ ] Performance mantida com debounce
- [ ] Cobertura de testes >90%

---

### [ALTA-003] Sistema de Internacionalização Completo

**Status:** 🔴 Não implementado  
**Execução:** ⏱️ 10-15 horas  
**Risco:** 🟡 Médio - Limitação de mercado  
**Benefício:** 🎯 Alto - Expansão internacional

**Descrição Técnica:**
A aplicação está completamente em português brasileiro hardcoded, limitando seu alcance internacional. Não há estrutura para localização, formatação de números por região ou adaptação cultural das informações veterinárias.

**Problemas Identificados:**
- Textos hardcoded em português
- Sem suporte a flutter_localizations
- Formatos de data/número fixos
- Informações veterinárias culturalmente específicas
- Interface não adaptada para RTL

**Prompt de Implementação:**
```
Implementar sistema de i18n completo:

1. Configuração básica:
   - flutter_localizations dependency
   - Configurar supported locales (pt_BR, en_US, es_ES)
   - Setup de AppLocalizations
   - Delegate configuration

2. Arquivos de tradução:
   - app_pt.arb (português brasileiro)
   - app_en.arb (inglês americano)  
   - app_es.arb (espanhol)
   - Incluir plurais e contextos

3. Adaptação cultural:
   - Fórmulas de idade por região (se diferem)
   - Terminologia veterinária local
   - Formatos de número regionais
   - Direcionamento de texto (LTR/RTL)

4. Refatoração do código:
   - Substituir strings hardcoded
   - Usar AppLocalizations.of(context)
   - Adaptar formatação de resultados
   - Testes com múltiplos locales

Manter estrutura MVC e performance.
```

**Dependências:**
- flutter_localizations: SDK
- intl: ^0.18.1

**Critérios de Validação:**
- [ ] Suporte completo pt_BR, en_US, es_ES
- [ ] Formatação correta por região
- [ ] Plurais funcionando adequadamente  
- [ ] Testes em todos os idiomas
- [ ] Performance não afetada

---

## Issues de Complexidade MÉDIA

### [MÉDIA-001] Melhorar UX com Estados de Loading

**Status:** 🔴 Não implementado  
**Execução:** ⏱️ 4-6 horas  
**Risco:** 🟡 Médio - UX comprometida  
**Benefício:** 🎯 Médio - Melhor experiência

**Descrição Técnica:**
O cálculo da idade é instantâneo mas não há feedback visual durante a operação, e no futuro com persistência/cache pode haver delays. A ausência de estados de loading deixa o usuário sem clareza sobre o que está acontecendo.

**Problemas Identificados:**
- Sem indicadores de progresso
- Botões ativos durante processamento
- Falta de feedback para operações assíncronas futuras
- Estados intermediários não representados

**Prompt de Implementação:**
```
Implementar estados de loading e feedback:

1. Estados no controller:
   - LoadingState enum (idle, calculating, saving, error)
   - isLoading getter boolean
   - Métodos para gerenciar estado

2. Componentes de loading:
   - Custom loading button
   - Skeleton loading para resultados
   - Progress indicators contextuais
   - Overlay para operações pesadas

3. Feedback visual:
   - Desabilitar campos durante cálculo
   - Animações de transição suaves
   - Cores e ícones de status
   - Mensagens de progresso

4. Integração:
   - Wrap métodos assíncronos com loading
   - Usar FutureBuilder onde apropriado
   - Tratamento de erros com feedback
   - Testes de estados intermediários

Manter performance e acessibilidade.
```

**Dependências:**
- shimmer: ^3.0.0 (para skeleton loading)

**Critérios de Validação:**
- [ ] Loading states funcionais
- [ ] Transições suaves
- [ ] Botões desabilitados adequadamente
- [ ] Feedback de erro claro
- [ ] Acessibilidade mantida

---

### [MÉDIA-002] Implementar Testes Unitários Abrangentes

**Status:** 🔴 Não implementado  
**Execução:** ⏱️ 8-12 horas  
**Risco:** 🔥 Alto - Regressões não detectadas  
**Benefício:** 🎯 Alto - Qualidade e manutenibilidade

**Descrição Técnica:**
A calculadora não possui testes automatizados, tornando difícil detectar regressões e garantir que os cálculos veterinários estão corretos. Com fórmulas complexas por porte/espécie, testes são essenciais.

**Problemas Identificados:**
- Zero cobertura de testes
- Lógica de cálculo complexa sem validação
- Refatorações arriscadas
- Falta de CI/CD confiável

**Prompt de Implementação:**
```
Criar suite completa de testes:

1. Testes unitários do model:
   - IdadeAnimalModel state management
   - Validação de dados
   - Métodos copyWith e limpar
   - Edge cases e null safety

2. Testes do controller:
   - Cálculos para todas combinações espécie/porte
   - Validação de formulários
   - Notificação de listeners
   - Lifecycle do controller

3. Testes de widgets:
   - Renderização de componentes
   - Interações do usuário
   - Estados visuais diferentes
   - Integração entre widgets

4. Testes de integração:
   - Fluxo completo de cálculo
   - Validação end-to-end
   - Performance benchmarks
   - Cenários de erro

Usar mockito para dependencies e golden tests para UI.
```

**Dependências:**
- flutter_test: SDK
- mockito: ^5.4.2
- build_runner: ^2.4.7

**Critérios de Validação:**
- [ ] Cobertura >85% no código crítico
- [ ] Todos os cálculos validados
- [ ] Testes de regressão
- [ ] CI pipeline configurado
- [ ] Documentação de testes

---

### [MÉDIA-003] Otimizar Performance de Renderização

**Status:** 🟡 Aceitável - Melhorias necessárias  
**Execução:** ⏱️ 5-8 horas  
**Risco:** 🟡 Médio - Performance degradada  
**Benefício:** 🎯 Médio - Fluidez melhorada

**Descrição Técnica:**
O widget tree possui rebuilds desnecessários no Consumer e falta otimizações como const constructors. Com animações futuras e mais dados, a performance pode degradar.

**Problemas Identificados:**
- Consumer rebuilda toda a árvore
- Falta de const constructors
- Widgets não otimizados
- Cálculos síncronos no build

**Prompt de Implementação:**
```
Otimizar performance de renderização:

1. Widget optimization:
   - Adicionar const constructors onde possível
   - Usar Selector ao invés de Consumer
   - Implementar shouldRebuild logic
   - Extrair sub-widgets estáticos

2. State management:
   - Granular notifyListeners()
   - Separate models for different concerns
   - Immutable state updates
   - Lazy loading onde apropriado

3. Build optimizations:
   - Mover cálculos para fora do build
   - Cache de valores computados
   - RepaintBoundary em widgets pesados
   - ProfileMode performance testing

4. Memory optimization:
   - Proper dispose of resources
   - WeakReference onde adequado
   - Image/asset caching
   - Garbage collection friendly

Manter funcionalidade e adicionar benchmarks.
```

**Dependências:**
- flutter/foundation.dart (para kDebugMode)

**Critérios de Validação:**
- [ ] 60fps consistente
- [ ] Reduziu rebuilds desnecessários
- [ ] Memory leaks corrigidos
- [ ] Benchmarks melhorados
- [ ] Profiling clean

---

### [MÉDIA-004] Implementar Acessibilidade Completa

**Status:** 🟡 Básica presente - Melhorias necessárias  
**Execução:** ⏱️ 6-10 horas  
**Risco:** 🟡 Médio - Exclusão de usuários  
**Benefício:** 🎯 Alto - Inclusão e compliance

**Descrição Técnica:**
A aplicação tem acessibilidade básica mas carece de semantics adequadas, navegação por teclado, e suporte completo para leitores de tela. Não atende padrões WCAG 2.1.

**Problemas Identificados:**
- Falta de labels semânticas específicas
- Navegação por teclado limitada
- Contraste não validado
- Sem suporte para voice control
- Feedback sonoro ausente

**Prompt de Implementação:**
```
Implementar acessibilidade completa:

1. Semantic widgets:
   - Adicionar Semantics com labels contextuais
   - Definir roles e states apropriados
   - Implementar custom semantic actions
   - Navegação lógica de foco

2. Keyboard navigation:
   - FocusNode management adequado
   - Shortcuts para ações principais
   - Tab order lógico
   - Escape/back navigation

3. Screen reader support:
   - Announcements para resultados
   - Context hints para dropdowns
   - Progress announcements
   - Error message reading

4. WCAG compliance:
   - Contrast ratio validation
   - Touch target sizing (44px mínimo)
   - Motion preferences respect
   - Text scaling support

Testar com TalkBack/VoiceOver e ferramentas de auditoria.
```

**Dependências:**
- flutter/semantics.dart
- Accessibility testing tools

**Critérios de Validação:**
- [ ] WCAG 2.1 AA compliance
- [ ] TalkBack/VoiceOver funcionais
- [ ] Navegação por teclado completa
- [ ] Contraste adequado
- [ ] Auditoria aprovada

---

## Issues de Complexidade BAIXA

### [BAIXA-001] Corrigir Memory Leak no Controller

**Status:** 🟡 Potencial problema  
**Execução:** ⏱️ 1-2 horas  
**Risco:** 🟡 Médio - Vazamento de memória  
**Benefício:** 🎯 Médio - Estabilidade

**Descrição Técnica:**
O `IdadeAnimalController` é criado no `ChangeNotifierProvider` sem dispose adequado, e embora implemente dispose(), pode haver listeners não removidos adequadamente em cenários específicos.

**Problemas Identificados:**
- Provider pode não chamar dispose em cenários edge
- TextEditingController pode vazar se dispose falhar
- Listeners podem persistir após dispose

**Prompt de Implementação:**
```
Corrigir possível memory leak:

1. Audit do lifecycle:
   - Verificar se dispose é sempre chamado
   - Adicionar logging em debug mode
   - Implementar dispose tracking

2. Defensive programming:
   - Null checks antes de dispose
   - Try-catch em dispose methods
   - Clear de listeners explicitamente

3. Provider optimization:
   - Usar Provider.dispose parameter
   - Considerar ProxyProvider se necessário
   - Memory leak testing

4. Monitoring:
   - Debug prints para lifecycle
   - Memory usage tracking
   - Automated leak detection

Foco em robustez e debugging.
```

**Dependências:**
Nenhuma nova

**Critérios de Validação:**
- [ ] Dispose sempre executado
- [ ] Zero memory leaks no profiler
- [ ] Logging adequado em debug
- [ ] Testes de lifecycle
- [ ] Documentação atualizada

---

### [BAIXA-002] Padronizar Constantes Mágicas

**Status:** 🟡 Múltiplas magic numbers  
**Execução:** ⏱️ 2-3 horas  
**Risco:** 🟢 Baixo - Manutenibilidade  
**Benefício:** 🎯 Médio - Código mais limpo

**Descrição Técnica:**
O código possui várias "magic numbers" nas fórmulas de cálculo (15, 24, 4, 5, 6, 7) e limites de idade hardcoded, dificultando manutenção e compreensão do código.

**Problemas Identificados:**
- Magic numbers nas fórmulas veterinárias
- Limites de idade hardcoded
- Constantes de UI espalhadas
- Falta de documentação dos valores

**Prompt de Implementação:**
```
Extrair e documentar constantes:

1. Classe AnimalAgeConstants:
   - DOG_FIRST_YEAR_HUMAN_AGE = 15
   - DOG_SECOND_YEAR_HUMAN_AGE = 24
   - CAT_FIRST_YEAR_HUMAN_AGE = 15
   - Fatores por porte documentados

2. Classe AgePhaseConstants:
   - Limites de fase por espécie/porte
   - Strings de fase de vida
   - Ranges para adulto/idoso

3. UI Constants:
   - Padding e margin values
   - Color constants
   - Size constraints

4. Documentação:
   - Comentários explicando origem dos valores
   - Referências veterinárias
   - Razão para cada constante

Manter compatibilidade e adicionar testes.
```

**Dependências:**
Nenhuma nova

**Critérios de Validação:**
- [ ] Zero magic numbers no código
- [ ] Constantes bem documentadas
- [ ] Agrupamento lógico
- [ ] Fácil modificação futura
- [ ] Testes não quebrados

---

### [BAIXA-003] Melhorar Responsividade Mobile

**Status:** 🟡 Funcional - Melhorias necessárias  
**Execução:** ⏱️ 3-4 horas  
**Risco:** 🟢 Baixo - UX mobile comprometida  
**Benefício:** 🎯 Alto - Melhor UX mobile

**Descrição Técnica:**
O layout possui largura fixa de 1120px e não se adapta adequadamente a diferentes tamanhos de tela, especialmente em dispositivos móveis onde pode haver overflow ou espaçamento inadequado.

**Problemas Identificados:**
- SizedBox com largura fixa (1120px)
- Padding não responsivo
- Não considera safe areas
- Dialog pode vazar em telas pequenas

**Prompt de Implementação:**
```
Implementar design responsivo:

1. Layout adaptivo:
   - Substituir largura fixa por ResponsiveLayout
   - Breakpoints para mobile/tablet/desktop
   - Flexible padding baseado em screen size
   - SafeArea implementation

2. Components adaptation:
   - Cards com max/min width constraints
   - Buttons com sizing apropriado
   - Text scaling baseado na tela
   - Dialog responsivo

3. Mobile optimizations:
   - Touch target sizing (44px+)
   - Scrolling improvements
   - Keyboard avoidance
   - Portrait/landscape support

4. Testing:
   - Multiple device sizes
   - Orientation changes
   - Edge cases (muito pequeno/grande)
   - Physical device testing

Usar MediaQuery e LayoutBuilder eficientemente.
```

**Dependências:**
Nenhuma nova (usar Flutter built-in)

**Critérios de Validação:**
- [ ] Funciona em todos os tamanhos
- [ ] Sem overflow em dispositivos
- [ ] Touch targets adequados
- [ ] Safe areas respeitadas
- [ ] Performance mantida

---

## Comandos Rápidos

### Análise de Issues
```bash
# Verificar cobertura de testes
flutter test --coverage

# Análise estática
flutter analyze

# Performance profiling
flutter run --profile

# Accessibility audit
flutter run --debug
```

### Implementação
```bash
# Criar testes
mkdir test/
touch test/idade_animal_test.dart

# Adicionar dependências
flutter pub add shared_preferences sqflite

# Gerar localizations
flutter gen-l10n

# Build e teste
flutter build apk --debug
```

### Validação
```bash
# Validar memory leaks
flutter run --profile --trace-startup

# Teste de acessibilidade
flutter test integration_test/accessibility_test.dart

# Análise de performance
flutter run --trace-startup --profile
```

---

**Legenda de Status:**
- 🔴 Crítico/Não implementado
- 🟡 Parcial/Atenção necessária  
- 🟢 OK/Pequenos ajustes

**Legenda de Risco:**
- 🔥 Alto - Impacto significativo
- 🟡 Médio - Impacto moderado
- 🟢 Baixo - Impacto mínimo

**Legenda de Benefício:**
- 🎯 Alto - Grande valor agregado
- 🎯 Médio - Valor moderado
- 🎯 Baixo - Pequeno valor
# Issues - Calculadora de Peso Ideal por Condição Corporal

## Índice de Issues

### ALTA COMPLEXIDADE (3 issues)
1. **[ARQUITETURA]** Refatoração completa da arquitetura de validação e cálculos
2. **[INTEGRAÇÃO]** Sistema de persistência de dados e histórico de cálculos
3. **[ALGORITMO]** Otimização dos algoritmos de cálculo com fatores adicionais

### MÉDIA COMPLEXIDADE (4 issues)
4. **[UX/UI]** Interface responsiva com validações em tempo real
5. **[FUNCIONALIDADE]** Sistema de sugestões inteligentes baseado em dados
6. **[PERFORMANCE]** Otimização de renderização e gerenciamento de estado
7. **[SEGURANÇA]** Validação robusta de entrada e sanitização de dados

### BAIXA COMPLEXIDADE (3 issues)
8. **[MANUTENIBILIDADE]** Padronização de nomenclatura e documentação
9. **[ACESSIBILIDADE]** Melhoria da acessibilidade e suporte a idiomas
10. **[QUALIDADE]** Cobertura de testes e logging estruturado

---

## ALTA COMPLEXIDADE

### 1. **[ARQUITETURA]** Refatoração completa da arquitetura de validação e cálculos

**Status:** Crítico  
**Execução:** 5-7 dias  
**Risco:** Alto  
**Benefício:** Extremamente Alto  

**Descrição Técnica:**
A arquitetura atual mistura lógica de negócio com apresentação, especialmente no `PesoIdealUtils.calcular()` que recebe um `BuildContext` desnecessariamente. O modelo `PesoIdealModel` possui dados hardcoded e não há separação clara entre domínio, aplicação e infraestrutura. O controller possui responsabilidades excessivas, gerenciando tanto UI quanto cálculos complexos.

**Problemas Identificados:**
- `PesoIdealUtils.calcular()` viola princípio de responsabilidade única
- Model com dados hardcoded (`racasPorEspecie`, `pesoIdealPorRaca`)
- Ausência de camada de domínio e casos de uso
- Validações dispersas entre utils e widgets
- Acoplamento forte entre controller e view

**Prompt de Implementação:**
```
Refatore a arquitetura da calculadora de peso ideal seguindo Clean Architecture:

1. Criar camada de domínio:
   - Entidades: Animal, CalculoPesoIdeal, EscalaECC
   - Value Objects: Peso, Idade, EspecieAnimal
   - Interfaces de repositório: AnimalRepository, CalculoRepository

2. Criar camada de aplicação:
   - Use Cases: CalcularPesoIdealUseCase, ValidarDadosAnimalUseCase
   - DTOs para transferência de dados
   - Serviços de domínio para cálculos

3. Refatorar controller:
   - Injeção de dependências
   - Separar validações de UI
   - Implementar padrão Command/Query

4. Criar repositórios para dados:
   - RacasRepository (dados de raças)
   - CalculosRepository (histórico)
   - ConfiguracoesRepository
```

**Dependências:**
- Package `injectable` ou `get_it` para DI
- Package `dartz` para tratamento de erros funcionais
- Reestruturação completa de diretórios

**Critérios de Validação:**
- [ ] Separação clara de responsabilidades por camada
- [ ] Testes unitários para cada use case
- [ ] Controller com máximo 50 linhas
- [ ] Zero dependências de Flutter na camada de domínio
- [ ] Cobertura de testes > 90%

### 2. **[INTEGRAÇÃO]** Sistema de persistência de dados e histórico de cálculos

**Status:** Importante  
**Execução:** 4-6 dias  
**Risco:** Médio-Alto  
**Benefício:** Alto  

**Descrição Técnica:**
A aplicação não persiste dados de cálculos anteriores, configurações do usuário ou histórico de animais. Não há integração com sistemas externos para dados veterinários atualizados. O sistema atual recalcula tudo a cada interação, perdendo oportunidades de otimização e personalização.

**Problemas Identificados:**
- Ausência de banco de dados local
- Nenhuma persistência de histórico de cálculos
- Dados de raças hardcoded e desatualizados
- Impossibilidade de comparar evolução do animal
- Falta de backup/sincronização de dados

**Prompt de Implementação:**
```
Implementar sistema completo de persistência:

1. Banco de dados local:
   - Tabelas: animais, calculos, configuracoes, racas
   - Migrations e versionamento de schema
   - Índices para queries frequentes

2. Repositórios com cache:
   - Cache em memória para dados frequentes
   - Estratégia de invalidação de cache
   - Fallback para dados offline

3. Sincronização remota:
   - API para dados de raças atualizados
   - Sync de configurações entre dispositivos
   - Backup automático na nuvem

4. Histórico e analytics:
   - Tracking de cálculos por animal
   - Gráficos de evolução de peso
   - Estatísticas de uso

5. Import/Export:
   - Exportar dados para CSV/PDF
   - Importar dados veterinários
   - Compartilhamento de relatórios
```

**Dependências:**
- `sqflite` ou `drift` para banco local
- `hive` para cache rápido
- `dio` para comunicação HTTP
- Package de sincronização (Firebase/Supabase)

**Critérios de Validação:**
- [ ] Todos os cálculos persistidos localmente
- [ ] Histórico acessível por animal
- [ ] Sync bidirecional funcionando
- [ ] Backup automático configurado
- [ ] Performance de queries < 100ms

### 3. **[ALGORITMO]** Otimização dos algoritmos de cálculo com fatores adicionais

**Status:** Importante  
**Execução:** 3-5 dias  
**Risco:** Médio  
**Benefício:** Alto  

**Descrição Técnica:**
Os algoritmos atuais são simplificados e não consideram fatores importantes como genética, histórico médico, nível de atividade específico, sazonalidade, ou condições climáticas. O cálculo de peso metabólico usa fórmula genérica que pode não ser precisa para todas as raças e idades.

**Problemas Identificados:**
- Fórmula de peso metabólico muito genérica
- Ausência de fatores de raça específicos
- Não considera histórico médico
- Falta de ajustes sazonais
- Algoritmo linear para tempo estimado

**Prompt de Implementação:**
```
Desenvolver algoritmos avançados de cálculo:

1. Algoritmo de peso metabólico refinado:
   - Fórmulas específicas por espécie/raça
   - Ajustes por idade em fases (filhote, adulto, senior)
   - Correções por condições médicas
   - Fatores genéticos por linhagem

2. Sistema de fatores dinâmicos:
   - Nível de atividade (sedentário, moderado, ativo, atlético)
   - Fatores ambientais (clima, estação)
   - Histórico de peso (tendências)
   - Metabolismo individual

3. Machine Learning para previsões:
   - Modelo de regressão para tempo estimado
   - Clustering por perfis similares
   - Ajuste automático de parâmetros
   - Aprendizado com feedback veterinário

4. Validação científica:
   - Comparação com dados veterinários
   - Testes com diferentes perfis
   - Margem de erro calculada
   - Intervalos de confiança

5. Sistema de alertas inteligentes:
   - Detecção de anomalias
   - Sugestões automáticas
   - Avisos de segurança
   - Recomendações personalizadas
```

**Dependências:**
- `ml_algo` ou `tensorflow_lite` para ML
- Dados científicos veterinários
- Package de análise estatística
- APIs de dados climáticos

**Critérios de Validação:**
- [ ] Precisão >85% em testes com dados reais
- [ ] Consideração de pelo menos 8 fatores
- [ ] Intervalos de confiança calculados
- [ ] Validação com veterinários
- [ ] Performance de cálculo < 200ms

---

## MÉDIA COMPLEXIDADE

### 4. **[UX/UI]** Interface responsiva com validações em tempo real

**Status:** Importante  
**Execução:** 3-4 dias  
**Risco:** Baixo-Médio  
**Benefício:** Alto  

**Descrição Técnica:**
A interface atual não é totalmente responsiva, especialmente em tablets e dispositivos móveis. As validações só ocorrem no submit do formulário, não há feedback visual durante preenchimento, e a UX não guia adequadamente o usuário através do processo de cálculo.

**Problemas Identificados:**
- Layout fixo de 1120px não responsivo
- Validações apenas on-submit
- Ausência de feedback visual em tempo real
- Campos não adaptados para mobile
- Falta de indicadores de progresso

**Prompt de Implementação:**
```
Criar interface responsiva com validações em tempo real:

1. Layout responsivo:
   - Breakpoints para mobile, tablet, desktop
   - Grid adaptativo com flutter_staggered_grid_view
   - Componentes que se reorganizam automaticamente
   - Testes em diferentes resoluções

2. Validações em tempo real:
   - Debounced validation nos TextFields
   - Feedback visual imediato (cores, ícones)
   - Tooltips com dicas contextuais
   - Autocomplete para campos de raça

3. UX aprimorada:
   - Stepper para guiar o processo
   - Indicadores de campos obrigatórios
   - Animações suaves entre estados
   - Loading states para cálculos

4. Acessibilidade:
   - Semantics para screen readers
   - Contraste adequado de cores
   - Tamanhos de toque > 44px
   - Navegação por teclado

5. Componentes inteligentes:
   - Campo de peso com formatação automática
   - Slider de ECC com preview visual
   - Dropdown de raças com busca
   - Calculadora integrada
```

**Dependências:**
- `flutter_form_builder` para formulários avançados
- `flutter_typeahead` para autocomplete
- Package de animações
- Testing em dispositivos reais

**Critérios de Validação:**
- [ ] Funcional em resoluções 320px-2560px
- [ ] Validações com debounce < 300ms
- [ ] Acessibilidade score > 90%
- [ ] Todas as animações < 300ms
- [ ] Zero overflow em qualquer dispositivo

### 5. **[FUNCIONALIDADE]** Sistema de sugestões inteligentes baseado em dados

**Status:** Desejável  
**Execução:** 2-4 dias  
**Risco:** Baixo  
**Benefício:** Médio-Alto  

**Descrição Técnica:**
O sistema atual não oferece sugestões inteligentes baseadas em dados históricos ou padrões. Não há sistema de recomendações personalizadas, comparações com animais similares, ou alertas proativos sobre tendências de peso.

**Problemas Identificados:**
- Ausência de sistema de recomendações
- Não compara com dados de animais similares
- Falta de alertas proativos
- Recomendações genéricas e estáticas
- Não aprende com histórico do usuário

**Prompt de Implementação:**
```
Implementar sistema de sugestões inteligentes:

1. Engine de recomendações:
   - Análise de padrões por raça/idade
   - Comparação com população similar
   - Sugestões baseadas em sucesso histórico
   - Machine learning para personalização

2. Alertas inteligentes:
   - Detecção de variações anômalas
   - Lembretes de pesagem
   - Sugestões de revisão veterinária
   - Alertas de tendências preocupantes

3. Comparações e benchmarks:
   - Posição relativa na população
   - Gráficos comparativos
   - Metas baseadas em dados reais
   - Progresso vs. expectativa

4. Assistente virtual:
   - Chatbot para dúvidas básicas
   - Explicações contextuais
   - Sugestões de próximos passos
   - Links para recursos educacionais

5. Gamificação:
   - Badges por metas atingidas
   - Desafios de melhoria
   - Compartilhamento de conquistas
   - Sistema de pontuação
```

**Dependências:**
- Base de dados ampla para comparações
- Sistema de analytics
- Package de ML/AI
- Backend para processamento

**Critérios de Validação:**
- [ ] Sugestões relevantes em >80% dos casos
- [ ] Alertas proativos implementados
- [ ] Sistema de comparação funcional
- [ ] Engagement aumentado em 30%
- [ ] Feedback positivo dos usuários

### 6. **[PERFORMANCE]** Otimização de renderização e gerenciamento de estado

**Status:** Importante  
**Execução:** 2-3 dias  
**Risco:** Baixo  
**Benefício:** Médio  

**Descrição Técnica:**
O sistema atual usa `notifyListeners()` em excesso, causando rebuilds desnecessários. Não há otimizações de performance como lazy loading, memoização ou cache de widgets. O controller reconstrói toda a árvore de widgets a cada mudança menor.

**Problemas Identificados:**
- Rebuilds excessivos com `notifyListeners()`
- Ausência de `const` constructors
- Widgets não otimizados para performance
- Cálculos repetidos desnecessariamente
- Falta de lazy loading para dados grandes

**Prompt de Implementação:**
```
Otimizar performance e gerenciamento de estado:

1. Gerenciamento de estado otimizado:
   - Implementar ValueNotifier específicos
   - Usar Selector widgets para rebuilds seletivos
   - Cache de cálculos computacionalmente caros
   - Memoização de operações repetitivas

2. Otimizações de renderização:
   - const constructors em todos os widgets
   - RepaintBoundary em componentes pesados
   - AutomaticKeepAliveClientMixin quando necessário
   - Lazy loading para listas grandes

3. Performance de cálculos:
   - Isolates para cálculos complexos
   - Debounce em operações frequentes
   - Cache de resultados intermediários
   - Otimização de algoritmos matemáticos

4. Monitoramento de performance:
   - Timeline tracking
   - Memory leak detection
   - FPS monitoring
   - Build time analytics

5. Otimizações específicas:
   - Image loading otimizado
   - Bundle size reduzido
   - Startup time melhorado
   - Battery usage otimizado
```

**Dependências:**
- `flutter_performance_tools`
- Ferramentas de profiling
- Packages de state management otimizado
- Testing de performance

**Critérios de Validação:**
- [ ] Rebuilds reduzidos em >70%
- [ ] Tempo de cálculo < 100ms
- [ ] Memory usage estável
- [ ] FPS consistente > 55
- [ ] Startup time < 2s

### 7. **[SEGURANÇA]** Validação robusta de entrada e sanitização de dados

**Status:** Crítico  
**Execução:** 2-3 dias  
**Risco:** Alto  
**Benefício:** Alto  

**Descrição Técnica:**
As validações atuais são básicas e podem ser bypassadas. Não há sanitização adequada de dados de entrada, validação de limites biológicos realistas, ou proteção contra injection de dados maliciosos. O sistema aceita valores irreais sem questionar.

**Problemas Identificados:**
- Validação básica apenas para null/empty
- Ausência de limites biológicos realistas
- Não há sanitização de entrada
- Possível overflow em cálculos
- Falta de validação cruzada entre campos

**Prompt de Implementação:**
```
Implementar sistema robusto de validação e segurança:

1. Validadores avançados:
   - Limites biológicos por espécie (peso mín/máx)
   - Validação cruzada entre campos
   - Regex patterns para formatos específicos
   - Validação de ranges realísticos

2. Sanitização de dados:
   - Input sanitization para todos os campos
   - Escape de caracteres especiais
   - Normalização de números decimais
   - Proteção contra overflow/underflow

3. Validação de negócio:
   - Regras específicas por espécie/raça
   - Validação de combinações impossíveis
   - Alertas para valores suspeitos
   - Confirmação para valores extremos

4. Segurança de dados:
   - Criptografia para dados sensíveis
   - Hashing de identificadores
   - Logs de auditoria
   - Rate limiting para operações

5. Error handling robusto:
   - Try-catch em todos os cálculos
   - Fallbacks para valores inválidos
   - Mensagens de erro claras
   - Recovery automático quando possível
```

**Dependências:**
- Package de validação avançada
- Biblioteca de criptografia  
- Sistema de logging
- Testes de segurança

**Critérios de Validação:**
- [ ] Todos os inputs validados e sanitizados
- [ ] Limites biológicos implementados
- [ ] Zero crashes por dados inválidos
- [ ] Logs de auditoria funcionais
- [ ] Testes de penetração passando

---

## BAIXA COMPLEXIDADE

### 8. **[MANUTENIBILIDADE]** Padronização de nomenclatura e documentação

**Status:** Importante  
**Execução:** 1-2 dias  
**Risco:** Muito Baixo  
**Benefício:** Médio  

**Descrição Técnica:**
O código possui inconsistências de nomenclatura (camelCase vs snake_case), documentação insuficiente, e não segue padrões estabelecidos do projeto. Faltam comentários explicativos em cálculos complexos e não há documentação de API.

**Problemas Identificados:**
- Inconsistência de nomenclatura entre arquivos
- Documentação insuficiente em métodos complexos
- Ausência de comentários em fórmulas matemáticas
- Não há documentação de uso da calculadora
- Falta padronização de estrutura de comentários

**Prompt de Implementação:**
```
Padronizar nomenclatura e melhorar documentação:

1. Padronização de código:
   - Aplicar dart format em todos os arquivos
   - Renomear variáveis para padrão camelCase
   - Padronizar nomes de métodos e classes
   - Aplicar linting rules rigorosas

2. Documentação técnica:
   - Documentar todos os métodos públicos
   - Explicar fórmulas matemáticas complexas
   - Adicionar examples nos comentários
   - Documentar parâmetros e retornos

3. Comentários explicativos:
   - Explicar lógica de negócio complexa
   - Documentar constantes e magic numbers
   - Comentários TODO e FIXME organizados
   - Headers informativos em arquivos

4. Documentação de usuário:
   - README com instruções de uso
   - Guia de contribuição
   - Documentação da API
   - Changelog estruturado

5. Padronização de estrutura:
   - Organização consistente de imports
   - Ordem padronizada de métodos
   - Estrutura de arquivos documentada
   - Naming conventions definidas
```

**Dependências:**
- Configuração de linter
- Ferramentas de documentação
- Code formatting tools
- Templates de documentação

**Critérios de Validação:**
- [ ] 100% dos métodos públicos documentados
- [ ] Linter sem warnings
- [ ] Padrões de nomenclatura consistentes
- [ ] README completo e atualizado
- [ ] Coverage de documentação > 80%

### 9. **[ACESSIBILIDADE]** Melhoria da acessibilidade e suporte a idiomas

**Status:** Desejável  
**Execução:** 1-2 dias  
**Risco:** Muito Baixo  
**Benefício:** Médio  

**Descrição Técnica:**
A aplicação não possui suporte adequado para acessibilidade, faltam semantic labels, não há suporte a multiple idiomas, e não está otimizada para screen readers. As cores podem não ter contraste suficiente para usuários com deficiência visual.

**Problemas Identificados:**
- Ausência de semantic labels
- Não há suporte a internacionalização
- Contraste de cores não verificado
- Navegação por teclado não implementada
- Falta de suporte a screen readers

**Prompt de Implementação:**
```
Implementar melhorias de acessibilidade e i18n:

1. Acessibilidade básica:
   - Semantic labels em todos os widgets
   - Contraste adequado de cores (WCAG 2.1)
   - Tamanhos mínimos de toque (44px)
   - Navegação por teclado funcional

2. Screen readers:
   - Semantics apropriados para conteúdo
   - Announcements para mudanças de estado
   - Ordem lógica de navegação
   - Descrições de imagens e gráficos

3. Internacionalização:
   - Configuração do flutter_localizations
   - Strings externalizadas em arquivos .arb
   - Tradução para inglês e espanhol
   - Formatação de números por locale

4. Customização de acessibilidade:
   - Modo alto contraste
   - Tamanhos de fonte ajustáveis
   - Opções de tema para dislexia
   - Redução de animações

5. Testes de acessibilidade:
   - Testes automáticos de semantic
   - Validação com screen readers
   - Testes com usuários reais
   - Compliance com diretrizes WCAG
```

**Dependências:**
- `flutter_localizations`
- Packages de acessibilidade
- Ferramentas de teste
- Tradutores profissionais

**Critérios de Validação:**
- [ ] Acessibilidade score > 90%
- [ ] Suporte a 3 idiomas
- [ ] Navegação por teclado funcional
- [ ] Teste com screen reader aprovado
- [ ] Contraste WCAG AA compliance

### 10. **[QUALIDADE]** Cobertura de testes e logging estruturado

**Status:** Crítico  
**Execução:** 2-3 dias  
**Risco:** Baixo  
**Benefício:** Alto  

**Descrição Técnica:**
Não existem testes unitários, de integração ou de widget para a calculadora. Não há sistema de logging estruturado para debug e monitoramento. Ausência de testes de regressão e validação de cálculos matemáticos.

**Problemas Identificados:**
- Zero cobertura de testes
- Ausência de logging estruturado
- Não há validação de cálculos matemáticos
- Falta de testes de edge cases
- Ausência de continuous integration

**Prompt de Implementação:**
```
Implementar cobertura completa de testes e logging:

1. Testes unitários:
   - Testes para todos os cálculos matemáticos
   - Validação de edge cases
   - Testes de validação de dados
   - Mocking de dependências externas

2. Testes de widgets:
   - Interação com formulários
   - Validação de UI responsiva
   - Testes de acessibilidade
   - Golden tests para consistência visual

3. Testes de integração:
   - Fluxo completo de cálculo
   - Persistência de dados
   - Sincronização remota
   - Performance under load

4. Sistema de logging:
   - Structured logging com níveis
   - Tracking de eventos importantes
   - Error logging com stack traces
   - Performance metrics

5. Continuous Integration:
   - Testes automáticos no CI/CD
   - Code coverage reports
   - Static analysis
   - Automated deployment

6. Testes matemáticos específicos:
   - Validação de fórmulas veterinárias
   - Testes com dados conhecidos
   - Verificação de precisão numérica
   - Testes de regressão
```

**Dependências:**
- `flutter_test` e `mockito`
- `logger` ou similar
- CI/CD pipeline (GitHub Actions)
- Ferramentas de coverage

**Critérios de Validação:**
- [ ] Cobertura de testes > 90%
- [ ] Todos os cálculos validados
- [ ] Zero bugs em production
- [ ] Logs estruturados funcionais
- [ ] CI/CD pipeline configurado

---

## Comandos Rápidos

### Análise do Código
```bash
# Verificar issues de linting
flutter analyze lib/app-petiveti/pages/calc/peso_ideal_condicao_corporal/

# Executar testes (quando implementados)
flutter test test/peso_ideal/

# Verificar cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Performance profiling
flutter run --profile --trace-startup
```

### Desenvolvimento
```bash
# Gerar código (se usando build_runner)
flutter packages pub run build_runner build

# Formatar código
dart format lib/app-petiveti/pages/calc/peso_ideal_condicao_corporal/

# Verificar dependências
flutter pub deps
```

### Validação de Qualidade
```bash
# Métricas de código
flutter pub global activate dart_code_metrics
metrics lib/app-petiveti/pages/calc/peso_ideal_condicao_corporal/

# Análise de segurança
flutter pub global activate security_monkey
security_monkey analyze

# Testes de acessibilidade
flutter test --dart-define=ACCESSIBILITY_TEST=true
```

### Comandos de Manutenção
```bash
# Limpar cache
flutter clean && flutter pub get

# Atualizar dependências
flutter pub upgrade

# Verificar versões obsoletas
flutter pub outdated
```
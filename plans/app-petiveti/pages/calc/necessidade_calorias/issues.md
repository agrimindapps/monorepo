# Issues - Calculadora de Necessidades Calóricas

## Índice

### Issues de Complexidade ALTA
1. [#001 - Implementar Serialização JSON e Persistência de Dados](#001)
2. [#002 - Criar Sistema de Validação Avançada de Dados Nutricionais](#002)
3. [#003 - Implementar Histórico e Analytics de Cálculos](#003)

### Issues de Complexidade MÉDIA
4. [#004 - Refatorar Nomenclatura de Classes para Padrão Consistente](#004)
5. [#005 - Implementar InfoCard Dinâmico com Show/Hide](#005)
6. [#006 - Adicionar Validações de Ranges de Peso por Espécie](#006)
7. [#007 - Melhorar Tratamento de Erros no Controller](#007)

### Issues de Complexidade BAIXA
8. [#008 - Corrigir Inconsistência de Tema no Result Card](#008)
9. [#009 - Implementar Loading State no Cálculo](#009)
10. [#010 - Padronizar Formatação de Números](#010)

---

## Issues de Complexidade ALTA

### #001 - Implementar Serialização JSON e Persistência de Dados <a id="001"></a>

**Status:** 🔴 Pendente  
**Execução:** 3-4 horas  
**Risco:** Alto - Impacta estrutura de dados  
**Benefício:** Alto - Permite salvar/carregar cálculos

**Descrição Técnica:**
O modelo `NecessidadesCaloricas` não possui serialização JSON, impedindo persistência de dados e integração com APIs. O sistema não permite salvar histórico de cálculos ou exportar resultados.

**Problemas Identificados:**
- Falta de `toJson()` e `fromJson()` no modelo
- Nenhuma persistência local de dados
- Impossibilidade de export/import de resultados
- Falta de sincronização com backend

**Prompt de Implementação:**
```
Implemente serialização JSON completa para o modelo NecessidadesCaloricas:

1. Adicione métodos toJson() e fromJson()
2. Crie SharedPreferences para persistir últimos cálculos
3. Implemente funcionalidade de salvar/carregar resultados
4. Adicione validação de dados na deserialização
5. Crie testes unitários para serialização

Considere versionamento de dados para compatibilidade futura.
```

**Dependências:**
- `shared_preferences` package
- Atualização do modelo base
- Testes unitários

**Critérios de Validação:**
- [ ] Modelo serializa/deserializa corretamente
- [ ] Dados persistem entre sessões
- [ ] Validação de integridade de dados
- [ ] Testes de compatibilidade JSON

---

### #002 - Criar Sistema de Validação Avançada de Dados Nutricionais <a id="002"></a>

**Status:** 🔴 Pendente  
**Execução:** 4-5 horas  
**Risco:** Alto - Impacta segurança dos cálculos  
**Benefício:** Alto - Previne erros nutricionais perigosos

**Descrição Técnica:**
A validação atual é básica (apenas números positivos). Faltam validações específicas por espécie, alertas para valores extremos e verificações de consistência nutricional.

**Problemas Identificados:**
- Aceita pesos irreais (ex: 0.001kg ou 1000kg)
- Não valida combinações inconsistentes (ex: filhote + idoso)
- Falta alertas para valores extremos de calorias
- Sem validação de ranges por espécie

**Prompt de Implementação:**
```
Crie sistema de validação avançada para a calculadora:

1. Defina ranges realistas de peso por espécie (cão: 0.5-100kg, gato: 0.2-15kg)
2. Implemente alertas para valores calóricos extremos
3. Adicione validação de consistência entre parâmetros
4. Crie sistema de warnings não-bloqueantes
5. Implemente tooltips explicativos para cada validação

Use padrão de validação em camadas: básica → específica → consistência.
```

**Dependências:**
- Atualização do Utils
- Refatoração do controller
- Nova UI para alertas

**Critérios de Validação:**
- [ ] Ranges de peso validados por espécie
- [ ] Alertas para valores extremos
- [ ] Validação de consistência implementada
- [ ] UI responsiva para warnings

---

### #003 - Implementar Histórico e Analytics de Cálculos <a id="003"></a>

**Status:** 🔴 Pendente  
**Execução:** 5-6 horas  
**Risco:** Médio - Nova funcionalidade complexa  
**Benefício:** Alto - Valor agregado significativo

**Descrição Técnica:**
Não existe sistema de histórico de cálculos, impossibilitando acompanhamento evolutivo das necessidades calóricas do animal e análise de tendências.

**Problemas Identificados:**
- Nenhum armazenamento de cálculos anteriores
- Impossibilidade de comparar resultados ao longo do tempo
- Falta de gráficos ou visualizações
- Sem exportação de dados históricos

**Prompt de Implementação:**
```
Desenvolva sistema completo de histórico e analytics:

1. Crie estrutura de dados para histórico com timestamps
2. Implemente tela de visualização de histórico
3. Adicione gráficos de evolução calórica (fl_chart)
4. Crie funcionalidade de exportação (PDF/CSV)
5. Implemente filtros por período e animal
6. Adicione comparação entre cálculos

Inclua analytics básicas: média, tendência, outliers.
```

**Dependências:**
- `fl_chart` para gráficos
- `pdf` para exportação
- Database local (SQLite)
- Nova estrutura de navegação

**Critérios de Validação:**
- [ ] Histórico armazenado corretamente
- [ ] Gráficos funcionais e informativos
- [ ] Exportação em múltiplos formatos
- [ ] Filtros e busca operacionais

---

## Issues de Complexidade MÉDIA

### #004 - Refatorar Nomenclatura de Classes para Padrão Consistente <a id="004"></a>

**Status:** 🟡 Em Análise  
**Execução:** 2-3 horas  
**Risco:** Médio - Refatoração extensiva  
**Benefício:** Médio - Melhora manutenibilidade

**Descrição Técnica:**
A nomenclatura das classes não segue padrão consistente. `NecessidasCaloricas_Controller` usa underscore, enquanto outras classes usam CamelCase padrão.

**Problemas Identificados:**
- `NecessidasCaloricas_Controller` deveria ser `NecessidadesCaloricas_Controller`
- Inconsistência entre underscore e CamelCase
- Nome da classe principal difere do arquivo
- Falta de padronização em todo o módulo

**Prompt de Implementação:**
```
Refatore toda nomenclatura do módulo para padrão consistente:

1. Renomeie NecessidasCaloricas_Controller → NecessidadesCaloricas_Controller
2. Padronize todos os nomes para PascalCase
3. Atualize todas as importações e referências
4. Verifique consistência com outros módulos do projeto
5. Execute testes para garantir que nada quebrou

Siga convenções Flutter/Dart oficiais.
```

**Dependências:**
- Refatoração em cascata
- Atualização de imports
- Testes de regressão

**Critérios de Validação:**
- [ ] Nomenclatura consistente em todo módulo
- [ ] Imports atualizados corretamente
- [ ] Aplicação compila sem erros
- [ ] Padrão alinhado com resto do projeto

---

### #005 - Implementar InfoCard Dinâmico com Show/Hide <a id="005"></a>

**Status:** 🔴 Pendente  
**Execução:** 2 horas  
**Risco:** Baixo - Funcionalidade UI  
**Benefício:** Médio - Melhora UX

**Descrição Técnica:**
O `InfoCardWidget` existe mas não é usado. Há um `showInfoCard` no controller mas não está implementado na UI. O diálogo de informações está hardcoded na página principal.

**Problemas Identificados:**
- InfoCardWidget não utilizado
- showInfoCard sem funcionalidade
- Duplicação de informações (dialog + widget)
- Falta de persistência de preferência do usuário

**Prompt de Implementação:**
```
Implemente sistema dinâmico de InfoCard:

1. Integre InfoCardWidget na UI principal
2. Conecte toggle showInfoCard do controller
3. Adicione botão show/hide no card
4. Persista preferência do usuário (SharedPreferences)
5. Remova duplicação com dialog
6. Adicione animação suave de show/hide

Use AnimatedContainer para transições suaves.
```

**Dependências:**
- Refatoração da UI principal
- SharedPreferences para persistência
- Remoção de código duplicado

**Critérios de Validação:**
- [ ] InfoCard mostra/esconde dinamicamente
- [ ] Preferência persistida entre sessões
- [ ] Animações suaves implementadas
- [ ] Sem duplicação de informações

---

### #006 - Adicionar Validações de Ranges de Peso por Espécie <a id="006"></a>

**Status:** 🔴 Pendente  
**Execução:** 1-2 horas  
**Risco:** Baixo - Melhoria incremental  
**Benefício:** Médio - Previne erros comuns

**Descrição Técnica:**
A validação atual aceita qualquer peso positivo, mas cada espécie tem ranges realistas específicos. Isso pode gerar cálculos imprecisos para pesos extremos.

**Problemas Identificados:**
- Aceita peso de 0.001kg para qualquer espécie
- Permite pesos irreais como 500kg para gatos
- Falta de feedback específico por espécie
- Sem sugestões de ranges normais

**Prompt de Implementação:**
```
Implemente validação específica de peso por espécie:

1. Defina ranges realistas no Utils:
   - Cão: 0.5kg - 100kg
   - Gato: 0.2kg - 15kg
2. Atualize validatePeso para receber espécie
3. Adicione warnings para pesos atípicos (não bloqueantes)
4. Inclua tooltips com ranges normais
5. Teste com casos extremos

Mantenha validação básica como fallback.
```

**Dependências:**
- Atualização do Utils
- Modificação do controller
- Melhoria da UI de validação

**Critérios de Validação:**
- [ ] Ranges específicos por espécie funcionais
- [ ] Warnings para pesos atípicos
- [ ] Tooltips informativos
- [ ] Validação não quebra fluxo existente

---

### #007 - Melhorar Tratamento de Erros no Controller <a id="007"></a>

**Status:** 🔴 Pendente  
**Execução:** 1-2 horas  
**Risco:** Médio - Pode impactar estabilidade  
**Benefício:** Alto - Aumenta robustez

**Descrição Técnica:**
O método `calcular()` usa `double.parse()` que pode lançar exceções. Não há tratamento de erros para casos extremos como overflow matemático ou valores inválidos nos mapas de fatores.

**Problemas Identificados:**
- `double.parse()` sem try-catch
- Acesso direto a mapas sem verificação de chaves
- Sem tratamento para overflow matemático
- Falta de logs de erro

**Prompt de Implementação:**
```
Implemente tratamento robusto de erros:

1. Adicione try-catch em calcular()
2. Valide existência de chaves nos mapas de fatores
3. Trate overflow em cálculos matemáticos
4. Adicione logging de erros
5. Implemente fallbacks para valores inválidos
6. Crie testes para casos extremos

Use logger configurável para debug.
```

**Dependências:**
- Package de logging
- Testes unitários
- Documentação de casos de erro

**Critérios de Validação:**
- [ ] Try-catch implementado em pontos críticos
- [ ] Validação de chaves dos mapas
- [ ] Tratamento de overflow matemático
- [ ] Logs informativos de erro

---

## Issues de Complexidade BAIXA

### #008 - Corrigir Inconsistência de Tema no Result Card <a id="008"></a>

**Status:** 🟡 Em Análise  
**Execução:** 30 minutos  
**Risco:** Baixo - Mudança cosmética  
**Benefício:** Baixo - Consistência visual

**Descrição Técnica:**
O `ResultCardWidget` não utiliza o sistema de temas do app, usando cores hardcoded enquanto outros componentes seguem o `ShadcnStyle`.

**Problemas Identificados:**
- Não usa ShadcnStyle.textColor
- Cores hardcoded em vez de tema
- Inconsistência com outros widgets
- Não responde a mudanças de tema

**Prompt de Implementação:**
```
Atualize ResultCardWidget para usar sistema de temas:

1. Substitua cores hardcoded por ShadcnStyle
2. Implemente responsividade ao tema escuro/claro
3. Mantenha consistência com outros widgets
4. Teste mudança de tema em runtime

Use Consumer<ThemeManager> se necessário.
```

**Dependências:**
- Acesso ao ThemeManager
- Verificação de outros widgets

**Critérios de Validação:**
- [ ] Cores seguem ShadcnStyle
- [ ] Responde a mudanças de tema
- [ ] Consistente com outros widgets
- [ ] Teste de tema escuro/claro

---

### #009 - Implementar Loading State no Cálculo <a id="009"></a>

**Status:** 🔴 Pendente  
**Execução:** 45 minutos  
**Risco:** Baixo - Melhoria UX  
**Benefício:** Baixo - Feedback visual

**Descrição Técnica:**
O cálculo é instantâneo mas não há feedback visual. Para cálculos mais complexos no futuro ou com validações assíncronas, um loading state seria útil.

**Problemas Identificados:**
- Nenhum feedback durante cálculo
- Botão não fica desabilitado
- Usuário pode clicar múltiplas vezes
- Sem indicação de processamento

**Prompt de Implementação:**
```
Adicione loading state ao processo de cálculo:

1. Adicione propriedade isCalculating no controller
2. Desabilite botão durante cálculo
3. Mostre indicador de loading
4. Implemente debounce para múltiplos cliques
5. Adicione feedback visual no resultado

Use CircularProgressIndicator no botão.
```

**Dependências:**
- Atualização do controller
- Modificação do InputFormWidget

**Critérios de Validação:**
- [ ] Loading state funcional
- [ ] Botão desabilitado durante cálculo
- [ ] Indicador visual presente
- [ ] Debounce implementado

---

### #010 - Padronizar Formatação de Números <a id="010"></a>

**Status:** 🔴 Pendente  
**Execução:** 30 minutos  
**Risco:** Baixo - Melhoria cosmética  
**Benefício:** Baixo - Consistência de apresentação

**Descrição Técnica:**
A formatação de números não está padronizada. O resultado usa `toStringAsFixed(0)` mas não há formatação de milhares ou padrão para campos de entrada.

**Problemas Identificados:**
- Sem separador de milhares
- Inconsistência entre entrada e saída
- Falta de formatação por localização
- Números grandes pouco legíveis

**Prompt de Implementação:**
```
Padronize formatação de números em todo módulo:

1. Use NumberFormat para formatação consistente
2. Adicione separadores de milhares
3. Mantenha precisão adequada (0 casas para kcal)
4. Configure locale brasileiro
5. Aplique em todos os displays numéricos

Use intl package para formatação.
```

**Dependências:**
- `intl` package
- Configuração de locale

**Critérios de Validação:**
- [ ] Separadores de milhares presentes
- [ ] Formatação consistente
- [ ] Locale brasileiro configurado
- [ ] Números legíveis em todos os contextos

---

## Comandos Rápidos

### Análise de Código
```bash
# Análise estática
flutter analyze lib/app-petiveti/pages/calc/necessidade_calorias/

# Verificar imports não utilizados
dart run import_sorter:import_sorter --no-comments

# Formatação de código
dart format lib/app-petiveti/pages/calc/necessidade_calorias/ --set-exit-if-changed
```

### Testes
```bash
# Executar testes específicos do módulo
flutter test test/calc/necessidade_calorias/

# Testes com coverage
flutter test --coverage test/calc/necessidade_calorias/
genhtml coverage/lcov.info -o coverage/html

# Testes de performance
flutter test --reporter=json > test_results.json
```

### Build e Deploy
```bash
# Build de desenvolvimento
flutter build apk --debug --target=lib/app-petiveti/pages/calc/necessidade_calorias/index.dart

# Análise de bundle size
flutter build apk --analyze-size

# Profile build para performance
flutter build apk --profile
```

### Refatoração
```bash
# Buscar referências à classe
grep -r "NecessidasCaloricas_Controller" lib/

# Renomear arquivos em lote
find . -name "*necessidas*" -exec rename 's/necessidas/necessidades/' {} \;

# Verificar dependências não utilizadas
flutter pub deps --no-dev
```